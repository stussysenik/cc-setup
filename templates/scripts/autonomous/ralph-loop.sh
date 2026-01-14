#!/bin/bash
#
# Ralph Wiggum Autonomous Loop
#
# Runs Claude autonomously until task completion.
# Best used inside tmux for persistence.
#
# Usage: ./ralph-loop.sh "Your task description"
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load config if available
if [[ -f "$PROJECT_DIR/.claude-ops/config.sh" ]]; then
  source "$PROJECT_DIR/.claude-ops/config.sh"
fi

# Configuration
MAX_ITERATIONS=${MAX_ITERATIONS:-50}
COMPLETION_MARKER="RALPH_COMPLETE"
LOG_DIR="$PROJECT_DIR/logs/ralph"
mkdir -p "$LOG_DIR"

TASK="$1"
if [[ -z "$TASK" ]]; then
  echo "Usage: $0 \"<task description>\""
  exit 1
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/ralph_${TIMESTAMP}.log"

echo "================================================" | tee -a "$LOG_FILE"
echo "Ralph Wiggum Autonomous Loop" | tee -a "$LOG_FILE"
echo "Started: $(date)" | tee -a "$LOG_FILE"
echo "Task: $TASK" | tee -a "$LOG_FILE"
echo "Max Iterations: $MAX_ITERATIONS" | tee -a "$LOG_FILE"
echo "Log: $LOG_FILE" | tee -a "$LOG_FILE"
echo "================================================" | tee -a "$LOG_FILE"

PROMPT="You are an autonomous AI developer. Your task:

$TASK

## Rules
1. Work until the task is FULLY complete
2. Run tests after each change
3. Commit working code frequently
4. If blocked, research solutions (brave-search)
5. When DONE, output exactly: $COMPLETION_MARKER

## Available Tools
- chrome-devtools: Browser automation
- brave-search: Documentation lookup
- playwright: E2E testing

Begin working on the task now."

iteration=0
completed=false

while [[ $iteration -lt $MAX_ITERATIONS ]] && [[ "$completed" != "true" ]]; do
  iteration=$((iteration + 1))

  echo "" | tee -a "$LOG_FILE"
  echo "=== Iteration $iteration / $MAX_ITERATIONS ===" | tee -a "$LOG_FILE"

  OUTPUT=$(timeout 600 claude --dangerously-skip-permissions -p "$PROMPT" 2>&1) || true

  echo "$OUTPUT" >> "$LOG_FILE"

  if echo "$OUTPUT" | grep -q "$COMPLETION_MARKER"; then
    completed=true
    echo "" | tee -a "$LOG_FILE"
    echo "================================================" | tee -a "$LOG_FILE"
    echo "TASK COMPLETE at iteration $iteration!" | tee -a "$LOG_FILE"
    echo "================================================" | tee -a "$LOG_FILE"
  fi

  sleep 3
done

if [[ "$completed" != "true" ]]; then
  echo "Max iterations reached. Task may be incomplete." | tee -a "$LOG_FILE"
  exit 1
fi

exit 0
