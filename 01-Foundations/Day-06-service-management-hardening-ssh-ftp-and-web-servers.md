# 🛡️ Service Management: Hardening SSH, FTP, and Web Servers
**A Master-Level Technical Handbook for Cybersecurity Architects**

---

## 🔬 Technical Deep Dive & Theory
In the modern enterprise, "Services" are the primary vectors of ingress. Hardening is not merely changing settings; it is the strategic reduction of the **Attack Surface Area**. 

*   **The Management Plane (SSH):** Operates at Layer 7 but controls the entire OS. Theory dictates that we must move from *Knowledge-based Authentication* (Passwords) to *Possession-based Authentication* (Cryptographic Keys).
*   **The Data Plane (FTP):** Inherently insecure due to cleartext transmission. Architecture requires the enforcement of **TLS/SSL wrappers** or transitioning to SFTP (SSH-subsystem) to eliminate packet sniffing of credentials.
*   **The Public Plane (Web Servers):** These are exposed to the global internet. Hardening shifts from the OS level to **Header Security** and **Process Isolation**. The goal is to prevent a web-based exploit (like LFI/RFI) from escalating to a full system compromise via *Lateral Movement*.

---

## 💻 Universal Implementation (The 'How-To')

### 🔵 Debian/Ubuntu/Kali | 🔴 RHEL/Fedora | ⚪ Arch Linux

#### 1. SSH Hardening (`/etc/ssh/sshd_config`)
**Action:** Disable root login, enforce Protocol 2, and switch to Key-based auth.
```bash
# Edit Config
sudo nano /etc/ssh/sshd_config

# Apply these settings:
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
Port 2222 # Security through obscurity (Layer 1 defense)

# Restart Service
# 🔵/🔴/⚪ Universal Systemd:
sudo systemctl restart sshd
```

#### 2. FTP Hardening (`/etc/vsftpd.conf`)
**Action:** Disable Anonymous access and force TLS.
```bash
# Edit Config
sudo nano /etc/vsftpd.conf

# Apply these settings:
anonymous_enable=NO
local_enable=YES
write_enable=YES
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES

# 🔵/🔴/⚪ Restart Service:
sudo systemctl restart vsftpd
```

#### 3. Web Server (Nginx) Hardening (`/etc/nginx/nginx.conf`)
**Action:** Hide versioning and implement Security Headers.
```nginx
# Inside the http {} block:
server_tokens off; # Disables version display
add_header X-Frame-Options "SAMEORIGIN";
add_header X-Content-Type-Options "nosniff";
add_header Content-Security-Policy "default-src 'self';";

# 🔵/🔴/⚪ Restart Service:
sudo systemctl restart nginx
```

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth
**Root Cause of Service Breaches:** Most service-level compromises stem from **Insecure Defaults** and **Credential Stuffing**. 

### Remediation Checklist:
1.  [ ] **Identity:** Is MFA enforced for SSH?
2.  [ ] **Network:** Is the service restricted by an IP Whitelist (UFW/Firewalld)?
3.  [ ] **Compute:** Is the service running as a non-privileged `service_user`?
4.  [ ] **Logging:** Are logs being shipped to a SIEM for anomaly detection?

---

## 🔍 Threat Actor Profiling & MITRE Mapping

| Threat Actor Group | Typical Motivation | MITRE ATT&CK Technique |
| :--- | :--- | :--- |
| **APT28 (Fancy Bear)** | Espionage / State-sponsored | **T1078** (Valid Accounts - SSH Keys) |
| **Fin7** | Financial Gain | **T1190** (Exploit Public-Facing Application) |
| **Script Kiddies** | Chaos / Defacement | **T1110** (Brute Force) |

*   **T1021.004:** Remote Services: SSH
*   **T1548.001:** Abuse Elevation Control Mechanism (Sudo)

---

## 🎮 Gamified Labs & Simulation Training
To master these concepts, complete the following modules:
*   **TryHackMe:** *SSH Hidden Gems* & *Hardening Linux* (Difficulty: Medium)
*   **HackTheBox (HTB) Academy:** *Linux Server Hardening* (Difficulty: Advanced)
*   **OverTheWire:** *Bandit* (Focus on Levels 10-20 for SSH/Service basics)

---

## 📊 GRC & Compliance Mapping
*   **NIST CSF (PR.AC-4):** Access control and least privilege enforcement.
*   **ISO 27001 (A.12.1.2):** Change management and service hardening.
*   **PCI-DSS (Requirement 2.2):** Develop configuration standards for all system components.
*   **Business Impact:** Proper hardening reduces the "Blast Radius" of a breach, potentially saving a mid-sized firm $4.45M (average cost of a data breach per IBM).

---

## 🧪 Verification & Validation (The Proof)
Validate your hardening with these professional-grade commands:

```bash
# 1. Audit SSH Configuration (Check for active settings)
sshd -T | grep -E "permitrootlogin|passwordauthentication"

# 2. Test Web Header Security
curl -I http://localhost

# 3. Check for open insecure ports (Nmap)
nmap -sV -p- localhost

# 4. Verify Fail2Ban is actively jailing IPs
fail2ban-client status sshd
```

---

## 🛠️ Lab Report: What We Mastered
> **Executive Summary:** Executed a comprehensive hardening audit of critical system services, focusing on SSH and Web Server security. Implemented key-based authentication, disabled root login, and configured custom ports to reduce automated brute-force visibility. Analyzed `sshd_config` and `nginx.conf` for insecure defaults, applying the 'Principle of Least Privilege' to service accounts and implementing `fail2ban` for automated IP blocking on my Arch Linux environment.

**Tools Used:** `OpenSSH`, `Nginx`, `vsftpd`, `Fail2Ban`, `Nmap`, `OpenSSL`, `Systemd`.

---

## 🚨 Real-World Breach Case Study: The VSftpd Backdoor
**CVE-2011-2523:** In a classic supply-chain attack, the source code for `vsftpd 2.3.4` was compromised. Attackers added a "smiley face" `:)` backdoor. When a user logged in with a username ending in `:)`, the server opened a shell on port 6200.
**Lesson Learned:** Hardening isn't just about config; it's about **Integrity Monitoring** and ensuring you are running verified, checksum-validated binaries.

---

## 💡 Senior Researcher Insights & Future Trends
1.  **Pro-Tip: Use SSH Certificates, Not Keys.** At scale, managing `authorized_keys` is a nightmare. Move to an SSH Certificate Authority (SSH CA) like HashiCorp Vault.
2.  **Pro-Tip: Socket Activation.** Use Systemd socket activation to keep services offline until a connection is requested, hiding the service from idle scanners.
3.  **Pro-Tip: Geofencing.** If your business only operates in the UK, block all SSH ingress from other regions at the firewall level.
4.  **Future Trend: Post-Quantum Cryptography (PQC).** Watch for **NIST SP 800-213**. We are moving toward "Quantum-Resistant" SSH key exchange algorithms (e.g., ML-KEM).

---

## 🎁 Free Web Resources & Official Documentation
*   **Mozilla Observatory:** [Analyze your Web Server Headers](https://observatory.mozilla.org/)
*   **SSH Audit:** [SSH Configuration Scanner (GitHub)](https://github.com/jtesta/ssh-audit)
*   **CIS Benchmarks:** [The Gold Standard for Hardening](https://www.cisecurity.org/benchmark/linux)
*   **Nginx Docs:** [Official Security Guide](https://www.nginx.com/resources/wiki/start/topics/tutorials/config_pitfalls/)
