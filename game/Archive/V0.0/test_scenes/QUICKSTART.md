# Quick Start Guide - Autonomous Testing

## Prerequisites

Ensure Godot is accessible from command line. If `godot` command is not found:

### Windows
Add Godot to your PATH, or use the full path:
```bash
"C:\Path\To\Godot_v4.5_win64.exe" --headless --path "c:\GoA" res://test_scenes/stat_test.tscn
```

### Finding Godot Executable
Common locations:
- `C:\Program Files\Godot\godot.exe`
- `C:\Godot\Godot_v4.x_win64.exe`
- `%LOCALAPPDATA%\Godot\godot.exe`

## Running Your First Test

1. **Open terminal** in project directory
2. **Run stat test:**
   ```bash
   godot --headless --path "c:\GoA" res://test_scenes/stat_test.tscn
   ```
3. **Check output** for test results
4. **View detailed logs:**
   ```bash
   type %APPDATA%\Godot\app_userdata\GoA\debug.log
   ```

## Quick Test Commands

### Stat Progression Test
```bash
godot --headless --path "c:\GoA" res://test_scenes/stat_test.tscn
```

### Victory Conditions Test
```bash
godot --headless --path "c:\GoA" res://test_scenes/victory_test.tscn
```

### Shop Purchase Test
```bash
godot --headless --path "c:\GoA" res://test_scenes/shop_test.tscn
```

## Understanding Output

### Success Output Example
```
[2025-10-29 14:23:15][INFO][TEST] === Starting Stat Test ===
[2025-10-29 14:23:15][INFO][TEST] Testing strength progression...
[2025-10-29 14:23:15][INFO][STAT_CHANGE] Stat 'strength': 1.00 -> 2.00 (exp: +150.00)
[2025-10-29 14:23:16][INFO][TEST] === Stat Test Complete - All Tests Passed ===
```

### Error Output Example
```
[2025-10-29 14:23:15][ERROR][TEST] Assertion failed: Strength should be level 2+
```

## Troubleshooting

### "godot: command not found"
Use full path to Godot executable instead of just `godot`

### "Failed to open debug log file"
DebugLogger autoload might not be registered. Check [project.godot:24](../project.godot#L24)

### Test hangs indefinitely
Add timeout parameter:
```bash
godot --headless --path "c:\GoA" res://test_scenes/stat_test.tscn --quit-after 30
```

## Next Steps

- Review [README.md](README.md) for complete testing documentation
- Check [.claude/docs/debug-system.md](../.claude/docs/debug-system.md) for logging details
- Create custom tests for your specific features

## Log File Location

The debug log is stored at:
- **Windows:** `%APPDATA%\Godot\app_userdata\GoA\debug.log`
- **Linux:** `~/.local/share/godot/app_userdata/GoA/debug.log`
- **Mac:** `~/Library/Application Support/Godot/app_userdata/GoA/debug.log`

Quick view command:
```bash
# Windows
type %APPDATA%\Godot\app_userdata\GoA\debug.log

# Linux/Mac
cat ~/.local/share/godot/app_userdata/GoA/debug.log
```
