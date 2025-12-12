# Level 1 Scene Content Standards (Reference Doc)

**Purpose**: Document standard UI elements, variables, and patterns for Level 1 (Copper Era) scenes as they emerge from implementation

**Referenced By**:
- [1.13-scene-template.md](../1/1.13-scene-template.md) - Universal scene structure
- [2.1-scene-network.md](2.1-scene-network.md) - Scene navigation system
- Individual scene plans (2.3+) - Implementation references

---

## Overview

This document captures **Level 1 specific standards** that emerge from scene implementation. The universal scene structure is defined in [1.13-scene-template.md](../1/1.13-scene-template.md) (Background, MainLayout, PlayArea, Menu, NotificationBar). This doc specifies what goes **inside** those containers for Level 1.

**Fill this in as patterns emerge** - don't pre-define standards, discover them through actual implementation.

---

## Standard Menu Content (Right Side - 33%)

_Document standard menu elements here as they're established across multiple Level 1 scenes_

### Currency Display

[TO BE DEFINED - add after implementing in first few scenes]

### Navigation Buttons

[TO BE DEFINED - add after implementing in first few scenes]

See [2.1-scene-network.md](2.1-scene-network.md) for scene navigation system and validation.

---

## Standard PlayArea Content (Left Side - 66%)

_Document common PlayArea patterns here as they emerge_

[TO BE DEFINED]

---

## Standard Variables

### Level1Vars

_Document Level1Vars properties used across multiple scenes_

[TO BE DEFINED]

---

## Standard Script Patterns

_Document common script patterns/boilerplate_

[TO BE DEFINED]

---

## Creating a New Level 1 Scene

**Quick reference process**:

1. Inherit from `res://level1/scene_template.tscn`
2. Add scene-specific content to PlayArea and Menu
3. Follow standards documented above (once they exist)
4. Add to scene network in [2.1-scene-network.md](2.1-scene-network.md)

---

**Last Updated**: 2025-12-03
**Document Type**: Reference / Standards Guide (Living Document)
**Maintainer**: Claude + User collaboration
