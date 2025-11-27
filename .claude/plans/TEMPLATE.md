# Phase [X.Y]: [Feature Name]

**Goal**: [One sentence describing what this feature accomplishes]

**Success Criteria**: [How you know this feature is complete and working]

**Prerequisites**: [List of phases or features that must exist first, or "None"]

---

## Overview

[Brief description of the feature, its purpose in the game, and how it fits into the overall experience. 2-4 sentences.]

### Key Design Principles

[If applicable, list important design constraints or guidelines:]
- [Principle 1]
- [Principle 2]
- [Principle 3]

---

## Implementation Tasks

[Break down the feature into concrete, actionable tasks. Use numbered subsections for major components.]

### 1. [Component Name]

[Description of what this component does]

**Variables needed** (if applicable):
```gdscript
# In [filename].gd
var variable_name: Type = default_value  # Description
```

**Implementation details:**
- [Step 1]
- [Step 2]
- [Step 3]

### 2. [Component Name]

[Continue for each major component...]

---

## Code Examples

[Provide key code snippets showing critical logic]

### [Function/System Name]

```gdscript
func example_function():
    # Implementation here
    pass
```

**Explanation:** [What this code does and why]

---

## Testing Strategy

[Choose appropriate test types based on the feature]

### Unit Tests (Headless)

[For pure logic, calculations, state management]

Create `tests/test_phase_[X]_[Y].gd`:

```gdscript
# Test: [What this test verifies]
func test_[feature_name]():
    # Setup
    var initial_value = some_starting_state

    # Execute
    perform_action()

    # Assert
    assert_eq(actual_value, expected_value)
```

**Test Cases:**
- [ ] [Test case 1 description]
- [ ] [Test case 2 description]
- [ ] [Edge case handling]

**Run tests:**
```bash
godot --headless --script res://tests/test_runner.gd
```

### Integration Tests

[For system interactions, save/load, scene transitions]

**Test Scenarios:**

| Scenario | Setup | Action | Expected Result |
|----------|-------|--------|-----------------|
| [Test name] | [Initial state] | [What to do] | [What should happen] |

### Manual Test Criteria

[For UI/UX, feel, visual feedback that can't be automated]

- [ ] [Manual test 1]
- [ ] [Manual test 2]
- [ ] [Visual feedback appears correctly]
- [ ] [Sound effects play appropriately]
- [ ] [UI layout looks correct at 1438x817]

---

## Files to Create

[List all new files needed]

- `res://path/to/file.gd` - [Purpose]
- `res://path/to/file.tscn` - [Purpose]
- `tests/test_phase_[X]_[Y].gd` - [Test suite]

## Files to Modify

[List existing files that need updates]

- `global.gd` - [What changes: add variables, functions, etc.]
- `level_1_vars.gd` - [What changes]
- `project.godot` - [What changes: autoloads, etc.]

---

## Design Values (Reference)

[Document all magic numbers, formulas, and constants for easy tuning]

### [System Name]

- **[Property]**: [Value] - [Description/reasoning]
- **[Formula]**: `[mathematical expression]` - [What it calculates]

**Example:**
- **Starting stamina**: 100
- **Stamina per shovel**: 5 (base, before stats/equipment)
- **Payment formula**: `coal_count * 0.05 * multiplier`

---

## UI Mockups (Optional)

[If UI-heavy feature, provide text mockups of screens]

```
+------------------------------------------+
| [Screen Title]                      [X] |
+------------------------------------------+
| [Description or status text]            |
|                                          |
| [Resource Display]  [####------] 40/100 |
|                                          |
| [Button 1]  [Button 2]  [Button 3]      |
+------------------------------------------+
```

---

## Dependencies & Integration

[How this feature integrates with existing systems]

**Depends On:**
- [Feature 1] - [Why needed]
- [Feature 2] - [Why needed]

**Used By:**
- [Future feature 1] - [How it uses this]
- [Future feature 2] - [How it uses this]

**Conflicts:**
- [Any known conflicts or incompatibilities]

---

## Balance Tuning Notes

[For designers/future balance passes]

**Tuneable Parameters:**
- `[variable_name]` in [filename] - [What it affects]
- `[constant_name]` in [filename] - [What it affects]

**Expected Player Progression:**
- [Minute 1-5]: [What player should experience]
- [Minute 5-15]: [What player should experience]
- [Minute 15+]: [What player should experience]

**Warning Signs:**
- If [X happens], increase [Y]
- If [X happens], decrease [Y]

---

## Phase Status

**Status**: [Planning / Ready for Implementation / In Progress / Complete]

**Estimated Time**: [X-Y hours]

**Dependencies Complete**: [Yes/No - list incomplete dependencies]

**Previous Phase**: [Link to previous plan doc if applicable]

**Next Phase**: [Link to next plan doc if applicable]

---

## Notes & Decisions

[Document important decisions, alternatives considered, and rationale]

**Decision 1:** [What was decided]
- **Rationale**: [Why]
- **Alternatives considered**: [What else was considered and why it was rejected]

**Open Questions:**
- [ ] [Unresolved question 1]
- [ ] [Unresolved question 2]

---

## Implementation Checklist

[Final checklist before marking complete - copy from Implementation Tasks]

- [ ] [Component 1] implemented
- [ ] [Component 2] implemented
- [ ] All unit tests passing
- [ ] All integration tests passing
- [ ] Manual tests completed
- [ ] UI tested at target resolution
- [ ] Save/load tested (if applicable)
- [ ] Performance acceptable (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated
