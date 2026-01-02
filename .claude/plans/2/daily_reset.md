# Daily Reset Variables

This document lists all variables reset when the player sleeps (daily reset). These reset at the start of each new work day within a run.

## Variables Reset Daily

### Coal Tracking (from 2.4, 2.5)
- `coal_dropped` -> 0
- `coal_delivered` -> 0

### Rage System (from 2.9)
- `rage` -> 0
- `whip_count` -> 0

### Focus (from 2.6)
- `focus` -> `focus_max` (full restore from mental rest)

### Technique System (via reset_techniques())
- `selected_techniques` -> {} (cleared)
- `upgrades_qty` -> 0
- `clean_streak_unlocked` -> false
- `heavy_combo_unlocked` -> false

### Combo State (via reset_techniques())
- `clean_streak_count` -> 0
- `clean_streak_max` -> 20 (base value)
- `forgiveness_charges` -> 0
- `forgiveness_coal_counter` -> 0
- `forgiveness_threshold` -> 0
- `forgiveness_max_capacity` -> 0
- `heavy_combo_stacks` -> 0
- `heavy_combo_timer` -> 0.0
- `recent_delivery_timestamps` -> [] (cleared)

### Hunger (from 2.9)
- `hungry` -> false
- `hunger_skip` -> false

## Variables NOT Reset Daily (Persist Within Run)

### Player Progression
- `player_level` - Shoveling mastery persists within run
- `player_exp` - XP toward next level persists

### Currency
- `currency` - All currency types persist within run
- `lifetime_currency` - Tracking persists

### Resource Pools
- `stamina` - Partially restored by eating and sleeping, NOT fully reset
- `stamina_max` - Maximum persists

## Reset Hierarchy

1. **Daily Reset** (sleeping): Resets stats from today's work shift, prepares for tomorrow
2. **Run Reset** (prestige/game over): Resets everything except permanent progression (see 2.x-prestige-system.md)

## Implementation Location

Daily reset is triggered in `Level1Vars.perform_daily_reset()` when player clicks "Go to Sleep" in dorm scene.

---

**Last Updated**: 2026-01-02
**Related Plans**: 2.4, 2.5, 2.6, 2.9, 2.13
