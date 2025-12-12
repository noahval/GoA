# Skill: Systematic Debugging

**Use when:** Encountering bugs, errors, test failures, or unexpected behavior.

---

## Core Principle

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST**

Prioritize understanding problems before attempting solutions to prevent symptomatic fixes that mask deeper issues.

---

## Four-Phase Structure

### Phase 1: Root Cause Investigation
1. Read error messages carefully
2. Reproduce issue consistently
3. Review recent changes
4. Gather diagnostic evidence
5. Add instrumentation at component boundaries
6. Use root-cause-tracing to trace data flow backward

### Phase 2: Pattern Analysis
1. Locate similar working code
2. Study reference implementations completely
3. Identify differences between working and broken examples
4. Understand all dependencies and assumptions

### Phase 3: Hypothesis and Testing
1. Formulate specific hypothesis about root cause
2. Test with minimal changes (one variable at a time)
3. Verify results before proceeding

### Phase 4: Implementation
1. Create failing test case first
2. Implement single fix targeting identified root cause
3. Verify solution works

---

## Critical Stopping Point

**If three or more fix attempts fail, STOP.**

Question whether the underlying architecture is sound rather than continuing to patch symptoms.

---

## Forbidden Rationalizations

❌ "Emergencies require speed" - Systematic debugging saves time
❌ "Issue seems simple" - All bugs have root causes requiring investigation

---

## Success Indicators

- ✓ Understand both WHAT and WHY problems occur
- ✓ Fix targets root cause, not symptoms
- ✓ Can explain the failure mechanism clearly

---

**Keywords:** debug, debugging, error, bug, failure, crash, issue, problem, fix
