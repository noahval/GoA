# Skill: Dispatching Parallel Agents

**Use when:** Facing 3+ test failures with different root causes, multiple broken subsystems, or independent problem domains.

---

## Core Concept

**Dispatch one agent per independent problem domain** to enable concurrent investigation rather than sequential processing.

---

## Decision Framework

### Use When:
- ✓ 3+ test failures with different root causes
- ✓ Multiple broken subsystems
- ✓ Independent problem domains
- ✓ No shared state requirements

### Avoid When:
- ✗ Failures are interconnected
- ✗ Full system context is needed
- ✗ Agents would interfere with each other
- ✗ Exploratory debugging is required

---

## The Four-Step Pattern

### 1. Identify Independent Domains
Group failures by what's broken:
- Separate test files
- Different subsystems
- Unrelated functionality

### 2. Create Focused Agent Tasks
Each agent receives:
- **Specific scope** (which files/tests)
- **Clear goal** (what to fix)
- **Constraints** (what NOT to touch)
- **Expected output format** (summary structure)

### 3. Dispatch in Parallel
Execute all tasks concurrently using multiple Task tool calls in a single message.

### 4. Review and Integrate
- Verify summaries
- Check for conflicts
- Run full test suite

---

## Prompt Structure Requirements

Effective agent prompts must be:
- **Focused** on one clear problem domain
- **Self-contained** with necessary context
- **Explicit** about required output format

---

## Common Pitfalls

❌ Overly broad assignments
❌ Missing context
❌ Unclear constraints
❌ Vague deliverables

---

**Keywords:** parallel agents, concurrent debugging, multiple failures, agent dispatch
