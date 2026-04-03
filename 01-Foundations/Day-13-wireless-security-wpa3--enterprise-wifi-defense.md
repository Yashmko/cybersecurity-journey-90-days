# 📶 Master Handbook: Wireless Security, WPA3, & Enterprise WiFi Defense

**Author:** Bhavishya Mamodiya
**Focus:** Wireless Infrastructure Hardening & Protocol Analysis

---

## 🔬 Technical Deep Dive & Theory

### The Evolution: From WPA2-PSK to WPA3-SAE
For a decade, the **WPA2 4-Way Handshake** was the industry standard, but it suffered from a fundamental flaw: the exposure of the PMK (Pairwise Master Key) during the exchange, allowing for **offline dictionary attacks**.

**WPA3-SAE (Simultaneous Authentication of Equals)** replaces the PSK with the **Dragonfly Key Exchange**. 
- **Zero-Knowledge Proof:** SAE uses a discrete logarithm problem to authenticate without ever sending the password across the air.
- **Forward Secrecy:** Even if an attacker captures the traffic and later discovers the password, they cannot decrypt historical traffic.
- **PMF (Protected Management Frames):** In WPA2, PMF was optional. In WPA3, it is **mandatory**, preventing deauthentication attacks (the "Death Packet").

### Enterprise WiFi (802.1X)
Enterprise defense moves away from "one password for all" to **Identity-Based Networking**.
- **Supplicant:** The client device.
- **Authenticator:** The Access Point (AP).
- **Authentication Server:** Usually a RADIUS server (FreeRADIUS, Cisco ISE) backed by LDAP/Active Directory.
- **EAP-TLS:** The gold standard, utilizing mutual certificate-based authentication.

---

## 💻 Universal Implementation (The 'How-To')

### 🔵 Debian/Ubuntu/Kali
**Configuring WPA3-SAE via `wpa_supplicant`:**
```bash
# Install dependencies
sudo apt update && sudo apt install wpasupplicant wireless-tools -y

# Edit configuration
sudo nano /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
```
*Config Template:*
```conf
network={
    ssid="SECURE_CORP_WPA3"
    proto=RSN
    key_mgmt=SAE
    pairwise=CCMP
    group=CCMP
    ieee80211w=2 # Force PMF
    psk="YourComplexPassword"
}
```

### 🔴 RHEL/Fedora
**Using `nmcli` (Network Manager CLI) for Enterprise 802.1X:**
```bash
sudo dnf install NetworkManager-wifi
nmcli con add type wifi ifname wlan0 con-name EnterpriseWiFi ssid SECURE_SSID \
-- wifi-sec.key-mgmt wpa-eap 802-1x.eap tls 802-1x.identity "user@domain.com" \
802-1x.ca-cert /etc/pki/ca-trust/source/anchors/rootCA.crt \
802-1x.client-cert /home/user/.certs/client.crt \
802-1x.private-key /home/user/.certs/client.key
```

### ⚪ Arch Linux
**Manual control using `iw` and `iwd` (Modern Wireless Daemon):**
```bash
sudo pacman -S iwd
sudo systemctl start iwd
iwctl
# Inside iwctl
[iwd]# device list
[iwd]# station wlan0 scan
[iwd]# station wlan0 connect SECURE_CORP_WPA3
```
*Note: Arch often leads the way in `iwd` adoption, which handles WPA3-SAE more natively than older `wpasupplicant` builds.*

---

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth

### Root Causes of Wireless Breaches
1.  **Legacy Protocol Support:** Allowing WPA1/TKIP for "compatibility."
2.  **Lack of PMF:** Allowing attackers to disconnect users and force them onto "Evil Twins."
3.  **Weak EAP Config:** Allowing MSCHAPv2 without certificate pinning (susceptible to credential relay).

### Remediation Checklist
- [ ] **Disable WPS:** Completely disable Wi-Fi Protected Setup (PIN/Push Button).
- [ ] **Mandate WPA3-SAE:** On hardware that supports it, disable WPA2 mixed mode.
- [ ] **Isolate Guest Networks:** VLAN tagging (802.1Q) to separate guest traffic from the production core.
- [ ] **Certificate Pinning:** Ensure clients validate the RADIUS server certificate.

---

## 🔍 Threat Actor Profiling & MITRE Mapping

| Threat Actor | Motivation | Primary Technique |
| :--- | :--- | :--- |
| **Script Kiddie** | Notoriety/Free WiFi | Deauth Attack / Airgeddon |
| **Industrial Spy** | Intellectual Property | Rogue Access Point / Evil Twin |
| **APT Group** | Persistence/Exfiltration | T1200 - Hardware Additions (Pineapple) |

### MITRE ATT&CK Mapping
*   **T1557.002:** Adversary-in-the-Middle (Wi-Fi)
*   **T1040:** Network Sniffing
*   **T1456:** Rogue Access Point
*   **T1539:** Stealing Web Session Cookie (via unencrypted public WiFi)

---

## 🎮 Gamified Labs & Simulation Training

*   **TryHackMe:** *WiFi Hacking 101* (Focus on WPA2/WPA3 logic) - **Difficulty: Easy**
*   **HackTheBox (HTB):** *"Sniper"* (Exploiting misconfigured services over network) - **Difficulty: Medium**
*   **Pentester Academy:** *Wireless Security Professional (WPSW)* course labs - **Difficulty: Advanced**

---

## 📊 GRC & Compliance Mapping

*   **NIST CSF (PR.AC-3):** Remote access is managed, including wireless.
*   **ISO 27001 (A.13.1.1):** Network controls to protect information in systems and applications.
*   **PCI-DSS 4.0 (Req 11.2):** Requirement to identify and manage all authorized and unauthorized wireless access points quarterly.
*   **Business Impact:** Proper WiFi hardening prevents unauthorized entry points that bypass physical perimeter security, reducing the risk of lateral movement.

---

## 🧪 Verification & Validation (The Proof)

**Confirming WPA3-SAE Connection:**
```bash
# Check if the interface is using SAE
iw dev wlan0 link
```
*Expected output: `link to [BSSID] ... SAE`*

**Testing for PMF (Protected Management Frames):**
```bash
# Using Wireshark or tshark to look for Management Frame Protection
tshark -I -i wlan0mon -Y "wlan.mgt.fixed.capabilities.privacy == 1"
```

---

## 🛠️ Lab Report: What We Mastered

In this module, I **took the battle to the airwaves**. I deep-dived into Wireless Security, moving beyond basic WPA2 handshakes to the robust **WPA3-SAE (Simultaneous Authentication of Equals)** protocol. I mastered the theory behind **'Evil Twin'** access points and deauthentication attacks on my **Arch lab**, identifying how PMF mitigates these risks. I explored how to harden home and enterprise WiFi using **802.1X authentication (EAP-TLS)** and VLAN segmentation. 

**"In a world without wires, the one who controls the spectrum controls the data. Stay encrypted, stay invisible."**

**Tools Used:**
- `Aircrack-ng` Suite (Spectral Analysis)
- `Wireshark` (Packet Decapsulation)
- `Hostapd-mana` (Rogue AP Simulation)
- `Bettercap` (MITRE T1557 Simulation)
- `Kismet` (WIDS - Wireless Intrusion Detection)

---

## 🚨 Real-World Breach Case Study: Dragonblood (CVE-2019-9494)
**The Vulnerability:** Researchers discovered that WPA3’s SAE handshake was vulnerable to **side-channel attacks**. Attackers could use "Cache-based" attacks to observe the timing of the dragonfly handshake and recover the password via brute force.
**The Fix:** Vendors issued microcode updates to ensure "constant-time" mathematical operations, preventing timing leaks.
**Lesson:** Even the strongest protocols can fail in implementation. Defense-in-depth (using Enterprise 802.1X over PSK) is always safer.

---

## 💡 Senior Researcher Insights & Future Trends

1.  **Pro-Tip: SSID Hiding is Security Theater.** It does not stop attackers (tools like `airodump-ng` reveal them instantly) and can actually make client devices more vulnerable by forcing them to "shout" the SSID name constantly.
2.  **Pro-Tip: Disable mDNS/LLMNR.** Once a user joins your "secure" WiFi, these protocols often leak credentials to anyone else on the same subnet.
3.  **Pro-Tip: Certificate Pinning.** Always force the client to validate the RADIUS server's CA. Without this, an Evil Twin can easily proxy an EAP-PEAP login.
4.  **Future Trend: WiFi 6E and 7.** The move to the **6GHz spectrum** essentially mandates WPA3. Legacy devices (WPA2/WEP) won't even see these bands, effectively creating a "hardware-enforced" security zone.

---

## 🎁 Free Web Resources & Official Documentation
*   **IEEE 802.11 Standard:** [Official IEEE Get Program](https://ieeexplore.ieee.org/browse/standards/get-program/ieee/22/)
*   **Wi-Fi Alliance WPA3 Specification:** [WPA3 Knowledge Base](https://www.wi-fi.org/discover-wi-fi/security)
*   **NIST SP 800-153:** [Guide to Securing Wireless Networks](https://csrc.nist.gov/publications/detail/sp/800-153/final)
