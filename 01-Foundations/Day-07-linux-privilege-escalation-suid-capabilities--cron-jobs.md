# 🛡️ Master-Level Handbook: Linux Privilege Escalation
**Focus Area:** SUID, Linux Capabilities, and Cron Jobs  
**Target Audience:** Security Engineers, Penetration Testers, and Systems Architects  
**Author:** Bhavishya

---

## 🔬 Technical Deep Dive & Theory

Privilege Escalation (PrivEsc) is the art of exploiting a misconfiguration, bug, or design flaw to gain a higher level of access (usually `root`) than intended.

### 1. SUID (Set User ID)
The SUID bit (represented by an `s` in the owner's execute field, e.g., `-rwsr-xr-x`) allows a user to execute a binary with the permissions of the file's owner. 
*   **The Logic:** When a binary like `/usr/bin/passwd` runs, it needs to write to `/etc/shadow`. Since a normal user can't do this, the SUID bit on `passwd` allows the process to assume the **Effective User ID (EUID)** of `root` temporarily.
*   **The Risk:** If a binary with SUID has a "feature" that allows command execution or file reading (e.g., `find`, `vim`, `bash`), a user can "break out" of the intended function and spawn a root shell.

### 2. Linux Capabilities
Capabilities decompose "Root Power" into distinct units. Instead of giving a binary full root access via SUID, we give it only what it needs.
*   **The Logic:** `CAP_SETUID` allows a process to change its UID. `CAP_DAC_OVERRIDE` allows it to bypass file read/write permissions.
*   **The Risk:** If an admin grants `CAP_SETUID` to a binary like `python`, an attacker can use a one-liner to set their UID to 0 and escalate.

### 3. Cron Jobs
Cron is a time-based job scheduler.
*   **The Logic:** System-wide crontabs (`/etc/crontab`) often run as `root`.
*   **The Risk:** If a root cron job executes a script that is **world-writable**, or uses a **relative path** (Path Hijacking), an attacker can modify the script or place a malicious binary in the path to intercept execution.

---

## 💻 Universal Implementation (The 'How-To')

### 🔵 Debian/Ubuntu/Kali | 🔴 RHEL/Fedora | ⚪ Arch Linux

Across all distributions, the discovery phase is identical, but the exploitation might vary based on available shells and installed packages.

#### Finding SUID Binaries
```bash
# Universal command to find SUID files, redirecting errors to /dev/null
find / -perm -u=s -type f 2>/dev/null
```

#### Finding Capabilities
```bash
# Check for binaries with dangerous capabilities
getcap -r / 2>/dev/null
```

#### Finding Vulnerable Cron Jobs
```bash
# Inspect system-wide cron jobs
cat /etc/crontab

# Arch Linux specific: Also check systemd timers (Modern Cron alternative)
systemctl list-timers --all
```

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth

### Root Cause Analysis
1.  **Over-privileged Binaries:** Developers use SUID as a "quick fix" for permission issues.
2.  **Weak File Permissions:** Automated scripts (Cron) created with `777` permissions.
3.  **Environment Pollution:** Cron jobs relying on a default `$PATH` that includes user-writable directories.

### 📋 Remediation Checklist
- [ ] **Audit SUID:** Remove SUID bits from binaries that don't strictly require them (`chmod u-s [file]`).
- [ ] **Principle of Least Privilege:** Replace SUID with specific Linux Capabilities where possible.
- [ ] **Secure Cron:** Ensure all scripts called by Cron are owned by root and NOT world-writable.
- [ ] **Absolute Paths:** Always use absolute paths (e.g., `/usr/bin/tar` instead of `tar`) in scripts.
- [ ] **No-SUID Mount:** Mount user-writable partitions (`/home`, `/tmp`) with the `nosuid` option.

---

## 🔍 Threat Actor Profiling & MITRE Mapping

| Technique | MITRE ID | Description | Threat Actor Example |
| :--- | :--- | :--- | :--- |
| **Abuse SUID/SGID** | [T1548.001](https://attack.mitre.org/techniques/T1548/001/) | Exploiting binaries with the SUID bit set to gain root. | **APT28 (Fancy Bear)** |
| **Scheduled Task/Job**| [T1053.003](https://attack.mitre.org/techniques/T1053/003/) | Modifying cron jobs to execute malicious code as root. | **Lazarus Group** |
| **Exploitation for PrivEsc** | [T1068](https://attack.mitre.org/techniques/T1068/) | Exploiting kernel vulnerabilities or misconfigured capabilities. | **FIN7** |

---

## 🎮 Gamified Labs & Simulation Training

*   **TryHackMe: [Linux PrivEsc](https://tryhackme.com/room/linuxprivesc)** (Difficulty: 🟠 Medium) - Excellent for SUID and Cron basics.
*   **HackTheBox Academy: [Linux Privilege Escalation](https://academy.hackthebox.com/module/details/51)** (Difficulty: 🔴 Hard) - Deep dive into capabilities.
*   **OverTheWire: [Bandit](https://overthewire.org/wargames/bandit/)** (Difficulty: 🟢 Easy-Medium) - Levels 19-25 focus heavily on SUID and permissions.

---

## 📊 GRC & Compliance Mapping

*   **NIST CSF (PR.AC-4):** Access control is managed according to the principle of least privilege.
*   **ISO 27001 (A.9.2.3):** Restriction and control of privileged access rights.
*   **PCI-DSS (Requirement 7.1.2):** Restrict access to privileged user IDs to least privileges necessary.
*   **Business Impact:** Failure to secure these vectors leads to **Lateral Movement** and **Full Domain Compromise**, resulting in regulatory fines (GDPR/CCPA) and irreparable brand damage.

---

## 🧪 Verification & Validation (The Proof)

To verify the success of your hardening, run these commands. If they return **no output**, your system is significantly more secure:
```bash
# 1. Verify no unauthorized SUID in /tmp or /home
find /home /tmp -perm -u=s -type f

# 2. Verify Cron scripts are not world-writable
ls -la /etc/cron.* | grep "rwx" # Look for 'w' in the 'other' column

# 3. Check for specific dangerous capabilities (Python/Perl)
getcap /usr/bin/python* /usr/bin/perl* 2>/dev/null
```

---

## 🛠️ Lab Report: What We Mastered

> **Field Notes:** Spent the day hunting for 'cracks' in the system to hit Root. Ran a deep audit to find those sneaky SUID binaries and misconfigured Cron Jobs that basically leave the keys in the ignition. Mastered 'LinPeas' for the heavy lifting and actually pulled off a manual SUID exploit via path hijacking. Feels good to go from a nobody to 'Root' on my Arch lab.

**Tools Used:**
*   **LinPeas:** Automated enumeration script.
*   **GTFOBins:** Database of binaries used for SUID/Capability bypasses.
*   **Pspy:** To monitor cron job execution in real-time without root access.
*   **strace:** To find which files an SUID binary looks for (useful for path hijacking).

---

## 🚨 Real-World Breach Case Study: CVE-2021-4034 (PwnKit)

In 2021, a vulnerability was found in `pkexec`, a SUID binary installed by default on almost every major Linux distro (Polkit). 
*   **The Hack:** By passing a specific set of environment variables to `pkexec`, attackers could trigger an out-of-bounds write, leading to instant root access.
*   **Lesson:** Even "trusted" system binaries with SUID bits are massive attack surfaces.

---

## 💡 Senior Researcher Insights & Future Trends

1.  **Pro-Tip: The 'Strings' Method.** If you find a custom SUID binary, run `strings [binary]` to look for system calls like `system()` or `exec()`. If it calls a command without a full path, it's vulnerable to Path Hijacking.
2.  **Pro-Tip: Capability Awareness.** Don't just look for SUID. Modern containers often strip SUID but forget to strip Capabilities. `CAP_DAC_READ_SEARCH` is enough to read `/etc/shadow`.
3.  **Pro-Tip: Pspy is Gold.** If you suspect a cron job is running but can't see `/etc/crontab`, use `pspy` to watch processes launch in real-time.
4.  **Future Trend: eBPF for Detection.** The future of Linux security isn't just stopping PrivEsc, but detecting it via **eBPF (Extended Berkeley Packet Filter)**. Tools like *Tetrogon* can detect when a process unexpectedly changes its UID, providing real-time alerting even if an exploit is successful.

---

## 🎁 Free Web Resources & Official Documentation

*   **[GTFOBins](https://gtfobins.github.io/):** The definitive list of Linux binaries and their exploitation.
*   **[HackTricks - Linux PrivEsc](https://book.hacktricks.xyz/linux-hardening/privilege-escalation):** The comprehensive manual for testers.
*   **[Linux Man Pages (Capabilities)](https://man7.org/linux/man-pages/man7/capabilities.7.html):** Official documentation.
