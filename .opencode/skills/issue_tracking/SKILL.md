---
name: issue_tracking
description: Global issue tracker management - creating issues, severity levels, and tech debt tracking
license: MIT
compatibility: opencode
metadata:
  category: methodology
  for_agent: reviewer, supervisor
  focus: quality, traceability
---

# Issue Tracking

## Issue Tracker Location

```
project_management/issue_tracker.yaml
```

## File Structure

```yaml
# Global Issue Tracker for Tock ESP32-C6 Port
next_id: 5  # Always increment after creating issue

issues:
  - id: 1
    severity: critical
    type: bug
    title: "Short description"
    status: open
    sprint: PI001/SP001
    created_by: reviewer
    created_at: 2024-01-15
    resolved_at: null
    notes: "Additional context"
```

## Creating an Issue

1. Read `issue_tracker.yaml`
2. Get `next_id` value
3. Create issue with that ID
4. Increment `next_id`
5. Write back the file

```yaml
# Before
next_id: 5
issues:
  - id: 4
    ...

# After adding new issue
next_id: 6
issues:
  - id: 4
    ...
  - id: 5
    severity: medium
    type: bug
    title: "GPIO interrupt not triggering"
    status: open
    sprint: PI001/SP002
    created_by: reviewer
    created_at: 2024-01-20
    resolved_at: null
    notes: "Works in test, fails on hardware"
```

## Severity Levels

| Severity | Description | Sprint Impact |
|----------|-------------|---------------|
| **critical** | Blocks functionality, safety issue | Must fix before approval |
| **high** | Significant bug, wrong behavior | Must fix before approval |
| **medium** | Code quality, minor bug | Should fix, can defer |
| **low** | Style, docs, nice-to-have | Defer to TechDebt PI |

## Issue Types

| Type | Description |
|------|-------------|
| **bug** | Something doesn't work correctly |
| **techdebt** | Known shortcut or cleanup needed |
| **enhancement** | Improvement opportunity |
| **question** | Needs PO/Analyst input |

## Status Values

| Status | Meaning |
|--------|---------|
| **open** | Issue identified, not started |
| **in_progress** | Currently being worked on |
| **resolved** | Fixed and verified |
| **wont_fix** | Decided not to fix (document reason) |

## ID Rules

**CRITICAL: IDs are NEVER reused**

- IDs are globally unique across all sprints and sessions
- Always use `next_id` and increment after use
- Never reassign or recycle IDs
- This ensures traceability in commit messages and reports

## Tech Debt Tracking

For issues that cannot be fixed immediately:

```yaml
- id: 7
  severity: medium
  type: techdebt
  title: "Timer accuracy could be improved"
  status: open
  sprint: PI001/SP003
  created_by: reviewer
  created_at: 2024-01-25
  resolved_at: null
  notes: |
    Current accuracy is 15%, acceptable for MVP.
    Should target 5% in TechDebt PI.
    See PI001/SP003/004_reviewer_report.md for details.
```

## Resolving Issues

When fixing an issue:

```yaml
- id: 5
  severity: medium
  type: bug
  title: "GPIO interrupt not triggering"
  status: resolved  # Changed from open
  sprint: PI001/SP002
  created_by: reviewer
  created_at: 2024-01-20
  resolved_at: 2024-01-22  # Add resolution date
  notes: |
    Works in test, fails on hardware.
    RESOLVED: Fixed in PI001/SP003 - interrupt enable bit was wrong.
    Commit: abc123
```

## Referencing Issues

In commit messages:
```
feat(gpio): implement interrupt handling

Fixes #5: GPIO interrupt not triggering
Related: #3 (timer accuracy)
```

In reports:
```markdown
## Issues
- Fixed Issue #5: GPIO interrupt
- Created Issue #8: Timer drift concern
```

## TechDebt PI

Periodically, schedule a TechDebt PI:
1. Filter `issue_tracker.yaml` for `type: techdebt` and `status: open`
2. Analyst reviews if issues are still relevant
3. Prioritize and plan sprints
4. Fix issues, update status to `resolved`

## Supervisor Responsibility

Supervisor ensures PO is aware of:
- All critical/high issues blocking sprint
- Tech debt accumulation trends
- Recommendations for TechDebt PI timing
