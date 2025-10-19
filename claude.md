# Claude Project Context for GoA

## Permissions & Access
Claude has full permissions to:
- **Pull/read all project files** - Read any file in the project directory
- **Web access** - Use WebFetch and WebSearch tools as needed
- **Computer/system access** - Execute bash commands, manage files, and perform system operations
- **Modify/write files** - Create, edit, and delete files as needed for development

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
