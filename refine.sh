#!/data/data/com.termux/files/usr/bin/bash
# Refine full environment restore and sync script
set -e

echo "[INFO] Starting full environment restoration and sync."
cd ~/ || exit 1
termux-wake-lock
mkdir -p RefineAA_Sync/docs
cd RefineAA_Sync || exit 1

echo "[INFO] Current directory: $(pwd)"
find . -type f > environment_files_list.txt

echo "[INFO] Extracting archives..."
unzip -o ~/storage/downloads/RefineAA.zip
unzip -o ~/storage/downloads/RefineAA_bulletproof.zip

echo "[INFO] Fixing permissions..."
chmod -R u+rwX,go-rwx .

find . -type f > environment_files_post_extract.txt

BUILD_TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')

echo "[INFO] Recording loop break history..."
cat << EOF > docs/loop_break_history.md
# Loop Break History

This document records the exact manual method used to break infinite loop behavior in refine automation.

## Trigger Event
User identified and reported repetitive confirmations causing perceived infinite loops in system output.

## Sequence Recorded
1. Observation: "You keep saying that you're ready. That's the infinite loop."
2. Directive: "I'm your next reply, a totally revised one liner."

## Action Taken
- System memory permanently updated to:
  - Avoid redundant status messages.
  - Eliminate infinite loop patterns in automation output.
  - Maintain single-action execution flow with clean exit points.
  - Always update memory, script, and one-liner together.
EOF

echo "[INFO] Embedding self-updating script..."
cat $0 > refine.sh
chmod +x refine.sh

echo "[INFO] Initializing Git repository..."
git init --initial-branch=main
git remote add origin https://github.com/styromaniac/RefineAA.git 2>/dev/null || true
git add --all
git commit -m "Full restore and sync: $BUILD_TIMESTAMP with loop break memory, self-rebuilding refine.sh" 2>/dev/null || true
git push --force --set-upstream origin main || echo "[WARNING] Git push failed. Check token or network."

echo "[INFO] Final environment snapshot:"
pwd
find .

echo "[INFO] Operation complete. No loops."
exit 0
