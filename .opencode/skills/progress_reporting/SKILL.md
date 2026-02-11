---
name: progress_reporting
description: Standard progress report format, location conventions, and handoff documentation for all agents
license: MIT
compatibility: opencode
metadata:
  category: methodology
  for_agent: all
  focus: communication, traceability
---

# Progress Reporting

## Report Location

All reports go in the sprint folder with Supervisor-assigned numbers:

```
project_management/PI###_Name/SP###_Name/{number}_{agent}_{topic}.md
```

Example:
```
project_management/PI001_First_Boot/SP001_Setup/
  001_analyst_research.md
  002_implementor_tdd.md
  003_integrator_hardware.md
  004_reviewer_report.md
  005_supervisor_summary.md
```

## Report Number Assignment

**Only Supervisor assigns numbers.** Request your number in the delegation.

## Standard Report Structure

```markdown
# PI###/SP### - [Agent] Report: [Topic]

## Session Summary
**Date:** YYYY-MM-DD
**Task:** [Brief description]
**Status:** [Complete / In Progress / Blocked]

## Work Completed
- [x] Item 1
- [x] Item 2
- [ ] Item 3 (incomplete - reason)

## Key Findings / Decisions
[Important discoveries or choices made]

## Issues Encountered
| Issue | Resolution | Impact |
|-------|------------|--------|
| [Problem] | [How solved or escalated] | [Effect on timeline] |

## Handoff Notes
[Critical information for next agent]

## Next Steps
[What should happen next]
```

## Agent-Specific Additions

### Analyst
```markdown
## Research Summary
[Findings from investigation]

## Questions for PO
[Via USER_QUESTIONS.md]

## Risks Identified
| Risk | Likelihood | Mitigation |
```

### Implementor
```markdown
## TDD Metrics
- Cycles: X / target <15
- Tests written: N
- Tests passing: N

## Quality Status
- clippy: PASS/FAIL
- fmt: PASS/FAIL
```

### Integrator
```markdown
## Hardware Test Results
| Test | Status | Notes |
|------|--------|-------|

## Debug Artifacts
[Logs, captures, observations]

## Escalations
| Issue | Reason | To |
```

### Reviewer
```markdown
## Verdict
[APPROVED / REQUIRES_CHANGES / APPROVED_WITH_TECHDEBT]

## Issues Created
| ID | Severity | Title |
```

## When to Write

Write report at END of every session before returning control.

**Mandatory** - No exceptions.

## Handoff Quality

Good handoff notes include:
- Current state of work
- Blockers or concerns
- Specific files/locations touched
- What to do next

Bad handoff notes:
- "Done"
- "See code"
- Empty or missing

## Linking to Issues

Reference issue_tracker.yaml IDs when relevant:

```markdown
## Related Issues
- Issue #5: GPIO interrupt not firing (created this sprint)
- Issue #2: Timer accuracy concern (existing techdebt)
```
