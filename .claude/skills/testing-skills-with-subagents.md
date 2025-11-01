# Skill: Testing Skills With Subagents

**Use when:** Validating new skill documentation or ensuring skills enforce desired behavior.

---

## Core Concept

Apply Test-Driven Development (TDD) principles to process documentation and agent behavior.

**Treat agent testing like code TDD:**
- Establish baseline failures (RED)
- Write documentation addressing failures (GREEN)
- Close loopholes in documentation (REFACTOR)

---

## When to Use

Apply to documentation enforcing:
- Discipline
- Compliance
- Practices agents might rationalize away
- Behaviors contradicting immediate goals (like speed)

---

## The RED-GREEN-REFACTOR Cycle for Skills

### RED Phase
Run scenarios **without the skill** to:
- Watch agents fail
- Document exact rationalizations

### GREEN Phase
Write skill content addressing specific failures observed.

### REFACTOR Phase
- Identify new rationalizations agents develop
- Add explicit counters to close loopholes

---

## Effective Pressure Scenarios

Best test scenarios combine **3+ pressure types:**
- Time constraints
- Sunk costs
- Exhaustion simulation
- Authority pressure
- Economic stakes

**Use concrete A/B/C choices** that force agents to act rather than theorize.

---

## Success Indicators

A bulletproof skill demonstrates:
- ✓ Correct choices under maximum pressure
- ✓ Citations of skill sections as justification
- ✓ Acknowledgment of temptation alongside rule compliance
- ✓ Meta-testing confirms clarity rather than agent negligence

---

## Common Mistakes

❌ Skipping baseline testing
❌ Using weak single-pressure scenarios
❌ Adding generic counters without testing

These undermine the entire approach.

---

**Keywords:** skill testing, skill validation, subagent testing, TDD for skills
