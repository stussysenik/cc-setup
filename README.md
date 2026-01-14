# cc-setup

Portable, language-agnostic development environment using Nix flakes.

**One command. Any machine. Identical environment.**

```bash
nix develop github:stussysenik/cc-setup
```

## Quick Start

### 1. Install Nix (one-time)

```bash
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install
```

Restart your terminal.

### 2. Enter the Environment

```bash
nix develop github:stussysenik/cc-setup
```

That's it. You now have 50+ tools ready to use.

## What's Included

### Claude Code
| Command | Description |
|---------|-------------|
| `cc` | Start Claude Code |
| `ralph` | Autonomous mode (Ralph Wiggum loop) |
| `cct [name]` | Claude in a tmux session |
| `init-husky` | Setup pre-commits in current project |

### JS/TS Runtimes
- **Node.js 22** (LTS)
- **Bun** (fast runtime + bundler)
- **Deno** (secure, TS-first)
- **pnpm, yarn** (package managers)

### Better CLI Tools (Ergonomics!)
| Old | New | Why |
|-----|-----|-----|
| `cat` | `bat` | Syntax highlighting |
| `ls` | `eza` | Colors, icons, git status |
| `find` | `fd` | Faster, intuitive syntax |
| `grep` | `rg` | 10x faster (ripgrep) |
| `cd` | `z` | Learns your frequent dirs |
| `sed` | `sd` | Human-readable syntax |
| `du` | `dust` | Visual disk usage |
| `ps` | `procs` | Better process viewer |
| `top` | `btm` | Beautiful system monitor |
| `man` | `tldr` | Examples, not essays |
| `curl` | `xh` | HTTPie but faster |

### Workflow Tools
| Tool | Purpose |
|------|---------|
| `just` | Language-agnostic task runner (better Makefile) |
| `watchexec` | Run commands on file changes |
| `fzf` | Fuzzy finder (Ctrl+R = magic) |
| `direnv` | Auto-load env per directory |
| `lazygit` | TUI for git |
| `lazydocker` | TUI for Docker |
| `k9s` | TUI for Kubernetes |

### Linting & Formatting
- **biome** - Fast linter + formatter (JS/TS)
- **eslint, prettier** - Classic combo
- **shellcheck, shfmt** - Bash linting
- **actionlint** - GitHub Actions linting
- **yamllint** - YAML validation

### Secrets & Security
- **age** - Modern encryption (like GPG but simple)
- **sops** - Encrypt secrets in git
- **git-crypt** - Transparent file encryption

### Containers & Infra
- **docker-compose** - Multi-container apps
- **dive** - Explore docker image layers
- **k9s** - Kubernetes dashboard in terminal

## Navigation Superpowers

After entering the shell:

```bash
# Fuzzy search command history
Ctrl+R

# Fuzzy find files
Ctrl+T

# Jump to frequently used directories
z projects    # goes to ~/projects if you've been there
z my          # goes to ~/Desktop/mymind-clone

# Interactive JSON
cat data.json | fx
```

## Environment Variables

Set these in your `~/.bashrc` or `~/.zshrc`:

```bash
export BRAVE_API_KEY="your-brave-api-key"
```

## Direnv Integration

For per-project auto-loading, create `.envrc` in any project:

```bash
# .envrc
use flake github:stussysenik/cc-setup

# Project-specific vars
export DATABASE_URL="postgres://localhost/mydb"
```

Then: `direnv allow`

Now every time you `cd` into that project, the environment loads automatically.

## Updating

```bash
# You: edit flake.nix, add tools
git add . && git commit -m "Add tool X" && git push

# Anyone (including future you on another machine):
nix flake update
nix develop github:stussysenik/cc-setup
```

## The Nix Mental Model

```
┌─────────────────────────────────────────────────────────────┐
│  nix develop github:stussysenik/cc-setup                    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  1. Download flake.nix + flake.lock from GitHub             │
│  2. Read flake.lock → exact package versions (hashes)       │
│  3. Download packages to /nix/store/abc123-nodejs-22/       │
│  4. Enter shell with all tools in PATH                      │
│  5. Run shellHook (symlinks, aliases, functions)            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  nix flake update                                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  1. Check nixpkgs for latest commit                         │
│  2. Update flake.lock with new hashes                       │
│  3. Next `nix develop` gets newer versions                  │
└─────────────────────────────────────────────────────────────┘
```

## Project Structure

```
cc-setup/
├── flake.nix              # All packages + shell config
├── flake.lock             # Pinned versions (reproducibility!)
├── config/
│   ├── claude/
│   │   ├── settings.json  # MCP servers
│   │   └── CLAUDE.md      # Global Claude instructions
│   ├── tmux.conf          # Session config
│   └── alacritty.toml     # Terminal theme (Tokyo Night)
└── scripts/
    ├── init-husky.sh      # Pre-commit setup
    └── ralph.sh           # Standalone autonomous launcher
```

## FAQ

**Q: First run is slow?**
A: Nix downloads and caches everything. Subsequent runs are instant.

**Q: How to add Python/Rust/Go?**
A: Edit `flake.nix`, add to packages list:
```nix
python312
rustc cargo
go
```

**Q: Works on macOS?**
A: Yes! Nix works on Linux and macOS. Same flake, same tools.

**Q: How to remove everything?**
A: `nix-collect-garbage -d` removes unused packages.
