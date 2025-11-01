# Skill: Requesting Code Review

**Use when:** After completing tasks in subagent-driven development, finishing major features, or before merging to main.

---

## Core Principle

**"Review early, review often"** to catch issues before they compound into larger problems.

---

## When to Use

### Required Scenarios:
- After completing each task in subagent-driven development
- Upon finishing major features
- Prior to merging into main branch

### Beneficial Situations:
- When development is blocked
- Before refactoring work
- Following complex bug fixes

---

## Implementation Steps

1. **Obtain git commit identifiers**
   Base commit and current commit SHAs

2. **Dispatch code-reviewer subagent**
   Use the Task tool with appropriate template

3. **Complete template with:**
   - Implementation details
   - Requirements
   - Commit SHAs

4. **Address feedback appropriately:**
   - Critical/Important issues → Immediately
   - Minor concerns → Later or document

---

## Feedback Response Guidelines

- **Critical findings:** Address right away
- **Important issues:** Tackle before advancing
- **Minor concerns:** Document for future attention
- **Disputes:** Only challenge with technical evidence (code or tests)

---

## Critical Warnings

❌ Never skip review for "simple" changes
❌ Don't proceed past unresolved critical/important issues
❌ Only dispute reviewer feedback when you can demonstrate functionality

---

**Keywords:** code review, review request, peer review, code quality check
