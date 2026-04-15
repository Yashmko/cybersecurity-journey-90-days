# 🛡️ Day 28: SSRF Exploitation & Advanced SecOps Automation

**Author:** Bhavishya | **Version:** 1.0 | **Subject:** Web Hacking & Python Automation
**Level:** 400 (Expert)

---

## 🔬 Phase 1: Technical Deep Dive & Theory

### 1. SSRF Architecture (The Attack)
Server-Side Request Forgery (SSRF) occurs when a logic flaw in the **Ingestion Layer** allows an attacker to influence server-side requests. By bypassing URL validation, we turn the server into an internal proxy.

### 2. Python SecOps Architecture (The Defense)
In a modern SOC, manual review is impossible. We utilize Python as a force multiplier:
* **Ingestion Layer:** Using `os` and `io` generators to stream gigabyte-sized logs without RAM exhaustion.
* **Logic Layer (RegEx):** Leveraging the `re` module to identify non-linear patterns (e.g., SSH brute force spikes).
* **Network Layer (Sockets):** Using the `socket` module to verify "zombie" ports that logs suggest are closed.

---

## 💻 Universal Implementation (Environment)

🔵 **Debian/Kali**: `sudo apt install python3-requests python3-pip -y`
⚪ **Arch Linux**: `sudo pacman -S python-requests python-pip --noconfirm`

---

## 🐍 The Master Scripts

### Script A: The Vulnerability (`vulnerable_proxy.py`)
```python
import requests
url = input("Enter Image URL: ")
try:
    response = requests.get(url)
    print(f"[+] Fetched {len(response.text)} bytes from internal source.")
except Exception as e:
    print(f"[-] Error: {e}")
Script B: The Defense Engine (cyber_parse.py)
Python
import re, socket, os

def check_port(ip, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(1)
    try:
        s.connect((ip, port))
        return True
    except:
        return False
    finally: s.close()

def parse_logs(file_path, pattern):
    if not os.path.exists(file_path): return
    with open(file_path, 'r') as file:
        for line in file:
            if re.search(pattern, line):
                print(f"[!] Alert: {line.strip()}")
🧪 Phase 2: Execution & Lab Proof
🎯 SSRF Lab Objective
Exploit the proxy tool to exfiltrate directory listings from a firewalled local service (Port 9000).

💻 Commands & Payloads
Internal Setup: python -m http.server 9000

Attack Payload: http://localhost:9000

🩸 Raw Output & Logs
Plaintext
➜ python vulnerable_proxy.py
--- Zenith Image Proxy Tool ---
Enter the URL: http://localhost:9000

[+] Metadata from http://localhost:9000:
Status Code: 200
Content Length: 15502 bytes
Preview: <!DOCTYPE HTML> <html lang="en"> <head> ...
🛡️ RCA & Defense-in-Depth
Root Cause: Inefficient visibility into log data and lack of input sanitization.
Strategy:

Layer 1: Implement URL Allow-listing.

Layer 2: Use cyber_parse.py to monitor /var/log/auth.log for SSRF-related patterns.

Layer 3: Socket-level verification of internal services.

🔍 MITRE Mapping & Threat Profiling
TechniqueMITRE IDDescription
SSRFT1557Exploiting trust to proxy internal requests.
Brute ForceT1110Automated credential guessing (Detected via RegEx).
Impair DefensesT1562.001Log erasure; monitored via Python file-size scripts.
📊 GRC & Compliance
NIST CSF (DE.CM-1): The Python automation provides continuous monitoring evidence.

ISO 27001 (A.12.4.1): Ensures events are recorded and reviewed via automated parsing.

Business Impact: Reduces Mean Time to Detect (MTTD) from 200 days to minutes.

🛠️ Lab Summary
Mastered the dual-role of a security professional: Exploiting a system via SSRF and Automating its defense using Python socket programming and RegEx-based log parsing.

💡 Senior Researcher Insight
"A vulnerability is a question; automation is the answer. If you can't script the detection of your own exploit, you haven't truly mastered the attack."
