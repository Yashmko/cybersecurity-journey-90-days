# 📘 Master-Level Technical Handbook: Cross-Site Scripting (XSS)
**Authored by:** [Your Name/Senior Cybersecurity Architect]
**Focus:** Stored, Reflected, & DOM-based Vulnerabilities

---

## 🔬 Technical Deep Dive & Theory
At its core, **Cross-Site Scripting (XSS)** is an injection attack where malicious scripts are injected into otherwise benign and trusted websites. The vulnerability exists when a web application includes untrusted data in a web page without proper validation or escaping.

### The Three Pillars of XSS:
1.  **Reflected XSS (Non-Persistent):** The script is "reflected" off a web application to the victim's browser. It is usually delivered via a link (e.g., in an email or chat). The payload is part of the HTTP request.
2.  **Stored XSS (Persistent):** The most dangerous form. The script is permanently stored on the target server (in a database, forum post, comment field, etc.). When a victim views the affected page, the script executes automatically.
3.  **DOM-based XSS:** The vulnerability exists in the client-side code rather than server-side code. The attack occurs when the application contains client-side JavaScript that processes data from an untrusted source in an unsafe way, usually by writing the data back to the Document Object Model (DOM).

**The Logic Chain:**
`Source (Untrusted Input)` -> `Processing (Lack of Sanitization/Encoding)` -> `Sink (Execution Point)`

---

## 💻 Universal Implementation (The 'How-To')
To analyze and test for XSS, you need a standardized toolkit. Here is how to set up the industry-standard **XSStrike** and **OWASP ZAP** across major distributions.

### 🔵 Debian/Ubuntu/Kali
```bash
sudo apt update && sudo apt install -y python3-pip git zaproxy
git clone https://github.com/s0md3v/XSStrike.git
cd XSStrike && pip3 install -r requirements.txt
```

### 🔴 RHEL/Fedora
```bash
sudo dnf install -y python3-pip git
# ZAP requires manual download or Flatpak on RHEL
git clone https://github.com/s0md3v/XSStrike.git
cd XSStrike && pip3 install -r requirements.txt
```

### ⚪ Arch Linux
```bash
sudo pacman -Syu python-pip git owasp-zap
git clone https://github.com/s0md3v/XSStrike.git
cd XSStrike && pip install -r requirements.txt
```

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth
**Root Cause:** The fundamental failure to maintain a strict boundary between "Data" and "Executable Code." When a browser receives HTML, it cannot distinguish between a legitimate script provided by the developer and a script injected by an attacker.

### The Remediation Checklist:
- [ ] **Context-Aware Output Encoding:** Encode data based on where it’s placed (HTML Body, Attribute, JavaScript variable, CSS).
- [ ] **Implement Content Security Policy (CSP):** Use `Content-Security-Policy: default-src 'self';` to disable inline scripts and restrict script sources.
- [ ] **Use HttpOnly Cookies:** Prevent JavaScript from accessing session cookies via `document.cookie`.
- [ ] **Input Validation:** Use "Allow-lists" for expected formats (e.g., age should only be integers).
- [ ] **Use Safe APIs:** In modern frameworks, use `innerText` instead of `innerHTML` to prevent DOM-based XSS.

---

## 🔍 Threat Actor Profiling & MITRE Mapping
XSS is a staple in the arsenal of both opportunistic attackers and APT groups.

*   **Threat Actors:**
    *   **Financial Gain:** Groups like **Magecart** (using XSS/Injection to inject "web skimmers" into checkout pages).
    *   **State-Sponsored:** **Lazarus Group** (using XSS for initial access and credential harvesting).
*   **MITRE ATT&CK Mapping:**
    *   **T1059.007:** Command and Scripting Interpreter: JavaScript
    *   **T1189:** Drive-by Compromise
    *   **T1539:** Steal Web Session Cookie

---

## 🎮 Gamified Labs & Simulation Training
Recommended path for mastery:

1.  **PortSwigger Web Security Academy (XSS Track):** 
    *   *Difficulty:* Beginner to Advanced.
    *   *Why:* The gold standard for learning DOM-based sinks.
2.  **TryHackMe: Cross-site Scripting:**
    *   *Difficulty:* Easy.
    *   *Focus:* Foundational Reflected/Stored methodology.
3.  **HackTheBox: "Jerry" or "Academy":**
    *   *Difficulty:* Intermediate.
    *   *Focus:* Real-world chaining of XSS to RCE (Remote Code Execution).

---

## 📊 GRC & Compliance Mapping
XSS isn't just a technical bug; it's a compliance failure.
*   **PCI DSS 4.0:** Requirement 6.2.4 mandates protection against injection attacks, specifically XSS.
*   **OWASP Top 10:** Ranked under **A03:2021 – Injection**.
*   **NIST CSF:** Maps to **PR.PT-4** (Information protection processes and procedures are maintained and used).
*   **Business Impact:** Loss of customer PII (Personally Identifiable Information), brand damage, and significant GDPR/CCPA fines.

---

## 🧪 Verification & Validation (The Proof)
How to verify if a fix is successful:

**1. Inspecting Headers for CSP:**
```bash
curl -I https://your-secure-site.com
# Look for: Content-Security-Policy: script-src 'self'
```

**2. Verifying Encoding via CLI:**
Test an input field with `<script>` and check the source code response:
```bash
curl -s "https://api.site.com/search?q=<script>alert(1)</script>" | grep -E "&lt;script&gt;"
# Success: The output is HTML-entity encoded.
```

---

## 🛠️ Lab Report: What We Mastered
> **Today I tackled Cross-Site Scripting (XSS) across Reflected, Stored, and DOM-based vectors.** Instead of relying on simple `alert()` popups, I focused on weaponizing payloads to exfiltrate session cookies and bypass basic WAF filters using varied encoding techniques (Hex, Unicode, and Double Encoding). I also utilized browser developer tools to trace data flow from sources (like `location.hash`) to execution sinks (like `eval()` or `.innerHTML`) for DOM XSS. This practical lab reinforced that context-aware output encoding—not just input sanitization—is the only robust defense against injection.

**Tools Used:**
*   **Burp Suite Professional:** Repeater and Intruder for payload fuzzing.
*   **XSStrike:** For automated polyglot generation.
*   **Mozilla DevTools:** Debugging the JavaScript call stack.
*   **Webhook.site:** To act as a listener for exfiltrated cookies.

---

## 🚨 Real-World Breach Case Study: British Airways (2018)
*   **The Attack:** Magecart actors exploited an XSS vulnerability in a JavaScript library (Feedify) used on the British Airways website.
*   **The Execution:** Attackers modified a script to capture 22 payment card fields and send them to a malicious domain (`bataways.com`).
*   **The Fallout:** Theft of data from 380,000 customers. BA was initially fined **£183 million** (later reduced) under GDPR.
*   **Lesson:** Third-party scripts are a major XSS vector. Use **Subresource Integrity (SRI)**.

---

## 💡 Senior Researcher Insights & Future Trends
1.  **Pro-Tip: Think Beyond `alert()`:** Use `print()` to test for XSS in modern browsers that block `alert()` popups, or use `fetch()` to verify you can actually move data out of the environment.
2.  **Pro-Tip: XSS to CSRF:** Always look to chain XSS with Cross-Site Request Forgery. An XSS vulnerability allows you to bypass CSRF tokens entirely, as the script executes within the victim's session.
3.  **Pro-Tip: Polyglot Payloads:** Master one "Polyglot" payload that works in multiple contexts (HTML, attribute, and JS).
    *   Example: ``javascript:/*--></title></style></textarea></script></xmp><svg/onload='+/"/+/onmouseover='true'/+/[+[]]*[~[static_reply](alert(1))]//'>``
4.  **Future Trend: Client-Side Security Posture (CSPM):** As logic moves to the frontend (React/Next.js), security is shifting to real-time monitoring of DOM changes and automated CSP generation using AI.

---

## 🎁 Free Web Resources & Official Documentation
*   **OWASP XSS Prevention Cheat Sheet:** [Official Guide](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)
*   **PortSwigger Academy:** [XSS Learning Path](https://portswigger.net/web-security/cross-site-scripting)
*   **MDN Web Docs:** [Understanding the DOM](https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model)
*   **Google Bughunter University:** [XSS Guide](https://bughunters.google.com/learn/library/web-vulnerabilities/xss)
