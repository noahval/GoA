# Claude Skills

**Reusable procedures and specialized capabilities that Claude can invoke**

---

## What Are Skills?

Skills are pre-defined procedures that give Claude specialized capabilities for specific tasks. They're like mini-agents that know how to perform complex operations.

---

## How Skills Work

1. **User requests task** that matches a skill's domain
2. **Claude invokes skill** by name
3. **Skill loads** with detailed instructions
4. **Claude executes** the skill's procedure
5. **Result returned** to main conversation

---

## Potential Skills for GoA

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

## Invoking Skills

Skills are invoked via the Skill tool:

```
User: "Test the stats system"
Claude: [Uses Skill tool with command: "test-stats"]
Claude: [Skill loads and executes procedure]
Claude: "Stats test complete! All scenarios passed. Strength leveling works correctly, notifications appear as expected."
```

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
