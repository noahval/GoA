# Skill: Writing Skills

**Use when:** Creating new skills or editing existing skill documentation.

---

## Core Definition

**"Writing skills IS Test-Driven Development applied to process documentation."**

Skills are reusable reference guides for proven techniques, patterns, or tools—not narratives about solving one-off problems.

---

## The Iron Law

**No skill deployment without a failing test first.**

This applies to new skills and edits alike.

---

## TDD Mapping

- **Test case** = Pressure scenario with subagent
- **Production code** = Skill document (SKILL.md)
- **RED phase** = Agent violates rule without skill
- **GREEN phase** = Agent complies with skill present
- **REFACTOR phase** = Close loopholes systematically

---

## Skill Structure

Flat namespace organization in `SKILL.md` files with:

```markdown
# Skill: [Name]

**Use when:** [Concrete triggering conditions]

---

## Core Principle
[Foundational rule]

## When to Use
[Specific scenarios]

## Implementation
[Step-by-step process]

## Common Mistakes
[Anti-patterns and forbidden shortcuts]
```

Supporting files separate only for:
- Heavy reference (100+ lines)
- Reusable tools

---

## Claude Search Optimization (CSO)

Descriptions must start with **"Use when..."** and include:
- Concrete triggering conditions and symptoms
- Problem statements (technology-agnostic unless skill-specific)
- What the skill accomplishes
- Third-person perspective

**"Use concrete triggers, symptoms, and situations that signal this skill applies."**

---

## Testing Requirements

Different skill types need tailored testing:

### Discipline-enforcing skills (TDD, verification)
Test with academic questions and maximum-pressure scenarios to identify rationalizations.

### Technique skills (how-to guides)
Test with application and variation scenarios to verify correct execution.

### Pattern skills (mental models)
Test recognition, application, and counter-examples.

### Reference skills (APIs/documentation)
Test information retrieval and practical application.

---

## Bulletproofing Against Rationalization

Close every loophole explicitly:
- Forbid specific workarounds with "no exceptions" lists
- Establish foundational principles early
- Build rationalization tables from baseline testing
- Create red flags lists for self-checking
- Add violation symptoms to search descriptions

---

## Deployment Checklist

Complete **RED-GREEN-REFACTOR** phases with mandatory stops between skills:

### RED
- Create pressure scenarios
- Run without skill
- Document failures

### GREEN
- Write minimal skill addressing identified issues
- Verify compliance

### REFACTOR
- Identify new rationalizations
- Add explicit counters
- Re-test

---

## Token Efficiency

Target:
- Getting-started workflows: **under 150 words**
- Frequently-loaded skills: **under 200 words**

---

**Keywords:** skill creation, writing skills, skill development, process documentation
