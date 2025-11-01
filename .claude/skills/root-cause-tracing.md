# Skill: Root Cause Tracing

**Use when:** Errors occur deep in execution, stack traces show long call chains, or data origin is unclear.

---

## Core Concept

**Trace backward through the call chain until you find the original trigger, then fix at the source.**

Find the original source of bugs that manifest deep in execution stacks, rather than fixing symptoms at the point of failure.

---

## Process Steps

1. **Observe the Symptom**
   Identify where the error appears

2. **Find Immediate Cause**
   Locate the code directly causing it

3. **Trace Upward**
   Ask what called that code

4. **Continue Backward**
   Follow the call chain to identify problematic values

5. **Identify Original Trigger**
   Find where invalid data originated

---

## Instrumentation Methods

Add diagnostic logging before problematic operations:
- Use `console.error()` for test visibility
- Include contextual data (directories, environment variables)
- Capture stack traces via `new Error().stack`

For Godot/GDScript:
- Use `push_error()` or `print_debug()`
- Include caller context in messages
- Log at component boundaries

---

## Defense-in-Depth Strategy

Rather than solely fixing at the source:
- Implement validation layers throughout call chain
- Make the bug impossible to trigger again
- Add guards at multiple levels

---

## When to Apply

- Errors occur deep in execution
- Stack traces show long call chains
- Data origin is unclear
- Need to identify which test triggers the problem

---

**Keywords:** root cause, trace, tracing, call stack, data flow, error origin
