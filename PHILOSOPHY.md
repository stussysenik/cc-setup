# Design Philosophy

cc-setup follows these principles. Every addition must pass this filter.

---

## The Secret Sauce

### Linus Torvalds' Rules
1. **Good taste** - Elegant code handles edge cases structurally, not with `if` statements
2. **8-space tabs** - If you're indenting past 3 levels, you're doing it wrong
3. **No comments for "what"** - Code should be self-evident; comments explain "why"
4. **Don't break userspace** - Backwards compatibility is non-negotiable

### Worse Is Better (Richard Gabriel)
Simplicity of implementation > Simplicity of interface > Completeness > Correctness

A simple system that ships beats a perfect system that doesn't.

### Gall's Law
> "A complex system that works evolved from a simple system that worked."

Never design complex. Start simple, evolve complexity only when forced.

### Chesterton's Fence
> "Don't remove something until you understand why it's there."

Before deleting code, understand what it does. The previous author wasn't stupid.

### Hyrum's Law
> "With enough users, every observable behavior becomes depended upon."

Don't expose internals. Every public API is a forever commitment.

### The Rule of Three
Don't abstract until you have 3 concrete examples. Premature abstraction is worse than duplication.

---

## Code as Knowledge (Generational Transfer)

> "Programs must be written for people to read, and only incidentally for machines to execute."
> — Harold Abelson, SICP

Code is not just instructions. It's **knowledge crystallized for the next generation**.

### The Hierarchy of Optimization

```
1. Comprehension   ← Optimize for this FIRST
2. Correctness     ← Then this
3. Performance     ← Only when measured and needed
```

Fast code that no one understands dies with its author.
Clear code lives forever and can always be optimized later.

### Comment Philosophy

**Comments explain WHY, code shows WHAT.**

```typescript
// BAD: Describes what (redundant)
// Loop through users and filter active ones
const activeUsers = users.filter(u => u.isActive);

// GOOD: Explains why (invaluable)
// Inactive users are soft-deleted but retained for audit compliance.
// Filter them out of customer-facing queries.
const activeUsers = users.filter(u => u.isActive);
```

### The Four Types of Essential Comments

```typescript
// ============================================================
// 1. INTENT: Why does this exist?
// ============================================================
// We denormalize user data here because the join query was
// taking 800ms at scale. See ADR-007 for benchmarks.

// ============================================================
// 2. DECISION: Why this approach over alternatives?
// ============================================================
// Using a Map instead of Object because we need to preserve
// insertion order and support non-string keys.
// Considered: WeakMap (no iteration), Object (no order guarantee)

// ============================================================
// 3. WARNING: What's non-obvious that could break?
// ============================================================
// ⚠️ ORDER MATTERS: Auth middleware must run before rate limiting
// because rate limits are per-user, not per-IP.

// ============================================================
// 4. CONTEXT: What external knowledge is needed?
// ============================================================
// RFC 7231 §6.5.4: 404 must be returned even if resource exists
// but user lacks permission (prevents enumeration attacks).
```

### Naming as Documentation

Names should tell a story. Optimize for **reading**, not typing.

```typescript
// BAD: Abbreviated, requires mental parsing
const usrMgr = new UMgr();
const x = usrMgr.proc(d);

// GOOD: Full words, reads like prose
const userManager = new UserManager();
const validatedUser = userManager.validateAndEnrich(userData);
```

### The Newspaper Rule

Structure code like a newspaper article:
1. **Headline** (function name): What does it do?
2. **Lead** (first lines): The main action
3. **Body** (details): Supporting logic
4. **Footnotes** (helpers): Implementation details

```typescript
// HEADLINE: Clear function name
async function processUserRegistration(userData: UserInput): Promise<User> {
  // LEAD: The main story in 3 lines
  const validated = validateInput(userData);
  const user = await createUser(validated);
  await sendWelcomeEmail(user);

  return user;
}

// FOOTNOTES: Helpers below, details hidden
function validateInput(data: UserInput): ValidatedUser { /* ... */ }
async function createUser(data: ValidatedUser): Promise<User> { /* ... */ }
async function sendWelcomeEmail(user: User): Promise<void> { /* ... */ }
```

### Architecture Decision Records (ADRs)

For significant decisions, write it down:

```markdown
# ADR-007: Denormalize User Data in Activity Feed

## Status
Accepted

## Context
Activity feed queries joining 4 tables were taking 800ms p99.

## Decision
Denormalize user display data into activity records.

## Consequences
- Feed queries now 50ms p99
- User updates require fan-out to activity records
- Accepted trade-off: eventual consistency (max 30s delay)
```

### The Test as Specification

Tests are executable documentation. Write them for readers:

```typescript
describe('UserRegistration', () => {
  it('sends welcome email after successful registration', async () => {
    // Given: A new user with valid data
    const userData = { email: 'new@example.com', name: 'New User' };

    // When: They complete registration
    const user = await processUserRegistration(userData);

    // Then: They receive a welcome email
    expect(emailService.sent).toContainEqual({
      to: 'new@example.com',
      template: 'welcome'
    });
  });

  it('rejects registration with existing email', async () => {
    // Given: An email that's already registered
    const existingEmail = 'taken@example.com';
    await createUser({ email: existingEmail });

    // When/Then: Registration fails with clear error
    await expect(
      processUserRegistration({ email: existingEmail })
    ).rejects.toThrow('Email already registered');
  });
});
```

---

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

## AI Self-Verification (CRITICAL)

**AI must PROVE its work is correct, not just claim it.**

### The Verification Stack

```
Level 5: Human Review      ← Final gate, non-negotiable
Level 4: Integration       ← Does it work with the rest?
Level 3: Tests Pass        ← Automated proof of correctness
Level 2: Types Check       ← Compiler catches mistakes
Level 1: Format/Lint       ← Consistent, no obvious errors
Level 0: It Runs           ← Bare minimum
```

### The `verify` Command

Every project should have this. AI runs it before declaring done.

```bash
verify() {
  set -e  # Fail fast

  echo "▶ Format..."
  biome format --check . 2>/dev/null || npx prettier --check . || true

  echo "▶ Lint..."
  biome lint . 2>/dev/null || npm run lint || true

  echo "▶ Types..."
  tsc --noEmit 2>/dev/null || true

  echo "▶ Tests..."
  npm test || bun test || pnpm test || echo "No tests configured"

  echo "▶ Build..."
  npm run build || bun run build || echo "No build configured"

  echo "▶ Security..."
  check-secrets

  echo "✅ VERIFIED"
}
```

### AI Must Not Say "Done" Until:

1. [ ] `verify` passes with zero errors
2. [ ] No `// TODO` or `// FIXME` left behind
3. [ ] No `console.log` in production code
4. [ ] No hardcoded secrets or credentials
5. [ ] Tests cover the new code path
6. [ ] Types are explicit, not `any`

### The RALPH_COMPLETE Signal

When running autonomously, AI outputs `RALPH_COMPLETE` ONLY when:
- All tests pass
- Build succeeds
- No lint errors
- Security scan clean

```bash
# The loop
while ! verify; do
  analyze_failure
  fix_issue
done
echo "RALPH_COMPLETE"
```

### Property-Based Verification

For critical logic, don't just test examples - test properties:

```typescript
// Bad: Example-based
test('add', () => expect(add(2, 2)).toBe(4))

// Good: Property-based
test('add is commutative', () => {
  fc.assert(fc.property(fc.integer(), fc.integer(), (a, b) => {
    return add(a, b) === add(b, a)
  }))
})
```

### Idempotency Rule

Running any operation twice should be safe:
- `npm install` twice = same result
- `verify` twice = same result
- Migration twice = no error (check before apply)

---

---

## The Expansion Model

Core is minimal. Power is opt-in through shells.

```
┌─────────────────────────────────────────────────────────────────────┐
│  EXPANSION PATTERN                                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  #default (core)                                                     │
│    Essential tools only. Works for any project.                      │
│    ~500MB, installs in 30 seconds.                                   │
│                                                                      │
│  #web, #rust, #ai, etc. (language layer)                            │
│    Core + language-specific tools.                                   │
│    Pick the one that matches your project.                           │
│                                                                      │
│  #nextjs, #tauri, #phoenix (framework layer)                        │
│    Language layer + framework conveniences.                          │
│    Use when you know your framework.                                 │
│                                                                      │
│  #full (everything)                                                  │
│    All languages, all frameworks.                                    │
│    ~4GB, for polyglot exploration.                                   │
│                                                                      │
│  #re (specialized)                                                   │
│    Heavy, specialized tools (Ghidra).                                │
│    Only when specifically needed.                                    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Progression Path

```
Beginner          →  Intermediate     →  Advanced
#web                 #nextjs             Custom flake.nix
"I'm learning"       "I know my stack"   "I have specific needs"
```

### Project-Local Expansion

When cc-setup isn't enough, extend in your project:

```nix
# your-project/flake.nix
{
  inputs.cc-setup.url = "github:stussysenik/cc-setup";

  outputs = { self, cc-setup, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShells.default = pkgs.mkShell {
        # Start with cc-setup's web shell
        inputsFrom = [ cc-setup.devShells.x86_64-linux.web ];

        # Add project-specific tools
        packages = [
          pkgs.awscli2        # Your project needs AWS
          pkgs.terraform      # Your project needs IaC
        ];
      };
    };
}
```

---

## What Doesn't Belong

- IDE-specific configs (use your own dotfiles)
- Project-specific tools (use project's flake.nix)
- Experimental/unstable tools (wait for stability)
- Tools with <1000 GitHub stars (wait for adoption)
- Tools that duplicate existing functionality
