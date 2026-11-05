#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# scripts/sandbox_run_ticket.sh
# Automated AFK Sandbox Runner for tickets using agy CLI sandbox.
# Usage: ./scripts/sandbox_run_ticket.sh <ticket-number-or-path> [feature-slug]
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

if [ $# -lt 1 ]; then
  echo "Usage: $0 <ticket-number-or-path> [feature-slug]"
  echo "Examples:"
  echo "  $0 01 storage-tracker"
  echo "  $0 1"
  echo "  $0 .scratch/storage-tracker/issues/01-executable-scaffold-and-menu-bar-anchor.md"
  exit 1
fi

INPUT_ARG="$1"
FEATURE_SLUG="${2:-}"

# 1. Resolve feature slug if not explicitly passed
if [ -z "$FEATURE_SLUG" ]; then
  if [[ "$INPUT_ARG" =~ \.scratch/([^/]+)/ ]]; then
    FEATURE_SLUG="${BASH_REMATCH[1]}"
  else
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
fi

# 2. Resolve ticket file
TICKET_FILE=""
if [ -f "$INPUT_ARG" ]; then
  TICKET_FILE="$INPUT_ARG"
elif [ -f "$REPO_ROOT/$INPUT_ARG" ]; then
  TICKET_FILE="$REPO_ROOT/$INPUT_ARG"
elif [[ "$INPUT_ARG" =~ ^[0-9]+$ ]]; then
  PADDED=$(printf "%02d" "$((10#$INPUT_ARG))")
  shopt -s nullglob
  matches=(
    .scratch/"$FEATURE_SLUG"/issues/"${PADDED}"-*.md
    .scratch/"$FEATURE_SLUG"/issues/"${PADDED}".md
    .scratch/"$FEATURE_SLUG"/issues/"$((10#$INPUT_ARG))"-*.md
  )
  shopt -u nullglob
  if [ ${#matches[@]} -gt 0 ]; then
    TICKET_FILE="${matches[0]}"
  fi
elif [ -f ".scratch/$FEATURE_SLUG/issues/$INPUT_ARG" ]; then
  TICKET_FILE=".scratch/$FEATURE_SLUG/issues/$INPUT_ARG"
fi

if [ -z "$TICKET_FILE" ] || [ ! -f "$TICKET_FILE" ]; then
  echo "❌ Error: Could not resolve ticket file for '$INPUT_ARG' in feature '$FEATURE_SLUG'."
  echo "Looked under .scratch/$FEATURE_SLUG/issues/"
  exit 1
fi

TICKET_FILENAME="$(basename "$TICKET_FILE")"
TICKET_BASENAME="${TICKET_FILENAME%.md}"
TICKET_NUM=$(echo "$TICKET_BASENAME" | grep -oE '^[0-9]+' || echo "$INPUT_ARG")
TICKET_SLUG=$(echo "$TICKET_BASENAME" | sed -E 's/^[0-9]+-?//')
if [ -z "$TICKET_SLUG" ]; then
  TICKET_SLUG="$TICKET_BASENAME"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 Ticket Target: $TICKET_FILENAME"
echo "🏷️  Feature:       $FEATURE_SLUG"
echo "📄 File:          $TICKET_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# -----------------------------------------------------------------------------
# Pre-execution Safety Invariants
# -----------------------------------------------------------------------------

# Safety Invariant a: Working tree must be completely clean
echo "🔒 Checking safety invariant: clean working tree..."
if [ -n "$(git status --porcelain)" ]; then
  echo "❌ Pre-execution safety invariant failed: Working tree is not completely clean."
  echo "Untracked or uncommitted changes detected:"
  git status --short
  echo "Please commit or stash your changes before running tickets."
  exit 1
fi
echo "  ✔️ Working tree is clean."

# Safety Invariant b: Skip if ticket is already marked Status: resolved
echo "🔒 Checking safety invariant: ticket resolution status..."
if grep -Ei '^\*{0,2}Status:\*{0,2}\s*resolved' "$TICKET_FILE" >/dev/null 2>&1; then
  echo "⏭️ Ticket $TICKET_FILENAME is already marked Status: resolved. Skipping."
  exit 0
fi
echo "  ✔️ Ticket is not yet resolved. Ready to execute."

# Safety Invariant c: Check Blocked by references; halt if any upstream blocker is not resolved
echo "🔒 Checking safety invariant: upstream blockers..."
BLOCKED_LINE=$(grep -Ei '^\*{0,2}Blocked by:\*{0,2}' "$TICKET_FILE" | head -n 1 || true)
if [ -n "$BLOCKED_LINE" ]; then
  BLOCKED_VALUE=$(echo "$BLOCKED_LINE" | sed -E 's/^\*{0,2}Blocked by:\*{0,2}[[:space:]]*//I')
  
  if ! echo "$BLOCKED_VALUE" | grep -Eiq '^[[:space:]]*none\b'; then
    # Parse comma-separated blocker items
    IFS=',' read -ra BLOCKER_ITEMS <<< "$BLOCKED_VALUE"
    for item in "${BLOCKER_ITEMS[@]}"; do
      BLOCKER_NUM=$(echo "$item" | grep -oE '[0-9]+' | head -n 1 || true)
      if [ -n "$BLOCKER_NUM" ]; then
        PADDED_BLOCKER=$(printf "%02d" "$((10#$BLOCKER_NUM))")
        shopt -s nullglob
        blocker_matches=(
          .scratch/"$FEATURE_SLUG"/issues/"${PADDED_BLOCKER}"-*.md
          .scratch/"$FEATURE_SLUG"/issues/"${PADDED_BLOCKER}".md
          .scratch/"$FEATURE_SLUG"/issues/"$((10#$BLOCKER_NUM))"-*.md
        )
        shopt -u nullglob

        if [ ${#blocker_matches[@]} -eq 0 ]; then
          echo "❌ Pre-execution safety invariant failed: Ticket $TICKET_FILENAME is blocked by ticket #$BLOCKER_NUM, but blocker ticket file was not found under .scratch/$FEATURE_SLUG/issues/."
          exit 1
        fi

        BLOCKER_FILE="${blocker_matches[0]}"
        if ! grep -Ei '^\*{0,2}Status:\*{0,2}\s*resolved' "$BLOCKER_FILE" >/dev/null 2>&1; then
          echo "❌ Pre-execution safety invariant failed: Ticket $TICKET_FILENAME is blocked by upstream ticket #$BLOCKER_NUM ($(basename "$BLOCKER_FILE")), which is NOT resolved."
          exit 1
        fi
        echo "  ✔️ Upstream blocker #$BLOCKER_NUM ($(basename "$BLOCKER_FILE")) is verified resolved."
      fi
    done
  else
    echo "  ✔️ No upstream blockers indicated (Blocked by: None)."
  fi
else
  echo "  ✔️ No Blocked by line present."
fi

# -----------------------------------------------------------------------------
# Context Injection (Feature Spec, Glossary, ADRs)
# -----------------------------------------------------------------------------

SPEC_FILE=".scratch/$FEATURE_SLUG/spec.md"
SPEC_SECTION=""
if [ -f "$SPEC_FILE" ]; then
  echo "📖 Ingesting feature specification from $SPEC_FILE..."
  SPEC_SECTION="## Feature Specification ($SPEC_FILE):
$(cat "$SPEC_FILE")
"
fi

GLOSSARY_FILE="GLOSSARY.md"
GLOSSARY_SECTION=""
if [ -f "$GLOSSARY_FILE" ]; then
  GLOSSARY_SECTION="## Project Glossary ($GLOSSARY_FILE):
$(cat "$GLOSSARY_FILE")
"
fi

ADR_SECTION=""
if [ -d "docs/adr" ]; then
  shopt -s nullglob
  adrs=(docs/adr/*.md)
  shopt -u nullglob
  if [ ${#adrs[@]} -gt 0 ]; then
    ADR_SECTION="## Architecture Decision Records (docs/adr/):"$'\n'
    for adr in "${adrs[@]}"; do
      ADR_SECTION+="$(cat "$adr")"$'\n\n'
    done
  fi
fi

TICKET_CONTENT="$(cat "$TICKET_FILE")"

# -----------------------------------------------------------------------------
# Construct Prompt Enforcing Strict TDD
# -----------------------------------------------------------------------------

PROMPT="You are an autonomous senior software engineer working in a sandboxed development environment on this repository.
Your task is to implement the following ticket:
Feature: ${FEATURE_SLUG}
Ticket: ${TICKET_FILENAME}

${SPEC_SECTION}

${GLOSSARY_SECTION}

${ADR_SECTION}

## Ticket Details (${TICKET_FILENAME}):
${TICKET_CONTENT}

## MANDATORY ENGINEERING & TDD INSTRUCTIONS:
1. STRICT TEST-DRIVEN DEVELOPMENT (TDD) IS REQUIRED:
   - Phase 1 (RED): Before writing any implementation code, write automated tests that explicitly reproduce or specify the acceptance criteria for this ticket.
   - Run the tests to verify that they fail for the expected reason.
   - Phase 2 (GREEN): Write the minimal, robust domain logic and code required to make the tests pass.
   - Phase 3 (REFACTOR & VERIFY): Clean up code, verify that all unit/integration tests pass, and verify that typechecking and builds succeed with zero errors and zero warnings.
   - For Swift projects: use standard SPM structure (Package.swift, Sources/, Tests/). Run and verify \`swift test\` and \`swift build\`.
   - Never mock what you can test directly, but decouple system dependencies (e.g., AppKit, disk capacity APIs) using clean protocols/interfaces (like VolumeProvider) for 100% deterministic testing.

2. FINISHING THE TICKET:
   - When all acceptance criteria checklist items are satisfied, tests pass, and builds are clean:
     - Update the ticket file (\`${TICKET_FILE}\`):
       - Check off all completed checkboxes (change \`- [ ]\` to \`- [x]\`).
       - Change the status line to: \`**Status:** resolved\` (or \`Status: resolved\`).
       - Append a short summary under a \`## Resolution Notes\` heading describing the solution and test results.
   - Do NOT run git commit or git push; the outer automated runner will verify tests and commit changes on the host.
"

# -----------------------------------------------------------------------------
# Spawning agy sandbox runner headlessly
# -----------------------------------------------------------------------------

echo "🤖 Spawning agy headlessly with restricted sandbox permissions..."
echo "Command: agy --sandbox --dangerously-skip-permissions -p [PROMPT]"

agy --sandbox --dangerously-skip-permissions -p "$PROMPT"
AGY_EXIT_CODE=$?

if [ $AGY_EXIT_CODE -ne 0 ]; then
  echo "❌ Error: agy sandbox runner exited with status code $AGY_EXIT_CODE."
  exit $AGY_EXIT_CODE
fi

# -----------------------------------------------------------------------------
# Post-execution Verification on Host
# -----------------------------------------------------------------------------

echo "🔍 Running post-execution verification on host..."

# Verify ticket marked resolved
if ! grep -Ei '^\*{0,2}Status:\*{0,2}\s*resolved' "$TICKET_FILE" >/dev/null 2>&1; then
  echo "❌ Post-execution verification failed: Ticket $TICKET_FILENAME was not marked 'Status: resolved' by the agent."
  exit 1
fi
echo "  ✔️ Ticket is marked Status: resolved."

# Adapt and run project test suite and typechecker
run_project_verification() {
  local ran_checks=false

  # Swift Package Manager
  if [ -f "$REPO_ROOT/Package.swift" ]; then
    echo "📦 Detected Swift project (Package.swift)"
    echo "⚙️  Typechecking and building with swift build..."
    swift build
    echo "🧪 Running test suite with swift test..."
    swift test
    ran_checks=true
  fi

  # Node / JavaScript / TypeScript
  if [ -f "$REPO_ROOT/package.json" ]; then
    echo "📦 Detected Node project (package.json)"
    if [ -x "$REPO_ROOT/node_modules/.bin/tsc" ]; then
      echo "⚙️  Typechecking with tsc --noEmit..."
      "$REPO_ROOT/node_modules/.bin/tsc" --noEmit
      ran_checks=true
    fi
    if npm run | grep -E '^[[:space:]]*test[[:space:]]*$' >/dev/null 2>&1; then
      echo "🧪 Running npm test..."
      npm test
      ran_checks=true
    fi
  fi

  # Python
  if [ -f "$REPO_ROOT/pyproject.toml" ] || [ -f "$REPO_ROOT/pytest.ini" ] || [ -f "$REPO_ROOT/setup.py" ]; then
    echo "📦 Detected Python project"
    if command -v mypy >/dev/null 2>&1; then
      echo "⚙️  Typechecking with mypy..."
      mypy .
      ran_checks=true
    elif command -v pyright >/dev/null 2>&1; then
      echo "⚙️  Typechecking with pyright..."
      pyright
      ran_checks=true
    fi
    if command -v pytest >/dev/null 2>&1; then
      echo "🧪 Running pytest..."
      pytest
      ran_checks=true
    fi
  fi

  # Rust
  if [ -f "$REPO_ROOT/Cargo.toml" ]; then
    echo "📦 Detected Rust project (Cargo.toml)"
    echo "⚙️  Checking with cargo check..."
    cargo check
    echo "🧪 Running tests with cargo test..."
    cargo test
    ran_checks=true
  fi

  # Go
  if [ -f "$REPO_ROOT/go.mod" ]; then
    echo "📦 Detected Go project (go.mod)"
    echo "⚙️  Checking with go vet..."
    go vet ./...
    echo "🧪 Running tests with go test..."
    go test ./...
    ran_checks=true
  fi

  if [ "$ran_checks" = false ]; then
    echo "⚠️  Note: No build/test manifest detected yet. Verification skipped."
  else
    echo "✅ All verification tests and typechecks passed successfully!"
  fi
}

run_project_verification

# -----------------------------------------------------------------------------
# Automatic Git Commit
# -----------------------------------------------------------------------------

echo "💾 Checking git changes for automated commit..."
if [ -z "$(git status --porcelain)" ]; then
  echo "ℹ️  No changes to commit for $TICKET_FILENAME."
else
  git add -A
  COMMIT_MSG="feat(${FEATURE_SLUG}-${TICKET_NUM}): implement ${TICKET_SLUG}"
  git commit -m "$COMMIT_MSG"
  echo "🎉 Successfully committed: $COMMIT_MSG"
fi

echo "🏁 Completed ticket $TICKET_FILENAME successfully!"
