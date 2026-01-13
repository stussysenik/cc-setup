#!/bin/bash
# Standalone Ralph Wiggum launcher
# Can be used outside of nix shell if claude is installed

set -e

# Colors
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════╗"
echo "║  🤖 Ralph Wiggum Autonomous Mode              ║"
echo "╠═══════════════════════════════════════════════╣"
echo "║  Claude will run autonomously until:          ║"
echo "║  • Task is complete (RALPH_COMPLETE)          ║"
echo "║  • You interrupt (Ctrl+C)                     ║"
echo "║  • An unrecoverable error occurs              ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if in tmux
if [ -z "$TMUX" ]; then
    echo -e "${YELLOW}💡 Tip: Run inside tmux for session persistence${NC}"
    echo "   tmux new -s ralph"
    echo ""
fi

# Launch Claude in autonomous mode
exec claude --dangerously-skip-permissions "$@"
