# OpenSpec Instructions

Spec-driven development workflow for AI coding assistants.

## Quick Start

```bash
# List existing specs
openspec list --specs

# Create a change proposal
openspec propose

# Apply after approval
openspec apply <change-id>

# Archive when complete
openspec archive <change-id>
```

## When to Create Specs

**CREATE spec for:**
- New features
- Breaking changes
- Architecture changes
- Performance optimization

**SKIP spec for:**
- Bug fixes
- Typos, formatting
- Dependency updates
- Config changes

## Workflow

```
1. PROPOSE → Create openspec/changes/<id>/proposal.md
2. REVIEW  → Get approval
3. APPLY   → Implement (test-driven)
4. ARCHIVE → Move to archive after deployment
```

## File Structure

```
openspec/
├── project.md              # Project conventions
├── specs/                  # Current truth
│   └── [capability]/
│       └── spec.md
└── changes/                # Proposals
    └── [change-id]/
        ├── proposal.md
        ├── tasks.md
        └── specs/
```

## Spec Format

```markdown
## ADDED Requirements
### Requirement: Feature Name
The system SHALL provide...

#### Scenario: Success case
- **WHEN** user does X
- **THEN** Y happens
```

Remember: Specs are truth. Changes are proposals.
