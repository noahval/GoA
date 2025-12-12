# Claude Skills

**Reusable procedures and specialized capabilities that Claude can invoke**

---

## What Are Skills?

Skills are pre-defined procedures that give Claude specialized capabilities for specific tasks. They're like mini-agents that know how to perform complex operations.

---

## How Skills Work

1. **User requests task** that matches a skill's domain
2. **Claude invokes skill** by name (or automatically via keywords)
3. **Skill loads** with detailed instructions
4. **Claude executes** the skill's procedure
5. **Result returned** to main conversation

---

## 🌟 Superpowers Skills Library

**Source**: [obra/superpowers](https://github.com/obra/superpowers)

This project includes 18 general-purpose development skills organized into 4 categories:

### Testing & Debugging Skills

| Skill | Purpose | Keywords |
|-------|---------|----------|
| [test-driven-development.md](test-driven-development.md) | RED-GREEN-REFACTOR cycle, write tests first | test, testing, TDD, feature, bug fix |
| [systematic-debugging.md](systematic-debugging.md) | 4-phase root cause analysis | debug, error, bug, failure, crash |
| [verification-before-completion.md](verification-before-completion.md) | Evidence-based completion claims | verify, complete, done, finished |
| [root-cause-tracing.md](root-cause-tracing.md) | Trace errors backward through call chains | root cause, trace, call stack |
| [defense-in-depth.md](defense-in-depth.md) | Multi-layer validation | validation, guards, error prevention |
| [condition-based-waiting.md](condition-based-waiting.md) | Polling over arbitrary timeouts | async, polling, flaky tests |
| [testing-anti-patterns.md](testing-anti-patterns.md) | Common testing mistakes to avoid | test anti-pattern, mocking |

### Collaboration & Planning Skills

| Skill | Purpose | Keywords |
|-------|---------|----------|
| [brainstorming.md](brainstorming.md) | Socratic design refinement | brainstorm, design, planning |
| [writing-plans.md](writing-plans.md) | Detailed implementation roadmaps | plan, roadmap, task breakdown |
| [plan-scope-decisions.md](plan-scope-decisions.md) | Decide when to combine vs split plans | combine, split, plan scope |
| [executing-plans.md](executing-plans.md) | Batch execution with checkpoints | execute plan, implementation |
| [dispatching-parallel-agents.md](dispatching-parallel-agents.md) | Concurrent task management | parallel agents, concurrent |
| [requesting-code-review.md](requesting-code-review.md) | Initiate code reviews | code review, review request |
| [receiving-code-review.md](receiving-code-review.md) | Process review feedback | review feedback, handling feedback |
| [subagent-driven-development.md](subagent-driven-development.md) | Plan execution with quality gates | subagent development, task execution |

### Development Workflow Skills

| Skill | Purpose | Keywords |
|-------|---------|----------|
| [using-git-worktrees.md](using-git-worktrees.md) | Isolated parallel workspaces | git worktree, parallel development |
| [finishing-a-development-branch.md](finishing-a-development-branch.md) | Merge/PR workflow completion | finish branch, merge, PR |

### Meta Skills

| Skill | Purpose | Keywords |
|-------|---------|----------|
| [using-superpowers.md](using-superpowers.md) | First-response skill selection protocol | skill usage, workflow selection |
| [writing-skills.md](writing-skills.md) | TDD for process documentation | skill creation, skill development |
| [sharing-skills.md](sharing-skills.md) | Contributing skills upstream | skill sharing, contributing |
| [testing-skills-with-subagents.md](testing-skills-with-subagents.md) | Validate skill effectiveness | skill testing, skill validation |

**See also**: [BIBLE.md](../docs/BIBLE.md) for keyword-based skill activation

---

## 🎮 GoA-Specific Skills (Future)

### `test-stats`
**Purpose**: Test the experience and stats system

**What it does**:
- Runs headless Godot with stat test scene
- Verifies XP calculations
- Checks level-up triggers
- Validates notification system

**Usage**: "Test the stats system"

---

### `test-shop`
**Purpose**: Validate shop upgrade mechanics

**What it does**:
- Tests cost calculation formulas
- Verifies progressive unlocking
- Checks coin transactions
- Validates upgrade effects

**Usage**: "Test shop purchases"

---

### `test-victory`
**Purpose**: Verify victory conditions

**What it does**:
- Checks victory condition logic
- Tests scene transitions
- Validates resource thresholds
- Ensures victory scene loads

**Usage**: "Test victory conditions"

---

### `debug-session`
**Purpose**: Run comprehensive debug session

**What it does**:
- Enables full debug logging
- Runs game for specified duration
- Collects and analyzes logs
- Reports issues found

**Usage**: "Run a debug session"

---

### `balance-check`
**Purpose**: Analyze game balance

**What it does**:
- Simulates player progression
- Calculates time-to-win
- Identifies bottlenecks
- Suggests balance tweaks

**Usage**: "Check game balance"

---

### `lint-code`
**Purpose**: Code quality check

**What it does**:
- Scans all GDScript files
- Checks style compliance
- Identifies code smells
- Suggests improvements

**Usage**: "Lint the codebase"

---

## Creating Skills

### Skill File Structure

**File**: `.claude/skills/test-stats.md`

```markdown
# Skill: Test Stats System

## Purpose
Validate the experience and leveling system

## Procedure

1. Read debug-system.md to understand test procedures
2. Create or update test_scenes/stat_test.gd
3. Run headless Godot with test scene
4. Capture output and analyze logs
5. Report findings to user

## Test Scenarios

### Scenario 1: Basic Level Up
- Add 150 XP to strength
- Verify strength reaches level 2
- Check notification appears

### Scenario 2: Multi-Level Jump
- Add 1000 XP to constitution
- Verify multiple levels gained
- Check XP overflow handled

### Scenario 3: All Stats
- Add XP to all six stats
- Verify independent tracking
- Check no interference

## Success Criteria
- All test scenarios pass
- No errors in logs
- Notifications appear correctly

## Report Format
- Summary: Pass/Fail
- Issues found (if any)
- Test execution time
- Log excerpts
```

---

## How to Invoke Skills

### Automatic Activation

Skills activate automatically when keywords are detected. The [using-superpowers](using-superpowers.md) skill enforces a **First Response Checklist** where Claude checks available skills before responding.

### Manual Invocation

Skills can be invoked directly via the Skill tool:

```
User: "Test the stats system"
Claude: [Uses Skill tool with command: "test-stats"]
Claude: [Skill loads and executes procedure]
Claude: "Stats test complete! All scenarios passed. Strength leveling works correctly, notifications appear as expected."
```

### BIBLE Integration

The [BIBLE.md](../docs/BIBLE.md) indexes all skills with keywords. When you use certain keywords in your request, Claude automatically checks for relevant skills.

---

## Best Practices

1. **Clear purpose**: Each skill should have one well-defined job
2. **Detailed procedure**: Step-by-step instructions for Claude
3. **Self-contained**: Skill should be usable without context
4. **Report back**: Always provide user-facing summary

---

## Skills vs Slash Commands

**Skills**:
- Complex, multi-step procedures
- Autonomous execution
- Claude interprets and adapts
- Example: Running tests, analyzing code

**Slash Commands**:
- Quick, direct actions
- Immediate execution
- Fixed behavior
- Example: /help, /clear

---

## Useful Skills to Implement

### High Priority
- `test-stats` - Validate experience system
- `test-shop` - Check shop mechanics
- `debug-session` - Full debug run

### Medium Priority
- `balance-check` - Analyze progression
- `lint-code` - Code quality
- `profile-performance` - Find bottlenecks

### Low Priority
- `generate-docs` - Auto-document systems
- `refactor-guide` - Suggest improvements
- `asset-check` - Validate resources

---

**See Also**:
- [Hooks README](../hooks/README.md)
- [Debug System](../docs/debug-system.md)
- [Game Systems](../docs/game-systems.md)
