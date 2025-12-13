# GoA - Complete Feature Implementation Roadmap

This document lists every feature in sequential implementation order for building the game from scratch. Each feature is numbered for tracking and reference.

## How to Use This Document

**IMPORTANT: Complete Rewrite Project**
This roadmap is for a complete game rewrite from scratch. All features listed should be implemented fresh with clean architecture - do not worry about maintaining backward compatibility with legacy files or old save systems. the legacy systems can be viewed for inspiration.

**Line Items and Plan Docs:**
- Each line item represents a feature or system to implement
- Plan docs are located in `.claude/plans/` folder
- Plan doc naming: `[section].[subsection]-[feature-name].md` (e.g., `2.1-core-loop.md`, `6.3-worker-management.md`)
- When a line item matches an existing plan doc name (e.g., "core-loop" -> `2.1-core-loop.md`), consult that doc for detailed implementation steps
- Check the plans folder if unsure whether a plan doc exists for a specific feature
- `[!]` markers indicate features that need a plan document created

**Cross-Referencing Plans:**
- When plans reference other plans, use the format: `1.x-feature-name.md`
- Example: "See 1.x-settings-panel.md for details"
- This format is resilient to plan renumbering and makes files easy to find with glob patterns
- Do NOT use "plan 1.16" style references as these break when plans are reordered

## Active Implementation Plans

## 1. base systems
1. Project Setup - Godot 4.5 project with GL Compatibility renderer
1. Project Architecture - global-vars, level 1 folder, level-1-vars
1. Global Autoload - Global.gd with stats system and game state management
1. [!] Level 1 Variables Autoload - level-1-vars.gd for level-specific state
1. Currencies - Copper, Silver, Gold, and Platinum currencies with current and lifetime tracking
1. Currency Manager - Currency exchange system with market rate hooks, transaction fees, and purse capacity
1. [!] Stats and Experience - Six stats (STR/DEX/CON/INT/WIS/CHA) with XP tracking and level-up mechanics
1. Scene Management - Generic scene changing with validation framework and save integration
1. Default Theme - UI theme resource (default_theme.tres) for consistent styling
1. Responsive Layout - Scaling guidelines for screen layout on different resolutions
1. UI Scale Slider - User-adjustable UI scale (0.8x-1.2x) on top of automatic resolution scaling
1. Scene Template - Base scene structure for all game scenes (inherits from scene_template.tscn)
1. Button Hierarchy - Automatic button ordering system (Action, Forward Nav, Back Nav)
1. Audio System - Audio manager with music and SFX playback, volume control
1. Settings Panel - Settings menu button and panel display in play area
1. Notifications - Unified notification system with queueing, stat variety, and history tracking
1. Notification History Panel - Interactive history viewer in play area with filtering
1. Nakama Server - Clean cloud backend client with auth and save/load framework
1. Save System Cloud - Cloud backup integration for cross-device play
1. Auth Screen - Authentication UI and background loading during auth
1. Simple Logging - Session-based logging with automatic rotation and memory buffer
1. Advanced Logging - Bug report UI with screenshot capture and Nakama integration
1. Error Handling - Global error handling and crash recovery
1. Version Management - Game version tracking for save compatibility
1. Deployment Pipeline - Dev/main git workflow with automated GitHub Actions builds, version incrementing, and deployment
1. web hosting - 

## 2. copper era
1. scene Network - Centralized scene registry and navigation map for all Level 1 scenes (copper, silver, gold eras)
1. Physics Objects Setup - Coal pile, furnace opening with obstacles, and shovel surface
1. Coal Physics Spawning - Coal piece RigidBody2D with physics properties and scooping mechanism
1. Coal Tracking System - Track dropped vs delivered coal with Level1Vars integration
1. Testing Polish - Unit tests, integration tests, and physics tuning for shovelling mechanic
1. [!] day cycle - day and evening alternating
1. 
1. 
1.
1. 
1. 
1. 
1. core-loop - Complete one work day with satisfying coal-shoveling feel
1. permanent-progression - Prestige system with skill tree and persistent upgrades
1. roguelite-techniques - Run-based mechanics with meta-progression
1. Breaks and Demand - Timed breaks(actions not clock), rush orders, and pressure mechanics
1. Discovery Mechanics - Hidden systems revealed through experimentation
1. content-and-balance - Tuning for difficulty curve and engagement
1. [!] Tutorial and FTUE - onboarding
1. [!] Feedback Systems - Particles, screen shake, sound effects for player actions
1. [!] Tooltip System - UI help text and explanations
1. [!] Manual Shovel Upgrade - Increase coal per drag (multiple tiers)
1. Offline Earnings - Automatic
1. [!] Break Timer System - time spent away from furnace
1. ATM Scene - Currency exchange UI with live market rate display and transaction preview
1. [!] Prestige System - Lifetime equipment value tracking, reputation currency, clear progress, retain upgrades, skill tree in dorm scene
1. [!] Victory Condition - Goal or achievement system for copper era

## 3. economy
1. Market Volatility - Dynamic exchange rate modifiers with bell curve distribution, market events, and notifications
1. [!] Currency Unlock Progression - each currency unlocks when the player has 800 of the previous currency

## 4. silver era
1. [!] Shift Work System - Time-limited assignments covering for other overseers
1. [!] Silver-Based Economy - Distinct from Phase 1 copper, earned through shifts
1. [!] Overseer Personality System - 5-8 unique overseers on cruelty spectrum
1. [!] Neutral Overseers - Hard shifts, low pay, moral high ground option
1. [!] Cruel Overseers - Easy shifts, high pay, moral compromise required
1. [!] Ultra-Cruel Overseers - Trivial shifts, very high pay, moral event horizon
1. [!] Bribery System - Pay to unlock access to specific overseers
1. [!] Referral System - Progressive unlocking of overseer network through relationships

## 5. gold era
1. Core Systems - Heat/steam production, dynamic demand (5 states), storage system, steam-to-gold payment
1. Scenes-Navigation - Furnace purchase, owned_furnace/owned_dorm scenes, navigation update
1. Worker Management - 3 types, 7 quality tiers, hidden fatigue/morale, breaks, hiring, food, amenities
1. Worker UI Formulas - Roster display, hiring/food/upgrade dialogs, production formulas
1. Hired Overseer - Offline progression with quality/duration/style upgrades, hidden charisma gain
1. Furnace Upgrades - Materials (7 tiers, 700°C-3,000°C), thickness, linings, special systems

## 6. environmental complexity
1. [!] Phase 6 Progressive Introduction - 2 systems per prestige cycle increase to avoid overwhelming
1. [!] Coal Quality Types - 3 types: Regular, Fine, Coarse with different properties
1. [!] Temperature Regulation System - 800-1500°F range with performance sweet spots
1. [!] Hidden Coal Synergy Combinations - 5 secret combinations for bonus effects (discovery-based)
1. [!] Dynamic Temperature Sweet Spots - Optimal ranges vary by time, coal type, worker treatment, speed, weather
1. [!] Time of Day Cycling - 6-hour phases: Dawn/Midday/Dusk/Night with different effects
1. [!] Airflow Control System - Closed/Partial/Open vents affecting combustion and temperature
1. [!] Hidden Environmental Calendar - Week-long weather patterns affecting operations
1. [!] Monthly Temperature Cycles - Seasonal-style temperature shifts over 30-day cycles
1. [!] 3-Day Electricity Tides - Ground electricity fluctuations on 3-day cycle
1. [!] Train Route Landmarks - 14-day circular journey with recognizable locations
1. [!] Train Speed Variations - Racing/Normal/Crawling affecting coal demand and other systems
1. [!] Speed Effect Coal Demand - Faster trains need more steam, higher demand
1. [!] Speed Effect Guard Scrutiny - Train speed affects security patrol intensity
1. [!] Ground Electricity Fluctuations - High/Normal/Low/Fluctuating states affecting electrical systems
1. [!] Sandstorm Warning System - 5 minute advance warning before event
1. [!] Sandstorm Event - 10-15 minute duration, prepare/brace decision point
1. [!] Heat Wave Event - Extended high temperature period requiring adaptation
1. [!] Cold Snap Event - Low temperature challenge affecting efficiency
1. [!] Electrical Surge Event - Sudden electricity spike with damage/benefit potential
1. [!] Equipment Failure Event - Random breakdowns requiring repair decisions
1. [!] Water Supply System - Affects worker health and performance
1. [!] Population Pressure System - Train city population affecting worker availability and quotas
1. [!] Worker Treatment Morality System - Poor/Fair/Good treatment with mechanical consequences
1. [!] Harmful Furnace Upgrades - High-productivity upgrades with moral costs (worker harm, environmental damage)
1. [!] Moral Choice Framework - system rewards efficiency over ethics, player chooses path

## 7. escape
1. [!] Nobility Credit System - Endgame currency for train escape prerequisites
1. [!] Train Escape Sequence - Final challenge to leave the train city
1. [!] Level 2 Transition - New location/era after escaping train