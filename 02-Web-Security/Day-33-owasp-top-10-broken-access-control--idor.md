# 📑 MASTER-LEVEL HANDBOOK: OWASP Top 10 – Broken Access Control & IDOR

**Date:**  OWASP top 10 based on October 26, 2023  
**Subject:** Advanced Authorization Vulnerabilities and Secure Architectural Design  
**Author:** Cybersecurity Architect & Mentor  
**Classification:** Technical / Instructional

---

## 🔬 Technical Deep Dive & Theory
At its core, **Broken Access Control (BAC)** is a failure of the **Authorization** layer. While Authentication verifies *identity*, Authorization determines *permissions*.

**Insecure Direct Object References (IDOR)**—now categorized under Broken Access Control—occurs when an application uses user-supplied input to access objects directly without an authorization check.

### The Architectural Flaw:
1.  **Direct Exposure:** The backend exposes internal database keys or file paths (e.g., `?id=101`) directly in the URL or API payload.
2.  **Lack of Ownership Validation:** The system verifies the user is logged in (Authentication) but fails to verify if the user *owns* the requested resource (Authorization).
3.  **Horizontal vs. Vertical Escalation:** 
    *   **Horizontal:** Accessing another user's data of the same privilege level (User A viewing User B's invoices).
    *   **Vertical:** Accessing functions or data of a higher privilege level (User A accessing `/admin/delete_user`).

---

## 💻 Universal Implementation (The 'How-To')
To hunt or defend against BAC, you must configure a local auditing environment across major Linux distributions.

### 🔵 Debian/Ubuntu/Kali
```bash
# Update and Install Apache/PHP Environment
sudo apt update && sudo apt install -y apache2 php libapache2-mod-php php-mysql
# Install Security Auditing Tools
sudo apt install -y burpsuite gobuster ffuf
# Configure Directory Permissions
sudo chown -R www-data:www-data /var/www/html/
```

### 🔴 RHEL/Fedora
```bash
# Install LAMP Stack
sudo dnf install -y httpd php php-mysqlnd
# Enable and start the service
sudo systemctl enable --now httpd
# Install Recon tools (requires EPEL for some)
sudo dnf install -y nmap
# Adjust SELinux for web traffic (Crucial for RHEL)
sudo setsebool -P httpd_can_network_connect 1
```

### ⚪ Arch Linux
```bash
# Update System and Install Core
sudo pacman -Syu apache php php-apache
# Note: Arch requires manual editing of /etc/httpd/conf/httpd.conf 
# to load 'mod_php.so' and 'php7_module'
sudo pacman -S burpsuite ffuf gobuster
# Start Service
sudo systemctl start httpd
```

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth
**Root Cause:** Trusting client-side input as the source of truth for resource ownership.

### Remediation Checklist:
1.  [ ] **Adopt Principle of Least Privilege (PoLP):** Deny by default.
2.  [ ] **Centralized Access Control:** Use a single, proven library/middleware for authorization; avoid "ad-hoc" checks in every route.
3.  [ ] **Use Indirect References:** Map internal IDs to non-sequential **UUIDs** (Universally Unique Identifiers) or hash-based tokens.
4.  [ ] **Server-Side Validation:** *Every* request must re-verify ownership. `SELECT * FROM invoices WHERE id = ? AND user_id = current_session_user;`
5.  [ ] **Disable Directory Browsing:** Prevent discovery of hidden files/endpoints.

---

## 🔍 Threat Actor Profiling & MITRE Mapping
| Actor Type | Motivation | Skill Level | Typical Technique |
| :--- | :--- | :--- | :--- |
| **Script Kiddie** | Notoriety / Chaos | Low | Automated IDOR fuzzing using Burp Intruder. |
| **Malicious Insider** | Revenge / Profit | High | Exploiting legitimate credentials to access peer data. |
| **State-Sponsored** | Intelligence Gathering | Expert | Surgical extraction of sensitive citizen records via API flaws. |

### MITRE ATT&CK Mapping:
*   **T1548:** Abuse Elevation Control Mechanism
*   **T1068:** Exploitation for Privilege Escalation
*   **T1567:** Exfiltration Over Web Service

---

## 🎮 Gamified Labs & Simulation Training
| Platform | Challenge Name | Difficulty | Focus |
| :--- | :--- | :--- | :--- |
| **TryHackMe** | [IDOR](https://tryhackme.com/room/idor) | 🟢 Easy | Basic parameter manipulation. |
| **HackTheBox** | [Love](https://app.hackthebox.com/machines/Love) | 🟠 Medium | SSRF and IDOR to gain initial access. |
| **PortSwigger** | [Access Control Labs](https://portswigger.net/web-security/access-control) | 🔴 Hard | Expert-level multi-stage bypasses. |

---

## 📊 GRC & Compliance Mapping
*   **NIST CSF:** PR.AC-1 (Access Control Policy), PR.AC-4 (Access Control Enforcement).
*   **ISO 27001:** Annex A.9 (Access Control Management).
*   **SOC2:** Common Criteria 6.0 (Logical and Physical Access Controls).
*   **Business Impact:** High likelihood of **GDPR/CCPA** violations, resulting in fines up to 4% of global turnover or $2,500-$7,500 per record breached.

---

## 🧪 Verification & Validation (The Proof)
To verify if a fix is successful, use `curl` to attempt cross-account access:

```bash
# Attempting to access User 101's data while logged in as User 105
# SUCCESSFUL DEFENSE: Should return 403 Forbidden or 404 Not Found
curl -X GET "https://api.target.com/v1/profile/101" \
     -H "Authorization: Bearer <User_105_Token>" \
     -i
```

---

## 🛠️ Lab Report: What We Mastered
> **Today’s focus was on authorization vulnerabilities, specifically Broken Access Control and IDOR (Insecure Direct Object References). I spun up a local lab environment to manually hunt for parameter manipulation flaws. By intercepting API requests in Burp Suite, I modified sequential user IDs and predictable document references, successfully demonstrating horizontal privilege escalation to access restricted data. I also tested vertical escalation by forcing access to hidden administrative endpoints. This session reinforced a critical security principle: simply hiding UI elements is useless; access controls and object ownership must be rigorously validated server-side for every single request.**

**Tools Used:**
*   **Burp Suite Professional:** Request interception and repeater for parameter tampering.
*   **Ffuf (Fuzz Faster U Fool):** Directory and parameter discovery.
*   **Postman:** API testing and header manipulation.
*   **OWASP ZAP:** Automated vulnerability scanning for baseline identification.

---

## 🚨 Real-World Breach Case Study: First American Financial (2019)
**The Incident:** First American Financial leaked **885 million** sensitive records (bank account numbers, social security digits).
**Technical Cause:** A classic IDOR. Their web portal allowed access to documents by simply changing a sequential ID in the URL. There was no validation that the person requesting the document was the one it belonged to.
**Lesson Learned:** Scalability requires automation, and automation without centralized authorization leads to catastrophic data exposure.

---

## 💡 Senior Researcher Insights & Future Trends
1.  **Pro-Tip: Avoid "Security by Obscurity."** Changing `/admin` to `/admin_123_xyz` is not security. If the endpoint doesn't check for an Admin role, it is vulnerable.
2.  **Pro-Tip: Log Authorization Failures.** Frequent 403 errors from a single IP are a "canary in the coal mine" indicating an active IDOR fuzzing attempt.
3.  **Pro-Tip: UUID v4 is your friend.** While not a replacement for ACLs, using non-guessable identifiers makes bulk scraping significantly harder for attackers.

**Future Trend:** **Policy-as-Code (PaC).** With tools like **Open Policy Agent (OPA)**, we are moving toward decoupled authorization where security policies are written as code and evaluated via API, ensuring consistency across microservices.

---

## 🎁 Free Web Resources & Official Documentation
*   **OWASP Top 10:** [A01:2021-Broken Access Control](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)
*   **PortSwigger Academy:** [Access Control Vulnerabilities](https://portswigger.net/web-security/access-control)
*   **CWE-639:** [Insecure Direct Object Reference (IDOR)](https://cwe.mitre.org/data/definitions/639.html)
