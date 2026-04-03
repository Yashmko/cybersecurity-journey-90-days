# 🧠 Master-Level Technical Handbook: Linux Forensics & Timeline Analysis

**Author:** [Your Name/Senior Cybersecurity Architect]  
**Focus:** Incident Response, Artifact Recovery, and Anti-Forensics Detection  
**Level:** 400 (Mastery)

---

## 🔬 Technical Deep Dive & Theory: The Ghost in the Shell
Linux forensics is the art of reconstructing the "Ground Truth" from volatile memory and non-volatile storage. Unlike Windows, which relies heavily on the Registry, Linux is **file-centric**.

### The MACB Principle
To reconstruct a timeline, we analyze four specific timestamps associated with an Inode:
*   **M (Modify):** Content change.
*   **A (Access):** Last time the file was read.
*   **C (Change):** Metadata change (permissions/ownership).
*   **B (Birth):** File creation (Requires modern filesystems like Ext4, XFS, or Btrfs).

### The Anatomy of Volatility
A senior architect looks for "Living off the Land" (LotL) techniques. We analyze the **VFS (Virtual File System)** layer. Even if a threat actor deletes a malicious binary while it's running, the process remains in `/proc/[pid]/exe`. In Linux forensics, **if it runs, it leaves a shadow.**

---

## 💻 Universal Implementation (The 'How-To')
Forensics begins with "Live Response" before pulling a full disk image.

### 🔵 Debian/Ubuntu/Kali
*   **Auth Logs:** `cat /var/log/auth.log | grep "Failed password"`
*   **Package Integrity:** `dpkg --verify` (Finds modified system binaries)
*   **Timeline Generation:** `find / -printf '%T+ %p\n' | sort -r | head -n 50`

### 🔴 RHEL/Fedora/CentOS
*   **Auth Logs:** `cat /var/log/secure | grep "Accepted publickey"`
*   **Package Integrity:** `rpm -Va` (The gold standard for detecting rootkits replacing `ls` or `ps`)
*   **Auditd Logs:** `ausearch -m USER_LOGIN -sv no`

### ⚪ Arch Linux
*   **Journald Mastery:** `journalctl _TRANSPORT=kernel` (View kernel-level tampering)
*   **Package Integrity:** `pacman -Qkk`
*   **Artifact Hunt:** `ls -lac /etc/systemd/system/` (Check for persistence in custom unit files)

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth
**Root Cause:** Usually traceable to **Credential Exhaustion (SSH Brute Force)**, **Insecure Web Applications (RCE)**, or **Misconfigured SUID Binaries**.

### Remediation Checklist
1.  [ ] **Immutable Logging:** Ship logs to a remote Syslog/SIEM (Splunk/ELK) immediately.
2.  [ ] **Kernel Hardening:** Enable `kernel.modules_disabled=1` after boot to prevent Rootkit insertion.
3.  [ ] **Auditd Policy:** Deploy a "STIG-compliant" `audit.rules` file to track every `execve()` syscall.
4.  [ ] **Access Control:** Transition from standard permissions to **SELinux** (Enforcing) or **AppArmor**.

---

## 🔍 Threat Actor Profiling & MITRE Mapping
Identifying the "Who" by analyzing the "How."

| Technique | MITRE ATT&CK ID | Actor Example |
| :--- | :--- | :--- |
| **Scheduled Task (Cron)** | T1053.003 | APT29 (Cozy Bear) |
| **Web Shell Persistence** | T1505.003 | Lazarus Group |
| **Hidden Files/Directories** | T1564.001 | Common Cryptojackers |
| **Shared Modules (LD_PRELOAD)** | T1574.006 | Advanced Rootkits |

---

## 🎮 Gamified Labs & Simulation Training
*   **TryHackMe:** [Investigating Linux](https://tryhackme.com/room/investigatinglinux) (Difficulty: Medium)
*   **Hack The Box (Sherlocks):** [LUMEN] (Difficulty: Hard - DFIR focused)
*   **OverTheWire:** [Bandit](https://overthewire.org/wargames/bandit/) (Difficulty: Easy - For mastering the CLI forensics basics)

---

## 📊 GRC & Compliance Mapping
*   **NIST SP 800-61 Rev. 2:** Directly addresses the Incident Handling Lifecycle (Preparation -> Recovery).
*   **ISO/IEC 27001:** Control A.12.4.1 (Logging) and A.12.4.3 (Administrator Logs).
*   **SOC2 Trust
