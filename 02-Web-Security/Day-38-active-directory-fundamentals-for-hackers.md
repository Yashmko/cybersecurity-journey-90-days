# 🏛️ Master-Level Handbook: Active Directory Fundamentals for Hackers
**Author:** Senior Cybersecurity Architect & Mentor  
**Focus:** Internal Network Identity Architecture & Exploitation Foundations  
**Target Audience:** Security Researchers, Pen-testers, and DevSecOps Engineers  

---

## 🔬 Technical Deep Dive & Theory

Active Directory (AD) is not just a database; it is a **multi-tiered identity ecosystem** built on three pillars: **Authentication (Who are you?), Authorization (What can you do?), and Management (Group Policy).**

### 1. The Trinity of AD Protocols
*   **LDAP (Lightweight Directory Access Protocol):** The phonebook of the network. It tracks objects (users, computers, groups) and their attributes.
*   **Kerberos:** The "Ticket-Based" gatekeeper. It avoids sending passwords over the wire by using encrypted tickets (TGT/TGS) issued by the Key Distribution Center (KDC).
*   **NTLM (NT LAN Manager):** The legacy challenge-response protocol. While deprecated by Microsoft, it remains ubiquitous for compatibility, making it a prime target for "Relay" and "Pass-the-Hash" attacks.

### 2. The Logical Structure
AD operates on a hierarchy: **Forests > Domains > OUs (Organizational Units)**. The security boundary is technically the **Forest**, not the Domain. Understanding "Trust Relationships" between these entities is how attackers move from a compromised branch office to the corporate headquarters.

---

## 💻 Universal Implementation (The 'How-To')
To interact with AD from a Linux-based attack platform, we must bridge the gap between Unix sockets and Windows protocols.

### 🔵 Debian/Ubuntu/Kali
```bash
# Install core toolkit
sudo apt update && sudo apt install -y python3-pip impacket-scripts bloodhound.py neo4j
# Install NetExec (The modern successor to CrackMapExec)
pip install netexec
```

### 🔴 RHEL/Fedora
```bash
# Install dependencies
sudo dnf install -y python3-pip python3-devel openldap-devel
pip install impacket netexec bloodhound
```

### ⚪ Arch Linux
```bash
# Use pacman for base and AUR for specialized tools
sudo pacman -S impacket python-pip neo4j
yay -S bloodhound-bin netexec
```

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth

### Why AD Environments Fall
1.  **Over-privileged Service Accounts:** Running SQL or IIS as a Domain Admin.
2.  **Legacy Protocol Support:** Allowing NTLMv1 or LLMNR/NBT-NS.
3.  **Lack of Network Segmentation:** A compromised HR laptop should never have a direct route to the Domain Controller (DC).

### 📋 Remediation Checklist
- [ ] **Enforce SMB Signing:** Prevents NTLM Relay attacks.
- [ ] **Implement Tiered Administration:** Admins only log into systems of their same tier (Tier 0 for DCs, Tier 1 for Servers, Tier 2 for Workstations).
- [ ] **Disable LLMNR/NetBIOS:** Mitigates poisoning attacks via Responder.
- [ ] **Enable LDAP Signing/Binding:** Prevents cleartext credential harvesting.

---

## 🔍 Threat Actor Profiling & MITRE Mapping

| Threat Actor | Typical Objective | Primary Technique |
| :--- | :--- | :--- |
| **APT29 (Cozy Bear)** | Espionage/Persistence | Golden Ticket/Silver Ticket generation |
| **FIN7** | Financial Theft | Service Principal Name (SPN) Scanning / Kerberoasting |
| **Lapsus$** | Extortion/Data Theft | Social Engineering to bypass MFA + AD Privilege Escalation |

### MITRE ATT&CK Mapping
*   **T1087.002:** Account Discovery (Domain Account)
*   **T1558.003:** Steal or Forge Kerberos Tickets (Kerberoasting)
*   **T1484.001:** Domain Policy Modification (Group Policy Modification)

---

## 🎮 Gamified Labs & Simulation Training

*   **TryHackMe: "Attackative Directory"** (Difficulty: Medium)
    *   *Focus:* Enumeration, AS-REP Roasting, and Hashcat.
*   **HackTheBox: "Forest"** (Difficulty: Easy/Medium)
    *   *Focus:* Mastering bloodhound and manual Kerberoasting.
*   **HackTheBox Academy: "Active Directory Enumeration"** (Difficulty: Professional)
    *   *Focus:* Deep dive into LDAP queries and bloodhound analysis.

---

## 📊 GRC & Compliance Mapping

*   **NIST CSF (PR.AC-4):** Access control policy is managed and system access is granted based on the principle of least privilege.
*   **ISO 27001 (A.9.2.2):** User access provisioning (ensuring the lifecycle of an AD account is documented).
*   **SOC2 (CC6.1):** The entity restricts logical access to confidential information to authorized users.

**Business Impact:** A single AD compromise results in **Total Identity Failure**, leading to complete data exfiltration, ransomware deployment, and regulatory fines exceeding millions of dollars.

---

## 🧪 Verification & Validation (The Proof)

To verify if your hardening worked, run these commands from your attack machine:

**1. Check for SMB Signing (Required = Secure):**
```bash
nxc smb <Target_IP> --gen-relay-list relay.txt
# If the output shows "signing: True", relaying is mitigated.
```

**2. Test for Anonymous LDAP Bind:**
```bash
ldapsearch -x -h <DC_IP> -s base namingContexts
# If results return without a password, your LDAP is misconfigured.
```

---

## 🛠️ Lab Report: What We Mastered

> **Today I shifted focus from external web applications to internal networks, diving into Active Directory (AD) fundamentals. Instead of just reading theory, I spun up a local vulnerable domain environment to analyze how LDAP, NTLM, and Kerberos operate on the wire. Using `netexec` from my Arch terminal, I performed initial SMB enumeration to map out domain controllers, password policies, and accessible shares. I also gathered routing data and ingested it into BloodHound to visualize user privileges and nested groups. This foundational mapping made it immediately clear how seemingly minor permission misconfigurations create devastating attack paths, perfectly setting the stage for actual exploitation.**

**Tools Used:**
*   **NetExec (NXC):** Multi-protocol enumeration tool.
*   **BloodHound:** Graph-theory based AD relationship mapper.
*   **Impacket:** A collection of Python classes for working with network protocols.
*   **Neo4j:** Graph database backend for BloodHound.

---

## 🚨 Real-World Breach Case Study: NotPetya (2017)
**CVEs involved:** CVE-2017-0144 (EternalBlue)
**Analysis:** While NotPetya used an SMB exploit to spread, its true power lay in its ability to steal AD credentials from memory using Mimikatz-like logic. Once it gained a Domain Admin credential on one machine, it used native AD tools (PsExec/WMI) to push the malware to every other machine in the forest.
**Lesson:** Patching the exploit isn't enough if your AD architecture allows a single credential to control the entire network.

---

## 💡 Senior Researcher Insights & Future Trends

1.  **Pro-Tip: "Telemetry over Tools":** Don't just learn how to run `mimikatz`. Learn what Event ID 4624 (Logon) looks like in the logs when a Pass-the-Hash attack occurs.
2.  **Pro-Tip: "The Power of the SPN":** Service Principal Names are an attacker's best friend. If you find an account with an SPN, you can request a ticket and crack it offline (Kerberoasting). No traffic touches the DC after the initial request.
3.  **Pro-Tip: "Clean Source Principle":** Always assume your AD is compromised if you are managing it from an internet-connected workstation. Use dedicated Jump Servers.
4.  **Future Trend: ITDR (Identity Threat Detection and Response):** The industry is moving away from just "End-point" protection toward "Identity" protection. Solutions that look for anomalous LDAP queries or "impossible travel" in AD logons are the next frontier.

---

## 🎁 Free Web Resources & Official Documentation
*   **ADSecurity.org:** [Sean Metcalf's AD Security Blog](https://adsecurity.org/) (The Gold Standard).
*   **The BloodHound Gang Slack:** Community for AD researchers.
*   **Microsoft Learn:** [Active Directory Domain Services Documentation](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/active-directory-domain-services).
*   **Harmj0y’s Blog:** [SpecterOps Insights](https://posts.specterops.io/) on AD Tradecraft.
