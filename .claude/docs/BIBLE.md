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

**Workflow**: Check keywords → Find docs in table above → Read them → Follow documented patterns

**Version**: 2.4 (Added local browser save system) | **Updated**: 2025-10-31
