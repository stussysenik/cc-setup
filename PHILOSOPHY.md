# Design Philosophy

cc-setup follows these principles. Every addition must pass this filter.

## Core Principles

### 1. Minimal by Default
Start with the smallest useful thing. Add only when there's clear need.

```
Bad:  "Let's add everything that might be useful"
Good: "What's the minimum that solves the problem?"
```

### 2. Single Responsibility (SRP)
Each shell does ONE thing well. Combine shells, don't bloat them.

```
#web       → JavaScript/TypeScript toolchain
#rust      → Rust toolchain
#tauri     → #rust + #web + Tauri CLI (composition)
```

### 3. Layered Architecture
Build like architecture: foundation → structure → details.

```
Layer 0: Core (security, DX, git tools) - ALWAYS included
Layer 1: Language (rust, python, node) - pick one
Layer 2: Framework (nextjs, tauri, phoenix) - specialization
```

### 4. Easy Reversal
Every change must be revertible. Work on experimental branches.

```bash
# Before adding features
exp add-rust-shell

# If it doesn't work out
git checkout main
wt-rm ../worktrees/add-rust-shell
```

### 5. Correctness Over Convenience
Prefer explicit over magic. Prefer correct over fast.

```
Bad:  Alias that hides important flags
Good: Alias that makes correct usage easier
```

## The Paint Ball Principle

> "Adding paint to a growing ball - you can only add so much before it's not legible anymore"

This means:
- Every tool must earn its place
- Remove before adding when possible
- If explaining takes too long, it's too complex

## Shell Composition Model

```
┌─────────────────────────────────────────────────────────────────┐
│                         #full                                    │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ Layer 2: Frameworks                                         ││
│  │ #nextjs #tauri #phoenix #capacitor #react-native            ││
│  ├─────────────────────────────────────────────────────────────┤│
│  │ Layer 1: Languages                                          ││
│  │ #web #rust #cpp #nim #ai #systems #fintech #lisp            ││
│  ├─────────────────────────────────────────────────────────────┤│
│  │ Layer 0: Core (always included)                             ││
│  │ Security, DX, Git, API tools, Observability                 ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## Adding New Tools Checklist

Before adding anything, answer:

1. [ ] Does this solve a real problem I've encountered?
2. [ ] Is there already a tool that does this?
3. [ ] Will I use this more than once a month?
4. [ ] Can I explain what it does in one sentence?
5. [ ] Does it work on both Linux and macOS?

If any answer is "no", don't add it.

## Adding New Shells Checklist

1. [ ] Does this represent a distinct workflow?
2. [ ] Is it more than just "language + one tool"?
3. [ ] Would combining existing shells be worse?
4. [ ] Can I name 3 projects that would use this?

## Version Control Discipline

```bash
# Feature branches for new shells
exp add-rust-shell
# ... work ...
git commit -m "feat(shells): add #rust with cargo tools"

# Atomic commits
# One commit = one logical change
# Easy to revert, easy to cherry-pick

# Never force push main
# Main is production
```

## What Doesn't Belong

- IDE-specific configs (use your own dotfiles)
- Project-specific tools (use project's flake.nix)
- Experimental/unstable tools (wait for stability)
- Tools with <1000 GitHub stars (wait for adoption)
- Tools that duplicate existing functionality
