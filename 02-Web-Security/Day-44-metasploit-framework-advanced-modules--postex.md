# 📑 Master-Level Handbook: Metasploit Framework (Advanced Post-Ex & Modules)
**Author:** Senior Cybersecurity Architect & Mentor  
**Focus:** Post-Exploitation, Pivoting, and Persistence  
**Classification:** Restricted / Technical Portfolio

---

## 🔬 Technical Deep Dive & Theory
At its core, the **Metasploit Framework (MSF)** is a Ruby-based modular penetration testing platform. To master it at a senior level, one must understand the **Meterpreter API** and the **Rex** (Ruby Extension) library.

### The Architecture of Post-Exploitation
1.  **Staged vs. Stageless Payloads:** 
    *   *Staged:* Small initial "stub" (`reverse_tcp`) that pulls the rest of the payload into memory. Better for small buffer exploits but noisier on the wire.
    *   *Stageless:* The entire payload (`reverse_tcp_uuid`) is sent at once. Better for OpSec and bypassing some firewalls.
2.  **In-Memory Execution (VREF):** Meterpreter operates via **Reflective DLL Injection**. It resides entirely in RAM, never touching the disk (T1027.002). This evades traditional AV/EDR signatures that focus on file-based scanning.
3.  **Railgun:** A powerful post-ex component that allows the attacker to call Windows API functions directly from the Meterpreter console without writing C code.

---

## 💻 Universal Implementation (The 'How-To')
To ensure cross-platform consistency, we utilize the official nightly installers or the community-driven repositories.

### 🔵 Debian/Ubuntu/Kali
```bash
# Kali comes pre-installed, but for a fresh Ubuntu/Debian server:
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
  chmod 755 msfinstall && \
  ./msfinstall
# Post-Install: Initialize Database
systemctl start postgresql
msfdb init
```

### 🔴 RHEL/Fedora/Rocky Linux
```bash
# Install dependencies
sudo dnf install -y curl postgresql-server postgresql-contrib
# Run nightly installer
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
  chmod 755 msfinstall && \
  sudo ./msfinstall
msfdb init
```

### ⚪ Arch Linux
```bash
# Metasploit is in the Community Repo
sudo pacman -Syu metasploit
# Arch specific initialization
sudo systemctl start postgresql
sudo -u postgres initdb -D /var/lib/postgres/data
msfdb init
```

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth
**Root Cause:** Most Metasploit modules succeed due to **Lateral Movement capabilities** and **Unquoted Service Paths**. 

### Remediation Checklist
- [ ] **EDR Implementation:** Deploy behavior-based detection (CrowdStrike/SentinelOne) to catch Reflective DLL Injection.
- [ ] **LSA Protection:** Enable `RunAsPPL` to prevent LSASS memory dumping (Mimikatz/Kiwi).
- [ ] **Egress Filtering:** Block all non-essential outbound traffic (ports 4444, 8443, 5555).
- [ ] **Credential Guard:** Use Windows Defender Credential Guard to isolate secrets.

---

## 🔍 Threat Actor Profiling & MITRE Mapping
Advanced actors like **FIN7** and **APT29** often leverage MSF for initial post-exploitation before deploying custom C2s.

| MITRE Technique | ID | Metasploit Module / Command |
| :--- | :--- | :--- |
| **OS Credential Dumping** | T1003 | `load kiwi`, `creds_all` |
| **Proxying** | T1090 | `post/multi/manage/autoroute` |
| **Process Injection** | T1055 | `migrate <PID>` |
| **System Information Discovery** | T1082 | `sysinfo` |

---

## 🎮 Gamified Labs & Simulation Training
*Sharpen your skills in these sandboxes:*

1.  **TryHackMe: Metasploit: Post-Exploitation** (Difficulty: 🟢 Easy) - Good for learning basic `migrate` and `hashdump`.
2.  **HackTheBox: Blue** (Difficulty: 🟠 Medium) - Focus on MS17-010 and the `eternalblue` module.
3.  **Proving Grounds: Heist** (Difficulty: 🔴 Hard) - Requires advanced pivoting through the `autoroute` and `SOCKS proxy` modules.

---

## 📊 GRC & Compliance Mapping
*   **NIST CSF (Detect/Respond):** Metasploit usage in Red Teaming fulfills **ID.RA-1** (Asset Vulnerabilities are identified and documented).
*   **ISO 27001 (A.12.6.1):** Management of technical vulnerabilities. Regular MSF-led testing ensures compliance with vulnerability management policies.
*   **SOC2 (CC7.1):** The organization reviews and monitors the infrastructure for anomalies.

**Business Impact:** Utilizing MSF reduces the "Mean Time to Detect" (MTTD) by simulating real-world breach scenarios before they occur.

---

## 🧪 Verification & Validation (The Proof)
To verify your system is hardened against MSF payloads:
```powershell
# Check if LSA Protection is enabled via PowerShell
Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa -Name RunAsPPL

# Check for unquoted service paths (Common MSF Escalation Vector)
wmic service get name,displayname,pathname,startmode | findstr /i "Get-Service" | findstr /i /v "C:\Windows\\" | findstr /i /v """
```

---

## 🛠️ Lab Report: What We Mastered
**Core Objective:** Full compromise and persistent access of a segmented network.
*   **Tools Used:** `msfconsole`, `msfvenom`, `Kiwi (Mimikatz)`, `Socks Proxy`.
*   **Key Achievement:** Successful **Pivoting**. Used a compromised web server to route traffic into a restricted DB VLAN using `post/multi/manage/autoroute`.

---

## 🚨 Real-World Breach Case Study: The "EternalBlue" Crisis
*   **CVE:** 2017-0144 (MS17-010).
*   **Context:** Shadow Brokers leaked the NSA exploit. Rapid7 quickly integrated it into Metasploit.
*   **Analysis:** This module demonstrated why "Staged Payloads" are lethal. An attacker could compromise a machine and, within seconds, use the `ms17_010_eternalblue` module to gain SYSTEM-level access and spread laterally via SMB.

---

## 💡 Senior Researcher Insights & Future Trends
1.  **Pro-Tip: Migration OpSec.** Never migrate to `lsass.exe` or `explorer.exe` immediately. These are heavily monitored. Target "quiet" services like `svchost.exe` or third-party drivers.
2.  **Pro-Tip: Resource Files.** Use `.rc` scripts to automate your setup. `msfconsole -r setup.rc` saves hours during time-sensitive engagements.
3.  **Pro-Tip: Transport Switching.** Use the `transport` command to switch from `reverse_tcp` to `reverse_https` mid-session to bypass changing firewall rules.
4.  **Future Trend:** **C2 Framework Interoperability.** We are seeing MSF integrate more deeply with frameworks like Cobalt Strike and Sliver, allowing Meterpreter sessions to be "passed" between different Command & Control infrastructures.

---

## 🎁 Free Web Resources & Official Documentation
*   **Official Docs:** [docs.metasploit.com](https://docs.metasploit.com/)
*   **Metasploit Unleashed (OffSec):** [Free Training Course](https://www.offisec.com/metasploit-unleashed/)
*   **Rapid7 Blog:** [Latest Module Updates](https://www.rapid7.com/blog/tag/metasploit/)
