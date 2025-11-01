# THE BIBLE - Master Documentation Index

**⚠️ MASTER INDEX FOR ALL GOA DOCUMENTATION ⚠️**

**Purpose**: Keyword-based navigation to technical documentation
**Usage**: Check this index before working on any system → Find relevant docs → Read them → Follow documented patterns

## 🤖 Automatic Hook System

The BIBLE Check Hook auto-triggers on development keywords (scene, stats, popup, etc.) and suggests relevant docs.

**Bypass**: Use "skip docs", "quick question", or "just read [specific-doc.md]" to skip the check.
**Details**: See [.claude/hooks/README.md](../../hooks/README.md)

---

## 📖 Documentation Quick Reference

| Doc | Keywords | Contents |
|-----|----------|----------|
| **[game-systems.md](game-systems.md)** | stats, experience, shop, timer, victory, suspicion, coins | Experience/leveling, shop mechanics, timers (whisper, suspicion, stamina), victory conditions, notifications |
| **[nakama-integration.md](nakama-integration.md)** | nakama, server, auth, authentication, cloud, save, multiplayer, online, login, local save, offline, browser save, LocalSaveManager, IndexedDB | Nakama server setup, NakamaClient API, authentication (email/password, Google OAuth), cloud saves, local browser saves, storage, login system |
| **[deployment.md](deployment.md)** | deploy, github, actions, workflow, build, export, pages | GitHub Actions workflow, automated builds, deployment process, export settings |
| **[scene-template.md](scene-template.md)** | scene, template, layout, container, background | Four-container layout, scene inheritance, container structure, background auto-loading |
| **[responsive-layout.md](responsive-layout.md)** | responsive, portrait, landscape, scaling, mobile | UI scaling, orientation handling, ResponsiveLayout system, mouse_filter management |
| **[popup-system.md](popup-system.md)** | popup, dialog, modal, PopupContainer | Popup API, PopupContainer requirement, implementation patterns |
| **[notifications.md](notifications.md)** | notification, NotificationBar, show_stat_notification | Notification flow, dynamic panel creation, auto-removal timers |
| **[theme-system.md](theme-system.md)** | theme, styling, colors, StyleBoxFlat | default_theme.tres, base styles, theme variations, color palette |
| **[debug-system.md](debug-system.md)** | debug, logging, test, DebugLogger, validate | Testing procedures, DebugLogger, headless testing, log analysis |
| **[godot-dev.md](godot-dev.md)** | godot, gdscript, node, signal, autoload | GDScript patterns, scene management, node lifecycle, best practices |

---

## 🎯 Common Tasks → Docs

- **Modify stats/shop/timers/victory** → [game-systems.md](game-systems.md)
- **Online features/cloud saves/authentication/login** → [nakama-integration.md](nakama-integration.md)
- **Offline saves/local browser storage** → [nakama-integration.md](nakama-integration.md#local-browser-storage)
- **Deploy to GitHub Pages/setup workflow** → [deployment.md](deployment.md)
- **Create/modify scenes** → [scene-template.md](scene-template.md) + [responsive-layout.md](responsive-layout.md)
- **Add popup/dialog** → [popup-system.md](popup-system.md)
- **Display notifications** → [notifications.md](notifications.md)
- **Fix UI scaling/buttons** → [responsive-layout.md](responsive-layout.md)
- **Change colors/theme** → [theme-system.md](theme-system.md)
- **Test/debug** → [debug-system.md](debug-system.md)
- **Godot patterns** → [godot-dev.md](godot-dev.md)

---

## ⚠️ Critical Patterns

**ALWAYS use these APIs** (NEVER bypass):
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

**See also**: [.claude/skills/README.md](../skills/README.md) for full skill documentation

---

**Workflow**: Check keywords → Find docs in table above → Read them → Follow documented patterns

**Version**: 2.5 (Added Superpowers skills) | **Updated**: 2025-11-01
