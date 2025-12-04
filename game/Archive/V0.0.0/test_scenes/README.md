# GoA Test Scenes

Autonomous testing suite for validating game systems.

## Available Tests

### 1. Stat Test (`stat_test.tscn`)
Tests the experience and stat progression system.

**What it tests:**
- Experience gain for all 6 stats (strength, constitution, dexterity, wisdom, intelligence, charisma)
- Stat level-ups based on experience thresholds
- Logging of stat changes

**Run command:**
```bash
godot --headless --path "c:\GoA" res://test_scenes/stat_test.tscn
```

### 2. Victory Condition Test (`victory_test.tscn`)
Tests the victory condition checking system.

**What it tests:**
- Initial state (no conditions met)
- Partial condition completion
- All conditions met
- Exceeding victory conditions

**Run command:**
```bash
godot --headless --path "c:\GoA" res://test_scenes/victory_test.tscn
```

### 3. Shop Purchase Test (`shop_test.tscn`)
Tests the shop system and purchase mechanics.

**What it tests:**
- Shop purchases and coin deduction
- Cost scaling after purchases
- Multiple sequential purchases
- Bribe shopkeep functionality
- Resource tracking

**Run command:**
```bash
godot --headless --path "c:\GoA" res://test_scenes/shop_test.tscn
```

## Running All Tests

Run all tests sequentially:
```bash
godot --headless --path "c:\GoA" res://test_scenes/stat_test.tscn
godot --headless --path "c:\GoA" res://test_scenes/victory_test.tscn
godot --headless --path "c:\GoA" res://test_scenes/shop_test.tscn
```

## Analyzing Test Results

### View Console Output
Tests output to stdout in real-time. Redirect to a file for analysis:
```bash
godot --headless --path "c:\GoA" res://test_scenes/stat_test.tscn 2>&1 | tee test_output.txt
```

### View Log File
After running tests, check the debug log file:

**Windows:**
```bash
type %APPDATA%\Godot\app_userdata\GoA\debug.log
```

**Linux/Mac:**
```bash
cat ~/.local/share/godot/app_userdata/GoA/debug.log
```

### Search for Specific Events

**Find all stat changes:**
```bash
grep "STAT_CHANGE" debug.log
```

**Find all shop purchases:**
```bash
grep "SHOP" debug.log
```

**Find all errors:**
```bash
grep "ERROR" debug.log
```

**Find test results:**
```bash
grep "TEST" debug.log
```

## Test Structure

Each test follows this pattern:

1. **Setup**: Initialize test data and resources
2. **Execute**: Perform actions being tested
3. **Assert**: Verify expected outcomes
4. **Log**: Record results via DebugLogger
5. **Cleanup**: Wait for logs to flush, then quit

## Creating New Tests

To create a new test:

1. Create a new `.gd` script in `test_scenes/`
2. Extend `Node`
3. Implement test logic in `_ready()`
4. Use `DebugLogger` to log events
5. Use `assert()` to validate outcomes
6. Create matching `.tscn` file
7. Always end with:
   ```gdscript
   await get_tree().create_timer(2.0).timeout
   get_tree().quit()
   ```

## Integration with CI/CD

These tests can be integrated into automated pipelines:

```bash
#!/bin/bash
# Run all tests and check for errors

echo "Running GoA test suite..."
godot --headless --path "c:\GoA" res://test_scenes/stat_test.tscn 2>&1 | tee test_log.txt

# Check for failures
if grep -q "ERROR" test_log.txt; then
    echo "Tests failed!"
    exit 1
fi

echo "All tests passed!"
exit 0
```

## Troubleshooting

### Tests hang or don't quit
- Ensure `get_tree().quit()` is called at the end
- Use `--quit-after N` parameter as backup
- Check for infinite loops in test logic

### Log file not found
- Verify DebugLogger is registered in project.godot
- Check file permissions for userdata directory
- Ensure `enable_file_output = true` in DebugLogger

### Assertions failing
- Review log output for actual vs expected values
- Check if global state is being properly reset between tests
- Verify autoload initialization order

## Log Categories

The DebugLogger tracks these categories:

- `TEST` - Test execution and results
- `STAT_CHANGE` - Stat level changes and experience
- `SHOP` - Shop purchases and upgrades
- `RESOURCE` - Coin and resource changes
- `VICTORY` - Victory condition checks
- `TIMER` - Timer events (whisper, suspicion, etc.)
- `SCENE` - Scene transitions
- `GET_CAUGHT` - Player caught events

## Best Practices

1. **Isolated tests**: Each test should be independent
2. **Clear logging**: Use descriptive log messages
3. **Comprehensive assertions**: Verify all expected outcomes
4. **Fast execution**: Keep tests under 10 seconds when possible
5. **Clean state**: Reset global variables as needed
6. **Meaningful names**: Use descriptive test and function names
