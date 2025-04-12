#!/data/data/com.termux/files/usr/bin/bash

WATCH_DIR=\"/storage/emulated/0/Download\"

inotifywait -m -e close_write --format \"%f\" \"\$WATCH_DIR\" | while read FILENAME; do
  if [[ \"\$FILENAME\" == \"RefineAA.zip\" ]]; then
    echo \"Detected new RefineAA.zip via live monitor.\" >> ~/RefineAA_Backups/auto-check-log.txt
    cp \"\$WATCH_DIR/RefineAA.zip\" ~/
    unzip -o ~/RefineAA.zip -d ~/RefineAA
    bash ~/RefineAA_Build.sh
    bash ~/create_full_snapshot.sh
  fi
done

