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
            # === Terminal & Session ===
            tmux
            alacritty

            # === Node.js Ecosystem ===
            nodejs_20
            nodePackages.pnpm
            bun

            # === Linting & Formatting ===
            nodePackages.eslint
            nodePackages.prettier
            biome

            # === Git & Workflow ===
            git
            gh  # GitHub CLI
            husky

            # === Browser Automation ===
            playwright-driver.browsers
            chromium

            # === Utilities ===
            jq
            curl
            ripgrep
            fd
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

            # === Welcome ===
            echo ""
            echo "╔══════════════════════════════════════════╗"
            echo "║  🤖 Claude Code Environment Ready        ║"
            echo "╠══════════════════════════════════════════╣"
            echo "║  cc          Start Claude                ║"
            echo "║  ralph       Autonomous mode             ║"
            echo "║  cct [name]  Claude in tmux session      ║"
            echo "║  init-husky  Setup pre-commits           ║"
            echo "╚══════════════════════════════════════════╝"
            echo ""
          '';
        };
      });
}
