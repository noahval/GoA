# Programming Principles

General programming principles and best practices for GoA development.

**⚠️ APPLY PROACTIVELY**: These principles should be applied to **all code**, not just when specific keywords appear. Reference this doc when:
- Writing new scripts/scenes
- Refactoring existing code
- Reviewing code quality
- Making architectural decisions
- Noticing code duplication or complexity

---

## SOLID Principles

Five design principles that make software more maintainable, flexible, and scalable.

### Single Responsibility (SRP)
Each script/class should have only one reason to change, with one specific responsibility.
- Separate UI logic from game logic (e.g., `shop.gd` handles UI, `Global` handles stats)
- Keep data management scripts focused on data operations only
- Isolate validation logic into dedicated scripts
- **Example**: `level_1_vars.gd` manages level state, `Global.gd` manages global state
- **Benefits**: easier testing, clearer code purpose, simpler maintenance

### Open/Closed (OCP)
Software entities should be open for extension but closed for modification.
- Use abstract base scripts and signals to define contracts
- Extend functionality by creating new implementations, not modifying existing code
- **Example**: Create base `Worker` class, extend with `Coppersmith`, `Smelter`, etc.
- **Godot pattern**: Use `class_extends` and override virtual methods
- **Benefits**: reduces bugs in existing code, safer to add features

### Liskov Substitution (LSP)
Objects of a subclass must be substitutable for objects of their parent class.
- Subclasses should strengthen, not weaken, parent class behavior
- Don't change expected signal parameters in child scenes
- **Example**: If base `Minigame` has `complete_game()`, all minigames must implement valid completion
- **Benefits**: predictable behavior, safer inheritance hierarchies

### Interface Segregation (ISP)
Components shouldn't be forced to depend on signals/methods they don't use.
- Create small, focused signal sets instead of large, monolithic ones
- Split complex autoloads into specialized ones (e.g., `Global`, `Level1Vars`)
- Scripts should only connect to signals they actually need
- **Benefits**: more flexible code, easier to implement and test

### Dependency Inversion (DIP)
Depend on abstractions, not concrete implementations.
- High-level game logic shouldn't depend on low-level UI details
- Use autoloads and signals to decouple systems
- **Example**: Game logic calls `Global.add_stat_exp()` (abstraction) rather than directly modifying stat values
- **Godot pattern**: Use autoloads as dependency injection containers
- **Benefits**: easier testing, flexible architecture, decoupled code

---

## DRY Principle (Don't Repeat Yourself)

Every piece of knowledge should have a single, authoritative representation.

- Extract repeated UI patterns into reusable scenes (e.g., `scene_template.tscn`)
- Use GDScript static functions and utility scripts for common operations
- Create base scenes for inheritance (UI containers, popups, etc.)
- Leverage autoloads for shared functionality (`Global`, `Level1Vars`)
- **Anti-pattern**: Copying the same stats calculation code into multiple minigames
- **Good pattern**: Using `Global.add_stat_exp()` everywhere
- **Benefits**: less code, easier maintenance, fewer bugs, single source of truth

---

## KISS Principle (Keep It Simple, Stupid)

Simplicity should be a key goal; unnecessary complexity should be avoided.

- Use Godot's built-in nodes instead of creating complex custom solutions
- Prefer clear, descriptive names over clever/terse ones
- Avoid over-engineering simple problems
- Break down complex scenes into smaller, manageable subscenes
- **Example**: Use `Timer` nodes instead of manual delta time tracking
- **Example**: Use built-in `PopupPanel` instead of custom modal system
- Start simple, add complexity only when necessary
- **Benefits**: easier to understand, faster to debug, better performance

---

## YAGNI Principle (You Aren't Gonna Need It)

Don't implement functionality until it's actually needed.

- Resist the urge to build features "just in case" they might be useful later
- Focus on current requirements, not hypothetical future needs
- Don't create abstract base classes for one implementation
- Avoid premature optimization before measuring performance
- Don't build configuration systems until you need configurability
- **Example**: Don't create `Level2Vars` until Level 2 exists
- **Example**: Don't add save/load for stats that don't exist yet
- Wait for actual use cases before adding flexibility
- **Benefits**: less code to maintain, faster delivery, lower complexity, easier to change

---

## Test-Driven Development (TDD)

**Write the test first. Watch it fail. Write minimal code to pass.**

TDD is a development methodology where tests drive design and implementation. No production code should exist without a failing test first.

### The RED-GREEN-REFACTOR Cycle

#### 🔴 RED: Write Failing Test
1. Write ONE minimal test showing desired behavior
2. Single behavior per test
3. Clear, descriptive test names
4. Use real code (minimal mocking)
5. **MANDATORY**: Run test and confirm it fails for the RIGHT reason

**Example** (GDScript test for stat system):
```gdscript
# test_stat_system.gd
extends GutTest

func test_adding_strength_exp_increases_strength_level():
    # Arrange
    Global.strength = 1.0
    Global.strength_exp = 0.0

    # Act
    Global.add_stat_exp("strength", 150.0)

    # Assert
    assert_eq(Global.strength, 2.0, "Strength should level up at 100 exp")
```

**Run and verify RED**: The test should fail because `add_stat_exp()` doesn't exist yet or doesn't work correctly.

#### 🟢 GREEN: Make It Pass
1. Write the **simplest** code to make the test pass
2. No over-engineering or extra features
3. Only implement what the test requires
4. Don't worry about edge cases yet

**Example** (minimal implementation):
```gdscript
# global.gd
func add_stat_exp(stat_name: String, amount: float):
    if stat_name == "strength":
        strength_exp += amount
        while strength_exp >= 100:
            strength += 1
            strength_exp -= 100
```

**Run and verify GREEN**: Test passes now.

#### 🔵 REFACTOR: Clean Code
1. Improve code quality without changing behavior
2. Extract duplicated code
3. Rename for clarity
4. Apply SOLID, DRY principles
5. **Keep tests green throughout**

**Example** (refactored):
```gdscript
# global.gd
const EXP_PER_LEVEL = 100

func add_stat_exp(stat_name: String, amount: float):
    var exp_var = stat_name + "_exp"
    set(exp_var, get(exp_var) + amount)
    _check_level_up(stat_name)

func _check_level_up(stat_name: String):
    var exp_var = stat_name + "_exp"
    var current_exp = get(exp_var)

    while current_exp >= EXP_PER_LEVEL:
        set(stat_name, get(stat_name) + 1)
        current_exp -= EXP_PER_LEVEL

    set(exp_var, current_exp)
```

### Why TDD Works

1. **Design First**: Tests force you to think about API before implementation
2. **Living Documentation**: Tests show how code should be used
3. **Fearless Refactoring**: Tests catch regressions immediately
4. **Minimal Code**: Only write what's needed (YAGNI)
5. **Fewer Bugs**: Edge cases caught early
6. **Better Architecture**: Testable code is usually well-designed code

### TDD in Godot/GDScript

#### Testing Framework
GoA uses **GUT (Godot Unit Test)** for automated testing.

**Installation**: Add GUT addon to `addons/gut/`

**Test File Structure**:
```
tests/
├── test_global_stats.gd
├── test_shop_system.gd
├── test_timer_mechanics.gd
└── test_victory_conditions.gd
```

#### Test Naming Convention
```gdscript
func test_[what_is_being_tested]_[expected_behavior]():
    # Examples:
    # test_shop_purchase_reduces_coins()
    # test_suspicion_timer_triggers_at_100()
    # test_victory_requires_all_conditions()
```

#### Arrange-Act-Assert Pattern
```gdscript
func test_shop_purchase_increases_shovel_level():
    # Arrange: Set up initial state
    Level1Vars.coins = 100
    Level1Vars.shovel_lvl = 0

    # Act: Perform the action
    var shop = Shop.new()
    shop._on_shovel_button_pressed()

    # Assert: Verify expectations
    assert_eq(Level1Vars.shovel_lvl, 1, "Shovel level should increase")
    assert_lt(Level1Vars.coins, 100, "Coins should decrease")
```

### TDD Best Practices

#### ✅ DO
- Write smallest possible test first
- Verify test fails before implementing
- Write minimal code to pass
- Test one behavior per test
- Use descriptive test names
- Keep tests fast and independent
- Test edge cases (null, zero, negative)
- Test error conditions
- Refactor after green

#### ❌ DON'T
- Write production code without failing test
- Skip verifying RED
- Over-engineer solutions
- Test implementation details
- Make tests dependent on each other
- Mock excessively (prefer real objects)
- Write tests after code (tests-after prove nothing)
- Rationalize skipping TDD

### Common TDD Rationalizations (FORBIDDEN)

These are excuses to avoid TDD. Don't fall for them:

❌ **"I'll test after I finish"**
- Tests written after pass immediately, proving nothing
- You've already made design decisions without test feedback
- Tests-after only verify "what does this do?" not "what should this do?"

❌ **"I already manually tested it"**
- Manual testing isn't repeatable or systematic
- Doesn't catch regressions in future changes
- Doesn't document expected behavior

❌ **"Deleting code I wrote is wasteful"**
- Sunk cost fallacy
- Untested code is technical debt
- Better to delete and write correctly with TDD

❌ **"This is too simple to test"**
- Simple code is easiest to test and good TDD practice
- "Simple" bugs still cause production issues
- Tests document even simple behavior

❌ **"I need to prototype first"**
- Throwaway prototypes are acceptable
- But production code must follow TDD
- Delete prototype and rebuild with tests

### TDD Workflow Example

**Task**: Add coal resource to the game

#### Step 1: RED - Write failing test
```gdscript
# tests/test_coal_resource.gd
extends GutTest

func test_coal_starts_at_zero():
    assert_eq(Level1Vars.coal, 0, "Coal should start at 0")

func test_mining_adds_coal():
    Level1Vars.coal = 0
    Level1Vars.add_coal(10)
    assert_eq(Level1Vars.coal, 10, "Mining should add coal")
```

Run test: ❌ FAILS (coal variable doesn't exist)

#### Step 2: GREEN - Minimal implementation
```gdscript
# level1/level_1_vars.gd
var coal: int = 0

func add_coal(amount: int):
    coal += amount
```

Run test: ✅ PASSES

#### Step 3: Add more tests
```gdscript
func test_coal_cannot_go_negative():
    Level1Vars.coal = 5
    Level1Vars.add_coal(-10)
    assert_eq(Level1Vars.coal, 0, "Coal should not go below 0")
```

Run test: ❌ FAILS (no validation)

#### Step 4: GREEN - Add validation
```gdscript
func add_coal(amount: int):
    coal = max(0, coal + amount)
```

Run test: ✅ PASSES

#### Step 5: REFACTOR - Improve design
```gdscript
func add_coal(amount: int):
    _modify_resource("coal", amount)

func _modify_resource(resource_name: String, amount: int):
    var current = get(resource_name)
    set(resource_name, max(0, current + amount))
    DebugLogger.log_resource_change(resource_name, current, get(resource_name))
```

Run tests: ✅ ALL PASS

### Integration with Other Principles

TDD naturally enforces other principles:

- **SOLID**: TDD encourages single-responsibility, testable code
- **DRY**: Refactor phase eliminates duplication
- **KISS**: Tests push toward simple solutions
- **YAGNI**: Only implement what tests require

### TDD Verification Checklist

Before completing any feature:

- [ ] Every function has at least one test
- [ ] Each test failed before implementation (verified RED)
- [ ] Tests fail for the correct reason
- [ ] Minimal code written per test (no over-engineering)
- [ ] All tests pass (verified GREEN)
- [ ] Code refactored for quality (REFACTOR phase)
- [ ] Tests use real code primarily (minimal mocking)
- [ ] Edge cases covered (null, zero, negative, boundary values)
- [ ] Error conditions tested
- [ ] Test names clearly describe behavior

---

## Godot-Specific Applications

### Scene Organization (SRP)
- One scene per logical UI component
- Separate game logic scripts from scene scripts
- Use autoloads for cross-scene functionality

### Signal-Based Architecture (DIP, ISP)
- Emit signals for events, don't call methods directly across scenes
- Keep signal parameters focused and minimal
- Use autoload signals for global events

### Resource Inheritance (OCP)
- Extend base themes/resources rather than modifying them
- Use resource inheritance for variations (e.g., `default_theme.tres`)

### Node Composition (KISS)
- Favor node composition over deep inheritance hierarchies
- Use built-in nodes when possible
- Keep node trees shallow and understandable

### Autoload Usage (DRY, DIP)
- Use autoloads as service locators
- Centralize cross-cutting concerns (stats, notifications, scene management)
- Keep autoloads focused (don't make god objects)

---

## Code Quality Checklist

Before committing code, verify:

### TDD Requirements
- [ ] Every function has at least one test
- [ ] Each test failed before implementation (verified RED)
- [ ] All tests pass (verified GREEN)
- [ ] Code refactored for quality (REFACTOR phase)
- [ ] Edge cases and error conditions tested

### Design Principles
- [ ] Each script has a single, clear responsibility (SRP)
- [ ] No duplicate logic across files (DRY)
- [ ] Simple, readable implementation (KISS)
- [ ] Only necessary features implemented (YAGNI)
- [ ] Dependencies go through abstractions (DIP)
- [ ] Scene inheritance used appropriately (OCP)
- [ ] Signals used for decoupling (ISP, DIP)
- [ ] Clear, descriptive names

---

## Summary

Following these principles results in:
- **Maintainable, extendable code** (SOLID, DRY)
- **Fewer bugs and faster debugging** (TDD, KISS)
- **Better team collaboration** (Clear tests, documentation)
- **Professional quality standards** (All principles combined)
- **Easier onboarding for new developers** (Tests as documentation)
- **More flexible architecture** (SOLID, TDD)
- **Confidence in changes** (TDD regression testing)
- **Better design decisions** (TDD design feedback)

**Remember: Good code is simple, clear, purposeful, and tested.**

---

**Version**: 2.0 | **Updated**: 2025-11-11
**Major Changes**: Added comprehensive TDD methodology section
