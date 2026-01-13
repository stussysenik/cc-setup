# cc-setup

Portable Claude Code development environment using Nix flakes.

## Quick Start

### 1. Install Nix (one-time)

```bash
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install
```

Restart your terminal after installation.

### 2. Enter the Environment

**From anywhere:**
```bash
nix develop github:YOUR_USERNAME/cc-setup
```

**Or clone locally:**
```bash
git clone https://github.com/YOUR_USERNAME/cc-setup.git ~/cc-setup
nix develop ~/cc-setup
```

## What You Get

| Command | Description |
|---------|-------------|
| `cc` | Start Claude Code |
| `ralph` | Autonomous mode (skips permissions) |
| `cct [name]` | Claude in a tmux session |
| `init-husky` | Setup pre-commits in current project |

### Packages Included
- **Terminal**: tmux, alacritty
- **Node.js**: node 20, pnpm, bun
- **Linting**: eslint, prettier, biome
- **Testing**: playwright with browsers
- **Git**: git, gh (GitHub CLI)
- **Utils**: jq, curl, ripgrep, fd

### MCP Servers (Auto-loaded)
- `chrome-devtools` - Browser automation & performance
- `brave-search` - Web search for research

## Configuration

### Environment Variables

Set these in your shell profile for API keys:
```bash
export BRAVE_API_KEY="your-brave-api-key"
```

### Customizing Configs

After entering the nix shell, configs are symlinked:
- `~/.claude/settings.json` → MCP servers
- `~/.claude/CLAUDE.md` → Global instructions

To use the terminal configs:
```bash
# tmux
cp ~/cc-setup/config/tmux.conf ~/.tmux.conf

# alacritty
mkdir -p ~/.config/alacritty
cp ~/cc-setup/config/alacritty.toml ~/.config/alacritty/
```

## Updating

When you add new packages or update configs:

```bash
# Push changes
git add . && git commit -m "Add new tool" && git push

# On any machine, get updates:
nix flake update
nix develop github:YOUR_USERNAME/cc-setup
```

## Ralph Wiggum Mode

Autonomous execution mode for persistent iteration:

```bash
ralph "implement the feature described in SPEC.md"
```

Ralph will:
1. Run until task complete or error
2. Persist through failures (errors = data)
3. Output `RALPH_COMPLETE` when done

Best used with tmux for session persistence:
```bash
cct ralph-session
# Then run ralph inside the session
```

## Project Structure

```
cc-setup/
├── flake.nix              # Nix packages & shell config
├── flake.lock             # Locked versions
├── config/
│   ├── claude/
│   │   ├── settings.json  # MCP servers
│   │   └── CLAUDE.md      # Global Claude instructions
│   ├── tmux.conf          # tmux configuration
│   └── alacritty.toml     # Terminal theme
└── scripts/
    ├── init-husky.sh      # Pre-commit setup
    └── ralph.sh           # Standalone ralph launcher
```

## Troubleshooting

### Nix command not found
Restart your terminal or run:
```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

### Playwright browsers not found
The `PLAYWRIGHT_BROWSERS_PATH` is set automatically. If issues persist:
```bash
npx playwright install
```

### MCP servers not loading
Ensure `~/.claude/settings.json` is symlinked correctly:
```bash
ls -la ~/.claude/settings.json
```
