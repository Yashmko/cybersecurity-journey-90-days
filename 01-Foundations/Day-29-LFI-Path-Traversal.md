# 🛡️ Day 29: Local File Inclusion (LFI) & Path Traversal

**Author:** Bhavishya | **Version:** 1.0 | **Subject:** Web Vulnerabilities & Filesystem Security
**Level:** 400 (Expert)

---

## 🔬 Technical Deep Dive & Theory

Local File Inclusion (LFI) is a vulnerability that allows an attacker to manipulate file paths to read sensitive files or execute code on a server. It typically arises when an application passes unvalidated user input to a file-inclusion API.

### The Attack Vector: Path Traversal
By utilizing "dot-dot-slash" (`../`) sequences, an attacker can climb out of the intended restricted directory (the web root or document folder) and navigate to the root of the filesystem (`/`).

---

## 💻 Lab: The "Dirty Hands" Execution

### 🎯 Objective
Exploit a path traversal vulnerability in a custom Python application to break out of a restricted document directory and access sensitive Linux system files.

### 🐍 The Vulnerable Asset: `vulnerable_reader.py`
The script utilized `os.path.join(base_path, filename)` to construct file paths. The fatal flaw was trusting the `filename` input without sanitizing directory traversal characters.

### 🩸 Raw Output & Logs (The Breach)
\`\`\`text
➜ python vulnerable_reader.py
--- Zenith Document Viewer v1.0 ---
Available files: news.txt, about.txt
Enter the filename to read: ../../../etc/passwd

[+] Displaying ../../../etc/passwd:

root:x:0:0::/root:/usr/bin/bash
bin:x:1:1::/:/usr/bin/nologin
daemon:x:2:2::/:/usr/bin/nologin
mail:x:8:12::/var/spool/mail:/usr/bin/nologin
ftp:x:14:11::/srv/ftp:/usr/bin/nologin
http:x:33:33::/srv/http:/usr/bin/nologin
nobody:x:65534:65534:Kernel Overflow User:/:/usr/bin/nologin
dbus:x:81:81:System Message Bus:/:/usr/bin/nologin
systemd-coredump:x:979:979:systemd Core Dumper:/:/usr/bin/nologin
systemd-network:x:978:978:systemd Network Management:/:/usr/bin/nologin
systemd-oom:x:977:977:systemd Userspace OOM Killer:/:/usr/bin/nologin
systemd-journal-remote:x:976:976:systemd Journal Remote:/:/usr/bin/nologin
systemd-resolve:x:975:975:systemd Resolver:/:/usr/bin/nologin
systemd-timesync:x:974:974:systemd Time Synchronization:/:/usr/bin/nologin
tss:x:973:973:tss user for tpm2:/:/usr/bin/nologin
uuidd:x:972:972:UUID generator helper daemon:/var/lib/libuuid:/usr/bin/nologin
alpm:x:971:971:Arch Linux Package Management:/:/usr/bin/nologin
pcscd:x:970:970:PC/SC Smart Card Daemon:/:/usr/bin/nologin
polkitd:x:102:102:User for polkitd:/:/usr/bin/nologin
12zse:x:1000:1000::/home/12zse:/bin/zsh
git:x:969:969:git daemon user:/:/usr/bin/git-shell
avahi:x:968:968:Avahi mDNS/DNS-SD daemon:/:/usr/bin/nologin
colord:x:967:967:colord colour management daemon:/var/lib/colord:/usr/bin/nologin
lightdm:x:966:966:Light Display Manager:/var/lib/lightdm:/usr/bin/nologin
_talkd:x:964:964:User for legacy talkd server:/:/usr/bin/nologin
rtkit:x:963:963:RealtimeKit:/:/usr/bin/nologin
ollama:x:961:961:ollama user:/var/lib/ollama:/usr/bin/nologin
flatpak:x:960:960:Flatpak system helper:/:/usr/bin/nologin
\`\`\`

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth

**Root Cause:** Direct mapping of unsanitized user input to filesystem APIs.

**Remediation Strategy:**
1. **Basename Filtering:** Strip directory traversal characters using `os.path.basename(filename)`. This ensures `../../../etc/passwd` simply becomes `passwd`.
2. **Absolute Path Validation:** Resolve the absolute path of the requested file and verify that it starts with the expected base directory (e.g., using `os.path.abspath()` and `startswith()`).
3. **Hardcoded Allow-list:** If the application only needs to serve a few files, use an explicit list: `if filename not in ['news.txt', 'about.txt']: return Access_Denied`.

---

## 🔍 Threat Actor Profiling & MITRE Mapping

| Threat Actor | Motivation | MITRE ATT&CK Technique |
| :--- | :--- | :--- |
| **Initial Access Brokers (IABs)** | Monetization / Recon | **T1083**: File and Directory Discovery |
| **Lapsus$** | Data Extortion | **T1005**: Data from Local System |
| **APT29 (Cozy Bear)** | Espionage / Lateral Movement | **T1552.001**: Credentials In Files (Stealing SSH keys via LFI) |

---

## 📊 GRC & Compliance Mapping

* **OWASP Top 10 (A01:2021):** Broken Access Control. Path traversal is a direct failure to enforce access restrictions.
* **NIST CSF (PR.PT-4):** Requires strict access control and input validation to protect system assets from unauthorized reads.
* **ISO 27001 (A.14.2.5):** Secure system engineering principles (Input validation is mandatory).

---

## 🛠️ Lab Report: What We Mastered

**Executive Summary:** Developed a custom vulnerable Python script simulating a document viewer component. Successfully bypassed the intended directory sandbox using a `../` (dot-dot-slash) payload. Exfiltrated the `/etc/passwd` file natively on an Arch Linux environment. Solidified understanding of how filesystem APIs interact with unvalidated user input and engineered the requisite Python patching strategies using `os.path.abspath()`.

---

## 🚨 Real-World Breach Case Study: Apache HTTP Server (CVE-2021-41773)

In late 2021, a zero-day path traversal vulnerability was discovered in Apache 2.4.49. A flaw in how Apache normalized paths allowed attackers to use a modified traversal payload (`.%2e/%2e%2e/`) to bypass the filter and read arbitrary files outside the document root. If CGI scripts were enabled, this LFI was instantly chained into Remote Code Execution (RCE). It serves as a stark reminder that even enterprise-grade web servers can fall victim to path traversal.

---

## 💡 Senior Researcher Insights & Future Trends

* **Insight:** "LFI is the silent killer. It doesn't crash the server or set off noisy alarms. It quietly allows the attacker to map your internal architecture, steal SSH keys, and prepare for a full system takeover."
* **Future Trend: LFI to RCE Chains:** Modern attackers rarely stop at reading files. The trend is leveraging LFI to read server logs (Log Poisoning) or utilize PHP wrappers (`php://filter`) to escalate LFI directly into Remote Code Execution.
* **Future Trend: Cloud-Native LFI:** In Kubernetes environments, attackers use LFI not to read `/etc/passwd`, but to read service account tokens located at `/var/run/secrets/kubernetes.io/serviceaccount/token` to hijack the pod's identity.
* **Future Trend: LLM Payload Generation:** Attackers are increasingly using AI to rapidly generate deeply obfuscated path traversal payloads (using diverse URL-encoding combinations) to bypass Next-Gen WAFs.

---

## 🎮 Gamified Labs & Simulation Training

* **PortSwigger Web Security Academy:** Directory Traversal (Beginner to Advanced filter bypasses).
* **TryHackMe:** File Inclusion Module (Medium).
* **HackTheBox:** "Beep" (Classic LFI/Directory Traversal exploitation).

---

## 🎁 Free Web Resources & Official Documentation

* [OWASP Path Traversal Guide](https://owasp.org/www-community/attacks/Path_Traversal)
* [PayloadsAllTheThings - Directory Traversal](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Directory%20Traversal)
* [Python `os.path` Official Documentation](https://docs.python.org/3/library/os.path.html)
