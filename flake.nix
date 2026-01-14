{
  description = "cc-setup: Dev environment boilerplate with security baked in";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # ══════════════════════════════════════════════════════════════════
        # CORE: Always included (Security + MCPs + DX)
        # ══════════════════════════════════════════════════════════════════
        corePkgs = with pkgs; [
          # ─── Session & Terminal ───
          tmux
          direnv
          nix-direnv

          # ─── CLI Improvements (DX) ───
          bat               # cat with syntax highlighting
          eza               # ls with icons
          fd                # find but intuitive
          ripgrep           # grep but fast
          fzf               # fuzzy finder
          zoxide            # smart cd
          jq                # JSON processor
          yq                # YAML processor
          delta             # pretty git diffs
          lazygit           # git TUI

          # ─── Task Running ───
          just              # language-agnostic Makefile
          watchexec         # watch files, run commands

          # ─── Security (ALWAYS INCLUDED) ───
          gitleaks          # scan for leaked secrets
          trivy             # vulnerability scanner
          # semgrep         # (large, optional - use via npx)

          # ─── Infrastructure CLIs ───
          supabase-cli      # database management
          nodePackages.vercel # deployment
          gh                # GitHub CLI
          git

          # ─── Browser Automation (MCPs) ───
          playwright-driver.browsers
          chromium
        ];

        # ══════════════════════════════════════════════════════════════════
        # LANGUAGE PACKS
        # ══════════════════════════════════════════════════════════════════

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
          ruff
          uv
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
          sbcl
        ];

        rubyPkgs = with pkgs; [
          ruby_3_3
          bundler
        ];

        # ══════════════════════════════════════════════════════════════════
        # SHELL HOOK
        # ══════════════════════════════════════════════════════════════════
        commonShellHook = ''
          # ─── Claude Config ───
          mkdir -p ~/.claude
          ln -sf ${self}/config/claude/settings.json ~/.claude/settings.json 2>/dev/null || true
          ln -sf ${self}/config/claude/CLAUDE.md ~/.claude/CLAUDE.md 2>/dev/null || true

          # ─── Environment ───
          export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
          export CHROME_PATH=${pkgs.chromium}/bin/chromium
          export CC_SETUP_DIR="${self}"

          # ─── Direnv ───
          eval "$(direnv hook bash 2>/dev/null || direnv hook zsh 2>/dev/null || true)"

          # ─── Zoxide ───
          eval "$(zoxide init bash 2>/dev/null || zoxide init zsh 2>/dev/null || true)"

          # ─── FZF ───
          eval "$(fzf --bash 2>/dev/null || fzf --zsh 2>/dev/null || true)"

          # ─── Aliases ───
          alias cat='bat --paging=never'
          alias ls='eza --icons'
          alias ll='eza -la --icons --git'
          alias find='fd'
          alias grep='rg'
          alias diff='delta'

          # ═══════════════════════════════════════════════════════════════
          # CLAUDE FUNCTIONS
          # ═══════════════════════════════════════════════════════════════

          cc() { claude "$@"; }

          ralph() {
            echo "🤖 Ralph Wiggum autonomous mode"
            claude --dangerously-skip-permissions "$@"
          }

          cct() {
            local name="''${1:-claude-$(basename $(pwd))}"
            tmux has-session -t "$name" 2>/dev/null && tmux attach -t "$name" || tmux new-session -s "$name" "claude"
          }

          # ═══════════════════════════════════════════════════════════════
          # PROJECT SETUP FUNCTIONS
          # ═══════════════════════════════════════════════════════════════

          init-project() {
            source ${self}/scripts/init-project.sh "$@"
          }

          init-husky() {
            source ${self}/scripts/init-husky.sh "$@"
          }

          init-openspec() {
            mkdir -p openspec/specs
            cp ${self}/templates/openspec/*.md openspec/
            echo "✅ OpenSpec initialized"
          }

          # ═══════════════════════════════════════════════════════════════
          # SECURITY FUNCTIONS
          # ═══════════════════════════════════════════════════════════════

          check-secrets() {
            if [[ -f "scripts/check-secrets.js" ]]; then
              node scripts/check-secrets.js
            else
              echo "Running gitleaks..."
              gitleaks detect --source . --verbose
            fi
          }

          scan-vulns() {
            echo "🔍 Scanning for vulnerabilities..."
            trivy fs . --severity HIGH,CRITICAL
          }

          audit() {
            echo "🔒 Running full security audit..."
            echo ""
            echo "=== Secret Detection ==="
            check-secrets || true
            echo ""
            echo "=== Vulnerability Scan ==="
            scan-vulns || true
            echo ""
            echo "=== Dependency Audit ==="
            npm audit 2>/dev/null || bun pm audit 2>/dev/null || pnpm audit 2>/dev/null || echo "No package manager found"
          }

          # ═══════════════════════════════════════════════════════════════
          # UTILITY FUNCTIONS
          # ═══════════════════════════════════════════════════════════════

          watch() { watchexec --clear --restart -- "$@"; }
          serve() { python3 -m http.server "''${1:-8000}" 2>/dev/null || npx serve -p "''${1:-8000}"; }

          # ─── Welcome ───
          echo ""
          echo "╔═══════════════════════════════════════════════════════════════╗"
          echo "║  🛠️  cc-setup: Dev Environment Boilerplate                     ║"
          echo "╠═══════════════════════════════════════════════════════════════╣"
          echo "║  CLAUDE        cc | ralph | cct                               ║"
          echo "║  SETUP         init-project | init-husky | init-openspec      ║"
          echo "║  SECURITY      check-secrets | scan-vulns | audit             ║"
          echo "║  NAVIGATION    z (smart cd) | Ctrl+R (fuzzy history)          ║"
          echo "╚═══════════════════════════════════════════════════════════════╝"
          echo ""
        '';

      in {
        devShells = {
          # ══════════════════════════════════════════════════════════════
          # DEFAULT: Core only
          # ══════════════════════════════════════════════════════════════
          default = pkgs.mkShell {
            packages = corePkgs;
            shellHook = commonShellHook;
          };

          # ══════════════════════════════════════════════════════════════
          # WEB: JS/TS development
          # ══════════════════════════════════════════════════════════════
          web = pkgs.mkShell {
            packages = corePkgs ++ webPkgs;
            shellHook = commonShellHook;
          };

          # ══════════════════════════════════════════════════════════════
          # AI: Python + ML
          # ══════════════════════════════════════════════════════════════
          ai = pkgs.mkShell {
            packages = corePkgs ++ pythonPkgs;
            shellHook = commonShellHook;
          };

          # ══════════════════════════════════════════════════════════════
          # SYSTEMS: C/C++/Zig/Go
          # ══════════════════════════════════════════════════════════════
          systems = pkgs.mkShell {
            packages = corePkgs ++ systemsPkgs;
            shellHook = commonShellHook;
          };

          # ══════════════════════════════════════════════════════════════
          # FINTECH: Elixir + Python
          # ══════════════════════════════════════════════════════════════
          fintech = pkgs.mkShell {
            packages = corePkgs ++ elixirPkgs ++ pythonPkgs;
            shellHook = commonShellHook;
          };

          # ══════════════════════════════════════════════════════════════
          # LISP: Common Lisp
          # ══════════════════════════════════════════════════════════════
          lisp = pkgs.mkShell {
            packages = corePkgs ++ lispPkgs;
            shellHook = commonShellHook;
          };

          # ══════════════════════════════════════════════════════════════
          # FULL: Everything
          # ══════════════════════════════════════════════════════════════
          full = pkgs.mkShell {
            packages = corePkgs ++ webPkgs ++ pythonPkgs ++ systemsPkgs ++ elixirPkgs ++ rubyPkgs ++ lispPkgs;
            shellHook = commonShellHook;
          };
        };
      });
}
