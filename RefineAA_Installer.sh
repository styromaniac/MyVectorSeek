#!/bin/bash

#=====================================================================

RefineAA_Installer.sh

Fully Automated Installer for RefineAA Environment

Goal: Zero manual intervention - "Never Debug Again"

#=====================================================================

set -e

#=== CONFIG === REPO_URL="https://github.com/AlexGoven/RefineAA.git" REPO_DIR="$HOME/RefineAA" SNAPSHOT_DIR="$REPO_DIR/snapshots" CRON_MARKER="# RefineAA Watchdog"

#=== FUNCTIONS ===

log() { echo -e "[RefineAA Installer] $1" }

ensure_termux() { log "Ensuring Termux environment..." if command -v termux-wake-lock &>/dev/null; then termux-wake-lock || true fi pkg update -y pkg upgrade -y pkg install -y git curl bash tsu cronie }

import_local_zip_if_exists() { if [ -f "/storage/emulated/0/Download/RefineAA.zip" ]; then log "Importing local RefineAA.zip..." mkdir -p "$REPO_DIR" unzip -o "/storage/emulated/0/Download/RefineAA.zip" -d "$REPO_DIR" fi }

clone_or_pull_repo() { if [ ! -d "$REPO_DIR/.git" ]; then log "Cloning RefineAA repository..." git clone "$REPO_URL" "$REPO_DIR" else log "Pulling latest RefineAA updates..." cd "$REPO_DIR" git reset --hard HEAD git clean -fd git pull --rebase || git fetch --all && git reset --hard origin/main fi }

ensure_cron_watchdog() { log "Setting up cron watchdog..." (crontab -l 2>/dev/null | grep -v "$CRON_MARKER"; echo "*/5 * * * * bash $REPO_DIR/self_heal.sh # RefineAA Watchdog") | crontab - log "Cron watchdog ensured." }

setup_self_heal_script() { log "Creating self-healing script..." cat > "$REPO_DIR/self_heal.sh" <<'EOF' #!/bin/bash set -e REPO_DIR="$HOME/RefineAA" if [ ! -d "$REPO_DIR/.git" ]; then echo "[Self-Heal] Repository missing, reinitializing..." git clone https://github.com/AlexGoven/RefineAA.git "$REPO_DIR" fi cd "$REPO_DIR" git fetch --all LOCAL=$(git rev-parse @) REMOTE=$(git rev-parse @{u}) if [ "$LOCAL" != "$REMOTE" ]; then echo "[Self-Heal] Changes detected, pulling updates..." git reset --hard "$REMOTE" fi bash "$REPO_DIR/installer.sh" || true EOF chmod +x "$REPO_DIR/self_heal.sh" }

snapshot_repo() { log "Creating snapshot..." mkdir -p "$SNAPSHOT_DIR" TIMESTAMP=$(date +"%Y%m%d-%H%M%S") git -C "$REPO_DIR" archive --format=tar HEAD | gzip > "$SNAPSHOT_DIR/snapshot-$TIMESTAMP.tar.gz" if [ $(find "$SNAPSHOT_DIR" -type f -size +0c | wc -l) -gt 0 ]; then log "Snapshot created: $TIMESTAMP" else log "Snapshot failed or empty." fi }

clean_snapshots() { log "Cleaning old snapshots..." find "$SNAPSHOT_DIR" -type f -mtime +7 -delete }

initialize_repo_if_missing() { if [ ! -d "$REPO_DIR/.git" ]; then log "Initializing repository from local if missing..." import_local_zip_if_exists if [ ! -d "$REPO_DIR/.git" ]; then git init "$REPO_DIR" cd "$REPO_DIR" git remote add origin "$REPO_URL" git fetch origin git reset --hard origin/main fi fi }

#=== EXECUTION ===

log "Starting RefineAA environment installation..." ensure_termux initialize_repo_if_missing clone_or_pull_repo setup_self_heal_script ensure_cron_watchdog snapshot_repo clean_snapshots

log "RefineAA environment fully installed and self-healing. Enjoy!"

exit 0
