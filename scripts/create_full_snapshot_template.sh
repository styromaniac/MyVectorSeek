#!/data/data/com.termux/files/usr/bin/bash

# Create full environment snapshot with health check and rotation
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
SNAPSHOT=~/RefineAA_Built_Zips/RefineAA_$DATE.zip
LOG=~/RefineAA_Built_Zips/RefineAA_$DATE.log

# Health check
echo \"Snapshot started at \$DATE\" > \$LOG
[ -d ~/RefineAA ] && echo \"✅ RefineAA directory exists\" >> \$LOG || echo \"❌ RefineAA directory missing\" >> \$LOG

# Archive
zip -rTq \$SNAPSHOT ~/RefineAA ~/RefineAA_Backups ~/RefineAA_Built_Zips ~/.termux/boot ~/RefineAA_Built_Zips/ >> \$LOG 2>&1

# Token redaction
sed -i \"s/ghp_[a-zA-Z0-9]*/REDACTED/g\" \$SNAPSHOT

# Rotation: keep only last 20
ls -t ~/RefineAA_Built_Zips/*.zip | tail -n +21 | xargs rm -f

# Done
echo \"✅ Snapshot completed: \$SNAPSHOT\" >> \$LOG

