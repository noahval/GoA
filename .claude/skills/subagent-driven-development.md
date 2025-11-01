# Skill: Subagent-Driven Development

**Use when:** Executing implementation plans within current session with built-in quality gates.

---

## Core Concept

**Fresh subagent per task + review between tasks = high quality, fast iteration.**

Execute plans by dispatching fresh subagents for each task and conducting code reviews between them.

---

## Key Distinctions

Unlike parallel-session "executing-plans" approach:
- ✓ Keeps you in the same session
- ✓ Prevents context pollution through independent subagent instances
- ✓ Includes automatic quality checkpoints without human intervention

---

## When to Apply

### Use When:
- Remaining in current session
- Tasks are mostly independent
- Want continuous progress with built-in quality gates

### Avoid When:
- Need to review the plan first
- Tasks are tightly interdependent

---

## Process Overview

1. **Load plan** into TodoWrite structure
2. **Dispatch fresh subagent** for each task with specific directives
3. **Conduct code review** after each completion
4. **Address issues** identified in review
5. **Mark task complete** before advancing
6. **Final comprehensive review** validates complete implementation

---

## Quality Assurance

**Never:**
- Skip code reviews
- Proceed past critical issues
- Manually correct problems (dispatch fix subagents instead)

**Critical findings halt progress until resolved.**

---

## Required Integration

Depends on three related workflows:
- **writing-plans:** Creates foundational plan
- **requesting-code-review:** Enables mandatory review checkpoints
- **finishing-a-development-branch:** Completes development cycle

---

**Keywords:** subagent development, task execution, quality gates, plan implementation
