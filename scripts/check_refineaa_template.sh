#!/data/data/com.termux/files/usr/bin/bash

# Simple environment verification
STATUS=0

[ -d ~/RefineAA ] && echo \"✅ RefineAA folder found.\" || { echo \"❌ RefineAA folder missing.\"; STATUS=1; }
[ -x ~/create_full_snapshot.sh ] && echo \"✅ Snapshot script is executable.\" || { echo \"❌ Snapshot script missing or not executable.\"; STATUS=1; }
[ -x ~/watch_downloads.sh ] && echo \"✅ Watch downloads script is executable.\" || { echo \"❌ Watch downloads script missing or not executable.\"; STATUS=1; }

if pgrep -f watch_downloads.sh > /dev/null; then
  echo \"✅ Watcher is running.\"
else
  echo \"❌ Watcher is not running.\"
  STATUS=1
fi

exit \$STATUS

