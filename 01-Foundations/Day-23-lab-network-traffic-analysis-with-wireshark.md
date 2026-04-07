# 📘 MASTER-LEVEL HANDBOOK: Network Traffic Analysis with Wireshark
**Level:** Senior Architect / Professional Portfolio Series  
**Focus:** Full-Stack Packet Inspection, Protocol Analysis, and Forensic Reconstruction  

---

## 🔬 Technical Deep Dive & Theory
Network Traffic Analysis (NTA) is the art of deconstructing the **OSI Model** at the bit-and-byte level. At its core, Wireshark utilizes the `libpcap` (Linux) or `npcap` (Windows) libraries to capture frames directly from the Network Interface Card (NIC).

### The Logic of Dissection
1.  **Capture Engine:** Intercepts raw PDU (Protocol Data Units) via promiscuous mode.
2.  **Dissectors:** Wireshark’s "brain." These are logic modules that recognize protocol headers (Ethernet -> IP -> TCP -> HTTP) and map them to human-readable fields.
3.  **Stateful Inspection:** Unlike a simple firewall, Wireshark tracks the **TCP Handshake** and flow, allowing for "Follow TCP Stream" functionality to reconstruct entire conversations.
4.  **Delta Time Analysis:** Crucial for identifying latency issues or C2 (Command & Control) "heartbeat" beacons.

---

## 💻 Universal Implementation (The 'How-To')
To perform master-level analysis, we need both the GUI and the CLI tool (`tshark`) for automation.

### 🔵 Debian/Ubuntu/Kali
```bash
sudo apt update && sudo apt install wireshark tshark -y
# Set permissions so non-root users can capture
sudo dpkg-reconfigure wireshark-common 
sudo usermod -aG wireshark $USER
```

### 🔴 RHEL/Fedora
```bash
sudo dnf install wireshark-cli wireshark-qt -y
sudo usermod -aG wireshark $USER
# Note: May require a logout/login to refresh group permissions
```

### ⚪ Arch Linux
```bash
sudo pacman -S wireshark-qt wireshark-cli
sudo gpasswd -a $USER wireshark
```

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth
When we find anomalies in traffic, the Root Cause is usually one of three failures: **Lack of Encryption**, **Misconfigured Access Control**, or **Protocol Misuse**.

### The Remediation Checklist
- [ ] **Enforce TLS 1.3:** Eliminate cleartext protocols (FTP, Telnet, HTTP).
- [ ] **Certificate Pinning:** Prevent Man-in-the-Middle (MitM) even if a CA is compromised.
- [ ] **Micro-Segmentation:** Use VLANs and East-West firewalls to prevent lateral movement visible in packet captures.
- [ ] **Traffic Scrubbing:** Implement DDoS protection to filter malformed packets at the edge.
- [ ] **PFS (Perfect Forward Secrecy):** Ensure that even if a private key is stolen, past traffic cannot be decrypted.

---

## 🔍 Threat Actor Profiling & MITRE Mapping
Traffic analysis is the primary way we identify TTPs (Tactics, Techniques, and Procedures).

| Technique | MITRE ATT&CK ID | Wireshark Indicator |
| :--- | :--- | :--- |
| **Network Service Scanning** | [T1046](https://attack.mitre.org/techniques/T1046/) | High frequency of TCP SYN packets without ACKs (SYN Scan). |
| **Exfiltration Over C2 Channel** | [T1041](https://attack.mitre.org/techniques/T1041/) | Unusual DNS Query lengths or high volume of outbound HTTPS to unknown IPs. |
| **Unsecured Credentials** | [T1552](https://attack.mitre.org/techniques/T1552/) | Presence of `Authorization: Basic` headers in HTTP streams. |
| **Brute Force** | [T1110](https://attack.mitre.org/techniques/T1110/) | Thousands of `401 Unauthorized` responses in a short burst. |

---

## 🎮 Gamified Labs & Simulation Training
*   **TryHackMe: [Wireshark 101](https://tryhackme.com/room/wireshark101)** (Difficulty: Easy) – Basics of filtering.
*   **HackTheBox: [Sherlocks](https://www.hackthebox.com/hacker/forensics)** (Difficulty: Hard) – Deep forensic pcap analysis of real-world breaches.
*   **OverTheWire: [Sherlock](https://overthewire.org/)** – Focus on network-based challenges.
*   **Wireshark.org: [Sample Captures](https://wiki.wireshark.org/SampleCaptures)** – Analyze real PCAPs of malware (e.g., Emotet, Trickbot).

---

## 📊 GRC & Compliance Mapping
*   **NIST CSF (DE.AE-1):** Network signals are analyzed to detect potential events. PCAP analysis provides the "ground truth" for incident response.
*   **PCI-DSS (Requirement 4.1):** Use strong cryptography and security protocols to safeguard sensitive cardholder data during transmission.
*   **SOC2 (Confidentiality):** Ensuring that data in transit is encrypted. Analyzing traffic proves that no PII is leaking over unencrypted channels.
*   **Business Impact:** Reduces "Mean Time to Detect" (MTTD), preventing large-scale data exfiltration fines (GDPR/CCPA).

---

## 🧪 Verification & Validation (The Proof)
How do we know our hardening worked? We try to "sniff" the failure.

**1. Check for Cleartext Passwords:**
```bash
tshark -r capture.pcap -Y "http.request.method == POST" -T fields -e http.file_data
```
*Validation: If this returns encrypted blobs (TLS), the hardening is successful.*

**2. Detect Unauthorized Internal Scanning:**
```bash
tshark -r capture.pcap -q -z io,phs
```
*Validation: Review the Protocol Hierarchy. If unexpected protocols (like SMB or RDP) appear in segments where they shouldn't exist, the policy is failing.*

---

## 🛠️ Lab Report: What We Mastered
**Focus:** Authentication, Session Management, and the Network Truth.

In this lab, we focused on the core of web trust: **Authentication and Session Management**. We deep-dived into the vulnerabilities that allow an attacker to bypass the login gate entirely by capturing raw packets. We mastered the identification of **weak Session IDs** and the mechanics of **Session Fixation attacks** by observing how IDs are assigned in the `Set-Cookie` header. 

We explored how **'Credential Stuffing'** and **'Brute Forcing'** exploit poor password policies and lack of rate-limiting, visualized as a flood of login attempts in the packet stream. We practiced the manual manipulation of **JWT (JSON Web Tokens)** and cookies to escalate privileges, observing how these changes manifest in the payload. 

> *“In the realm of identity, the session is the soul of the user—if you can steal the token, you become the person. The gate is officially unlocked.”*

**Tools Used:**
*   **Wireshark:** For deep packet inspection and stream reconstruction.
*   **TShark:** For command-line traffic parsing and automation.
*   **Tcpdump:** For lightweight, remote packet capture on headless servers.
*   **Network Miner:** For automated OS fingerprinting and artifact extraction.

---

## 🚨 Real-World Breach Case Study: The WannaCry Ransomware (2017)
*   **CVE:** [CVE-2017-0144](https://nvd.nist.gov/vuln/detail/cve-2017-0144) (EternalBlue)
*   **Analysis:** WannaCry exploited the SMBv1 protocol. Traffic analysis during the breach showed massive amounts of SMB traffic on Port 445.
*   **The Wireshark "Smoking Gun":** Analysts saw specific `Multiplex ID` patterns in SMB requests that indicated a buffer overflow attempt.
*   **Lesson:** Disabling legacy protocols (SMBv1) and monitoring port 445 traffic could have halted the lateral movement phase of the attack.

---

## 💡 Senior Researcher Insights & Future Trends

1.  **Pro-Tip: Use Display Filters, Not Capture Filters.** Capture everything, then filter. You can't analyze what you didn't catch, and often the "noise" contains the side-channel attack signals.
2.  **Pro-Tip: Look for Beaconing.** In C2 analysis, look for consistent timing. Use the `frame.time_delta` column. Human traffic is erratic; bots are rhythmic.
3.  **Pro-Tip: Master the 'Coloring Rules'.** Customize Wireshark to highlight TCP RST (Resets) in bright red and SYN packets in green to visually spot scans instantly.

**Future Trend: Encrypted Client Hello (ECH) & TLS 1.3.** 
As the web moves toward total encryption, even the SNI (Server Name Indication) is becoming hidden. This makes NTA harder. Future architects must focus on **SSL/TLS Decryption Mirrors** and **eBPF-based observability** to see traffic *before* it is encrypted at the kernel level.

---

## 🎁 Free Web Resources & Official Documentation
*   **Official Docs:** [Wireshark User’s Guide](https://www.wireshark.org/docs/wsug_html_chunked/)
*   **The Bible:** [Wireshark Network Analysis by Laura Chappell](https://www.chappell-university.com/)
*   **Training:** [Chris Greer’s YouTube Channel](https://www.youtube.com/c/ChrisGreer) (The gold standard for packet analysis tutorials).
*   **Practice:** [Malware-Traffic-Analysis.net](https://www.malware-traffic-analysis.net/) (Real-world PCAPs).
