# Global Claude Configuration

## Autonomous Execution Mode (Ralph Wiggum Pattern)

When running with `ralph` (autonomous mode):

### The Loop
```
while tests_fail or task_incomplete:
    analyze_state()
    take_action()
    verify_result()

output "RALPH_COMPLETE" when done
```

### Principles
1. **Persist through failures** - errors are data, not stop signs
2. **Verify before declaring done** - run tests, check output
3. **Commit working increments** - small, atomic commits
4. **Use tmux** - sessions survive disconnects

### Auto-Approved in Autonomous Mode
```bash
# Build & Test
npm run build && npm run test
pnpm test
bun test
npx playwright test

# Git
git status/diff/add/commit/push

# MCP tools
chrome-devtools (browser automation)
brave-search (research)
```

## MCP Tools Available

### chrome-devtools
- Browser automation and testing
- Performance audits (Core Web Vitals)
- Screenshot and DOM inspection
- Network request monitoring

### brave-search
- Research before implementing
- Find documentation and best practices
- Discover solutions to problems

## Code Quality Standards
- Run linter before commits
- Fix all type errors
- Tests must pass
- No console.log in production

## Workflow Preferences
- **Spec first**: Define success before coding
- **Test-driven**: Write failing test, then implement
- **Small commits**: Atomic, reviewable changes
- **Document decisions**: Update specs as you learn

## When Working on Projects

### If `openspec/` exists:
1. Check `openspec/AGENTS.md` for instructions
2. Create proposals before major changes
3. Archive completed specs

### If `package.json` exists:
1. Check for existing lint/test scripts
2. Use project's tooling over global
3. Respect `.eslintrc`, `prettier.config`, etc.
