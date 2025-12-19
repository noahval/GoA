# THE BIBLE - Master Documentation Index

**⚠️ MASTER INDEX FOR ALL GOA DOCUMENTATION ⚠️**

**Purpose**: Keyword-based navigation to technical documentation
**Usage**: Check this index before working on any system → Find relevant docs → Read them → Follow documented patterns

---

## ⭐ HIGHEST PRIORITY: Knowledge as Progression

**🧠 GoA's Core Design Philosophy: Knowledge > Power**

Before designing ANY new system or feature:
1. **Read** [game-design-principles.md#knowledge-as-progression](game-design-principles.md#knowledge-as-progression-high-priority-for-goa)
2. **Ask**: Can this be learned through observation instead of tutorials?
3. **Check**: Does this respect the player's intelligence and curiosity?

**Key Principle**: "Keep the locks, give players information to pick them instead of keys"

**Why This Matters**:
- Players feel **smart** when they discover patterns themselves
- Mysterious gameplay (qualitative over quantitative) = knowledge-based design
- Your overseer mood, worker treatment, and environmental systems ARE knowledge gates
- Discovery is the game - don't spoil it with explicit tutorials

**When Designing Features**: Use the [Knowledge-Based Systems Checklist](game-design-principles.md#design-checklist-for-knowledge-based-systems)

---

## Documentation Standards

### Text Formatting Rules

**CRITICAL: Avoid Unicode Symbols in Documentation**

Unicode symbols (emoji, special characters) display incorrectly in many web contexts (GitHub, browsers, etc.).

**Forbidden**:
- Emoji (warning sign, checkmark, star, robot, etc.)
- Unicode arrows (→, ←, ↑, ↓)
- Special symbols (★, ✓, ✗, etc.)

**Use Instead**:
- Plain text markers: [!], [x], [*]
- ASCII arrows: ->, <-, ^, v
- Words: WARNING, CHECK, NOTE, CRITICAL
- Markdown: **bold**, *italic*, `code`

**Examples**:
```
Bad:  ⚠️ CRITICAL: Do not use unicode
Good: [!] CRITICAL: Do not use unicode

Bad:  ✅ Correct approach
Good: [x] Correct approach

Bad:  ⭐ Important feature
Good: [*] Important feature or **Important feature**

Bad:  File path → line 42
Good: File path -> line 42
```

**Why**: Unicode symbols break in:
- GitHub markdown rendering
- Web browsers (varying font support)
- Terminal displays
- Copy/paste operations
- Search functionality

**When Writing Documentation**:
1. Use plain ASCII characters only
2. Use markdown formatting for emphasis
3. Use words instead of symbols for clarity
4. Test rendering in multiple contexts

### Dash Usage in Language Text

**CRITICAL: Avoid Dashes in In-Game Text and Flavor Text**

Dashes should not be used to separate clauses or provide explanations in language text (dialogue, descriptions, flavor text, notifications).

**Forbidden**:
- Using dashes for explanations: "Morning rush - all elevators running"
- Using dashes for clarifications: "Deep night - all city districts sleeping"
- Using dashes as separators: "Steep grade - maximum power needed"

**Use Instead**:
- Colons for explanations: "Morning rush: all elevators running"
- Commas for continuation: "Deep night, all city districts sleeping"
- Semicolons for related clauses where appropriate
- Remove hyphenated phrases where possible

**Examples**:
```
Bad:  "Coasting downhill - gravity assist"
Good: "Coasting downhill: gravity assist"

Bad:  "Night shift - residential districts dormant"
Good: "Night shift, residential districts dormant"

Bad:  "Noble override - lower districts cut off!"
Good: "Noble override: lower districts cut off!"
```

**Why**: Dashes create visual clutter and reduce readability in compact UI text. Colons and commas provide clearer semantic meaning.

**When Writing In-Game Text**:
1. Use colons (:) for explanations or results
2. Use commas (,) for continuation or description
3. Use semicolons (;) for related but distinct clauses
4. Keep text concise and punchy

---

## Automatic Hook System

The BIBLE Check Hook auto-triggers on development keywords (scene, stats, popup, etc.) and suggests relevant docs.

**Bypass**: Use "skip docs", "quick question", or "just read [specific-doc.md]" to skip the check.
**Details**: See [.claude/hooks/README.md](../../hooks/README.md)

---

## 📖 Documentation Quick Reference

| Doc | Keywords | Contents |
|-----|----------|----------|
| **[TOC.md](TOC.md)** | roadmap, implementation order, feature list, TOC, plans, dependencies, plan docs, feature roadmap, development order, system dependencies, plan references | Complete feature implementation roadmap listing all features in sequential order. Cross-references to plan docs in `.claude/plans/` folder. Use for understanding implementation order, checking which features need plans, and navigating system dependencies. |
| **⭐ [game-design-principles.md](game-design-principles.md)** | **PRIORITY: knowledge as progression, metroidbrainia, discovery, mysterious gameplay, grimdark, theme, atmosphere, tone**, game design, principles, best practices, player engagement, retention, UX, UI, feedback, progression, balance, difficulty, idle, incremental, loop, motivation, polish, quality, observation, experimentation, aha moments | **HIGH PRIORITY**: Knowledge-based progression (players learn through discovery, not tutorials). Grimdark theme (oppressive atmosphere, grim vocabulary, no false hope). Comprehensive game design guide: core principles (easy to learn/hard to master, clear goals, player agency), engagement/retention strategies, UX/UI best practices, gameplay loop design, idle/incremental mechanics, balancing, feedback systems, progression design, quality checklist |
| **[game-systems.md](game-systems.md)** | stats, experience, shop, timer, victory, suspicion, coins | Experience/leveling, shop mechanics, timers (whisper, suspicion, stamina), victory conditions, notifications |
| **[nakama-integration.md](nakama-integration.md)** | nakama, server, auth, authentication, cloud, save, multiplayer, online, login, local save, offline, browser save, LocalSaveManager, IndexedDB | Nakama server setup, NakamaClient API, authentication (email/password, Google OAuth), cloud saves, local browser saves, storage, login system |
| **[deployment.md](deployment.md)** | deploy, github, actions, workflow, build, export, pages | GitHub Actions workflow, automated builds, deployment process, export settings |
| **[scene-template.md](scene-template.md)** | scene, template, layout, container, background | Four-container layout, scene inheritance, container structure, background auto-loading |
| **[responsive-layout.md](responsive-layout.md)** | responsive, portrait, landscape, scaling, mobile | UI scaling, orientation handling, ResponsiveLayout system, mouse_filter management |
| **[popup-system.md](popup-system.md)** | popup, dialog, modal, PopupContainer | Popup API, PopupContainer requirement, implementation patterns |
| **[notifications.md](notifications.md)** | notification, NotificationBar, show_stat_notification | Notification flow, dynamic panel creation, auto-removal timers |
| **[theme-system.md](theme-system.md)** | theme, styling, colors, StyleBoxFlat | default_theme.tres, base styles, theme variations, color palette |
| **[button-hierarchy.md](button-hierarchy.md)** | button order, button hierarchy, navigation buttons, button organization, ForwardNavButton, BackNavButton, RightVBox, LeftVBox | Button ordering standards, navigation button hierarchy, configurable button priority system, left/right panel organization |
| **[debug-system.md](debug-system.md)** | debug, logging, test, DebugLogger, validate | Testing procedures, DebugLogger, headless testing, log analysis |
| **[godot-dev.md](godot-dev.md)** | godot, gdscript, node, signal, autoload | GDScript patterns, scene management, node lifecycle, best practices |
| **[programming-principles.md](programming-principles.md)** | **TDD, test-driven development, RED-GREEN-REFACTOR**, SOLID, DRY, KISS, YAGNI, principles, best practices, code quality, refactoring, clean code, maintainability, testing methodology, write tests first | General programming principles (SOLID, DRY, KISS, YAGNI) and **comprehensive TDD methodology** (RED-GREEN-REFACTOR cycle) adapted for GDScript/Godot development, code quality checklist |

---

## 🎯 Common Tasks → Docs

- **⭐ Design new features (ALWAYS START HERE)** → [game-design-principles.md#knowledge-as-progression](game-design-principles.md#knowledge-as-progression-high-priority-for-goa)
- **Create mysterious/discoverable systems** → [game-design-principles.md#knowledge-as-progression](game-design-principles.md#knowledge-as-progression-high-priority-for-goa)
- **Design without tutorials/hand-holding** → [game-design-principles.md#knowledge-as-progression](game-design-principles.md#knowledge-as-progression-high-priority-for-goa)
- **⭐ Writing dialogue/narrative/descriptions** → Check [BIBLE.md#grimdark-theme](BIBLE.md#design-philosophy-highest-priority) for tone guidelines
- **Evaluate game quality/design principles** → [game-design-principles.md](game-design-principles.md)
- **Improve player engagement/retention** → [game-design-principles.md](game-design-principles.md)
- **Balance progression/difficulty** → [game-design-principles.md](game-design-principles.md)
- **Enhance UX/UI/feedback** → [game-design-principles.md](game-design-principles.md)
- **Modify stats/shop/timers/victory** → [game-systems.md](game-systems.md)
- **Online features/cloud saves/authentication/login** → [nakama-integration.md](nakama-integration.md)
- **Offline saves/local browser storage** → [nakama-integration.md](nakama-integration.md#local-browser-storage)
- **Deploy to GitHub Pages/setup workflow** → [deployment.md](deployment.md)
- **Create/modify scenes** → [scene-template.md](scene-template.md) + [responsive-layout.md](responsive-layout.md)
- **Add popup/dialog** → [popup-system.md](popup-system.md)
- **Display notifications** → [notifications.md](notifications.md)
- **Fix UI scaling/buttons** → [responsive-layout.md](responsive-layout.md)
- **Change colors/theme** → [theme-system.md](theme-system.md)
- **Order buttons in scenes/navigation hierarchy** → [button-hierarchy.md](button-hierarchy.md)
- **Test/debug** → [debug-system.md](debug-system.md)
- **Write new features/fix bugs** → [programming-principles.md#test-driven-development-tdd](programming-principles.md#test-driven-development-tdd) (TDD methodology)
- **Write tests first** → [programming-principles.md#test-driven-development-tdd](programming-principles.md#test-driven-development-tdd)
- **Godot patterns** → [godot-dev.md](godot-dev.md)
- **Refactor code/improve code quality** → [programming-principles.md](programming-principles.md)
- **Code review/architectural decisions** → [programming-principles.md](programming-principles.md)
- **Review/improve plans before implementation** → [improve-plan skill](../skills/improve-plan.md)

---

## ⚠️ Critical Patterns

### Design Philosophy (HIGHEST PRIORITY)
**⭐ Knowledge as Progression** (applies to ALL features):
- **Players learn through observation**, not tutorials
- **Hide numbers, show qualitative feedback** (adjectives, not multipliers)
- **Tools available early**, understanding comes later
- **Discovery is the reward** - don't spoil with explicit explanations
- **Use the checklist**: [game-design-principles.md#design-checklist-for-knowledge-based-systems](game-design-principles.md#design-checklist-for-knowledge-based-systems)

**⭐ Grimdark Theme** (applies to ALL content):
- **Oppressive atmosphere**: You are a slave in a harsh industrial setting
- **No false hope**: Avoid overly positive language (e.g., "ecstatic" → "delighted" at best)
- **Grim vocabulary**: Use words that reflect suffering, oppression, and survival
- **Dark humor acceptable**: Gallows humor fits the theme
- **NPCs are oppressors**: Overseer, guards, and authority figures are harsh/indifferent
- **Player is powerless but clever**: Power comes through cunning, not strength

### Code Quality Standards (ALWAYS apply)
- **Follow Test-Driven Development (TDD)**: Write tests FIRST, then implementation
  - **RED-GREEN-REFACTOR cycle**: Write failing test → Make it pass → Refactor
  - **Verify RED**: Always confirm test fails before implementing
  - **No production code without failing test first**
  - See [programming-principles.md#test-driven-development-tdd](programming-principles.md#test-driven-development-tdd)
- **Apply SOLID, DRY, KISS, YAGNI principles** to all code
- **Proactive application**: Reference [programming-principles.md](programming-principles.md) when:
  - Writing new scripts/scenes (use TDD!)
  - Refactoring existing code
  - Reviewing code quality
  - Making architectural decisions
  - Noticing code duplication or complexity
- **Code Quality Checklist**: Use the TDD + design principles checklist before completing tasks

### Technical APIs (ALWAYS use, NEVER bypass)
- **Stats**: `Global.add_stat_exp()` (not direct modification)
- **Scene changes**: `Global.change_scene_with_check()` (not direct change_scene)
- **Notifications**: `Global.show_stat_notification()`
- **Popups**: Place in `PopupContainer`
- **Responsive**: Call `ResponsiveLayout.apply_to_scene(self)` in `_ready()`
- **Timers**: Use Global timers (not scene-local)
- **Cloud saves**: Use `NakamaManager` autoload (authenticate before storage operations)
- **Local saves**: Use `LocalSaveManager` autoload (for offline play)

---

## 🔧 Development Skills (Superpowers)

**Purpose**: Systematic workflows for testing, debugging, planning, and code quality

| Skill | Keywords | When to Use |
|-------|----------|-------------|
| **[test-driven-development](../skills/test-driven-development.md)** | test, testing, TDD, feature, bug fix, new code | Writing new features, fixing bugs, refactoring |
| **[systematic-debugging](../skills/systematic-debugging.md)** | debug, debugging, error, bug, failure, crash | Encountering bugs, errors, test failures |
| **[verification-before-completion](../skills/verification-before-completion.md)** | verification, verify, complete, done, finished | Before claiming work is complete or tests pass |
| **[brainstorming](../skills/brainstorming.md)** | brainstorm, design, planning, architecture | Turning ideas into designs, planning features |
| **[writing-plans](../skills/writing-plans.md)** | plan, implementation plan, roadmap | Creating detailed implementation plans |
| **[executing-plans](../skills/executing-plans.md)** | execute plan, implementation, batch execution | Implementing detailed plans with checkpoints |
| **[root-cause-tracing](../skills/root-cause-tracing.md)** | root cause, trace, call stack, data flow | Deep errors, long stack traces, unclear origins |
| **[defense-in-depth](../skills/defense-in-depth.md)** | validation, guards, error prevention | Implementing validation, hardening code |
| **[condition-based-waiting](../skills/condition-based-waiting.md)** | async, asynchronous, waiting, polling, flaky | Async operations, flaky tests, race conditions |
| **[testing-anti-patterns](../skills/testing-anti-patterns.md)** | test anti-pattern, mocking, test quality | Writing or reviewing test code |
| **[dispatching-parallel-agents](../skills/dispatching-parallel-agents.md)** | parallel agents, concurrent debugging | Multiple independent failures or subsystems |
| **[requesting-code-review](../skills/requesting-code-review.md)** | code review, review request, peer review | After completing tasks or major features |
| **[receiving-code-review](../skills/receiving-code-review.md)** | review feedback, handling feedback | Processing code review feedback |
| **[using-git-worktrees](../skills/using-git-worktrees.md)** | git worktree, parallel development | Working on multiple branches simultaneously |
| **[finishing-a-development-branch](../skills/finishing-a-development-branch.md)** | finish branch, merge, pull request, PR | Completing feature development, integration |
| **[subagent-driven-development](../skills/subagent-driven-development.md)** | subagent development, task execution | Executing plans with quality gates |
| **[writing-skills](../skills/writing-skills.md)** | skill creation, writing skills, skill development | Creating new skill documentation |
| **[sharing-skills](../skills/sharing-skills.md)** | skill sharing, contributing skills | Contributing skills to upstream |
| **[testing-skills-with-subagents](../skills/testing-skills-with-subagents.md)** | skill testing, skill validation | Validating skill documentation |
| **[using-superpowers](../skills/using-superpowers.md)** | skill usage, using skills, workflow selection | Beginning any task (first response checklist) |
| **[improve-plan](../skills/improve-plan.md)** | improve plan, review plan, check plan, plan review, enhance plan | Reviewing plan quality, checking for issues before implementation |

**See also**: [.claude/skills/README.md](../skills/README.md) for full skill documentation

---

**Workflow**:
1. **Always start with Knowledge as Progression** when designing features
2. **Maintain grimdark tone** in all content (dialogue, descriptions, mood adjectives)
3. **Apply SOLID, DRY, KISS, YAGNI principles** to all code (see Critical Patterns above)
4. Check keywords → Find docs in table above
5. Read them → Follow documented patterns
6. Use the [Knowledge-Based Systems Checklist](game-design-principles.md#design-checklist-for-knowledge-based-systems) before implementing

**Version**: 2.9 (Added TDD as critical development pattern) | **Updated**: 2025-11-11
