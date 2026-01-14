# cc-setup

Portable Claude Code environment with language-specific shells.

## Quick Start

```bash
# 1. Install Nix (one-time)
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install

# 2. Use it
nix develop github:stussysenik/cc-setup#web      # JS/TS project
nix develop github:stussysenik/cc-setup#ai       # Python/ML project
nix develop github:stussysenik/cc-setup#systems  # C/Zig/Go project
nix develop github:stussysenik/cc-setup#full     # Everything
```

## Available Shells

| Shell | Command | Languages |
|-------|---------|-----------|
| **default** | `nix develop` | Core tools only (Claude + DX) |
| **web** | `nix develop .#web` | Node 22, Bun, Deno, pnpm, Biome |
| **ai** | `nix develop .#ai` | Python 3.12, uv, ruff |
| **systems** | `nix develop .#systems` | Zig, Go, GCC, CMake, GDB |
| **fintech** | `nix develop .#fintech` | Elixir, Erlang, Python |
| **lisp** | `nix develop .#lisp` | SBCL (Common Lisp) |
| **full** | `nix develop .#full` | All of the above |

## What's Always Included (Core)

**Claude Code:**
- `cc` - Start Claude
- `ralph` - Autonomous mode (runs until done)
- `cct` - Claude in tmux session

**MCPs (auto-loaded):**
- chrome-devtools (browser automation)
- brave-search (web research)
- playwright (E2E testing)

**DX Tools:**
- `tmux` - Session persistence
- `fzf` - Ctrl+R fuzzy history, Ctrl+T fuzzy files
- `zoxide` - `z` command (smart cd)
- `bat` - Syntax-highlighted cat
- `eza` - ls with icons
- `lazygit` - Git TUI
- `just` - Task runner
- `watchexec` - File watcher

## The Workflow

### Example: ~/Desktop/clean-writer (web project)

```bash
# Open terminal (Alacritty or any)
cd ~/Desktop/clean-writer

# Enter web environment
nix develop github:stussysenik/cc-setup#web

# Start Claude in persistent tmux session
cct clean-writer

# Or run autonomous mode
ralph "implement the feature in SPEC.md"
```

### Example: ~/Desktop/trading-bot (fintech)

```bash
cd ~/Desktop/trading-bot
nix develop github:stussysenik/cc-setup#fintech
cct trading
```

## Per-Project Auto-Loading (direnv)

Create `.envrc` in any project:

```bash
# ~/Desktop/clean-writer/.envrc
use flake github:stussysenik/cc-setup#web
```

Then:
```bash
direnv allow
```

Now every `cd ~/Desktop/clean-writer` auto-loads the environment.

## How It Fits Together

```
┌─────────────────────────────────────────────────┐
│  Terminal (Alacritty/iTerm/any)                 │
│  ┌───────────────────────────────────────────┐  │
│  │  tmux (session survives disconnects)      │  │
│  │  ┌─────────────────────────────────────┐  │  │
│  │  │  Nix Shell (#web, #ai, #systems)    │  │  │
│  │  │  ┌───────────────────────────────┐  │  │  │
│  │  │  │  Claude + MCPs                │  │  │  │
│  │  │  │  (ralph for autonomous)       │  │  │  │
│  │  │  └───────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

## Commands Reference

| Command | What it does |
|---------|--------------|
| `cc` | Start Claude |
| `ralph "task"` | Autonomous mode until task complete |
| `cct [name]` | Claude in tmux (persistent) |
| `z dir` | Jump to frequent directory |
| `Ctrl+R` | Fuzzy search command history |
| `Ctrl+T` | Fuzzy find files |
| `watch cmd` | Run cmd on file changes |
| `serve [port]` | Quick HTTP server |
| `lazygit` | Git TUI |

## Updating

```bash
# Edit flake.nix locally
cd ~/Desktop/cc-setup
# Make changes...
git add . && git commit -m "Add X" && git push

# On any machine, get updates:
nix flake update
```

## FAQ

**Alacritty?**
It's just a fast terminal. Install separately: `nix profile install nixpkgs#alacritty`

**First run slow?**
Yes, Nix downloads everything once. Then it's cached.

**Add a language?**
Edit `flake.nix`, add to the relevant `*Pkgs` list.
