#!/data/data/com.termux/files/usr/bin/bash
# RefineAA Installer Script (final fixed version)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "Starting RefineAA environment setup..."

# Prepare environment
mkdir -p ~/RefineAA_Built_Zips
mkdir -p ~/RefineAA_Watch_Dir

export WATCH_DIR=~/RefineAA_Watch_Dir
export BUILT_ZIPS_DIR=~/RefineAA_Built_Zips

# Permissions
chmod +x scripts/*.sh || true

# Safe run helper scripts
bash scripts/create_full_snapshot_template.sh || echo "Snapshot script failed."
bash scripts/watch_downloads_template.sh || echo "Watcher script failed."

echo "RefineAA environment setup completed."
