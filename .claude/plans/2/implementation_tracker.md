# Implementation Tracker - Rage System (2.10-rage.md)

## Status: COMPLETE

## Files Created

- [x] `level1/vignette.gdshader` - Radial vignette shader
- [x] `level1/vignette_overlay.gd` - Vignette flash controller
- [x] `level1/vignette_overlay.tscn` - Vignette scene (CanvasLayer + ColorRect with shader)

## Files Modified

- [x] `level1/level_1_vars.gd` - Added rage system logic (signals, constants, functions), rage tracking state variables
- [x] `level1/coal_piece.gd` - Call Level1Vars rage methods in drop/delivery handlers, flash vignette
- [x] `level1/furnace.gd` - Connect rage signals to notification system, add vignette scene instance

## Implementation Checklist

- [x] Level1Vars rage/whip_count variables present (already existed)
- [x] Level1Vars rage system signals added (rage_warning_triggered, rage_severe_warning_triggered, rage_whip_triggered)
- [x] Level1Vars rage constants added (thresholds, damage values)
- [x] Level1Vars rage functions added (on_coal_dropped_rage, on_coal_delivered_rage, _check_rage_thresholds, _apply_whip)
- [x] Level1Vars perform_daily_reset() updated with rage tracking state reset
- [x] Vignette shader (vignette.gdshader) created with radial gradient
- [x] VignetteOverlay scene created (CanvasLayer + ColorRect with shader)
- [x] Vignette flash_red() function working with shader intensity
- [x] Warning dialog pool implemented in Level1Vars
- [x] Severe warning dialog pool implemented in Level1Vars
- [x] Whipping logic implemented (increases constitution_exp by 0.5)
- [x] Coal drop triggers rage increase and vignette flash
- [x] Coal delivery triggers rage decrease check
- [x] Furnace connects to Level1Vars rage signals for notifications
- [ ] All tests passing (manual testing required)

## Testing Checklist

### Rage Tracking Tests
- [ ] Rage starts at 0
- [ ] Dropping coal increments rage by 1
- [ ] Delivering 10 coal decrements rage by 1
- [ ] Rage cannot go below 0
- [ ] Rage resets to 0 at day start

### Warning Tests
- [ ] Warning notification appears at rage 2
- [ ] Warning notification appears at rage 3, 4
- [ ] Different warning messages appear (randomized)
- [ ] Severe warning appears at rage 5
- [ ] Severe warning appears at rage 6, 7
- [ ] Different severe warning messages appear (randomized)
- [ ] No duplicate warnings for same rage level

### Whipping Tests
- [ ] First whip at rage 8, removes 10 stamina
- [ ] Second whip at rage 12, removes 15 stamina
- [ ] Third whip at rage 16, removes 20 stamina
- [ ] Constitution_exp increases by 0.5 per whip
- [ ] Whip count resets with rage at day start

### Visual Feedback Tests
- [ ] Red vignette flashes when coal dropped
- [ ] Vignette lasts approximately 300ms
- [ ] Vignette fades in quickly, fades out slowly
- [ ] Multiple drops can trigger overlapping flashes

### Integration Tests
- [ ] Coal dropped -> vignette + rage increase + possible warning
- [ ] Coal delivered -> rage decrease tracking
- [ ] Day transition -> rage reset
- [ ] Stamina display updates after whipping

## Notes

- Rage system variables (rage, whip_count) already existed in Level1Vars, no changes needed
- Save/load system updated to include new tracking state variables (_rage_coal_delivered_counter, _rage_last_warning_level, _rage_last_severe_level)
- reset_to_defaults() also updated to reset tracking state
- **Bug fix**: Added null check for `get_tree()` in coal_piece.gd vignette flash - `get_tree()` returns null during physics callbacks on nodes being removed from tree
