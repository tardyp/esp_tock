# Multi-Agent Workflow for Tock ESP32-C6 Port

## Overview

This project uses a Scrum-inspired multi-agent workflow to implement the Tock OS port for ESP32-C6. The workflow emphasizes TDD, continuous integration on hardware, and structured communication via the `project_management/` folder.

---

## Team Roles

| Agent | Role | Responsibility |
|-------|------|----------------|
| **Supervisor** | ScrumMaster | Task list management, sprint coordination, commit creation, PO communication |
| **Analyst** | PI Planner | Research, requirement clarification, eliminate uncertainty before work starts |
| **Implementor** | TDD Developer | Write tests first, implement code, ensure `cargo fmt` and `cargo clippy` pass |
| **Integrator** | Hardware Tester | Validate on board, write test automation, light bug fixes, debug prints |
| **Reviewer** | Quality Gate | Sprint review, issue tracking, approval/rejection for sprint completion |

---

## Workflow Structure

### Product Increment (PI)
- Work is organized into PIs as directed by the PO (user)
- Each PI has a dedicated folder: `project_management/PI###_Name/`
- TechDebt PIs focus exclusively on resolving tracked technical debt

### Sprint
- Each PI is divided into sprints
- Each sprint has a folder: `project_management/PI###_Name/SP###_Name/`
- Sprints end with Reviewer approval and Supervisor commit

### Report Ordering
- All reports inside PI/SP folders are prefixed with a sequential number assigned by Supervisor
- Format: `001_analyst_research.md`, `002_implementor_tdd.md`, etc.

---

## Communication Flow

```
PO (User) <---> USER_QUESTIONS.md
    |
    v
Supervisor (ScrumMaster)
    |
    +---> Analyst (PI Planning, Research)
    |
    +---> Implementor (TDD on Host)
    |         ^
    |         | (calls back for medium/large fixes)
    +---> Integrator (Hardware Testing)
    |
    +---> Reviewer (Sprint Review)
    |
    v
Git Commit (end of sprint)
```

---

## Folder Structure

```
project_management/
|-- README.md                    # This file
|-- issue_tracker.yaml           # Global issue tracker (never reuse IDs)
|-- PI001_First_Boot/
|   |-- SP001_Folder_Structure/
|   |   |-- 001_analyst_research.md
|   |   |-- 002_implementor_tdd.md
|   |   |-- 003_integrator_test.md
|   |   |-- 004_reviewer_report.md
|   |   `-- 005_supervisor_summary.md
|   `-- SP002_Minimal_Kernel/
|       `-- ...
|-- PI002_GPIO_Support/
|   `-- ...
`-- PI_TECHDEBT_001/
    `-- SP001_Resolve_Stale_Issues/
        `-- ...
```

---

## Issue Tracker

**File:** `project_management/issue_tracker.yaml`

### Format
```yaml
issues:
  - id: 1
    severity: critical  # critical, high, medium, low
    type: bug           # bug, techdebt, enhancement
    title: "Short description"
    status: open        # open, in_progress, resolved, wont_fix
    sprint: PI001/SP001
    created_by: reviewer
    created_at: 2024-01-15
    resolved_at: null
    notes: "Additional context"
```

### Rules
1. Issue IDs are globally unique and never reused
2. Severity levels: `critical`, `high`, `medium`, `low`
3. Reviewer creates issues; Supervisor ensures PO awareness
4. TechDebt items remain until resolved in a TechDebt PI

---

## Agent Responsibilities

### Supervisor (ScrumMaster)
- Creates PI and Sprint folders
- Assigns report numbers to agents
- Tracks sprint checklist via TodoWrite tool
- Ensures PO is aware of blocking issues and tech debt
- Summarizes sprint work in commit message at sprint end
- Creates git commit after Reviewer approval
- **Does NOT write code**

### Analyst
- Conducts research for PI planning
- Identifies risks and uncertainties
- Asks clarifying questions via USER_QUESTIONS.md (PO responds there)
- Writes detailed analysis reports
- Ensures plan is clear before handoff to Implementor

### Implementor
- Uses Test-Driven Development (TDD)
- Writes unit tests that run on host
- Ensures `cargo clippy --all-targets -- -D warnings` passes
- Ensures `cargo fmt --check` passes
- Tags tests with requirement references
- Stops for medium/large changes; hands back to Analyst

### Integrator
- Tests code on actual ESP32-C6 hardware
- Writes test automation (similar to Tock's existing tests)
- May add debug prints for investigation
- Fixes only light bugs directly
- For medium/large changes, pauses and calls back Implementor
- Resets debug code before handoff

### Reviewer
- Reviews sprint deliverables
- Applies safety and quality checklists
- Creates issues in `issue_tracker.yaml`
- Provides verdict: APPROVED / REQUIRES_CHANGES
- Team must close review comments before sprint completion

---

## Sprint Lifecycle

### 1. Planning (Analyst)
- Research requirements
- Document uncertainties
- Ask PO clarifying questions
- Produce analysis report

### 2. Implementation (Implementor)
- TDD cycle: Red -> Green -> Refactor
- Run clippy and fmt continuously
- Unit tests on host
- Handoff when complete

### 3. Integration (Integrator)
- Flash to ESP32-C6
- Run hardware tests
- Document findings
- Light fixes or handoff back

### 4. Review (Reviewer)
- Quality and safety review
- Create issues if needed
- Approve or request changes

### 5. Commit (Supervisor)
- Summarize sprint work
- Create git commit
- Update issue tracker status

---

## TechDebt PI

Periodically, a TechDebt PI is created to:
1. Review all open issues in `issue_tracker.yaml`
2. Analyze if issues are still relevant
3. Plan and execute fixes
4. Close resolved issues

---

## Key Principles

1. **No Uncertainty in Sprint** - Analyst eliminates ambiguity before implementation
2. **TDD Mandatory** - Tests before code, always
3. **Hardware Validation** - Integrator validates on real board
4. **Tracked Issues** - All problems go in issue_tracker.yaml
5. **Sprint Gate** - Reviewer must approve before commit
6. **Sequential Reports** - Supervisor assigns numbers for ordering
7. **PO Visibility** - Supervisor keeps PO informed of blockers and debt

---

## Escalation Rules

| Situation | Action |
|-----------|--------|
| Uncertainty during implementation | Stop, ask Analyst |
| Medium/large bug found by Integrator | Stop, return to Implementor |
| Reviewer rejects sprint | Team addresses comments |
| Blocking issue found | Supervisor notifies PO |
| Tech debt accumulates | Schedule TechDebt PI |

---

## Report Templates

### Analyst Report
```markdown
# PI###/SP### - Analysis Report

## Research Summary
[Key findings]

## Requirements Clarification
[Answered questions]

## Risks Identified
[Potential issues]

## Recommendation
[Proposed approach]
```

### Implementor Report
```markdown
# PI###/SP### - Implementation Report

## TDD Summary
- Tests written: N
- Tests passing: N
- Cycles: X / target <15

## Files Modified
- path/to/file.rs

## Clippy/Fmt Status
- clippy: PASS
- fmt: PASS

## Handoff Notes
[Notes for Integrator]
```

### Integrator Report
```markdown
# PI###/SP### - Integration Report

## Hardware Tests
- [x] Test 1: PASS
- [ ] Test 2: FAIL - Issue #N

## Debug Findings
[Observations]

## Handoff Notes
[For Implementor if changes needed]
```

### Reviewer Report
```markdown
# PI###/SP### - Review Report

## Verdict: [APPROVED / REQUIRES_CHANGES]

## Issues Created
| ID | Severity | Title |
|----|----------|-------|
| 42 | medium   | Description |

## Comments
[Review feedback]

## Approval Conditions
[What must be fixed]
```

---

## Skill Selection

Before delegating to a sub-agent, Supervisor suggests applicable skills:

```
Task @implementor: Implement GPIO driver

Mandatory: load Skill(tdd)
Mandatory: load Skill(tock_kernel_patterns)
Suggested: load Skill(esp32c6_registers)

Output: GPIO driver with unit tests
Report: project_management/PI001/SP002/003_implementor_gpio.md
```
