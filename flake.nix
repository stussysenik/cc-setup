{
  description = "Portable Claude Code environment - minimal core";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # ════════════════════════════════════════════════════════════
        # CORE: Always included (Claude + DX essentials)
        # ════════════════════════════════════════════════════════════
        corePkgs = with pkgs; [
          # Session & Terminal
          tmux

          # Environment auto-loading
          direnv
          nix-direnv

          # Essential CLI improvements
          bat               # cat with syntax highlighting
          eza               # ls with icons
          fd                # find but intuitive
          ripgrep           # grep but fast
          fzf               # fuzzy finder (Ctrl+R magic)
          zoxide            # cd that learns
          jq                # JSON

          # Git
          git
          gh
          delta             # pretty diffs
          lazygit           # TUI

          # Task running
          just              # language-agnostic Makefile
          watchexec         # watch files, run commands

          # Browser automation (for Claude MCPs)
          playwright-driver.browsers
          chromium
        ];

        # ════════════════════════════════════════════════════════════
        # LANGUAGE PACKS (mix and match)
        # ════════════════════════════════════════════════════════════

        webPkgs = with pkgs; [
          nodejs_22
          bun
          deno
          nodePackages.pnpm
          nodePackages.typescript
          biome
        ];

        pythonPkgs = with pkgs; [
          python312
          python312Packages.pip
          python312Packages.virtualenv
          ruff              # fast Python linter
          uv                # fast pip replacement
        ];

        systemsPkgs = with pkgs; [
          zig
          go
          gcc
          gnumake
          cmake
          gdb
          valgrind
        ];

        elixirPkgs = with pkgs; [
          elixir
          erlang
        ];

        lispPkgs = with pkgs; [
          sbcl              # Steel Bank Common Lisp
          # quicklisp via sbcl
        ];

        rubyPkgs = with pkgs; [
          ruby_3_3
          bundler
        ];

        kotlinSwiftPkgs = with pkgs; [
          kotlin
          # swift via xcode on macOS
        ];

        # ════════════════════════════════════════════════════════════
        # SHELL HOOK (same for all variants)
        # ════════════════════════════════════════════════════════════
        commonShellHook = ''
          # === Claude Config ===
          mkdir -p ~/.claude
          ln -sf ${self}/config/claude/settings.json ~/.claude/settings.json 2>/dev/null || true
          ln -sf ${self}/config/claude/CLAUDE.md ~/.claude/CLAUDE.md 2>/dev/null || true

          # === Environment ===
          export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
          export CHROME_PATH=${pkgs.chromium}/bin/chromium

          # === Direnv ===
          eval "$(direnv hook bash 2>/dev/null || direnv hook zsh 2>/dev/null || true)"

          # === Zoxide (smart cd) ===
          eval "$(zoxide init bash 2>/dev/null || zoxide init zsh 2>/dev/null || true)"

          # === FZF keybindings ===
          eval "$(fzf --bash 2>/dev/null || fzf --zsh 2>/dev/null || true)"

          # === Aliases ===
          alias cat='bat --paging=never'
          alias ls='eza --icons'
          alias ll='eza -la --icons --git'
          alias find='fd'
          alias grep='rg'
          alias diff='delta'

          # === Claude Functions ===
          cc() { claude "$@"; }

          ralph() {
            echo "🤖 Ralph Wiggum autonomous mode"
            claude --dangerously-skip-permissions "$@"
          }

          cct() {
            local name="''${1:-claude-$(basename $(pwd))}"
            tmux has-session -t "$name" 2>/dev/null && tmux attach -t "$name" || tmux new-session -s "$name" "claude"
          }

          watch() { watchexec --clear --restart -- "$@"; }
          serve() { python3 -m http.server "''${1:-8000}" 2>/dev/null || npx serve -p "''${1:-8000}"; }

          # === Welcome ===
          echo "🤖 cc | ralph | cct    📁 z (smart cd)    🔍 Ctrl+R (fuzzy history)"
        '';

      in {
        devShells = {
          # ════════════════════════════════════════════════════════════
          # DEFAULT: Core only (minimal)
          # ════════════════════════════════════════════════════════════
          default = pkgs.mkShell {
            packages = corePkgs;
            shellHook = commonShellHook;
          };

          # ════════════════════════════════════════════════════════════
          # WEB: JS/TS development
          # ════════════════════════════════════════════════════════════
          web = pkgs.mkShell {
            packages = corePkgs ++ webPkgs;
            shellHook = commonShellHook;
          };

          # ════════════════════════════════════════════════════════════
          # AI-ML: Python + data science
          # ════════════════════════════════════════════════════════════
          ai = pkgs.mkShell {
            packages = corePkgs ++ pythonPkgs;
            shellHook = commonShellHook;
          };

          # ════════════════════════════════════════════════════════════
          # SYSTEMS: C/C++/Zig/Go (low-level)
          # ════════════════════════════════════════════════════════════
          systems = pkgs.mkShell {
            packages = corePkgs ++ systemsPkgs;
            shellHook = commonShellHook;
          };

          # ════════════════════════════════════════════════════════════
          # FULL: Web + Python + Systems (your main stack)
          # ════════════════════════════════════════════════════════════
          full = pkgs.mkShell {
            packages = corePkgs ++ webPkgs ++ pythonPkgs ++ systemsPkgs ++ elixirPkgs ++ rubyPkgs;
            shellHook = commonShellHook;
          };

          # ════════════════════════════════════════════════════════════
          # FINTECH: Elixir + Python (fault-tolerant + data)
          # ════════════════════════════════════════════════════════════
          fintech = pkgs.mkShell {
            packages = corePkgs ++ elixirPkgs ++ pythonPkgs;
            shellHook = commonShellHook;
          };

          # ════════════════════════════════════════════════════════════
          # LISP: Common Lisp exploration
          # ════════════════════════════════════════════════════════════
          lisp = pkgs.mkShell {
            packages = corePkgs ++ lispPkgs;
            shellHook = commonShellHook;
          };
        };
      });
}
