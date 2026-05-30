#!/bin/bash
# Daily communication audit runner
# Idempotent: skips if yesterday's data already exists in daily-log.json

cd ~/comms-tracker

YESTERDAY=$(date -v-1d +%Y-%m-%d)
LOG_FILE="data/daily-log.json"
LOG_DIR="logs"

mkdir -p "$LOG_DIR"

# Idempotent check
if [ -f "$LOG_FILE" ] && grep -q "\"date\": \"$YESTERDAY\"" "$LOG_FILE" 2>/dev/null; then
  echo "$(date): Data for $YESTERDAY already exists, skipping." >> "$LOG_DIR/audit.log"
  exit 0
fi

echo "$(date): Running audit for $YESTERDAY..." >> "$LOG_DIR/audit.log"

claude -p "$(cat audit-prompt.md)" >> "$LOG_DIR/audit.log" 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo "$(date): Audit for $YESTERDAY completed successfully." >> "$LOG_DIR/audit.log"
else
  echo "$(date): Audit for $YESTERDAY failed with exit code $EXIT_CODE." >> "$LOG_DIR/audit.log"
fi

exit $EXIT_CODE
