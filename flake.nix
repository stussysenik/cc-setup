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

          # ─── Observability (Minimalist but Powerful) ───
          hyperfine         # CLI benchmarking
          tokei             # code statistics (LOC)
          bottom            # process monitor (btm)
          httpstat          # curl with timing breakdown
          oha               # HTTP load testing
          dog               # DNS lookup with timing

          # ─── API Development ───
          xh                # httpie in Rust (fast, colorful)
          hurl              # HTTP requests from files
          curlie            # curl + httpie syntax
          posting           # TUI API client (like Postman)

          # ─── Database CLIs ───
          pgcli             # PostgreSQL with autocomplete
          litecli           # SQLite with autocomplete
          usql              # Universal SQL client

          # ─── Infrastructure CLIs ───
          supabase-cli      # database management
          nodePackages.vercel # deployment
          gh                # GitHub CLI
          git

          # ─── Stacked Diffs (Modern Git Workflow) ───
          git-branchless    # stacked commits, undo, smartlog
          git-absorb        # auto-fixup commits to right place

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
        # SYSTEMS LANGUAGES (Focused)
        # ══════════════════════════════════════════════════════════════════

        rustPkgs = with pkgs; [
          rustc
          cargo
          rustfmt
          clippy
          rust-analyzer
          cargo-watch       # watch and rebuild
          cargo-edit        # cargo add/rm
          cargo-nextest     # better test runner
        ];

        cppPkgs = with pkgs; [
          clang
          clang-tools       # clangd, clang-format
          cmake
          ninja
          ccache            # compilation cache
          gdb
          lldb
          valgrind
          meson             # modern build system
          pkg-config
        ];

        nimPkgs = with pkgs; [
          nim
          nimble            # package manager
          nimlsp            # language server
        ];

        # ══════════════════════════════════════════════════════════════════
        # MOBILE / CROSS-PLATFORM
        # ══════════════════════════════════════════════════════════════════

        # iOS requires macOS - these are CLI tools that work on Linux for CI
        iosPkgs = with pkgs; [
          cocoapods         # dependency manager
          fastlane          # automation
          xcpretty          # xcodebuild output formatter
        ];

        # Reverse Engineering (Heavy - separate shell)
        rePkgs = with pkgs; [
          ghidra            # NSA's RE tool
          radare2           # Lighter RE framework
          binwalk           # Firmware analysis
          file              # File type detection
          hexyl             # Hex viewer (like xxd but pretty)
          binutils          # objdump, nm, strings
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
          # STACKED DIFFS (git-branchless)
          # ═══════════════════════════════════════════════════════════════

          # Initialize git-branchless in repo (run once per repo)
          stack-init() {
            git branchless init
            echo "✅ Stacked diffs enabled. Use 'sl' for smartlog"
          }

          # Smartlog - visual commit graph (THE main command)
          alias sl='git branchless smartlog'

          # Navigation
          alias prev='git branchless prev'
          alias next='git branchless next'

          # Restack after changes to parent commits
          alias restack='git branchless restack'

          # Undo last git operation
          alias undo='git branchless undo'

          # Submit stack for review (creates PRs)
          alias submit='git branchless submit'

          # Auto-absorb staged changes into correct commits
          alias absorb='git absorb --and-rebase'

          # ═══════════════════════════════════════════════════════════════
          # BRANCH SAFETY (Worktrees for Agent Isolation)
          # ═══════════════════════════════════════════════════════════════

          # Create experimental branch with worktree for isolated agent work
          exp() {
            local task_name="''${1:-task}"
            local branch_name="exp/$(date +%Y%m%d)-''${task_name}"
            local worktree_dir="../worktrees/''${branch_name##*/}"

            if [[ ! -d .git ]]; then
              echo "❌ Not a git repository"
              return 1
            fi

            # Ensure base branch exists
            local base_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")

            # Create worktree with new experimental branch
            mkdir -p ../worktrees
            git worktree add -b "$branch_name" "$worktree_dir" "$base_branch" 2>/dev/null || \
              git worktree add "$worktree_dir" "$branch_name"

            echo "✅ Created experimental branch: $branch_name"
            echo "📁 Worktree location: $worktree_dir"
            echo ""
            echo "To work in isolation: cd $worktree_dir"
          }

          # List all worktrees
          wt-list() {
            echo "📋 Git Worktrees:"
            git worktree list
          }

          # Remove a worktree safely
          wt-rm() {
            local worktree="''${1:?Usage: wt-rm <worktree-path>}"
            git worktree remove "$worktree" --force
            echo "🗑️  Removed worktree: $worktree"
          }

          # Prune stale worktrees
          wt-prune() {
            git worktree prune
            echo "🧹 Pruned stale worktrees"
          }

          # ═══════════════════════════════════════════════════════════════
          # CLAUDE FUNCTIONS
          # ═══════════════════════════════════════════════════════════════

          cc() { claude "$@"; }

          # Standard ralph (requires manual experimental branch)
          ralph() {
            echo "🤖 Ralph Wiggum autonomous mode"
            claude --dangerously-skip-permissions "$@"
          }

          # Safe ralph: auto-creates experimental branch with worktree
          ralph-safe() {
            local task_name="''${1:-autonomous}"

            if [[ ! -d .git ]]; then
              echo "❌ Not a git repository"
              return 1
            fi

            # Check if already on experimental branch
            local current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
            if [[ "$current_branch" != exp/* ]]; then
              echo "⚠️  Not on experimental branch. Creating one..."
              exp "$task_name"
              local worktree_dir="../worktrees/$(date +%Y%m%d)-''${task_name}"
              echo "📂 Switching to: $worktree_dir"
              cd "$worktree_dir" || return 1
            fi

            echo "🤖 Ralph Wiggum (SAFE) - Branch: $(git branch --show-current)"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            shift  # Remove task_name from args
            claude --dangerously-skip-permissions "$@"
          }

          cct() {
            local name="''${1:-claude-$(basename $(pwd))}"
            tmux has-session -t "$name" 2>/dev/null && tmux attach -t "$name" || tmux new-session -s "$name" "claude"
          }

          # Safe cct: Creates tmux session in experimental worktree
          cct-safe() {
            local task_name="''${1:-task}"
            local session_name="exp-''${task_name}"

            if tmux has-session -t "$session_name" 2>/dev/null; then
              tmux attach -t "$session_name"
              return
            fi

            # Create experimental branch and worktree
            exp "$task_name"
            local worktree_dir="../worktrees/$(date +%Y%m%d)-''${task_name}"

            # Start tmux in worktree
            tmux new-session -s "$session_name" -c "$worktree_dir" "claude"
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
          echo "║  SAFE MODE     ralph-safe | cct-safe (auto experimental)      ║"
          echo "║  STACKED       sl | prev | next | restack | submit | absorb   ║"
          echo "║  BRANCHES      exp <name> | wt-list | wt-rm | wt-prune        ║"
          echo "║  SETUP         init-project | init-husky | init-openspec      ║"
          echo "║  SECURITY      check-secrets | scan-vulns | audit             ║"
          echo "║  OBSERVE       hyperfine | btm | httpstat | oha | tokei       ║"
          echo "║  API           xh | hurl | posting | pgcli | usql           ║"
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
          # RUST: Memory-safe systems programming
          # ══════════════════════════════════════════════════════════════
          rust = pkgs.mkShell {
            packages = corePkgs ++ rustPkgs;
            shellHook = commonShellHook + ''
              echo "🦀 Rust Shell"
              alias cw='cargo watch -x check'
              alias ct='cargo nextest run'
              alias cb='cargo build --release'
            '';
          };

          # ══════════════════════════════════════════════════════════════
          # C/C++: Low-level systems programming
          # ══════════════════════════════════════════════════════════════
          cpp = pkgs.mkShell {
            packages = corePkgs ++ cppPkgs;
            shellHook = commonShellHook + ''
              echo "⚙️  C/C++ Shell (clang)"
              export CC=clang
              export CXX=clang++
              alias cm='cmake -B build -G Ninja'
              alias cmb='cmake --build build'
              alias cmt='ctest --test-dir build'
            '';
          };

          # ══════════════════════════════════════════════════════════════
          # NIM: Efficient, expressive, elegant
          # ══════════════════════════════════════════════════════════════
          nim = pkgs.mkShell {
            packages = corePkgs ++ nimPkgs;
            shellHook = commonShellHook + ''
              echo "👑 Nim Shell"
              alias nr='nim r'
              alias nc='nim c -d:release'
            '';
          };

          # ══════════════════════════════════════════════════════════════
          # iOS: Apple development (macOS only for full Xcode)
          # ══════════════════════════════════════════════════════════════
          ios = pkgs.mkShell {
            packages = corePkgs ++ webPkgs ++ iosPkgs;
            shellHook = commonShellHook + ''
              echo "🍎 iOS Shell"
              echo "   Note: Full Xcode requires macOS"
              alias pod='bundle exec pod'
              alias fl='bundle exec fastlane'
            '';
          };

          # ══════════════════════════════════════════════════════════════
          # FULL: Everything
          # ══════════════════════════════════════════════════════════════
          full = pkgs.mkShell {
            packages = corePkgs ++ webPkgs ++ pythonPkgs ++ systemsPkgs ++ elixirPkgs ++ rubyPkgs ++ lispPkgs ++ rustPkgs ++ cppPkgs ++ nimPkgs;
            shellHook = commonShellHook;
          };

          # ══════════════════════════════════════════════════════════════
          # FRAMEWORK-SPECIFIC SHELLS
          # ══════════════════════════════════════════════════════════════

          # Next.js - Full-stack React framework
          nextjs = pkgs.mkShell {
            packages = corePkgs ++ webPkgs ++ [
              pkgs.nodePackages.eslint
            ];
            shellHook = commonShellHook + ''
              echo "⚛️  Next.js Shell - create-next-app, App Router ready"
              alias next='npx next'
              alias cna='npx create-next-app@latest'
            '';
          };

          # React - Client-side React with Vite
          react = pkgs.mkShell {
            packages = corePkgs ++ webPkgs ++ [
              pkgs.nodePackages.eslint
            ];
            shellHook = commonShellHook + ''
              echo "⚛️  React Shell - Vite + React ready"
              alias vite='npx vite'
              alias cra='npm create vite@latest -- --template react-ts'
            '';
          };

          # Svelte - Compiler-based framework
          svelte = pkgs.mkShell {
            packages = corePkgs ++ webPkgs;
            shellHook = commonShellHook + ''
              echo "🔶 Svelte Shell - SvelteKit ready"
              alias sk='npx sv create'
              alias svelte-add='npx svelte-add@latest'
            '';
          };

          # Tailwind - Utility-first CSS
          tailwind = pkgs.mkShell {
            packages = corePkgs ++ webPkgs ++ [
              pkgs.nodePackages.prettier
            ];
            shellHook = commonShellHook + ''
              echo "🎨 Tailwind Shell - PostCSS + Autoprefixer ready"
              alias tw-init='npx tailwindcss init -p'
              alias tw='npx tailwindcss'
            '';
          };

          # Storybook - Component development
          storybook = pkgs.mkShell {
            packages = corePkgs ++ webPkgs ++ [
              pkgs.nodePackages.prettier
              pkgs.nodePackages.eslint
            ];
            shellHook = commonShellHook + ''
              echo "📖 Storybook Shell - Component development ready"
              echo "   sb-init     - Initialize Storybook in project"
              echo "   sb          - Run Storybook dev server"
              echo "   sb-build    - Build static Storybook"
              alias sb-init='npx storybook@latest init'
              alias sb='npx storybook dev -p 6006'
              alias sb-build='npx storybook build'
              alias chromatic='npx chromatic'
            '';
          };

          # Elixir - Phoenix framework
          phoenix = pkgs.mkShell {
            packages = corePkgs ++ elixirPkgs ++ [
              pkgs.inotify-tools  # for live reload
              pkgs.postgresql     # for ecto
            ];
            shellHook = commonShellHook + ''
              echo "🧪 Phoenix Shell - Mix + Hex ready"
              alias phx='mix phx'
              alias phx-new='mix archive.install hex phx_new && mix phx.new'
              alias iex='iex -S mix'
            '';
          };

          # Reverse Engineering (Heavy - ~2GB download)
          re = pkgs.mkShell {
            packages = corePkgs ++ rePkgs;
            shellHook = commonShellHook + ''
              echo "🔬 Reverse Engineering Shell"
              echo "   ghidra      - Launch Ghidra GUI"
              echo "   r2 <file>   - Radare2 analysis"
              echo "   binwalk     - Firmware extraction"
              alias r2='radare2'
              alias hex='hexyl'
            '';
          };

          # API Development (lightweight, focused)
          api = pkgs.mkShell {
            packages = corePkgs ++ webPkgs ++ [
              pkgs.openapi-generator-cli  # Generate clients from OpenAPI
              pkgs.redocly-cli            # OpenAPI linting/bundling
            ];
            shellHook = commonShellHook + ''
              echo "🔌 API Development Shell"
              echo "   xh           - HTTP client (like httpie)"
              echo "   hurl         - Run HTTP files"
              echo "   posting      - TUI API client"
              echo "   openapi-gen  - Generate from OpenAPI spec"
              alias api='xh'
              alias openapi-gen='openapi-generator-cli generate'
            '';
          };

          # ══════════════════════════════════════════════════════════════
          # CROSS-PLATFORM SHELLS (Compositions)
          # ══════════════════════════════════════════════════════════════

          # Tauri - Rust + Web → native desktop apps
          tauri = pkgs.mkShell {
            packages = corePkgs ++ webPkgs ++ rustPkgs ++ [
              pkgs.tauri-cli
              pkgs.webkitgtk             # Linux webview
              pkgs.libsoup
              pkgs.openssl
              pkgs.pkg-config
            ];
            shellHook = commonShellHook + ''
              echo "🦀 Tauri Shell (Rust + Web → Desktop)"
              alias tauri='cargo tauri'
              alias tauri-init='cargo create-tauri-app'
              alias tauri-dev='cargo tauri dev'
              alias tauri-build='cargo tauri build'
            '';
          };

          # Capacitor - Web → iOS/Android (WebView)
          capacitor = pkgs.mkShell {
            packages = corePkgs ++ webPkgs ++ iosPkgs ++ [
              pkgs.openjdk17            # Android SDK
            ];
            shellHook = commonShellHook + ''
              echo "⚡ Capacitor Shell (Web → Mobile)"
              alias cap='npx cap'
              alias cap-init='npx @capacitor/cli init'
              alias cap-add='npx cap add'
              alias cap-sync='npx cap sync'
              alias cap-run='npx cap run'
            '';
          };

          # React Native - React → native iOS/Android
          react-native = pkgs.mkShell {
            packages = corePkgs ++ webPkgs ++ iosPkgs ++ [
              pkgs.openjdk17            # Android
              pkgs.watchman             # Metro file watching
            ];
            shellHook = commonShellHook + ''
              echo "📱 React Native Shell"
              alias rn='npx react-native'
              alias rn-init='npx react-native init'
              alias rn-start='npx react-native start'
              alias rn-ios='npx react-native run-ios'
              alias rn-android='npx react-native run-android'
            '';
          };

          # Expo - Managed React Native (easier, less config)
          expo = pkgs.mkShell {
            packages = corePkgs ++ webPkgs ++ [
              pkgs.openjdk17
              pkgs.watchman
            ];
            shellHook = commonShellHook + ''
              echo "📱 Expo Shell (Managed React Native)"
              alias expo='npx expo'
              alias expo-init='npx create-expo-app'
              alias expo-start='npx expo start'
            '';
          };
        };
      });
}
