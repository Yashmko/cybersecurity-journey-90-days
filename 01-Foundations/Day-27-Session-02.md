# Day 27 | Session 02: Post-Exploitation & Integrity Research

**Focus:** Mapping RCE to Persistence (Rootkits)
**Status:** Deep-Dive Completed

---

## 🔬 Phase 1: Strategic Research (Persistence Mechanisms)

After achieving Initial Access via the Command Injection exploit in Session 01, the focus shifted to maintaining access. In a professional engagement, this is where **Rootkits** are leveraged.

### 🛡️ The Rootkit Hierarchy:
1. **User-Mode:** Intercepts standard library calls (API hooking). Common technique: `LD_PRELOAD` trickery to hide files from `ls`.
2. **Kernel-Mode (LKM):** Operates at Ring 0. It modifies the kernel’s syscall table, making it nearly invisible to standard user-space detection tools.
3. **Bootkits:** Infects the Master Boot Record (MBR) to execute before the OS even initializes.

### 🔍 Detection & Verification:
To counter these, I researched the implementation of:
* **rkhunter:** Signature-based check of system binaries against known-good hashes.
* **chkrootkit:** Anomaly-based detection looking for discrepancies in `/proc`.

---

## 🧪 Phase 2: Technical Proof (Initial Access via RCE)

**Target:** Custom Python Environment (`vulnerable_ping.py`)

### 🎯 Objective
Validate the exploit chain by achieving Remote Code Execution (RCE) on the host machine.

### 💻 Execution & Logs
I exploited a logic flaw in a script using the unsafe `os.system()` call. By injecting shell metacharacters, I bypassed the intended function.

**Payload Used:** `8.8.8.8; whoami; cat /etc/passwd`

**Terminal Log:**
\`\`\`text
➜ python vulnerable_ping.py
Welcome to the Network Ping Tool!
Enter an IP address to ping: 8.8.8.8; whoami; cat /etc/passwd
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=117 time=38.4 ms

--- 8.8.8.8 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss

12zse
root:x:0:0::/root:/usr/bin/bash
bin:x:1:1::/:/usr/bin/nologin
...
12zse:x:1000:1000::/home/12zse:/bin/zsh
ollama:x:961:961:ollama user:/var/lib/ollama:/usr/bin/nologin
\`\`\`

---

## ❌ Mistakes & Remediation Notes

* **Field Obstacle:** Encountered a `SyntaxError` during script deployment due to a multi-line paste error in the terminal.
* **Resolution:** Used a **Bash Here-Doc** to write the Python file directly, ensuring indentation integrity.
* **Remediation:** Migrated the code to use the `subprocess` module with argument arrays. This prevents the shell from interpreting characters like `;` or `&`, effectively killing the injection vector.

---

## 🏁 Summary
Session 02 bridged the gap between a "simple" web bug and the high-level persistence strategies used by APTs. Understanding the **Initial Access** (Command Injection) is the first step in defending against **Persistence** (Rootkits).
