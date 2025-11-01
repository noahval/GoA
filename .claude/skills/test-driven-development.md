# Skill: Test-Driven Development (TDD)

**Use when:** Writing new features, fixing bugs, refactoring code, or changing behavior.

---

## Core Principle

**Write the test first. Watch it fail. Write minimal code to pass.**

No production code may exist without a failing test first. Code written before tests must be deleted entirely—no exceptions.

---

## The RED-GREEN-REFACTOR Cycle

### RED: Write Failing Test
- Write ONE minimal test showing desired behavior
- Single behavior per test
- Clear, descriptive names
- Real code (minimal mocking)

### Verify RED
- **MANDATORY:** Confirm test fails correctly
- Not due to typos or existing features
- Fails for the RIGHT reason

### GREEN: Make It Pass
- Write simplest code to pass the test
- No over-engineering
- No features beyond test requirements

### Verify GREEN
- Confirm tests pass
- No regressions

### REFACTOR: Clean Code
- Improve names, remove duplication
- Extract helpers
- Keep tests green throughout

---

## Exceptions Requiring Approval

- Throwaway prototypes
- Generated code
- Configuration files

---

## Common Rationalizations (FORBIDDEN)

❌ "I'll test after" - Tests pass immediately, proving nothing
❌ "Already manually tested" - Ad-hoc testing isn't systematic
❌ "Deleting code is wasteful" - Sunk cost fallacy

Tests-first answer "what should this do?" while tests-after answer only "what does this?"

---

## Verification Checklist

Before completion:
- [ ] Every function has a test
- [ ] Each test failed before implementation for correct reasons
- [ ] Minimal code written per test
- [ ] All tests pass cleanly
- [ ] Tests use real code primarily
- [ ] Edge cases and errors covered

---

**Keywords:** test, testing, TDD, feature, bug fix, refactoring, new code
