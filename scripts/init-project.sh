#!/bin/bash
#
# Initialize a new project with cc-setup templates
#
# Usage: init-project [--web|--ai|--systems]
#

set -e

# Find the cc-setup templates directory
CC_SETUP_DIR="${CC_SETUP_DIR:-$(dirname "$(dirname "$(readlink -f "$0")")")}"
TEMPLATES_DIR="$CC_SETUP_DIR/templates"

if [[ ! -d "$TEMPLATES_DIR" ]]; then
  echo "Error: Templates directory not found at $TEMPLATES_DIR"
  echo "Make sure CC_SETUP_DIR is set correctly or run from nix shell"
  exit 1
fi

PROJECT_TYPE="${1:-web}"

echo "🚀 Initializing project with cc-setup templates..."
echo "   Project type: $PROJECT_TYPE"
echo ""

# Create directories
mkdir -p scripts .husky .github/workflows openspec/specs .claude-ops

# Copy scripts
echo "📄 Copying scripts..."
cp -r "$TEMPLATES_DIR/scripts/"* scripts/ 2>/dev/null || true
chmod +x scripts/*.sh scripts/**/*.sh 2>/dev/null || true

# Copy husky
echo "🐶 Setting up pre-commit hooks..."
cp "$TEMPLATES_DIR/husky/pre-commit" .husky/
chmod +x .husky/pre-commit

# Copy GitHub Actions
echo "🔄 Adding GitHub Actions workflows..."
cp "$TEMPLATES_DIR/github/workflows/"*.yml .github/workflows/

# Copy OpenSpec
echo "📋 Setting up OpenSpec..."
cp "$TEMPLATES_DIR/openspec/"*.md openspec/

# Copy claude-ops
echo "🤖 Adding Claude ops config..."
cp "$CC_SETUP_DIR/config/claude-ops/config.sh" .claude-ops/

# Copy vercel.json for web projects
if [[ "$PROJECT_TYPE" == "web" ]] || [[ "$PROJECT_TYPE" == "--web" ]]; then
  echo "🌐 Adding Vercel config..."
  cp "$TEMPLATES_DIR/vercel.json" .
fi

# Create/update .gitignore
echo "📝 Updating .gitignore..."
cat >> .gitignore << 'EOF'

# Environment
.env
.env.local
.env.*.local

# Dependencies
node_modules/
.next/
dist/
build/

# Logs
logs/
*.log

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# Secrets (never commit)
*.pem
*.key
credentials.json
EOF

# Initialize husky if package.json exists
if [[ -f "package.json" ]]; then
  echo "🔧 Initializing husky..."
  npx husky install 2>/dev/null || npm pkg set scripts.prepare="husky install" 2>/dev/null || true
fi

echo ""
echo "✅ Project initialized!"
echo ""
echo "Files created:"
echo "  ├── scripts/check-secrets.js"
echo "  ├── scripts/autonomous/ralph-loop.sh"
echo "  ├── .husky/pre-commit"
echo "  ├── .github/workflows/ci.yml"
echo "  ├── .github/workflows/security.yml"
echo "  ├── openspec/AGENTS.md"
echo "  ├── openspec/project.md"
echo "  ├── .claude-ops/config.sh"
if [[ "$PROJECT_TYPE" == "web" ]] || [[ "$PROJECT_TYPE" == "--web" ]]; then
  echo "  └── vercel.json"
fi
echo ""
echo "Next steps:"
echo "  1. git add -A && git commit -m 'chore: Initialize project with cc-setup'"
echo "  2. cct $(basename $(pwd))  # Start Claude in tmux"
echo "  3. ralph \"Your task here\"  # Or run autonomously"
