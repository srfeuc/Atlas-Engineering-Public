---
Title: Pi01 Hardening Checklist (CIS-Informed)
Path: Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services
---

# Pi01 Hardening Checklist (CIS-Informed)

<!-- provenance -->
> **Lab-01 - Mikrotik-Core (FROZEN 2026-07-16)** - Host: PI01 - Role: Shared Services

## Document Control

| Item | Value |
|---|---|
| Owner | Atlas Engineering |
| Status | Draft — curated priority checklist, not exhaustive |
| Version | 1.0 |
| Applies To | Pi01 (Debian 13 "Trixie") |
| Reference | CIS Debian Linux 13 Benchmark v1.0.0 |

## OS Version — Now Confirmed

Pi01's base OS was an open question in the Build Record for this entire session ("Base OS: Unconfirmed"). Resolved without needing a fresh live check — two independent pieces of evidence already in hand this session both confirm **Debian 13 ("Trixie")**: the `dig` version banner seen in every DNS check tonight (`DiG 9.20.23-1~deb13u1-Debian`), and the `DietPi_RPi234-ARMv8-Trixie.img.xz` image found among the original build files, matching Debian 13's actual codename. Both point to the same answer — this benchmark version is the correct match, confirmed, not assumed.

## How to Use This Checklist

Each item lists: the CIS category and recommendation area, and — where already known from tonight's extensive live work on this host — whether Atlas's state already satisfies it. Cited by category and title only, in Atlas's own words, not reproduced from the benchmark text.

---

## 1. Initial Setup

### 1.1 Filesystem
- [ ] **Separate partitions for `/tmp`, `/var`, `/home`** — **Unverified.** Given tonight's repeated use of `/tmp` for certificate/key staging, worth checking whether `/tmp` has `noexec`/`nosuid` mount options — a real, relevant hardening item given how this host is actually used.

### 1.4 Bootloader
- [ ] **Bootloader password set** — **Unverified**, low priority for a headless device with physical access already controlled.

### 1.5 Process Hardening / Additional Hardening
- [x] **Persistent logging enabled** — done this session (`/var/log/journal` created, `systemd-journald` restarted), directly motivated by the earlier incident where a hang left no diagnostic history. See `038-Pi01-Troubleshooting-Guide.md`.

### 1.6 Command Line Warning Banners
- [ ] **Login/SSH banner present** — device-verified 2026-07-16: **absent** (`sshd -T` → `banner none`). `030` §4 specifies a `/etc/issue.net` banner and its build checklist leaves this box unticked; the live host confirms it was never applied. Low priority — add the banner to close it.

---

## 2. Services

### 2.1 Server Services
- [x] **Unused services not enabled** — largely confirmed by design: this host runs exactly Pi-hole, FreeRADIUS, Vaultwarden, nginx, and the Lab CA — no unrelated services accumulated.

### 2.3 Time Synchronization
- [x] **Time synchronization configured** — device-verified 2026-07-16 (`timedatectl`): `System clock synchronized: yes`, `NTP service: active` via **`systemd-timesyncd`**, contacting `0.debian.pool.ntp.org`. 🔴 **Corrected:** an earlier version credited `chrony` synced to `time.cloudflare.com` — neither is real on this host (`chrony` is **inactive**); that tick was written from memory, not a check. 🔴 This is an SNTP **client** only — **Pi01 serves no NTP.** SW01 is pointed at `10.10.0.5` as an NTP server and receives nothing (`CM-0030`); there is still no NTP *server* anywhere in Atlas.

---

## 3. Network

### 3.3 Network Kernel Parameters
- [ ] **IP forwarding, source routing, ICMP redirects disabled where not needed** — **Unverified.** Genuinely relevant given this host does real routing-adjacent work (DNS forwarding) — worth confirming the kernel-level settings match intent.

---

## 4. Host Based Firewall

### 4.1 UFW
- [x] **UFW enabled with explicit, scoped rules** — done this session. Previously **completely inactive with zero rules** — every port unfiltered until tonight. Full rule set built and reviewed before enabling, tested with a fresh connection before trusting it. See the Firewall section in `029-Pi01-Build-Record.md`.

---

## 5. Access Control

### 5.1 SSH Server
- [x] **Key-based authentication, password auth disabled, non-default port** — matches the documented base build (`030-Pi01-Base-System-Build-Guide.md`): key-only, port 2222.
- [ ] **`MaxAuthTries`, `LoginGraceTime` tuned** — confirmed set per the base build guide's sshd_config table; not re-verified live this session specifically.

### 5.4 User Accounts
- [x] **`dnsadmin` in required service groups** (`sudo`, `pihole`, `docker`) — device-verified 2026-07-16 (`id dnsadmin`). 🔴 **Corrected:** an earlier version listed `freerad` here; `dnsadmin` is **not** in `freerad` on the live host — `033` §2's optional "add to `freerad` to read config without `sudo`" step was never applied, and RADIUS works without it. (The account also holds DietPi's default hardware groups — `adm`, `dialout`, `audio`, `video`, `gpio`, etc. — distribution defaults, not deliberate grants.)
- [ ] **Password aging/complexity policy** — **Unverified** for the `dnsadmin` account itself.

---

## 6. Logging and Auditing
- [x] **Persistent journal** — done this session, see above.
- [ ] **`auditd` or equivalent for security event auditing** — **Not yet configured.** A real gap; worth considering once Book 5 (Monitoring) exists to actually consume this data.

## 7. System Maintenance
- [ ] **Regular patching cadence confirmed** — **Unverified**, no documented patch schedule for this host currently.

---

## Real Priorities, Ranked

1. **`/tmp` mount hardening** — directly relevant given tonight's own workflow relied on `/tmp` for sensitive file staging repeatedly.
2. **Kernel network parameter review** — this host does real DNS/routing-adjacent work, worth confirming it's not more permissive than needed.
3. **`auditd`**, once there's somewhere for the data to go (Book 5).
4. **Confirm SSH banner and password aging policy.**

## Related Pages

- `Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Build-Record.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Troubleshooting.md`
- `Labs/Lab-01-Mikrotik-Core/Devices/PI01-Services/Build-Guide-Base.md`
