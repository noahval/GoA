# Button Hierarchy & Ordering Guide

**Version**: 1.1
**Last Updated**: 2025-11-05

## Overview

This document defines the standard ordering hierarchy for buttons in GoA's UI. Consistent button ordering improves UX by creating predictable patterns across all scenes.

**🎯 Automatic Enforcement**: Button hierarchy is now automatically enforced by `ResponsiveLayout`. All scenes that call `ResponsiveLayout.apply_to_scene(self)` will have their buttons automatically sorted according to this hierarchy.

---

## Quick Reference

### RightVBox/BottomVBox Button Order (Top to Bottom)
1. **Action Buttons** - Primary gameplay actions
2. **Forward Navigation** - Advance to deeper scenes
3. **Back Navigation** - Return to previous scenes

### LeftVBox/TopVBox Element Order (Top to Bottom)
1. **Title Panel** - Scene name
2. **Timer/Progress Panels** - Break timer, stamina, etc.
3. **Resource Panels** - Coins, coal, components, etc.
4. **Status Panels** - Suspicion, overseer mood, etc.

---

## Detailed Hierarchy Configuration

### RightVBox/BottomVBox Hierarchy

The hierarchy defines the **visual order from top to bottom**. Buttons should be arranged in .tscn files following this order:

#### Tier 1: Action Buttons (Top)
**Purpose**: Primary gameplay actions that affect game state
**Theme**: Standard orange buttons
**Examples**:
- Shovel Coal
- Place Pipe
- Assemble Component
- Buy Auto Shovel
- Bribe Overseer
- Bribe Barkeep
- Developer buttons

**Characteristics**:
- Direct gameplay mechanics
- Resource spending/generation
- Non-navigation actions

#### Tier 2: Forward Navigation (Middle)
**Purpose**: Navigate to new/deeper scenes
**Theme**: `ForwardNavButton` (light blue, 2px border)
**Examples**:
- To Crankshaft's
- To Workshop
- To Overseer's Office
- To Currency Converter
- Enter Secret Passage
- Approach Hidden Door

**Characteristics**:
- Move player forward in game progression
- Explore new areas
- Advance to sub-locations
- Text pattern: "To [Location]", "Enter [Place]", "Approach [Thing]"

#### Tier 3: Back Navigation (Bottom)
**Purpose**: Return to previous scenes
**Theme**: `BackNavButton` (dark blue, 1px border)
**Examples**:
- To Blackbore Bar
- To Coppersmith Carriage Hall
- To Secret Passage
- To Bar

**Characteristics**:
- Return to previously visited locations
- Exit current area
- Go back in scene hierarchy
- Text pattern: "To [Previous Location]", "Back to [Place]"

---

### LeftVBox/TopVBox Hierarchy

The left/top menu is primarily for **information display** with occasional action buttons.

#### Tier 1: Title Panel (Top)
**Purpose**: Display current scene name
**Examples**:
- "Blackbore Furnace"
- "Crankshaft's"
- "Currency Converter"

#### Tier 2: Timer/Progress Panels
**Purpose**: Time-sensitive or player-status information
**Examples**:
- Break Timer (with progress bar)
- Stamina (with progress bar)
- Suspicion (with progress bar)

#### Tier 3: Resource Panels
**Purpose**: Display collected resources/currency
**Examples**:
- Coins
- Coal Shoveled
- Components
- Mechanisms
- Pipes

#### Tier 4: Status Panels
**Purpose**: Narrative or world state information
**Examples**:
- Overseer Mood
- Notification messages

---

## Reordering the Hierarchy

### How to Change Button Order Priority

To modify the hierarchy, edit the `ButtonHierarchy` autoload (`button_hierarchy_config.gd`):

```gdscript
# Current hierarchy (lower number = higher priority = displayed higher)
const BUTTON_ORDER = {
	ButtonType.ACTION: 0,      # Top
	ButtonType.FORWARD_NAV: 1, # Middle
	ButtonType.BACK_NAV: 2     # Bottom
}
```

**To change order**: Swap the numbers. For example, to put Back Nav above Forward Nav:

```gdscript
const BUTTON_ORDER = {
	ButtonType.ACTION: 0,      # Top
	ButtonType.BACK_NAV: 1,    # Middle (was 2)
	ButtonType.FORWARD_NAV: 2  # Bottom (was 1)
}
```

### How to Add New Button Types

1. Add new enum value in `button_hierarchy_config.gd`:
```gdscript
enum ButtonType {
	ACTION,
	FORWARD_NAV,
	BACK_NAV,
	DEVELOPER,  # New type
}
```

2. Add ordering priority:
```gdscript
const BUTTON_ORDER = {
	ButtonType.ACTION: 0,
	ButtonType.FORWARD_NAV: 1,
	ButtonType.BACK_NAV: 2,
	ButtonType.DEVELOPER: 3  # Add position
}
```

3. Update button type detection logic in `get_button_type()` function

---

## Implementation Guide

### Ordering Buttons in .tscn Files

In Godot scene files, buttons are defined in order. Follow this pattern:

```
[node name="ActionButton1" type="Button" ...]  # Tier 1: Action
[node name="ActionButton2" type="Button" ...]  # Tier 1: Action
[node name="ForwardNavButton" type="Button" ...]  # Tier 2: Forward Nav
[node name="BackNavButton" type="Button" ...]  # Tier 3: Back Nav
```

**Important**: The `index` attribute in parent path determines visual order:
```
[node name="Button1" parent="HBoxContainer/RightVBox" index="0"]  # Top
[node name="Button2" parent="HBoxContainer/RightVBox" index="1"]
[node name="Button3" parent="HBoxContainer/RightVBox" index="2"]  # Bottom
```

### Example: Correct Button Order

**Coppersmith Carriage Hall** ([coppersmith_carriage.tscn](../../level1/coppersmith_carriage.tscn)):
```
Tier 1 (Action):
  - Bribe Overseer: 5

Tier 2 (Forward Nav):
  - To Overseer's Office (ForwardNavButton)
  - To Crankshaft's (ForwardNavButton)
  - To Currency Converter (ForwardNavButton)

Tier 3 (Back Nav):
  - To Blackbore Bar (BackNavButton)
```

**Shop/Crankshaft's** ([shop.tscn](../../level1/shop.tscn)):
```
Tier 1 (Action):
  - Shovels
  - Auto-Shovels
  - Bribe Shopkeep: 10

Tier 2 (Forward Nav):
  - To Workshop (ForwardNavButton)

Tier 3 (Back Nav):
  - To Coppersmith Carriage (BackNavButton)
```

---

## Pattern Recognition

### Forward Navigation Indicators
- Text contains: "To [New Place]", "Enter", "Approach", "Explore"
- Theme: `ForwardNavButton`
- Leads to: Sub-locations, new areas, deeper exploration

### Back Navigation Indicators
- Text contains: "To [Previous Place]", "Back to", "Return to"
- Theme: `BackNavButton`
- Leads to: Previously visited locations, parent scenes

### Action Button Indicators
- Text contains: Action verbs ("Shovel", "Buy", "Bribe", "Assemble")
- Theme: Default orange button
- Effect: Changes game state, spends/earns resources

---

## Migration Checklist

When updating existing scenes to follow hierarchy:

- [ ] Read the scene's .tscn file
- [ ] Identify all buttons in RightVBox/BottomVBox
- [ ] Categorize each button (Action, Forward Nav, Back Nav)
- [ ] Reorder buttons in .tscn file following hierarchy
- [ ] Update `index` attributes to match new order
- [ ] Apply correct `theme_type_variation` for nav buttons
- [ ] Test scene to verify button order

---

## Scene-Specific Button Orders

### Current Implementations

| Scene | Actions | Forward Nav | Back Nav |
|-------|---------|-------------|----------|
| **furnace.tscn** | Shovel Coal, Convert Coal, Toggle Mode, Steal Coal | Take Break | - |
| **bar.tscn** | Anthracite Delight, Steel Stout, Bribe Barkeep, Developer: Free Coins, Follow whispering voice | Enter Secret Passage, To Coppersmith Carriage | To Blackbore Furnace |
| **coppersmith_carriage.tscn** | Bribe Overseer | To Overseer's Office, To Crankshaft's, To Currency Converter | To Blackbore Bar |
| **shop.tscn** | Shovels, Auto-Shovels, Bribe Shopkeep | To Workshop | To Coppersmith Carriage |
| **workshop.tscn** | Assemble Component, Assemble Pipe, Assemble Mechanism, Developer: Pipes | - | To Crankshaft's |
| **atm.tscn** | - | - | To Coppersmith Carriage Hall |
| **secret_passage_entrance.tscn** | - | Approach Hidden Door | To Bar |
| **secret_passage_puzzle.tscn** | Place Pipe | - | To Secret Passage |
| **train_heart.tscn** | Take Whispering Crystal | - | To Secret Passage |

---

## Automatic Enforcement

**Button hierarchy is now enforced automatically!**

The `ResponsiveLayout.apply_to_scene()` function (called by all scenes) automatically sorts buttons according to the hierarchy defined in `ButtonHierarchy`. This means:

- ✅ **Automatic sorting**: Buttons are reordered at runtime to match the hierarchy
- ✅ **No manual implementation needed**: Individual scenes don't need sorting code
- ✅ **Centralized changes**: Modify `button_hierarchy_config.gd` and all scenes update
- ✅ **Debug validation**: In debug builds, warnings appear if hierarchy is violated

### How It Works

1. Scene calls `ResponsiveLayout.apply_to_scene(self)` in `_ready()`
2. ResponsiveLayout automatically calls `ButtonHierarchy.sort_buttons_by_hierarchy()`
3. Buttons are reordered according to their type (Action, Forward Nav, Back Nav, Developer)
4. In debug mode, validation warnings appear in console if there are issues

### Manual Validation (Optional)

For each scene with buttons:
1. Open the .tscn file
2. Check RightVBox button order matches hierarchy (will be auto-corrected at runtime)
3. Verify theme_type_variation is correct for nav buttons
4. Confirm button text patterns match button type

---

## Best Practices

### Button Naming
- **Action buttons**: Descriptive verb phrase (`ShovelCoalButton`, `BribeOverseerButton`)
- **Forward nav**: `[Location]Button` (`ShopButton`, `WorkshopButton`)
- **Back nav**: `To[Location]Button` or `BackButton` (`ToBarButton`, `BackButton`)

### Visibility Management
Buttons can be hidden/shown dynamically while maintaining hierarchy order:
```gdscript
forward_nav_button.visible = false  # Hidden but still in correct position
```

### Dynamic Button Creation
When creating buttons in code, add them in hierarchy order:
```gdscript
func add_navigation_buttons():
    # Add forward nav buttons first
    var forward_btn = _create_button("Enter Area", forward_callback)
    forward_btn.theme_type_variation = &"ForwardNavButton"
    right_vbox.add_child(forward_btn)

    # Then add back nav buttons
    var back_btn = _create_button("To Previous Area", back_callback)
    back_btn.theme_type_variation = &"BackNavButton"
    right_vbox.add_child(back_btn)
```

---

## Related Documentation

- [theme-system.md](theme-system.md) - Button theme variations (ForwardNavButton, BackNavButton)
- [godot-dev.md](godot-dev.md) - Scene structure and node organization
- [responsive-layout.md](responsive-layout.md) - Layout system and adaptive UI

---

## Version History

**v1.1** (2025-11-05)
- Added automatic button hierarchy enforcement via ResponsiveLayout
- Buttons now auto-sort at runtime based on ButtonHierarchy configuration
- Centralized implementation - no per-scene code needed
- Debug validation warnings in console

**v1.0** (2025-11-05)
- Initial hierarchy definition
- Three-tier system for RightVBox
- Four-tier system for LeftVBox
- Migration guide and examples
