# Skill: Testing Anti-Patterns

**Use when:** Writing tests, reviewing test code, or debugging test failures.

---

## Core Principle

**Test what the code does, not what the mocks do.**

---

## Three Iron Laws

1. **Never test mock behavior**
2. **Never add test-only methods to production classes**
3. **Never mock without understanding dependencies**

---

## Five Key Anti-Patterns

### Anti-Pattern 1: Testing Mock Behavior
**Problem:** Assertions verify that a mock exists rather than validating genuine component functionality.

**You're verifying the mock works, not that the component works.**

**Solution:** Test real components or remove assertions on mock elements.

---

### Anti-Pattern 2: Test-Only Methods in Production
**Problem:** Adding methods exclusively for test purposes pollutes production code.

**Example:** A `destroy()` method only called in cleanup creates confusion about object lifecycle.

**Solution:** Move such functionality to test utility modules.

---

### Anti-Pattern 3: Mocking Without Understanding
**Problem:** Over-mocking can break test logic by preventing necessary side effects.

**Solution:** Understand dependencies before mocking, particularly what side effects the real method produces.

---

### Anti-Pattern 4: Incomplete Mocks
**Problem:** Partial mocks create false confidence by omitting fields downstream code might require.

**Solution:** **Mirror real API completeness** by including all documented fields.

---

### Anti-Pattern 5: Integration Tests as Afterthought
**Problem:** Treating testing as optional follow-up rather than integral to development.

**Solution:** Use TDD—write tests first.

---

## TDD Connection

Test-Driven Development prevents these anti-patterns by:
- Forcing tests first
- Observing real failures
- Implementing minimally
- Ensuring mocking serves isolation, not testing

---

**Keywords:** test anti-pattern, testing mistakes, mocking, test quality, test code
