# 📘 Master-Level Handbook: Python for Cyber—Scripting Automation & Log Parsing

**Author:** [Your Name/Senior Cybersecurity Architect]
**Version:** 1.0
**Subject:** Advanced Automation for Security Operations (SecOps)

---

## 🔬 Technical Deep Dive & Theory
In the modern SOC, **automation is the force multiplier**. Manual log review is impossible at scale. This handbook focuses on the architecture of **Log Parsing** and **Network Socket Programming** using Python.

### The Architecture of a Security Script:
1.  **Ingestion Layer:** Utilizing `os` and `io` modules to stream data without loading gigabyte-sized log files into RAM (using generators).
2.  **Logic Layer (RegEx):** Leveraging the `re` module to identify Non-Linear patterns (e.g., failed login spikes, unauthorized `sudo` attempts).
3.  **Network Layer (Sockets):** Using the `socket` module to verify service availability or identify "zombie" ports that logs suggest are closed but remain open.
4.  **Error Handling:** Implementing `try-except-finally` blocks to ensure scripts don't crash mid-analysis on malformed log entries.

---

## 💻 Universal Implementation (The 'How-To')

### 🔵 Debian/Ubuntu/Kali
```bash
sudo apt update && sudo apt install python3 python3-pip -y
# Standard log path: /var/log/auth.log
```

### 🔴 RHEL/Fedora
```bash
sudo dnf install python3 python3-pip -y
# Standard log path: /var/log/secure
```

### ⚪ Arch Linux
```bash
sudo pacman -Syu python python-pip --noconfirm
# Standard log path: journalctl (requires python-systemd)
```

### 🐍 The Master Script: `cyber_parse.py`
```python
import re
import socket
import os
import argparse

def check_port(ip, port):
    """Socket programming to verify port status."""
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(1)
    try:
        s.connect((ip, port))
        return True
    except:
        return False
    finally:
        s.close()

def parse_logs(file_path, pattern):
    """Modular log parsing engine."""
    if not os.path.exists(file_path):
        print(f"[-] Error: {file_path} not found.")
        return

    print(f"[*] Analyzing {file_path} for pattern: {pattern}")
    with open(file_path, 'r') as file:
        for line in file:
            if re.search(pattern, line):
                print(f"[!] Alert: {line.strip()}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Cyber Tool v1.0")
    parser.add_argument("--log", help="Path to log file")
    parser.add_argument("--ip", help="IP to scan")
    args = parser.parse_args()

    if args.log:
        # Detects SSH Brute Force patterns
        parse_logs(args.log, r"Failed password|Invalid user")
    
    if args.ip:
        status = check_port(args.ip, 22)
        print(f"[*] Port 22 status on {args.ip}: {'OPEN' if status else 'CLOSED'}")
```

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth
**Root Cause:** Inefficient visibility into log data leads to a "dwell time" (the time an attacker is in the system before detection) of 200+ days.
**Defense-in-Depth Strategy:**
1.  **Layer 1 (Prevention):** Disable password-based SSH; use PKI.
2.  **Layer 2 (Detection):** Deploy the Python automation script as a `cron` job to alert on `Failed password` counts > 5.
3.  **Layer 3 (Response):** Integration with `iptables` to auto-ban detected IPs.

### Remediation Checklist:
- [ ] Implement Centralized Logging (ELK/Splunk).
- [ ] Rotate logs weekly to prevent disk exhaustion.
- [ ] Apply the Principle of Least Privilege (PoLP) to the script execution user.

---

## 🔍 Threat Actor Profiling & MITRE Mapping
*   **Threat Actor Profile:** **APT28 (Fancy Bear)** or generic **Initial Access Brokers**.
*   **Technique:** Brute Force / Log Erasure.

| MITRE ID | Technique | Description |
| :--- | :--- | :--- |
| **T1110** | Brute Force | Attempting multiple passwords to gain access. |
| **T1071** | Application Layer Protocol | Using standard protocols (SSH/HTTP) for C2. |
| **T1562.001** | Impair Defenses: Disable Tools | Actors may delete logs to hide tracks; Python scripts can detect log size shrinkage. |

---

## 🎮 Gamified Labs & Simulation Training
*   **TryHackMe:** [Python for Pentesters](https://tryhackme.com/room/pythonforpentesters) (Medium)
*   **HackTheBox:** [Blue](https://app.hackthebox.com/machines/Blue) - Scripting simple exploits. (Easy/Medium)
*   **OverTheWire:** [Bandit](https://overthewire.org/wargames/bandit/) - Levels 12-14 (Log analysis & port connecting). (Beginner)

---

## 📊 GRC & Compliance Mapping
*   **NIST CSF (DE.CM-1):** Monitoring of networks/physical environment to identify potential cybersecurity events.
*   **ISO 27001 (A.12.4.1):** Event logging—ensuring logs are recorded, protected, and reviewed.
*   **SOC2 (CC7.2):** The script provides "Continuous Monitoring" evidence for auditors.
*   **Business Impact:** Reduces "Mean Time to Detect" (MTTD), directly lowering the potential cost of a data breach.

---

## 🧪 Verification & Validation (The Proof)
To verify the script is functional and the environment is hardened:
1.  **Trigger a False Positive:** `ssh non-existent-user@localhost`
2.  **Check Script Output:** `python3 cyber_parse.py --log /var/log/auth.log`
3.  **Verify Hardening:** `systemctl status fail2ban` (Ensure the service is active and consuming the logs processed by Python).

---

## 🛠️ Lab Report: What We Mastered
**Executive Summary:**
Developed custom Python scripts for security automation, focusing on socket programming and log parsing. Built a modular script to automate the identification of 'suspicious' patterns in system logs. Integrated error handling and OS-agnostic library practices to ensure the automation is scalable across different Linux environments.

**Tools Used:**
*   **Language:** Python 3.10+
*   **Modules:** `re` (Regex), `socket` (Network), `argparse` (CLI UX), `os` (Filesystem).
*   **OS Environments:** Ubuntu 22.04 LTS, Rocky Linux 9 (RHEL-based).

---

## 🚨 Real-World Breach Case Study: The "Morris Worm" (Historical Context)
While ancient, the Morris Worm used "Finger" protocol vulnerabilities. Modern equivalents involve SSH brute force on cloud instances.
**CVE-2024-3094 (XZ Utils):** While a backdoor, detection of such anomalies often starts with identifying unusual execution patterns in logs—automation scripts are the first line of defense in flagging these anomalies before they escalate.

---

## 💡 Senior Researcher Insights & Future Trends
1.  **Pro-Tip 1:** Use `logging` module instead of `print()` for production scripts to allow for severity levels (INFO, WARN, CRITICAL).
2.  **Pro-Tip 2:** Use Python `pandas` for heavy log analysis if the datasets exceed 500MB; it is significantly faster for data manipulation.
3.  **Pro-Tip 3:** Always hash your log files (`hashlib`) to ensure integrity; if the hash changes unexpectedly, the attacker may be editing logs.
4.  **Future Trend:** **AI-Augmented Parsing.** We are moving toward "Semantic Log Parsing," where LLMs identify suspicious intent rather than just matching RegEx strings.

---

## 🎁 Free Web Resources & Official Documentation
*   **Python Official Docs:** [docs.python.org](https://docs.python.org/3/)
*   **Regex101:** [regex101.com](https://regex101.com/) (Essential for testing log patterns).
*   **MITRE ATT&CK:** [attack.mitre.org](https://attack.mitre.org/)
*   **SANS Institute:** [Python for InfoSec Cheat Sheet](https://www.sans.org/blog/python-cheat-sheet/).
