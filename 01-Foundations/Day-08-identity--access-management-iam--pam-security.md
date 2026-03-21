# 📑 Master-Level Handbook: IAM & PAM Security Architectures
**Author:** Senior Cybersecurity Architect & Mentor
**Focus:** Linux Identity, Privileged Access, and Local Persistence Defense

---

## 🔬 Technical Deep Dive & Theory
In the Linux ecosystem, **Identity & Access Management (IAM)** is the gatekeeper, while **Privileged Access Management (PAM)** is the vault guardian. 

The core logic rests on **Pluggable Authentication Modules (PAM)**. PAM allows system administrators to choose how applications authenticate users without rewriting the applications themselves. It works via a stack of four management groups:
1.  **auth:** Verifies the user's identity (Passwords, Biometrics).
2.  **account:** Checks if the account is valid (Password expiry, time-of-day access).
3.  **password:** Handles password updates and complexity requirements.
4.  **session:** Configures the environment before/after the user logs in (Mounting directories, logging).

**Privileged Access** focuses on the transition from `uid 1000` (Standard User) to `uid 0` (Root). This is governed by the `sudoers` policy and the handling of **SUID (Set User ID)** bits, which allow a program to run with the permissions of the file owner (usually root).

---

## 💻 Universal Implementation (The 'How-To')
Hardening the authentication stack across the major distributions.

### 🔵 Debian/Ubuntu/Kali
**Goal:** Implement Account Locking after failed attempts and enforce password complexity.
```bash
# Install the necessary library
sudo apt update && sudo apt install libpam-pwquality -y

# Configure account lockout (faillock)
# Path: /etc/pam.d/common-auth
# Add: auth required pam_faillock.so preauth silent deny=5 unlock_time=900
```

### 🔴 RHEL/Fedora
**Goal:** Configure centralized sudo logging and secure the `pwquality` module.
```bash
# RHEL uses authselect for profile management
sudo authselect select sssd with-faillock --force

# Path: /etc/security/pwquality.conf
# Edit: minlen = 14, dcredit = -1, ucredit = -1
```

### ⚪ Arch Linux
**Goal:** Manual configuration of the PAM stack and sudoers isolation.
```bash
# Install pam_pwquality if not present
sudo pacman -S libpwquality

# Edit Sudoers safely (Never edit /etc/sudoers directly!)
sudo visudo /etc/sudoers.d/audit-log
# Add: Defaults logfile="/var/log/sudo.log"
```

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth
### Root Cause of PAM/IAM Failure:
1.  **Excessive SUID Permissions:** Binaries like `nmap`, `vim`, or `find` having the SUID bit set, allowing execution of shell commands as root.
2.  **Insecure Pathing:** Adding world-writable directories to the `$PATH` variable, enabling **Path Hijacking**.
3.  **Orphaned Accounts:** Local accounts created for vendors/testing that are never decommissioned.

### Remediation Checklist:
- [ ] **Audit Sudoers:** Ensure `NOPASSWD` is strictly prohibited for non-automation accounts.
- [ ] **Enforce MFA:** Use `google-authenticator` PAM module for SSH.
- [ ] **Immutable Logs:** Ship `/var/log/auth.log` or `/var/log/secure` to a remote SIEM immediately.
- [ ] **SUID Sweep:** Regularly run `find / -perm -4000 -type f 2>/dev/null` to find new SUID binaries.

---

## 🔍 Threat Actor Profiling & MITRE Mapping
| Threat Actor Type | Motivation | MITRE ATT&CK Technique |
| :--- | :--- | :--- |
| **Script Kiddie** | Notoriety | **T1078.003:** Local Accounts (Default creds) |
| **Ransomware Op** | Financial | **T1548.001:** Abuse Elevation Control (SUID) |
| **APT / State Actor** | Espionage | **T1098:** Account Manipulation (Backdoor PAM) |
| **Insider Threat** | Revenge/Theft | **T1543.003:** Create or Modify System Process (Cron) |

---

## 🎮 Gamified Labs & Simulation Training
*   **TryHackMe:** [Linux PrivEsc](https://tryhackme.com/room/linuxprivesc) (Difficulty: Intermediate) - *Focus on SUID and Cron.*
*   **HackTheBox:** [Academy: Linux Privilege Escalation](https://academy.hackthebox.com/) (Difficulty: Advanced) - *Deep dive into Kernel exploits and PAM.*
*   **OverTheWire:** [Bandit](https://overthewire.org/wargames/bandit/) (Difficulty: Easy/Intermediate) - *Fundamentals of Linux permissions.*

---

## 📊 GRC & Compliance Mapping
*   **NIST SP 800-53 (AC-2/AC-3):** Mandates account management and access enforcement.
*   **ISO 27001 (A.9):** Requires a formal user registration and access de-provisioning process.
*   **PCI-DSS (Requirement 7):** Restricts access to system components and cardholder data to only those individuals whose job requires such access.
*   **Business Impact:** Proper IAM prevents **Lateral Movement**, which is the difference between a single compromised workstation and a company-wide data breach.

---

## 🧪 Verification & Validation (The Proof)
Validate your hardening with these "Audit Commands":
```bash
# 1. Check for 'No Password' Sudo entries
grep -r "NOPASSWD" /etc/sudoers /etc/sudoers.d/

# 2. Verify account lockout status for a user
faillock --user <username>

# 3. Test Password Quality settings (Manual check)
passwd --status <username>
```

---

## 🛠️ Lab Report: What We Mastered
> **Executive Summary of Operations:**
> Spent the day hunting for 'cracks' in the system to hit Root. Ran a deep audit to find those sneaky SUID binaries and misconfigured Cron Jobs that basically leave the keys in the ignition. Mastered **'LinPeas'** for the heavy lifting and actually pulled off a manual SUID exploit via path hijacking. Feels good to go from a nobody to 'Root'.
>
> **Tools Utilized:**
> *   **LinPeas:** Automated enumeration script for PE vectors.
> *   **GTFOBins:** Database for bypassing local security restrictions.
> *   **Pspy:** Unprivileged crontab/process monitoring.
> *   **Strace:** Analyzing system calls to find library hijack opportunities.

---

## 🚨 Real-World Breach Case Study: Baron Samedit (CVE-2021-3156)
In 2021, a massive vulnerability was found in `sudo`. By exploiting a heap-based buffer overflow, any unprivileged user could gain root access without a password, even if they weren't in the sudoers file.
*   **The Lesson:** Even "trusted" IAM tools have vulnerabilities. **Defense-in-Depth** (e.g., using SELinux or AppArmor) is required to restrict what a "Root" user can actually do once they escalate.

---

## 💡 Senior Researcher Insights & Future Trends
1.  **Pro-Tip: SSH Keys > Passwords.** Disable password authentication entirely in `sshd_config` and use ED25519 keys with passphrases.
2.  **Pro-Tip: Use `sudoedit`.** Instead of letting users run `sudo vi /etc/file`, use `sudoedit`. This prevents users from escaping the editor to a root shell.
3.  **Pro-Tip: Auditd is your best friend.** Configure `auditd` to track every execution of `execve` to see exactly what commands are being run under sudo.
4.  **Future Trend: Zero Trust Architecture (ZTA) for Linux.** Moving away from static permissions toward **Just-In-Time (JIT)** access where root privileges are granted for 15 minutes via a ticketed request system.

---

## 🎁 Free Web Resources & Official Documentation
*   **GTFOBins:** [https://gtfobins.github.io/](https://gtfobins.github.io/) (Essential for SUID exploitation/defense)
*   **PAM Documentation:** [Linux-PAM Guides](http://www.linux-pam.org/Linux-PAM-html/)
*   **NIST Digital Identity Guidelines:** [NIST 800-63](https://pages.nist.gov/800-63-3/)
*   **MITRE ATT&CK Matrix:** [Linux Matrix](https://attack.mitre.org/matrices/enterprise/linux/)
