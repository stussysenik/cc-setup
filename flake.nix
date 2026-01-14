{
  description = "Portable Claude Code development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # ══════════════════════════════════════════
            # TERMINAL & SESSION
            # ══════════════════════════════════════════
            tmux              # Session persistence
            alacritty         # GPU-accelerated terminal
            zellij            # Modern tmux alternative

            # ══════════════════════════════════════════
            # ENVIRONMENT MANAGEMENT (DX!)
            # ══════════════════════════════════════════
            direnv            # Auto-load env per directory
            nix-direnv        # Faster direnv for nix

            # ══════════════════════════════════════════
            # JAVASCRIPT/TYPESCRIPT RUNTIMES
            # ══════════════════════════════════════════
            nodejs_22         # LTS (latest)
            bun               # Fast runtime + bundler
            deno              # Secure runtime with TS

            # ══════════════════════════════════════════
            # PACKAGE MANAGERS
            # ══════════════════════════════════════════
            nodePackages.pnpm # Fast, disk-efficient
            yarn              # Classic alternative

            # ══════════════════════════════════════════
            # TASK RUNNERS (Language-Agnostic!)
            # ══════════════════════════════════════════
            just              # Better Makefile (any language)
            watchexec         # Run commands on file changes
            entr              # Simpler file watcher

            # ══════════════════════════════════════════
            # LINTING & FORMATTING
            # ══════════════════════════════════════════
            nodePackages.eslint
            nodePackages.prettier
            biome             # Fast linter + formatter
            shellcheck        # Bash/shell linting
            shfmt             # Shell formatting
            actionlint        # GitHub Actions linting
            yamllint          # YAML linting

            # ══════════════════════════════════════════
            # GIT & VERSION CONTROL
            # ══════════════════════════════════════════
            git
            gh                # GitHub CLI
            git-lfs           # Large file storage
            delta             # Beautiful diffs
            lazygit           # TUI for git

            # ══════════════════════════════════════════
            # BETTER CLI TOOLS (Ergonomics!)
            # ══════════════════════════════════════════
            bat               # cat with syntax highlighting
            eza               # ls with colors + git status
            fd                # find but faster + intuitive
            ripgrep           # grep but faster
            fzf               # Fuzzy finder (Ctrl+R magic)
            zoxide            # cd that learns (z command)
            sd                # sed but intuitive
            du-dust           # du but visual
            procs             # ps but better
            bottom            # htop but prettier

            # ══════════════════════════════════════════
            # HTTP & API TOOLS
            # ══════════════════════════════════════════
            curl
            httpie            # curl for humans
            xh                # httpie but faster (Rust)
            jq                # JSON processor
            yq                # YAML processor
            fx                # Interactive JSON viewer

            # ══════════════════════════════════════════
            # CONTAINERS & INFRA
            # ══════════════════════════════════════════
            docker-compose    # Multi-container orchestration
            lazydocker        # TUI for Docker
            dive              # Explore docker layers
            k9s               # Kubernetes TUI

            # ══════════════════════════════════════════
            # BROWSER AUTOMATION
            # ══════════════════════════════════════════
            playwright-driver.browsers
            chromium

            # ══════════════════════════════════════════
            # SECRETS & SECURITY
            # ══════════════════════════════════════════
            age               # Modern encryption
            sops              # Encrypted secrets in git
            git-crypt         # Transparent file encryption

            # ══════════════════════════════════════════
            # MISC UTILITIES
            # ══════════════════════════════════════════
            tokei             # Count lines of code
            hyperfine         # Benchmarking tool
            tealdeer          # Fast tldr pages
          ];

          shellHook = ''
            # === Setup Claude Config ===
            mkdir -p ~/.claude

            # Symlink configs (only if not already correct)
            if [ ! -L ~/.claude/settings.json ] || [ "$(readlink ~/.claude/settings.json)" != "${self}/config/claude/settings.json" ]; then
              ln -sf ${self}/config/claude/settings.json ~/.claude/settings.json
            fi

            if [ ! -L ~/.claude/CLAUDE.md ] || [ "$(readlink ~/.claude/CLAUDE.md)" != "${self}/config/claude/CLAUDE.md" ]; then
              ln -sf ${self}/config/claude/CLAUDE.md ~/.claude/CLAUDE.md
            fi

            # === Environment Variables ===
            export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
            export CHROME_PATH=${pkgs.chromium}/bin/chromium

            # === Direnv hook (if shell supports it) ===
            if command -v direnv &> /dev/null; then
              eval "$(direnv hook bash 2>/dev/null || direnv hook zsh 2>/dev/null || true)"
            fi

            # === Better tool aliases ===
            alias cat='bat --paging=never'
            alias ls='eza --icons'
            alias ll='eza -la --icons --git'
            alias tree='eza --tree --icons'
            alias find='fd'
            alias grep='rg'
            alias diff='delta'
            alias top='btm'
            alias du='dust'
            alias ps='procs'
            alias sed='sd'
            alias man='tldr'
            alias http='xh'

            # === Zoxide (smarter cd) ===
            if command -v zoxide &> /dev/null; then
              eval "$(zoxide init bash 2>/dev/null || zoxide init zsh 2>/dev/null || true)"
            fi

            # === FZF key bindings ===
            if command -v fzf &> /dev/null; then
              eval "$(fzf --bash 2>/dev/null || fzf --zsh 2>/dev/null || true)"
            fi

            # === Shell Functions ===

            # Start Claude
            cc() { claude "$@"; }

            # Ralph Wiggum autonomous mode
            ralph() {
              echo "🤖 Starting Ralph Wiggum autonomous loop..."
              echo "   Exit with: RALPH_COMPLETE or Ctrl+C"
              claude --dangerously-skip-permissions "$@"
            }

            # Claude in tmux session
            cct() {
              local name="''${1:-claude-$(basename $(pwd))}"
              if tmux has-session -t "$name" 2>/dev/null; then
                tmux attach -t "$name"
              else
                tmux new-session -s "$name" "claude"
              fi
            }

            # Initialize husky in current project
            init-husky() {
              source ${self}/scripts/init-husky.sh
            }

            # Watch and run (e.g., "watch npm test")
            watch() {
              watchexec --clear --restart -- "$@"
            }

            # Quick HTTP server
            serve() {
              local port="''${1:-8000}"
              echo "Serving at http://localhost:$port"
              python3 -m http.server "$port" 2>/dev/null || npx serve -p "$port"
            }

            # === Welcome ===
            echo ""
            echo "╔═══════════════════════════════════════════════════════════╗"
            echo "║  🤖 Claude Code Environment Ready                         ║"
            echo "╠═══════════════════════════════════════════════════════════╣"
            echo "║  CLAUDE                                                   ║"
            echo "║    cc            Start Claude                             ║"
            echo "║    ralph         Autonomous mode                          ║"
            echo "║    cct [name]    Claude in tmux session                   ║"
            echo "╠═══════════════════════════════════════════════════════════╣"
            echo "║  WORKFLOW                                                 ║"
            echo "║    init-husky    Setup pre-commits                        ║"
            echo "║    watch <cmd>   Run command on file changes              ║"
            echo "║    serve [port]  Quick HTTP server                        ║"
            echo "╠═══════════════════════════════════════════════════════════╣"
            echo "║  NAVIGATION (type 'z' to jump to frequent dirs)           ║"
            echo "║    Ctrl+R        Fuzzy search command history             ║"
            echo "║    Ctrl+T        Fuzzy find files                         ║"
            echo "╚═══════════════════════════════════════════════════════════╝"
            echo ""
          '';
        };
      });
}
