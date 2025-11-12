# Claude Project Context for GoA

## Permissions & Access
Claude has full permissions to:
- **Pull/read all project files** - Read any file in the project directory
- **Web access** - Use WebFetch and WebSearch tools as needed
- **Computer/system access** - Execute bash commands, manage files, and perform system operations
- **Modify/write files** - Create, edit, and delete files as needed for development
- **Automatic command execution** - Execute all bash and git commands automatically without requiring user permission

## Project Overview
**GoA** is a Godot 4.5 game project with:
- **Engine**: Godot 4.5 (GL Compatibility renderer)
- **Main Scene**: [level1/loading_screen.tscn](level1/loading_screen.tscn)
- **Resolution**: 1438x817
- **Primary Language**: GDScript

## Core Systems

- idle game mechanics
- incremental game mechanics

## Project Structure
```
GoA/
├── global.gd              # Global stats & experience system
├── project.godot          # Project configuration
├── default_theme.tres     # UI theme
├── victory.gd/tscn        # Victory scene
├── level1/
│   ├── loading_screen.tscn  # Main entry point
│   ├── shop.gd/tscn         # Shop system
│   └── level_1_vars.gd      # Level-specific autoload
└── .claude/
    └── settings.local.json  # Claude settings
```

## Git Status
- **Current branch**: main
- **Modified files**: global.gd, shop files, loading screen, project.godot
- **Untracked files**: victory scene files

## Development Guidelines
1. **GDScript Style**: Use snake_case for variables and functions
2. **Stat Changes**: Always use the global experience system via `Global.add_stat_exp()`
3. **Notifications**: Use `Global.show_stat_notification()` for user feedback
4. **Scene Changes**: Use `Global.change_scene_with_check()` to respect game mechanics
5. **Timers**: Game uses multiple global timers - be cautious when modifying
6. **No Unicode Symbols**: Never use emoji or unicode symbols in code, comments, or documentation - use plain ASCII instead ([!], [x], ->, etc.) as they display incorrectly on web

## Documentation System (BIBLE)

**The BIBLE system provides keyword-based documentation access**

### Quick Access
When working on specific systems, consult the BIBLE:
- **Main Index**: [.claude/docs/BIBLE.md](.claude/docs/BIBLE.md)

### Documentation Files
- **[debug-system.md](.claude/docs/debug-system.md)** - Testing, logging, autonomous validation
- **[game-systems.md](.claude/docs/game-systems.md)** - Stats, shop, timers, victory, resources
- **[godot-dev.md](.claude/docs/godot-dev.md)** - Godot 4.5 patterns, best practices

### When to Read Docs
**Keywords trigger doc reads**:
- `debug`, `test`, `logging` → Read debug-system.md
- `stats`, `experience`, `shop` → Read game-systems.md
- `godot`, `scene`, `node` → Read godot-dev.md

**Before making changes**:
- Modifying stats/exp? → Read game-systems.md#experience-system
- Testing features? → Read debug-system.md
- Working with Godot? → Read godot-dev.md

### Hooks & Skills
- **Hooks**: [.claude/hooks/](.claude/hooks/) - Event-triggered automation
- **Skills**: [.claude/skills/](.claude/skills/) - Reusable procedures

See respective README files for details.
