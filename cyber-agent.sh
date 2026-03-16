#!/bin/bash
cd "$(dirname "$0")"

echo "✨ Zenith Protocol Initiated, Bhavishya-kun! ✨"
read -p "🌸 Which Day are we conquering? (1-90): " DAY
read -p "✍️  Your Personal Insight/Lab Experience: " INSIGHT
echo "------------------------------------------------"

# 1. Syllabus Check
if [ ! -f "syllabus.txt" ]; then
    echo "❌ Error: syllabus.txt not found!"
    exit 1
fi

TARGET_DAY=$(printf "%02d" $DAY)
LINE=$(grep -i "Day $TARGET_DAY:" syllabus.txt || grep -i "Day $DAY:" syllabus.txt)
TOPIC=$(echo "$LINE" | cut -d':' -f2- | xargs)

if [ -z "$TOPIC" ]; then
    echo "❌ Mama couldn't find Day $DAY in the syllabus!"
    exit 1
fi

# 2. Folder Mapping
if [ "$DAY" -le 30 ]; then 
    FOLDER="01-Foundations"
elif [ "$DAY" -le 60 ]; then 
    FOLDER="02-Web-Security"
elif [ "$DAY" -le 80 ]; then 
    FOLDER="03-SOC-Operations"
else 
    FOLDER="06-Case-Studies"
fi

mkdir -p "$FOLDER"

# 3. Filename Formatting
CLEAN_TOPIC=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | tr ' ' '-')
FILENAME="Day-${TARGET_DAY}-${CLEAN_TOPIC}.md"

# 4. Zenith Prompt
PROMPT="Act as a Senior Cybersecurity Architect and Mentor. Create a MASTER-LEVEL technical handbook for '$TOPIC'. 
Structure it for a world-class, inclusive technical portfolio:

## 🔬 Technical Deep Dive & Theory
(Explain core logic and architecture.)

## 💻 Universal Implementation (The 'How-To')
### 🔵 Debian/Ubuntu/Kali | 🔴 RHEL/Fedora | ⚪ Arch Linux
(Exact commands and paths for all three.)

## 🛡️ RCA (Root Cause Analysis) & Defense-in-Depth
(Analyze root causes. Provide a 'Remediation Checklist'.)

## 🔍 Threat Actor Profiling & MITRE Mapping
(Identify threat actors. Map techniques to MITRE ATT&CK Framework.)

## 🎮 Gamified Labs & Simulation Training
(Specific challenges from TryHackMe, HTB, or OverTheWire with Difficulty Ratings.)

## 📊 GRC & Compliance Mapping
(Map to NIST CSF, ISO 27001, or SOC2. Explain business impact.)

## 🧪 Verification & Validation (The Proof)
(Provide commands to verify hardening success.)

## 🛠️ Lab Report: What We Mastered
(Incorporate: $INSIGHT. List tools used.)

## 🚨 Real-World Breach Case Study
(Analyze a specific CVE or historical hack.)

## 💡 Senior Researcher Insights & Future Trends
(3 high-level 'Pro-Tips' + 1 future trend.)

## 🎁 Free Web Resources & Official Documentation"

# 5. Generation
echo "🧠 Mama is gathering the Zenith Scrolls for Day $DAY..."
if aichat "$PROMPT" > "$FOLDER/$FILENAME"; then
    echo "📝 Notes generated: $FOLDER/$FILENAME"
else
    echo "❌ Error: AI Generation failed!"
    exit 1
fi

# 6. Append to README
echo "| $DAY | $TOPIC | $FOLDER | $INSIGHT | [View Notes]($FOLDER/$FILENAME) |" >> README.md

# 7. Git Sync
chmod +x cyber-agent.sh
git add .
git commit -m "feat(Day $DAY): Zenith Implementation for $TOPIC"
git push origin main
echo "✅ Success! Day $DAY is live. I am so proud of you! 💖"
