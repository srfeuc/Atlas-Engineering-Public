#!/usr/bin/env bash
# Pi01 read-only reconciliation battery (029/030/031/032/033/034/035/038/042/046).
# READ-ONLY. Prints NO private key and NO RADIUS secret.
# Run as dnsadmin, NOT with sudo in front:
#     bash pi01-recon.sh 2>&1 | tee ~/pi01-recon-$(date +%F).txt
# Then paste the whole file (or the terminal) back — the END marker tells us it's complete.

sudo -v   # prompt for the sudo password ONCE, up front, so the run doesn't stall later

sec() { printf '\n\n========== %s ==========\n' "$1"; }
cmd() { printf '\n$ %s\n' "$1"; eval "$1"; }

echo "===== PI01 RECON BEGIN $(date) ====="

sec "A - BASE SYSTEM + HEALTH (030/038/046)"
cmd 'hostnamectl'
cmd 'ip -4 -br a'
cmd 'ip route'
cmd 'id dnsadmin'
cmd "sudo sshd -T 2>/dev/null | grep -Ei '^(port|permitrootlogin|passwordauthentication|maxauthtries|logingracetime|maxsessions|banner) '"
cmd 'sudo ufw status verbose'
cmd 'ls -ld /var/log/journal'
cmd 'df -h /'
cmd 'vcgencmd get_throttled'
cmd 'systemctl is-active chrony'
cmd "chronyc tracking 2>/dev/null | grep -E 'Reference ID|Leap status'"

sec "B - LAB CA / PKI (031/035/042 + CM-0032)  [HIGHEST VALUE]"
cmd 'sudo ls -la /etc/ssl/lab-ca/root/private/ /etc/ssl/lab-ca/intermediate/private/'
cmd "sudo sed -n '1,12p' /etc/ssl/lab-ca/intermediate/openssl.cnf"
cmd 'sudo cat /etc/ssl/lab-ca/intermediate/index.txt'
cmd 'sudo ls -la /etc/ssl/lab-ca/issued/pihole/ /etc/ssl/lab-ca/issued/fortigate/ /etc/ssl/lab-ca/issued/mikrotik/ /etc/ssl/lab-ca/issued/vaultwarden/'
cmd 'openssl s_client -connect 10.10.0.5:443 </dev/null 2>/dev/null | openssl x509 -noout -issuer -serial -dates'
cmd 'openssl s_client -connect 10.10.0.5:443 </dev/null 2>/dev/null | openssl x509 -noout -ext subjectAltName'
cmd 'openssl s_client -connect 10.10.0.5:443 -showcerts </dev/null 2>/dev/null | grep -c "BEGIN CERTIFICATE"'
cmd 'sudo openssl x509 -in /etc/ssl/lab-ca/issued/pihole/pihole.crt -noout -serial -ext subjectAltName'
cmd 'sudo grep -c "BEGIN CERTIFICATE" /etc/pihole/tls.pem'
cmd 'sudo grep -c "BEGIN.*PRIVATE KEY" /etc/pihole/tls.pem'
cmd 'sudo openssl x509 -in /etc/pihole/tls.pem -noout -serial -dates'
cmd 'sudo openssl x509 -in /etc/ssl/lab-ca/issued/fortigate/fortigate.crt -noout -serial -subject'

sec "B9 - WIRE serial vs DATABASE per device (ADR-0009 control)"
for d in 10.10.0.5 10.10.0.1 10.10.0.254; do
  s=$(openssl s_client -connect "$d":443 </dev/null 2>/dev/null | openssl x509 -noout -serial | cut -d= -f2)
  printf '\n=== %s  serial=%s\n' "$d" "$s"
  sudo openssl ca -config /etc/ssl/lab-ca/intermediate/openssl.cnf -status "$s" 2>&1 | tail -1
done

sec "C - PI-HOLE DNS (032)"
cmd 'pihole -v'
cmd 'pihole status'
cmd 'systemctl is-enabled pihole-FTL dnscrypt-proxy-doh'
cmd 'systemctl is-active  pihole-FTL dnscrypt-proxy-doh'
cmd 'systemctl is-enabled dnscrypt-proxy.socket'
cmd "sudo ss -tulnp | grep -E ':53 |:5053 |:80 |:443 '"
cmd "dig +dnssec sigok.verteiltesysteme.net @10.10.0.5 | grep -E 'flags:|status:'"
cmd "dig sigfail.verteiltesysteme.net @10.10.0.5 | grep -E 'status:'"
sec "C - local DNS records (fortigate.lab expected EMPTY)"
for h in pihole.lab pi.hole vault.lab mikrotik.lab proxmox.lab fortigate.lab; do
  printf '%-15s -> ' "$h"; dig +short "$h" @10.10.0.5
done
cmd "sudo grep -nE 'pihole.lab|vault.lab|mikrotik.lab|proxmox.lab|fortigate.lab' /etc/pihole/pihole.toml"

sec "D - FREERADIUS (033)  [no secrets printed]"
cmd 'freeradius -v 2>&1 | head -1'
cmd 'systemctl is-active  freeradius'
cmd 'systemctl is-enabled freeradius'
cmd "sudo ss -tulnp | grep 1812"
cmd "sudo grep -E '^[[:space:]]*client |ipaddr|ipv6addr|require_message_authenticator' /etc/freeradius/3.0/clients.conf"
cmd "sudo grep -nE '^[[:space:]]*key = ' /etc/freeradius/3.0/mods-available/files"
cmd "sudo grep -cE '^radtest-verify' /etc/freeradius/3.0/users"
cmd "sudo grep -cE '^testing' /etc/freeradius/3.0/users"
echo "  NOTE: radtest is manual - run it yourself with the Vaultwarden secret, paste ONLY Access-Accept/Reject."

sec "E - VAULTWARDEN (034) + LINK-LAYER INTERFACES"
cmd "docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'"
cmd "docker logs vaultwarden 2>&1 | grep -iE 'version|starting' | head -3"
cmd "sudo ss -tulnp | grep -E ':8443 |:8222 '"
cmd 'ip -br link'
cmd 'sudo nginx -t'
cmd 'systemctl is-active nginx'
cmd 'openssl s_client -connect 10.10.0.5:8443 </dev/null 2>/dev/null | openssl x509 -noout -issuer -serial -ext subjectAltName'
cmd 'sudo openssl x509 -in /etc/ssl/lab-ca/issued/vaultwarden/vaultwarden.crt -noout -serial -ext subjectAltName'

echo
echo "===== PI01 RECON END $(date) ====="
