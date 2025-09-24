#!/usr/bin/env bash
# upgrade_all.sh
# Run: ./upgrade_all.sh
# Must be placed in the same directory as ./cmd (e.g. docmix/docmix/scripts)

set -uo pipefail

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULES_DIR="$SCRIPTS_DIR/../modules"
CMD="$SCRIPTS_DIR/cmd"

if [[ ! -x "$CMD" ]]; then
  echo "Error: $CMD not found or not executable. Run this from the scripts directory." >&2
  exit 2
fi

if [[ ! -d "$MODULES_DIR" ]]; then
  echo "Error: modules dir '$MODULES_DIR' not found." >&2
  exit 3
fi

echo "Starting upgrade for all modules in: $MODULES_DIR"
echo "Timestamp: $(date --iso-8601=seconds)"
echo

failed=()

# iterate non-hidden directories only
shopt -s nullglob
for d in "$MODULES_DIR"/*/; do
  mod="$(basename "$d")"
  # skip hidden directories just in case
  [[ "$mod" = .* ]] && continue

  echo "-----"
  echo "Upgrading module: $mod"
  echo "Command: $CMD upgrade $mod"
  if (cd "$SCRIPTS_DIR" && ./cmd upgrade "$mod"); then
    echo "Success: $mod"
  else
    rc=$?
    echo "FAILED: $mod (exit $rc)" >&2
    failed+=("$mod:$rc")
  fi
  echo
done
shopt -u nullglob

echo "Finished at: $(date --iso-8601=seconds)"
if [[ ${#failed[@]} -gt 0 ]]; then
  echo
  echo "Some upgrades failed:"
  for f in "${failed[@]}"; do
    echo "  $f"
  done
  exit 4
else
  echo "All upgrades completed successfully."
  exit 0
fi

