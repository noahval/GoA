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
- [ ] Each script has a single, clear responsibility
- [ ] No duplicate logic across files
- [ ] Simple, readable implementation
- [ ] Only necessary features implemented
- [ ] Dependencies go through abstractions (autoloads, signals)
- [ ] Scene inheritance used appropriately
- [ ] Signals used for decoupling
- [ ] Clear, descriptive names

---

## Summary

Following these principles results in:
- Maintainable, extendable code
- Fewer bugs and faster debugging
- Better team collaboration
- Professional quality standards
- Easier onboarding for new developers
- More flexible architecture

**Remember: Good code is simple, clear, and purposeful.**

---

**Version**: 1.0 | **Updated**: 2025-11-05
