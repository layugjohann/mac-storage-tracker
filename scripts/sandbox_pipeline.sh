#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# scripts/sandbox_pipeline.sh
# Sequential AFK Sandbox Pipeline across a range of tickets:
# Strict TDD -> Two-Axis Code Review -> Re-implementation & Verification.
# Usage: ./scripts/sandbox_pipeline.sh <start-ticket-number> <end-ticket-number> [feature-slug]
# -----------------------------------------------------------------------------

# Resolve repo root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# Adapt PATH to include local project bin tools (node_modules, virtualenvs, local bins)
if [ -d "$REPO_ROOT/node_modules/.bin" ]; then
  export PATH="$REPO_ROOT/node_modules/.bin:$PATH"
fi
if [ -d "$REPO_ROOT/.venv/bin" ]; then
  export PATH="$REPO_ROOT/.venv/bin:$PATH"
elif [ -d "$REPO_ROOT/venv/bin" ]; then
  export PATH="$REPO_ROOT/venv/bin:$PATH"
fi
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

if [ $# -lt 2 ]; then
  echo "Usage: $0 <start-ticket-number> <end-ticket-number> [feature-slug]"
  echo "Examples:"
  echo "  $0 01 07 storage-tracker"
  echo "  $0 1 7"
  exit 1
fi

START_INPUT="$1"
END_INPUT="$2"
FEATURE_SLUG="${3:-}"

# Validate numeric inputs
if ! [[ "$START_INPUT" =~ ^[0-9]+$ ]] || ! [[ "$END_INPUT" =~ ^[0-9]+$ ]]; then
  echo "❌ Error: Start ticket ($START_INPUT) and End ticket ($END_INPUT) must be positive integers."
  exit 1
fi

START_INT=$((10#$START_INPUT))
END_INT=$((10#$END_INPUT))

if [ "$START_INT" -gt "$END_INT" ]; then
  echo "❌ Error: Start ticket ($START_INT) cannot be greater than End ticket ($END_INT)."
  exit 1
fi

# Auto-detect feature slug if not provided
if [ -z "$FEATURE_SLUG" ]; then
  shopt -s nullglob
  features=($(find .scratch -mindepth 1 -maxdepth 1 -type d ! -name '.*' -exec basename {} \; 2>/dev/null || true))
  shopt -u nullglob
  if [ ${#features[@]} -eq 1 ]; then
    FEATURE_SLUG="${features[0]}"
  elif [ ${#features[@]} -eq 0 ]; then
    echo "❌ Error: No feature directory found under .scratch/."
    exit 1
  else
    echo "❌ Error: Multiple features found under .scratch/ (${features[*]}). Please specify [feature-slug]."
    exit 1
  fi
fi

TOTAL_TICKETS=$((END_INT - START_INT + 1))
echo "================================================================================"
echo "🚀 Starting AFK Sandbox Pipeline"
echo "Feature:       $FEATURE_SLUG"
echo "Ticket Range:  #$START_INPUT -> #$END_INPUT ($TOTAL_TICKETS tickets total)"
echo "Working Tree:  $REPO_ROOT"
echo "================================================================================"

COMPLETED_COUNT=0
SKIPPED_COUNT=0

for ((i = START_INT; i <= END_INT; i++)); do
  PADDED_NUM=$(printf "%02d" "$i")
  echo ""
  echo "--------------------------------------------------------------------------------"
  echo "▶️  Pipeline Ticket Step: #$PADDED_NUM (Ticket $i of $END_INT)"
  echo "--------------------------------------------------------------------------------"

  # Find matching ticket file in .scratch/$FEATURE_SLUG/issues/
  shopt -s nullglob
  matches=(
    .scratch/"$FEATURE_SLUG"/issues/"${PADDED_NUM}"-*.md
    .scratch/"$FEATURE_SLUG"/issues/"${PADDED_NUM}".md
    .scratch/"$FEATURE_SLUG"/issues/"$i"-*.md
  )
  shopt -u nullglob

  if [ ${#matches[@]} -eq 0 ]; then
    echo "⚠️  No ticket file found for #$PADDED_NUM under .scratch/$FEATURE_SLUG/issues/. Skipping."
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    continue
  fi

  TICKET_FILE="${matches[0]}"

  # Check if already resolved before running to track stats
  if grep -Ei '^\*{0,2}Status:\*{0,2}\s*resolved' "$TICKET_FILE" >/dev/null 2>&1; then
    echo "⏭️  Ticket $(basename "$TICKET_FILE") is already resolved. Skipping."
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    continue
  fi

  # Execute runner for ticket
  if ! "$SCRIPT_DIR/sandbox_run_ticket.sh" "$TICKET_FILE" "$FEATURE_SLUG"; then
    echo ""
    echo "❌ Pipeline halted: Ticket #$PADDED_NUM ($TICKET_FILE) failed execution or verification."
    exit 1
  fi

  COMPLETED_COUNT=$((COMPLETED_COUNT + 1))
  echo "✅ Finished ticket #$PADDED_NUM."
done

echo ""
echo "================================================================================"
echo "🎉 AFK Sandbox Pipeline Completed Successfully!"
echo "Feature:          $FEATURE_SLUG"
echo "Tickets Range:    #$START_INPUT to #$END_INPUT"
echo "Processed/Done:   $COMPLETED_COUNT"
echo "Skipped/Resolved: $SKIPPED_COUNT"
echo "================================================================================"
