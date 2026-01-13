#!/bin/bash
# Initialize Husky pre-commits in current project
# Usage: init-husky (function available in nix shell)

set -e

echo "🐶 Setting up Husky pre-commits..."

# Check if package.json exists
if [ ! -f package.json ]; then
    echo "❌ No package.json found. Run this in a Node.js project."
    return 1 2>/dev/null || exit 1
fi

# Detect package manager
if [ -f bun.lockb ]; then
    PM="bun"
elif [ -f pnpm-lock.yaml ]; then
    PM="pnpm"
elif [ -f yarn.lock ]; then
    PM="yarn"
else
    PM="npm"
fi

echo "📦 Using package manager: $PM"

# Install dependencies
$PM add -D husky lint-staged

# Initialize husky
npx husky init

# Create pre-commit hook
cat > .husky/pre-commit << 'EOF'
npx lint-staged
EOF

# Create lint-staged config
cat > .lintstagedrc.json << 'EOF'
{
  "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
  "*.{js,jsx}": ["eslint --fix", "prettier --write"],
  "*.{json,md,yml,yaml}": ["prettier --write"],
  "*.css": ["prettier --write"]
}
EOF

echo ""
echo "✅ Husky + lint-staged configured!"
echo ""
echo "Files created:"
echo "  .husky/pre-commit"
echo "  .lintstagedrc.json"
echo ""
echo "Pre-commit will now run linting on staged files."
