# 🧠 Master-Level Handbook: Exploiting & Securing Cloud Identities (S3 & IAM)
**Version:** 1.0 | **Author:** Senior Cybersecurity Architect | **Classification:** Master Portfolio Series

---

## 🔬 Technical Deep Dive & Theory
In the cloud, **Identity is the new Perimeter.** Unlike traditional networks where a firewall acts as a moat, cloud security relies on the interaction between **Principals** (Users/Roles) and **Resources** (S3 Buckets).

### The "Toxic Combination" Logic:
1.  **S3 Misconfiguration:** A resource-based policy allows `s3:ListBucket` or `s3:GetObject` to `AllUsers` (Public) or `AuthenticatedUsers` (Any AWS account).
2.  **IAM Over-Privilege:** An EC2 instance or Lambda function is assigned a role with more permissions than necessary (e.g., `AdministratorAccess` instead of `S3ReadOnly`).
3.  **The Pivot:** A threat actor finds a public S3 bucket, discovers an AWS Access Key or a script containing credentials, or exploits a web vulnerability (SSRF) to query the **Instance Metadata Service (IMDS)** to steal temporary IAM credentials.

---

## 💻 Universal Implementation (The 'How-To')
To audit or exploit these environments, you need the **AWS CLI** and specialized tools.

### 🔵 Debian/Ubuntu/Kali
```bash
sudo apt update && sudo apt install awscli -y
pip install prowler pacu
```

### 🔴 RHEL/Fedora
```bash
sudo dnf install awscli -y
pip install prowler pacu
```

### ⚪ Arch Linux
```bash
sudo pacman -S aws-cli
yay -S prowler-git pacu-git
```

### The "Execution Flow" (Manual Discovery):
1.  **Enumerate Public Buckets:**
    `aws s3 ls s3://[target-bucket-name] --no-sign-request`
2.  **Exfiltrate Data:**
    `aws s3 cp s3://[target-bucket-name]/config.php . --no-sign-request`
3.  **Query Metadata (If inside an EC2 via SSRF):**
    `curl http://169.254.169.254/latest/meta-data/iam/security-credentials/[role-name]`

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth
### Root Causes:
*   **Shadow IT:** Developers creating buckets for quick testing and forgetting to set "Block Public Access."
*   **IAM Bloat:** Attaching managed policies (like `PowerUserAccess`) to roles that only need access to a single S3 folder.
*   **Legacy IMDS:** Using IMDSv1 which is vulnerable to Server-Side Request Forgery (SSRF).

### Remediation Checklist:
- [ ] **Enable S3 Block Public Access** at the account level.
- [ ] **Enforce IMDSv2** (Session-oriented) on all EC2 instances.
- [ ] **Implement Service Control Policies (SCPs)** to restrict sensitive API calls (e.g., `iam:CreateUser`) across the entire organization.
- [ ] **Encrypt at Rest:** Use AWS KMS with Customer Master Keys (CMKs).

---

## 🔍 Threat Actor Profiling & MITRE Mapping
| Actor Type | Motivation | Primary Technique |
| :--- | :--- | :--- |
| **Initial Access Broker** | Financial Gain | Scanning for public buckets to sell access. |
| **Ransomware Groups** | Extortion | Data exfiltration via S3 + deleting backups. |

### MITRE ATT&CK Mapping:
*   **T1530:** Data from Cloud Storage (S3 Discovery/Exfiltration).
*   **T1078.004:** Valid Accounts: Cloud Accounts (IAM Role Assumption).
*   **T1552.005:** Unsecured Credentials: Cloud Instance Metadata.

---

## 🎮 Gamified Labs & Simulation Training
| Platform | Lab Name | Difficulty | Focus |
| :--- | :--- | :--- | :--- |
| **TryHackMe** | *Cloud Breaker* | 🟠 Medium | S3 Buckets & IAM misconfigs. |
| **HackTheBox** | *Bucket* | 🟠 Medium | S3 Web-root poisoning. |
| **flaws.cloud** | *Level 1-6* | 🟢 Beginner | Foundational AWS security. |
| **CloudGoat** | *iam_privesc_by_rollback* | 🔴 Expert | Advanced IAM exploitation by Rhino Security. |

---

## 📊 GRC & Compliance Mapping
Misconfigured S3/IAM is a direct violation of:
*   **NIST SP 800-53:** AC-6 (Least Privilege) & IA-2 (Identification/Authentication).
*   **ISO 27001:** Annex A.9 (Access Control).
*   **SOC 2 Type II:** Common Criteria (CC6.1) – Access Transmission and Unauthorized Access.
*   **Business Impact:** Potential GDPR/CCPA fines exceeding $20M or 4% of global turnover for data exposure.

---

## 🧪 Verification & Validation (The Proof)
To prove the fix works, run these commands:

1.  **Verify S3 Public Access Block:**
    `aws s3api get-public-access-block --bucket [your-bucket-name]`
    *Result should return `True` for all fields.*

2.  **Audit IAM Privileges (Prowler):**
    `prowler aws --check 1.22` (Checks for over-privileged roles).

---

## 🛠️ Lab Report: What We Mastered
*   **Concept:** Cloud Identity Pivot (SSRF → IMDS → IAM → S3).
*   **Tools Used:** `aws-cli`, `prowler`, `pacu`, `Burp Suite`.
*   **Outcome:** Successfully demonstrated how a single misconfigured IAM policy allows a low-privilege web shell to escalate to an AWS Global Administrator.

---

## 🚨 Real-World Breach Case Study: Capital One (2019)
*   **The Hack:** A threat actor exploited an SSRF vulnerability on a web application firewall (WAF) running on EC2.
*   **The Pivot:** The WAF’s IAM Role was over-privileged. The attacker queried IMDSv1 to obtain credentials.
*   **The Payload:** The attacker used those credentials to run `s3:ListBuckets` and `s3:Sync`, exfiltrating 100 million credit card applications.
*   **The Lesson:** If the IAM role had followed the **Principle of Least Privilege**, the stolen credentials would have been useless for accessing S3.

---

## 💡 Senior Researcher Insights & Future Trends
1.  **Pro-Tip: Use Permission Boundaries.** Don't just set an IAM Policy; set a *Boundary* that acts as a maximum ceiling for what a user can *ever* do, regardless of the policies attached.
2.  **Pro-Tip: Monitor CloudTrail.** Any `s3:ListBuckets` call from an unexpected IP or a spike in `AssumeRole` events should trigger an automated PagerDuty alert.
3.  **Pro-Tip: Pre-Signed URLs.** Never make a bucket public. Use temporary Pre-Signed URLs for sharing data securely.
4.  **Future Trend: CIEM (Cloud Infrastructure Entitlement Management).** The future is AI-driven identity governance that automatically "right-sizes" permissions based on actual usage patterns, eliminating over-privilege without human intervention.

---

## 🎁 Free Web Resources & Official Documentation
*   [AWS Security Best Practices](https://docs.aws.amazon.com/whitepapers/latest/aws-security-best-practices/aws-security-best-practices.pdf)
*   [Rhino Security Labs - CloudGoat](https://github.com/RhinoSecurityLabs/cloudgoat)
*   [Prowler Open Source Security Tool](https://github.com/prowler-cloud/prowler)
*   [OWASP Cloud-Native Security Project](https://owasp.org/www-project-cloud-native-security/)
