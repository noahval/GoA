# Skill: Condition-Based Waiting

**Use when:** Tests have arbitrary delays, flaky tests, race conditions, or asynchronous operations requiring completion verification.

---

## Core Concept

**Wait for the actual condition you care about, not a guess about how long it takes.**

Replace arbitrary timeouts with condition polling to eliminate flaky tests.

---

## Main Pattern

Replace `sleep`/`setTimeout` statements with polling logic:

```gdscript
# GDScript example
func wait_for_condition(check_fn: Callable, timeout_ms: int = 5000) -> bool:
    var start_time = Time.get_ticks_msec()
    while Time.get_ticks_msec() - start_time < timeout_ms:
        if check_fn.call():
            return true
        await get_tree().create_timer(0.01).timeout  # Poll every 10ms
    push_error("Timeout waiting for condition")
    return false
```

---

## Key Use Cases

- Tests with arbitrary delays that pass inconsistently
- Race conditions appearing under load or in CI
- Asynchronous operations requiring completion verification
- Parallel test execution causing timeout failures

---

## Critical Constraints

- ✓ Avoid polling intervals that waste CPU resources
- ✓ Always include timeout boundaries with descriptive error messages
- ✓ Query state freshly within each loop iteration (no caching)
- ✓ Document and justify any legitimate arbitrary timeouts

---

## Benefits

- Flaky test pass rates: 60% → 100%
- Execution time improved by 40%
- Race condition issues eliminated

---

**Keywords:** async, asynchronous, waiting, polling, flaky tests, race condition, timeout
