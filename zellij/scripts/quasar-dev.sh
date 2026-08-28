#!/usr/bin/env bash

# Paths
STATUS_FILE="/tmp/quasar_status"

# Colors or emoji for status
GREEN_ICON="✅"
RED_ICON="❌"

# Function to update status
function set_status() {
  echo "$1" >"$STATUS_FILE"
}

# Start fresh
set_status "$RED_ICON"

# Run Quasar Dev and capture output
quasar dev 2>&1 | tee /tmp/quasar_output.log | while read -r line; do
  echo "$line"

  # Look for a line that indicates success
  if [[ "$line" =~ "[ESLint] Found 0 error" || "$line" =~ "Compiled successfully" ]]; then
    set_status "$GREEN_ICON"
  elif [[ "$line" =~ "ERROR" || "$line" =~ "Error" ]]; then
    set_status "$RED_ICON"
  fi

done
