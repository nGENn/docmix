#!/usr/bin/env bash
set -euo pipefail

KEEP_NAME="backup_borg"
# Everything after the first arg is the command to run:
CMD=( "/root/.local/bin/borgmatic" "create" "--verbosity" "1" "--stats" )

# 1) Build a list of all running containers except the one to keep
declare -a STOP_IDS=()
while read -r NAME ID; do
  if [ "$NAME" != "$KEEP_NAME" ]; then
    STOP_IDS+=("$ID")
  fi
done < <(docker ps --format '{{.Names}} {{.ID}}')

# 2) Stop them (if any)
if [ ${#STOP_IDS[@]} -gt 0 ]; then
  echo "Stopping containers in parallel: ${STOP_IDS[*]}"
  for id in "${STOP_IDS[@]}"; do
    docker stop "$id" &
  done
  wait  # Wait for all background jobs to finish
else
  echo "No other containers to stop."
fi

# 3) Run the arbitrary command
echo "Running command: ${CMD[*]}"
(
  set +e
  "${CMD[@]}"
)
CMD_EXIT=$?

# 4) Restart the previously stopped containers
if [ ${#STOP_IDS[@]} -gt 0 ]; then
  echo "Restarting containers in parallel: ${STOP_IDS[*]}"
  for id in "${STOP_IDS[@]}"; do
    docker start "$id" &
  done
  wait
fi


# Exit
if [ "$CMD_EXIT" -ne 0 ]; then
  echo "Command failed with exit code $CMD_EXIT" >&2
  exit "$CMD_EXIT"
fi

echo "Done."

