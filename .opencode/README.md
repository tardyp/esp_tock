# OpenCode Agent Configuration - Tock ESP32-C6 Port

This directory contains the multi-agent workflow configuration for the Tock ESP32-C6 port development using a Scrum-inspired methodology.

## Quick Start

The project uses a multi-agent architecture with TDD and hardware validation:

| Agent | Role | Max Iterations |
|-------|------|----------------|
| **supervisor** | ScrumMaster, orchestration | 50 |
| **analyst** | PI planning, research | 15 |
| **implementor** | TDD Rust coding | 30 |
| **integrator** | Hardware testing | 30 |
| **reviewer** | Sprint review, quality gate | 10 |

## Workflow Overview

```
PO (User) <---> USER_QUESTIONS.md
    |
    v
Supervisor (ScrumMaster)
    |
    +---> Analyst (PI Planning)
    |
    +---> Implementor (TDD on Host)
    |         ^
    |         | (calls back for fixes)
    +---> Integrator (Hardware Testing)
    |
    +---> Reviewer (Sprint Review)
    |
    v
Git Commit (end of sprint)
```

## Directory Structure

```
.opencode/
  agents/
    supervisor.md      # ScrumMaster orchestrator
    analyst.md         # PI planning and research
    implementor.md     # TDD implementation
    integrator.md      # Hardware testing
    reviewer.md        # Sprint review
  skills/
    tdd/               # TDD methodology
    tock_kernel/       # Tock patterns
    esp32c6/           # Hardware specifics
    progress_reporting/# Report format
    hardware_testing/  # Test automation
  README.md            # This file
```

## Skills System

Skills are loaded on-demand by agents:

| Skill | Purpose | Used By |
|-------|---------|---------|
| `tdd` | Test-Driven Development | @implementor |
| `tock_kernel` | Tock patterns and HIL | @implementor, @analyst |
| `esp32c6` | Hardware specifics | All agents |
| `progress_reporting` | Report format | All agents |
| `hardware_testing` | Test automation | @integrator |

## Supervisor Delegation Format

Before delegating, Supervisor suggests applicable skills:

```
Task @implementor: Implement GPIO driver

Context:
- Sprint: PI001/SP002
- Report number: 003

Mandatory: load Skill(tdd)
Mandatory: load Skill(tock_kernel)
Suggested: load Skill(esp32c6)

Output: GPIO driver with unit tests
Report: project_management/PI001/SP002/003_implementor_gpio.md
```

## Key Principles

1. **No Uncertainty in Sprint** - Analyst eliminates ambiguity first
2. **TDD Mandatory** - Tests before code, clippy and fmt always pass
3. **Hardware Validation** - Integrator tests on real ESP32-C6 board
4. **Quality Gate** - Reviewer must approve before commit
5. **Tracked Issues** - All problems in issue_tracker.yaml
6. **PO Communication** - Via USER_QUESTIONS.md in PI/Sprint folders

## Project Management

See `project_management/README.md` for full workflow documentation.

```
project_management/
  README.md              # Workflow documentation
  issue_tracker.yaml     # Global issue tracker (IDs never reused)
  PI###_Name/
    USER_QUESTIONS.md    # PO communication for this PI
    SP###_Name/
      001_analyst_*.md
      002_implementor_*.md
      003_integrator_*.md
      004_reviewer_*.md
      005_supervisor_*.md
```

## Usage

```bash
# Launch OpenCode
opencode

# Switch to supervisor agent (Tab key)
# Then:
# "Start PI001 for first boot"
# "Create sprint SP001 for folder structure"
```

## Sprint Lifecycle

1. **Planning** - @analyst researches, asks questions via USER_QUESTIONS.md
2. **Implementation** - @implementor uses TDD, runs on host
3. **Integration** - @integrator validates on hardware, light fixes or escalate
4. **Review** - @reviewer approves or requests changes
5. **Commit** - @supervisor creates git commit after approval
