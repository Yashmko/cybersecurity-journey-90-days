# 📘 Master-Level Handbook: Information Gathering (Passive Recon & OSINT)
**Author:** Bhavishya
**Version:** 1.0 (The Zenith Protocol)
**Objective:** Mastering the art of invisibility and observation without touching the target's perimeter.

---

## 🔬 Technical Deep Dive & Theory
Passive Reconnaissance is the science of harvesting the **"Digital Exhaust"** an organization leaves behind. Unlike active scanning, passive recon interacts with third-party datasets, ensuring zero direct contact with the target's infrastructure.

### The Architecture of the Shadow Footprint:
1.  **DNS Metadata:** Leveraging passive DNS databases (e.g., RiskIQ, SecurityTrails) to view historical IP changes.
2.  **The Certificate Transparency (CT) Logs:** Monitoring SSL/TLS certificate issuance via `crt.sh` to discover hidden subdomains (e.g., `dev-api.internal.company.com`).
3.  **Search Engine Hacking (Dorking):** Utilizing advanced operators to index sensitive directories (`intitle:index of`), configuration files (`filetype:env`), and leaked credentials.
4.  **Social Engineering OSINT:** Mapping the human attack surface via LinkedIn/Twitter to identify technology stacks mentioned in job descriptions.

---

## 💻 Universal Implementation (The 'How-To')
To build a world-class OSINT workstation, you need cross-distribution compatibility for the core toolkit: `theHarvester`, `subfinder`, and `shodan-cli`.

### 🔵 Debian/Ubuntu/Kali
```bash
sudo apt update && sudo apt install -y subfinder whois dnsutils python3-pip
pip3 install shodan theHarvester
```

### 🔴 RHEL/Fedora
```bash
sudo dnf install -y bind-utils whois
pip3 install shodan theHarvester
# Subfinder requires Go
sudo dnf install golang
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
```

### ⚪ Arch Linux
```bash
sudo pacman -Syu subfinder bind whois python-pip
pip install shodan theHarvester
# Pro-tip: Use the AUR for specialized tools
yay -S maltego-community
```

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth
**Root Cause:** The fundamental reason OSINT is effective is the **Lack of Data Minimization** and **Misconfigured Cloud/DNS Policies**. Organizations often prioritize "Functionality" over "Information Obfuscation."

### Remediation Checklist:
- [ ] **DNS Hardening:** Implement `DNSSEC` and disable zone transfers (`AXFR`) on public-facing nameservers.
- [ ] **WHOIS Privacy:** Enable WHOIS privacy protection to hide registrant contact details.
- [ ] **Robots.txt Tuning:** Use `Robots.txt` to prevent indexing, but avoid listing sensitive paths (as attackers read this file first).
- [ ] **Metadata Stripping:** Implement automated pipelines to strip EXIF data from public-facing assets/images.
- [ ] **Cloud Storage:** Enforce IAM policies to prevent public `S3` or `Azure Blob` listing.

---

## 🔍 Threat Actor Profiling & MITRE Mapping
Passive Recon is the "Phase 0" for every Advanced Persistent Threat (APT).

*   **Threat Actor Profile:** **APT29 (Cozy Bear)** – Known for extensive OSINT to craft pixel-perfect spear-phishing campaigns.
*   **MITRE ATT&CK Mapping:**
    *   **TA0043 (Reconnaissance):** The primary tactic.
    *   **T1592 (Gather Victim Host Information):** Identifying OS/Hardware via Shodan.
    *   **T1593 (Search Open Technical Databases):** Using CT Logs and Search Engines.
    *   **T1594 (Search Victim-Owned Websites):** Crawling for employee names/emails.

---

## 🎮 Gamified Labs & Simulation Training
*   **TryHackMe: [Google Dorking](https://tryhackme.com/room/googledorking)** (Difficulty: Easy) - Mastering the art of the search query.
*   **HackTheBox: [OSINT Analysis](https://app.hackthebox.com/challenges/osint)** (Difficulty: Medium) - Real-world scenarios involving social media tracking.
*   **OSINT Combine: [Verification Challenge](https://www.osintcombine.com/challenges)** (Difficulty: Advanced) - Deep-web forensic analysis.

---

## 📊 GRC & Compliance Mapping
OSINT isn't just for hackers; it’s a compliance requirement for risk assessment.
*   **NIST CSF (ID.RA-1):** Asset identification starts with understanding what the world can see.
*   **ISO 27001 (A.12.6.1):** Management of technical vulnerabilities requires monitoring external exposure.
*   **SOC2 (CC3.2):** Risk assessment processes must identify threats; OSINT identifies the "Attack Surface" that threats exploit.

---

## 🧪 Verification & Validation (The Proof)
Validate your hardening by running these "Attacker-View" audits:
```bash
# Verify DNS Zone Transfer is blocked (Should return 'Transfer Failed')
dig axfr @ns1.targetdomain.com targetdomain.com

# Check for leaked subdomains via CT Logs
curl -s "https://crt.sh/?q=%25.targetdomain.com&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u

# Audit your own IP for open ports via Shodan (Passive)
shodan host [Your-Public-IP]
```

---

## 🛠️ Lab Report: What We Mastered
> Today I stopped being a 'Script Kiddie' and started being a 'Script Creator.' Built a custom Bash security auditor that automatically hunts for misconfigured permissions, weak SSH settings, and suspicious Cron Jobs across my Arch system. Mastered 'grep', 'awk', and 'sed' to slice through massive log files like a katana. Automation is the real superpower—why spend 2 hours auditing a server manually when a 2-second script can find the same cracks? The Zenith Protocol is getting faster every day.

**Tools Leveraged:**
*   `Subfinder`: Rapid subdomain enumeration.
*   `TheHarvester`: Scraped emails and hostnames from 20+ sources.
*   `Shodan API`: Identified "Low Hanging Fruit" (unquoted service paths/open DBs).
*   `Custom Bash Script`: *ZenithAuditor.sh* (Internal Tool).

---

## 🚨 Real-World Breach Case Study: The 2021 Twitch Leak
**The Incident:** An anonymous poster leaked 125GB of Twitch data, including the entirety of their source code and creator payout data.
**OSINT Role:** Before the breach, attackers used OSINT to map Twitch’s GitHub repositories and identify misconfigured internal servers. The "Initial Access" was facilitated by a server misconfiguration that was visible to anyone using passive scanning techniques (metadata leakage).
**Lesson:** If you can see it via OSINT, so can the adversary.

---

## 💡 Senior Researcher Insights & Future Trends
1.  **Pro-Tip: API-First Recon.** Stop using web UIs. Integrate Shodan, BinaryEdge, and Hunter.io APIs into your scripts for real-time alerts on new assets.
2.  **Pro-Tip: The 'Favicon' Trick.** Use the MMH3 hash of a company's favicon to find hidden IP addresses running the same web service via Shodan (`http.favicon.hash:-12345678`).
3.  **Pro-Tip: Historical WHOIS.** If a target has masked their data, check historical WHOIS records from 5 years ago. Humans often forget to redact data during the first year of registration.
4.  **Future Trend: AI-Driven Synthetic OSINT.** We are entering an era where AI will automatically correlate social media posts with technical leaks to predict which employee is most likely to be a "Phishing Hook."

---

## 🎁 Free Web Resources & Official Documentation
*   **[OSINT Framework](https://osintframework.com/):** The ultimate directory for investigative tools.
*   **[IntelTechniques (Michael Bazzell)](https://inteltechniques.com/):** The gold standard for privacy and OSINT.
*   **[ProjectDiscovery Documentation](https://docs.projectdiscovery.io/):** For mastering `subfinder` and `naabu`.
*   **[Bellingcat Investigation Toolkit](https://www.bellingcat.com/resources/2021/11/09/bellingcats-online-investigation-toolkit/):** High-level investigative journalism techniques.
