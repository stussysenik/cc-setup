# cc-setup Reference Guide

Your complete encyclopedia. Learn this as your CLI.

---

## Quick Mental Model

```
cc-setup gives you:
1. SHELLS      → Development environments (pick one per project)
2. COMMANDS    → Functions that do things (type and run)
3. TOOLS       → Programs in your PATH (use directly)
4. PHILOSOPHY  → Patterns to follow (optional but recommended)
```

---

## Part 1: Shells (Pick Your Environment)

**What is a shell?** A pre-configured environment with specific tools installed.

```bash
nix develop github:stussysenik/cc-setup#SHELL_NAME
```

### Core Shells (Start Here)

| Shell | When to Use | What's Inside |
|-------|-------------|---------------|
| `#default` | Don't know yet / exploring | Core tools only (git, security, DX) |
| `#web` | Any JavaScript/TypeScript | Node 22, Bun, Deno, pnpm, TypeScript |
| `#python` | ML, scripts, FastAPI | Python 3.12, uv, ruff, pip |
| `#rust` | CLI tools, systems, WASM | cargo, clippy, rust-analyzer |
| `#cpp` | C/C++, game engines | clang, cmake, ninja, gdb |
| `#full` | Want everything | All languages combined (~4GB) |

### Framework Shells (More Specific)

| Shell | When to Use | What's Added |
|-------|-------------|--------------|
| `#nextjs` | Building Next.js app | ESLint, `cna` (create-next-app) |
| `#react` | React + Vite | ESLint, `cra` (create vite react) |
| `#svelte` | SvelteKit | `sk` (sv create) |
| `#tailwind` | Styling with Tailwind | Prettier, `tw-init` |
| `#phoenix` | Elixir backend | Mix, Hex, PostgreSQL |

### Mobile/Desktop Shells

| Shell | When to Use | What's Added |
|-------|-------------|--------------|
| `#tauri` | Desktop app (Rust + Web) | Tauri CLI, webkitgtk |
| `#capacitor` | Mobile app (WebView) | Capacitor CLI, CocoaPods |
| `#react-native` | Mobile app (Native) | React Native CLI, Watchman |
| `#expo` | Mobile app (Easiest) | Expo CLI |
| `#ios` | iOS-specific work | CocoaPods, Fastlane |

### Specialized Shells

| Shell | When to Use | What's Added |
|-------|-------------|--------------|
| `#graphics` | OpenGL/Vulkan/WebGPU | glfw, shaderc, vulkan |
| `#wasm` | WebAssembly | wasm-pack, emscripten |
| `#asm` | Assembly language | nasm, gdb, objdump |
| `#nvim` | Want Neovim | Neovim + LSP servers |
| `#emacs` | Want Emacs | Emacs 29 + Org mode |
| `#api` | API development | OpenAPI generator |
| `#re` | Reverse engineering | Ghidra, Radare2 (~2GB) |

### How to Choose

```
Q: What am I building?

Web app          → #web (or #nextjs, #react, #svelte if you know)
Mobile app       → #expo (easiest) or #capacitor (web skills) or #react-native
Desktop app      → #tauri (Rust+Web) or #cpp (native)
CLI tool         → #rust or #go or #python
ML/AI            → #python
Game             → #cpp or #graphics
Learning         → #default (start minimal)
```

---

## Part 2: Commands (Things You Type)

### Claude Commands

| Command | What It Does | When to Use |
|---------|--------------|-------------|
| `cc` | Start Claude | Quick question or task |
| `ralph <task>` | Autonomous Claude (SAFE) | Let Claude work alone, creates exp branch |
| `ralph-yolo` | Autonomous Claude (DANGEROUS) | You're sure, current branch |
| `cct <task>` | Claude in tmux (SAFE) | Long task, want to disconnect |
| `cct-yolo` | Claude in tmux (DANGEROUS) | You're sure, current branch |

**Example:**
```bash
ralph auth-feature      # Creates exp/20260114-auth-feature, runs Claude there
cct payment-system      # Same but in tmux (survives disconnect)
```

### Branch Safety Commands

| Command | What It Does | When to Use |
|---------|--------------|-------------|
| `exp <name>` | Create experimental branch + worktree | Starting risky work |
| `wt-list` | List all worktrees | See what branches exist |
| `wt-rm <path>` | Remove a worktree | Done with experiment |
| `wt-prune` | Clean up stale worktrees | Housekeeping |

**Example:**
```bash
exp new-feature         # Creates exp/20260114-new-feature in ../worktrees/
cd ../worktrees/20260114-new-feature
# ... work safely ...
wt-rm ../worktrees/20260114-new-feature  # Delete if you don't like it
```

### Git Style: Stacked Diffs (Optional)

| Command | What It Does | When to Use |
|---------|--------------|-------------|
| `stack-init` | Enable stacked diffs in repo | Once per repo |
| `sl` | Smartlog (visual commit graph) | See your commits beautifully |
| `prev` | Go to parent commit | Navigate stack |
| `next` | Go to child commit | Navigate stack |
| `restack` | Rebase stack after changes | After editing parent commit |
| `submit` | Create PRs for stack | Ready for review |
| `absorb` | Auto-fixup staged changes | Fix earlier commit |
| `undo` | Undo last git operation | Made a mistake |

**Example workflow:**
```bash
stack-init              # Enable (once)
git commit -m "Add model"
git commit -m "Add API"
git commit -m "Add UI"
sl                      # See beautiful stack
submit                  # Create 3 linked PRs
```

### Verification Commands

| Command | What It Does | When to Use |
|---------|--------------|-------------|
| `verify` | Run ALL checks | Before saying "done" |
| `fmt` | Auto-fix formatting | Before commit |
| `check-secrets` | Scan for API keys | Before commit |
| `scan-vulns` | Security scan | Periodically |
| `audit` | Full security audit | Before release |

**Example:**
```bash
# Before every "I'm done":
verify                  # Must pass with 0 errors
```

### Setup Commands

| Command | What It Does | When to Use |
|---------|--------------|-------------|
| `init-project` | Copy all templates | New project |
| `init-husky` | Just pre-commit hooks | Want commit checks |
| `init-openspec` | Just spec templates | Want spec-driven dev |
| `init-docs` | Add ADR template | Want decision records |
| `adr 'title'` | Create new ADR | Making significant decision |

**Example:**
```bash
mkdir my-project && cd my-project
nix develop github:stussysenik/cc-setup#web
init-project            # Get all templates
git init && git add -A && git commit -m "init"
```

### Utility Commands

| Command | What It Does | When to Use |
|---------|--------------|-------------|
| `help-cc` | Show all commands | Forgot something |
| `watch <cmd>` | Re-run on file change | Development loop |
| `serve [port]` | Quick HTTP server | Test static files |
| `lg` | lazygit (git TUI) | Visual git |

---

## Part 3: Tools (Programs in PATH)

These are always available. Use them directly.

### Search & Navigation

| Tool | Replaces | Why Better |
|------|----------|------------|
| `rg` | grep | 10x faster, better defaults |
| `fd` | find | Intuitive syntax |
| `fzf` | - | Fuzzy find anything (Ctrl+R, Ctrl+T) |
| `z` | cd | Learns your frequent dirs |
| `bat` | cat | Syntax highlighting |
| `eza` | ls | Icons, git status |

**Note:** We don't alias these over POSIX commands. Use them directly:
```bash
rg "pattern" .          # Search (not grep)
fd "*.ts"               # Find files (not find)
bat file.txt            # View file (not cat)
```

### Git Tools

| Tool | What It Does |
|------|--------------|
| `lazygit` | Full git TUI |
| `delta` | Pretty diffs |
| `git-branchless` | Stacked diffs |
| `git-absorb` | Auto-fixup commits |

### API & Database

| Tool | What It Does |
|------|--------------|
| `xh` | HTTP client (like curl but pretty) |
| `hurl` | Run HTTP files |
| `posting` | TUI API client (like Postman) |
| `pgcli` | PostgreSQL with autocomplete |
| `litecli` | SQLite with autocomplete |
| `usql` | Universal SQL client |

### Observability

| Tool | What It Does |
|------|--------------|
| `hyperfine` | Benchmark commands |
| `btm` | Process monitor (bottom) |
| `httpstat` | curl with timing breakdown |
| `oha` | HTTP load testing |
| `tokei` | Lines of code stats |

### Security

| Tool | What It Does |
|------|--------------|
| `gitleaks` | Scan for secrets |
| `trivy` | Vulnerability scanner |

---

## Part 4: Philosophy (Patterns to Follow)

### The Three Rules

1. **Safe by default** - `ralph` and `cct` create experimental branches
2. **Verify before done** - Always run `verify` before claiming completion
3. **Start minimal** - Use `#default`, expand to specific shells when needed

### Git Style Choice

```
TRADITIONAL (fine for small projects):
  git commit → git push → PR → merge

STACKED DIFFS (better for complex work):
  stack-init → small commits → sl → submit → linked PRs
```

### Comment Style

```typescript
// BAD: What (redundant)
// Loop through users
for (const user of users) { }

// GOOD: Why (valuable)
// Filter inactive users - they're soft-deleted but retained for audit
const active = users.filter(u => u.isActive);
```

### The Verification Loop

```
while not done:
    write code
    verify        # format, lint, types, test, build, security
    if fails:
        fix
    else:
        done
```

---

## Part 5: Quick Recipes

### Start a New Project
```bash
mkdir my-app && cd my-app
nix develop github:stussysenik/cc-setup#web
init-project
git init && git add -A && git commit -m "init"
cct my-app
```

### Work on Existing Project
```bash
cd existing-project
nix develop github:stussysenik/cc-setup#web
ralph fix-bug           # Safe autonomous mode
```

### Try a New Language
```bash
nix develop github:stussysenik/cc-setup#rust
# ... experiment ...
exit                    # Nothing permanently installed
```

### Review Someone's Code
```bash
nix develop github:stussysenik/cc-setup#default
git clone <repo>
cd <repo>
sl                      # See commit structure
verify                  # Check quality
```

---

## Cheat Sheet (Print This)

```
SHELLS                          COMMANDS
───────────────────────────     ───────────────────────────
#default  Minimal               cc          Start Claude
#web      JavaScript            ralph       Safe autonomous
#python   Python/ML             cct         Safe Claude+tmux
#rust     Rust                  verify      Check everything
#full     Everything            help-cc     Show all commands

GIT STYLE                       SAFETY
───────────────────────────     ───────────────────────────
stack-init  Enable stacked      ralph       Safe (exp branch)
sl          See commits         ralph-yolo  Dangerous
submit      Create PRs          exp <name>  Create exp branch
absorb      Auto-fixup          wt-list     List worktrees

TOOLS (use directly)
───────────────────────────
rg      Search code             xh       HTTP client
fd      Find files              pgcli    PostgreSQL
bat     View files              lazygit  Git TUI
fzf     Fuzzy find (Ctrl+R)     btm      Process monitor
```
