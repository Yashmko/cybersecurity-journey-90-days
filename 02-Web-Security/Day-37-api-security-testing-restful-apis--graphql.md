# 📘 Master-Level Handbook: Advanced API Security & Offensive Testing
**Author:** Senior Cybersecurity Architect & Mentor
**Focus:** RESTful Architectures & GraphQL Query Languages
**Version:** 1.0 (Master Series)

---

## 🔬 Technical Deep Dive & Theory
Modern application security has shifted from the "Perimeter" to the "Interface." While traditional web apps render HTML, APIs (REST & GraphQL) exchange raw data.

### 1. REST (Representational State Transfer)
REST relies on **statelessness** and **standard HTTP methods** (GET, POST, PUT, DELETE). The security flaw isn't usually in the protocol, but in the **Logic Layer**. The most critical vulnerability is **BOLA (Broken Object Level Authorization)**, where the application validates *who* you are but fails to check *what* you should access.

### 2. GraphQL (The Graph)
Unlike REST's multiple endpoints, GraphQL uses a **single endpoint** (usually `/graphql`). 
*   **Introspection:** A feature that allows clients to query the schema. If enabled in production, it's a blueprint for attackers.
*   **Mutations:** The GraphQL equivalent of POST/PUT. Without strict validation, these allow unauthorized data modification.
*   **Depth/Complexity:** Nested queries can lead to Denial of Service (DoS) via "Resource Exhaustion."

---

## 💻 Universal Implementation (The 'How-To')
To test these, you need a standardized toolkit across environments.

### 🔵 Debian/Ubuntu/Kali
```bash
sudo apt update && sudo apt install -y ffuf golang-go burpsuite
# Install GraphQL specific tools
go install github.com/doyensec/inql@latest
go install github.com/proabere/graphw00f@latest
```

### 🔴 RHEL/Fedora
```bash
sudo dnf install -y ffuf golang burpsuite
# Paths for Go binaries
export PATH=$PATH:$(go env GOPATH)/bin
```

### ⚪ Arch Linux
```bash
sudo pacman -Syu ffuf go burpsuite
# Community-driven GraphQL tools via AUR
yay -S inql-git
```

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth
### The Root Cause: "Implicit Trust"
Developers often assume that if a user has a valid JWT (JSON Web Token), they are authorized for all resources. This is the **AuthN vs. AuthZ** fallacy.

### Remediation Checklist:
1.  **Zero-Trust Authorization:** Implement a centralized authorization module. Never trust the `user_id` passed in the URL; pull it from the secure session/token.
2.  **Schema Validation:** For GraphQL, use **Allow-listing** for queries. Disable Introspection in production.
3.  **Rate Limiting:** Implement non-linear rate limiting (exponential backoff) to prevent fuzzing and brute-force.
4.  **Data Masking:** Ensure the API doesn't return more data than the UI requires (Preventing Excessive Data Exposure).

---

## 🔍 Threat Actor Profiling & MITRE Mapping
| Threat Actor | Motivation | Typical Technique |
| :--- | :--- | :--- |
| **Cyber Criminals** | Financial Gain | BOLA for PII harvesting/Resale. |
| **State-Sponsored** | Espionage | GraphQL Introspection to find undocumented admin hooks. |
| **Hacktivists** | Disruption | Resource Exhaustion (DoS) via nested GraphQL queries. |

### MITRE ATT&CK Mapping:
*   **T1595.002:** Active Scanning: Vulnerability Scanning (API Fuzzing).
*   **T1059:** Command and Scripting Interpreter (GraphQL Mutations).
*   **T1539:** Steal Web Session Cookie (JWT Hijacking).

---

## 🎮 Gamified Labs & Simulation Training
*   **TryHackMe: "API Hackery"** (Difficulty: Medium) – Great for REST basics.
*   **HackTheBox: "Pentesting REST APIs"** (Difficulty: Hard) – Focuses on BOLA and Mass Assignment.
*   **OWASP Juice Shop** (Difficulty: Adaptive) – Use the "NoSQL Injection" and "BOLA" challenges.
*   **VAmPI (Vulnerable API)** – A self-hosted Docker lab specifically for OWASP API Top 10.

---

## 📊 GRC & Compliance Mapping
API Security is no longer optional; it is a regulatory requirement:
*   **NIST CSF (PR.AC-4):** Access Control. APIs must enforce "Least Privilege."
*   **ISO 27001 (A.14.2):** Security in development and support processes.
*   **SOC2 (Trust Services Criteria):** Confidentiality and Privacy controls via API encryption and authorization.
*   **Business Impact:** A single API breach (e.g., Optus) can result in millions in fines and a 10-15% drop in stock valuation.

---

## 🧪 Verification & Validation (The Proof)
How do we know the fix worked?
```bash
# 1. Verify Introspection is disabled (GraphQL)
graphw00f -u https://api.target.com/graphql -d

# 2. Verify BOLA Fix (REST)
# Attempt to access ID 1001 while logged in as ID 1002
curl -H "Authorization: Bearer <User_1002_Token>" https://api.target.com/v1/users/1001
# SUCCESS: Should return 403 Forbidden or 404 Not Found.
```

---

## 🛠️ Lab Report: What We Mastered
**Executive Summary:** Pivoted to API security today. Started by fuzzing for hidden REST endpoints with `ffuf` and manually testing for BOLA (Broken Object Level Authorization) by swapping resource IDs in Burp Repeater. Then I moved to GraphQL—managed to dump the entire backend schema using an Introspection query, which exposed several undocumented administrative mutations. Realized pretty quickly that APIs are an absolute goldmine if developers rely purely on top-level authentication and forget to implement strict object-level validation.

**Tools Used:** 
*   `ffuf`: Directory and parameter discovery.
*   `Burp Suite Professional`: Intercepting and modifying IDOR/BOLA payloads.
*   `InQL`: GraphQL schema visualization.
*   `Postman`: Documenting identified endpoints for exploitation.

---

## 🚨 Real-World Breach Case Study: Optus (2022)
**The Incident:** An unauthenticated API endpoint was exposed to the internet.
**The Vulnerability:** It did not require any authentication and allowed sequential ID harvesting (BOLA).
**The Outcome:** Data of nearly 10 million customers was stolen. 
**Architect's Note:** This was a "Shadow API"—a legacy version that was left online and forgotten. **Inventory Management** is a security control.

---

## 💡 Senior Researcher Insights & Future Trends
1.  **Pro-Tip: Use the "Referer" check.** While not a primary defense, checking the Referer header can help identify unauthorized cross-origin API calls.
2.  **Pro-Tip: Fuzz the Content-Type.** Change `application/json` to `application/xml` or `text/plain`. Sometimes backends are configured to parse multiple types, leading to injection vulnerabilities.
3.  **Pro-Tip: Watch for "Mass Assignment."** If an API allows `PUT /user/settings`, try adding `"role": "admin"` to the JSON body.
4.  **Future Trend: AI-Enhanced WAFs.** We are moving toward "Positive Security Models" where AI learns the legitimate schema of an API and blocks any request that deviates—making traditional fuzzing much harder.

---

## 🎁 Free Web Resources & Official Documentation
*   **OWASP API Security Top 10:** [https://owasp.org/www-project-api-security/](https://owasp.org/www-project-api-security/)
*   **GraphQL Security Best Practices:** [https://graphql.org/learn/security/](https://graphql.org/learn/security/)
*   **APIsecurity.io:** Weekly newsletter for the latest API vulnerabilities.
*   **Microsoft Azure API Management Security Guide:** (Standard for Cloud Architects).
