# CM-0008 — Reissue MikroTik Certificate with Correct SAN, Fix Stale DNS Record

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: MKT01 - Role: Core Router

| Item | Value |
|---|---|
| Status | Closed |
| Risk | Low — admin GUI certificate and a local DNS record, no traffic-path impact |
| Affected systems | MKT01, Pi01 |

## Purpose

The certificate installed via CM-0007 is valid and correctly chained, but its Subject Alternative Name lists `10.0.0.1` and `172.31.4.144` — both stale, pre-VLAN-migration addresses — and does not include the current real management IP `10.10.0.1`. Browsers correctly reject it with a name-mismatch warning as a result. Separately, Pi-hole's `mikrotik.lab` DNS record also still points at the old `10.0.0.1`. Both are fixed together since they're the same underlying staleness.

## Reason

Found during CM-0007 validation: browser test against `https://10.10.0.1` returned a certificate name-mismatch error. Investigation confirmed the SAN never got updated after the VLAN migration, and `dig mikrotik.lab @10.10.0.5` confirmed the DNS record has the same problem.

## Prerequisites

- Root CA already trusted on the admin workstation (confirmed working, from the FGT01 work).
- MikroTik's WinBox access as the fallback path if HTTPS GUI access is needed mid-change (HTTP is disabled, WinBox is the only currently working management path per the live service list).

## Backup

```
/certificate print detail
```
Save output — current three-object chain (`mikrotik-bundle.crt_0/1/2`) before replacement.

On Pi01:
```bash
cat /etc/pihole/custom.list
```
Save current content before editing.

## Implementation

### Part 1 — Reissue the certificate (Pi01)

```bash
ssh pihole
cd /etc/ssl/lab-ca/intermediate
sudo openssl req -config openssl.cnf -key /etc/ssl/lab-ca/issued/mikrotik/mikrotik.key \
  -new -sha256 -out csr/mikrotik.csr \
  -addext "subjectAltName=DNS:mikrotik.lab,IP:10.10.0.1"
```
(If the existing key can't be reused with a new CSR cleanly, generate a fresh key first, same as the original Part A process in `035-Lab-CA-Certificate-Issuance-and-Trust-Runbook.md`.)

```bash
sudo openssl ca -config openssl.cnf -extensions server_cert \
  -days 365 -notext -md sha256 \
  -in csr/mikrotik.csr \
  -out /etc/ssl/lab-ca/issued/mikrotik/mikrotik.crt
```

Rebuild the bundle:
```bash
cat /etc/ssl/lab-ca/issued/mikrotik/mikrotik.crt /etc/ssl/lab-ca/intermediate/certs/ca-chain.crt \
  | sudo tee /etc/ssl/lab-ca/issued/mikrotik/mikrotik-bundle.crt
```

Stage for retrieval:
```bash
sudo cp /etc/ssl/lab-ca/issued/mikrotik/mikrotik-bundle.crt /etc/ssl/lab-ca/issued/mikrotik/mikrotik.key /tmp/
sudo chown dnsadmin:dnsadmin /tmp/mikrotik-bundle.crt /tmp/mikrotik.key
```

### Part 2 — Install on MikroTik

1. From Windows (WinBox running **as Administrator**, per the working method from CM-0007): `scp pihole:/tmp/mikrotik-bundle.crt .` and `scp pihole:/tmp/mikrotik.key .`, saved to a local non-repo folder (e.g. `C:\Temp`).
2. Drag both into WinBox Files.
3. Remove the old certificate objects first to avoid confusion between old and new:
   ```
   /certificate remove [find name~"mikrotik-bundle"]
   ```
4. Import the new bundle:
   ```
   /certificate import file-name=mikrotik-bundle.crt
   /certificate import file-name=mikrotik.key
   ```
5. Note the new object name RouterOS assigns (check via `/certificate print detail` — will likely again be `mikrotik-bundle.crt_0`, but confirm rather than assume).
6. Bind it:
   ```
   /ip service set www-ssl certificate=<new-object-name>
   ```
7. Delete the source files from MikroTik's File List and from the local Windows folder once import is confirmed working.

### Part 3 — Fix the DNS record (Pi01)

```bash
sudo nano /etc/pihole/custom.list
```
Change:
```
10.0.0.1 mikrotik.lab
```
to:
```
10.10.0.1 mikrotik.lab
```
```bash
sudo systemctl restart pihole-FTL
```

## Validation

```bash
dig mikrotik.lab @10.10.0.5
```
Confirm it now returns `10.10.0.1`.

```bash
openssl s_client -connect 10.10.0.1:443 -showcerts 2>/dev/null | openssl x509 -noout -text | grep -A1 "Subject Alternative Name"
```
Confirm the SAN now includes `10.10.0.1`.

Browser test at `https://10.10.0.1` — should load without a name-mismatch warning. (Note: browsing to `https://mikrotik.lab` still won't work until the broader DNS-pointed-at-Pi-hole deviation is resolved in Book 3 — this record only fixes the IP-based access path and the DNS record's own correctness, not the network-wide DNS routing gap.)

## Rollback

Re-bind to the previous certificate object if it still exists and wasn't deleted:
```
/ip service set www-ssl certificate=mikrotik-bundle.crt_0
```
Revert `/etc/pihole/custom.list` from the saved backup if needed.

## Documentation updates

- [x] MKT01 Build Record (`022-MKT01-Build-Record.md`) — certificate SAN details updated
- [x] **Pi01 DNS records — done, 2026-07-13, larger scope than originally planned.** `custom.list` was edited first and confirmed correct in the file, but the live query still returned the stale address. Root cause: this Pi-hole v6 install actually reads local DNS entries from an embedded `hosts` array inside `/etc/pihole/pihole.toml`, not from `custom.list` — the file edit alone did nothing. On inspecting `pihole.toml` directly, found **all three local records stale, not just MikroTik's**: `pihole.lab` pointed at its own old pre-VLAN address (`10.0.0.5` instead of `10.10.0.5`), and `proxmox.lab` pointed at `10.0.0.254` — not PVE01's real address (`10.10.0.10`) at all, likely a leftover from whatever briefly held that address on the old flat network. Corrected all three directly in `pihole.toml` (TOML array syntax, quotes and trailing comma required), then `sudo systemctl restart pihole-FTL`. Confirmed via `dig` against all three: `pihole.lab` → `10.10.0.5`, `mikrotik.lab` → `10.10.0.1`, `proxmox.lab` → `10.10.0.10`.
- [x] `041-MKT01-Troubleshooting-Guide.md` — written, covers this incident
- [ ] Revision History

## Closeout

- [x] Implemented (certificate side, and DNS side)
- [x] Validated (certificate side, and DNS side)
- [x] Documentation updated
- [x] Closed
