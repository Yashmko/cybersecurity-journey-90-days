# 🛡️ Master-Level Handbook: Advanced Rootkit Detection & System Integrity

**Author:** [Your Name/Senior Cybersecurity Architect]
**Focus:** Post-Exploitation Persistence Detection
**Level:** 400 (Expert)

---

## 🔬 Technical Deep Dive & Theory

Rootkits are the "invisibility cloaks" of the digital world. Unlike standard malware, their primary objective is **Persistence** and **Evasion**. 

### The Architectural Divide:
1.  **User-Mode Rootkits:** These hijack standard system APIs (like `ls`, `ps`, or `netstat`) by replacing binaries or using `LD_PRELOAD` to intercept function calls. If you run `ls`, the rootkit-modified version filters out the attacker’s files.
2.  **Kernel-Mode Rootkits (LKM):** These operate at Ring 0. They modify the kernel’s syscall table. When a user-space application asks the kernel for a process list, the kernel itself lies to the application.
3.  **Bootkits:** The most dangerous tier, infecting the MBR (Master Boot Record) or VBR (Volume Boot Record) to gain execution before the OS even loads.

### Detection Logic:
*   **`rkhunter` (Rootkit Hunter):** Uses **Signature-based detection** and **File Integrity Monitoring (FIM)**. It compares SHA-1 hashes of system binaries against a known-good database and checks for hidden directories and incorrect permissions.
*   **`chkrootkit` (Check Rootkit):** Uses **Heuristic/Anomaly detection**. It looks for specific "signatures" of known rootkits in memory and checks for discrepancies (e.g., a process exists in `/proc` but isn't visible via `ps`).

---

## 💻 Universal Implementation (The 'How-To')

### 🔵 Debian/Ubuntu/Kali
```bash
sudo apt update && sudo apt install rkhunter chkrootkit -y
# Initialize rkhunter database (Crucial: Do this on a clean install)
sudo rkhunter --propupd
# Run check
sudo rkhunter --check --sk
sudo chkrootkit
```

### 🔴 RHEL/Fedora/AlmaLinux
```bash
sudo dnf install epel-release -y
sudo dnf install rkhunter chkrootkit -y
# Update properties
sudo rkhunter --propupd
# Run check
sudo rkhunter --check --skip-keypress
sudo chkrootkit
```

### ⚪ Arch Linux
```bash
sudo pacman -S rkhunter
# chkrootkit is typically in the AUR
git clone https://aur.archlinux.org/chkrootkit.git && cd chkrootkit && makepkg -si
# Initialize and Run
sudo rkhunter --propupd
sudo rkhunter --check
```

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth

**Root Cause:** Rootkits are rarely the initial entry point. They are the *result* of a successful exploit (RCE, SQLi, or Credential Stuffing) where the attacker escalated privileges to `root`.

### Remediation Checklist:
- [ ] **Immutable Bits:** Set the immutable attribute on critical binaries (`chattr +i /bin/ps`).
- [ ] **Kernel Hardening:** Enable `kernel.modules_disabled=1` after boot to prevent LKM loading.
- [ ] **Secure Boot:** Ensure UEFI Secure Boot is enabled to prevent Bootkits.
- [ ] **FIM:** Deploy a real-time File Integrity Monitor like **Wazuh** or **AIDE**.

---

## 🔍 Threat Actor Profiling & MITRE Mapping

| Technique | MITRE ID | Description |
| :--- | :--- | :--- |
| **Rootkit** | [T1014](https://attack.mitre.org/techniques/T1014/) | Hiding presence by hooking OS API calls. |
| **Boot or Logon Autostart Execution** | [T1547](https://attack.mitre.org/techniques/T1547/) | Persistence via Init scripts or Systemd services. |
| **Modify System Image** | [T1601](https://attack.mitre.org/techniques/T1601/) | Patching binaries to bypass authentication. |

**Threat Actor Profile:** Often used by **APTs (e.g., APT28/Fancy Bear)** for long-term espionage or **Ransomware groups** to disable AV/EDR before encryption.

---

## 🎮 Gamified Labs & Simulation Training
*   **TryHackMe: Rootkits** (Difficulty: Medium) - Hands-on with LKM rootkits.
*   **HackTheBox: Bastion** (Difficulty: Hard) - Focuses on deep persistence and hidden files.
*   **OverTheWire: Behemoth** - Excellent for understanding setuid and privilege escalations.

---

## 📊 GRC & Compliance Mapping
*   **NIST CSF (ID.AM-2):** Software platforms and applications within the organization are inventoried.
*   **ISO 27001 (A.12.2.1):** Protection against malware.
*   **PCI-DSS (Requirement 11.5):** Deploy file-integrity monitoring software to alert personnel to unauthorized modification of critical system files.
*   **Business Impact:** A rootkit breach leads to total loss of **Confidentiality** and **Integrity**, potentially resulting in massive GDPR fines and loss of brand trust.

---

## 🧪 Verification & Validation (The Proof)
To verify your detection tools are working, simulate a "suspicious" file:
```bash
# Create a hidden directory in a sensitive area
sudo mkdir /usr/bin/.hidden_rootkit_test
# Run rkhunter
sudo rkhunter --check --sk --report-warnings-only
# Result: Should flag "Hidden directory found"
```

---

## 🛠️ Lab Report: What We Mastered
**Executive Summary:** 
In this lab, I transcended theoretical knowledge by simulating a full-cycle attack and defense scenario. I dropped the theory and built a vulnerable Python ping tool to test OS Command Injection natively. Exploited my own script by bypassing the `os.system()` call with a semicolon, achieving Remote Code Execution to dump the Arch Linux user database. Hit a syntax error early on but fixed it using a bash Here-Doc. Learned that using the `subprocess` module is the only way to neutralize shell operators. The vulnerability isn't just bad code; it's trusting the user.

**Tools Leveraged:**
*   **Detection:** `rkhunter`, `chkrootkit`
*   **Offensive Simulation:** Python3 (`os` & `subprocess` modules), Bash, Netcat.
*   **Analysis:** `strace`, `lsof`, `journalctl`.

---

## 🚨 Real-World Breach Case Study: The LoJax Incident
**Target:** Central European Government Agencies (2018).
**The Tool:** **LoJax**, the first UEFI rootkit used in the wild by the Sednit group (APT28).
**Analysis:** LoJax targeted the SPI flash memory to survive OS reinstallation and hard drive replacement. This highlighted the inadequacy of OS-level detection alone and forced the industry to adopt **Hardware Root of Trust**.

---

## 💡 Senior Researcher Insights & Future Trends
1.  **Baseline Early:** Always run `rkhunter --propupd` immediately after a fresh OS install. A baseline created *after* an infection is worthless.
2.  **The eBPF Frontier:** Modern rootkits are moving to **eBPF (Extended Berkeley Packet Filter)**. They can intercept network traffic and syscalls without modifying the kernel disk image, making them invisible to traditional FIM.
3.  **Trust Nothing:** In a high-security environment, treat "Warning" flags as "Infections" until proven otherwise. False positives are the price of vigilance.
4.  **Future Trend:** **AI-Driven Heuristics** in EDR will soon replace signature-based detection, identifying rootkits by "behavioral jitter"—micro-delays in system calls caused by hooking.

---

## 🎁 Free Web Resources & Official Documentation
*   [Rootkit Hunter Project Home](http://rkhunter.sourceforge.net/)
*   [Chkrootkit Official Site](http://www.chkrootkit.org/)
*   [Linux Kernel Security Hardening Guide](https://www.kernel.org/doc/html/latest/admin-guide/LSM/index.html)
*   [MITRE ATT&CK Framework](https://attack.mitre.org/)
