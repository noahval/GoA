# GoA - Complete Feature Implementation Roadmap

This document lists every feature in sequential implementation order for building the game from scratch. Each feature is numbered for tracking and reference.

## How to Use This Document

**Line Items and Plan Docs:**
- Each line item represents a feature or system to implement
- Plan docs are located in `.claude/plans/` folder
- Plan doc naming: `[section].[subsection]-[feature-name].md` (e.g., `2.1-core-loop.md`, `6.3-worker-management.md`)
- When a line item matches an existing plan doc name (e.g., "core-loop" -> `2.1-core-loop.md`), consult that doc for detailed implementation steps
- Check the plans folder if unsure whether a plan doc exists for a specific feature

## Active Implementation Plans

## 1. base systems
1. Project Setup - Godot 4.5 project with GL Compatibility renderer
1. [!] Project Architecture - global-vars, level 1 folder, level-1-vars
1. [!] Global Autoload - Global.gd with stats system and game state management
1. [!] Level Variables Autoload - level-1-vars.gd for level-specific state
1. [!] Currencies - Copper, Silver, Gold, and Platinum currencies. Approx Conversion Ratios 1000:1 (1 silver = 1000 copper, 1 gold = 1000 silver, 1 platinum = 1000 gold)
1. [!] Six-Stat System - Strength, Dexterity, Constitution, Intelligence, Wisdom, Charisma (Global vars, not level-1-vars)
1. [!] Experience System - XP tracking per stat with level-up mechanics
1. [!] Scene Management - Global scene changing with validation, transition effects, and scene network map
1. [!] Default Scene - Initial scene setup
1. Default Theme - UI theme resource (default_theme.tres) for consistent styling
1. Responsive Layout Guide - Scaling guidelines for screen layout on different resolutions
1. [!] Audio System - Audio manager with music and SFX playback, volume control
1. [!] Input System - Unified input handling for mouse, touch, and keyboard
1. [!] Notifications - Notification system that displays messages
1. [!] Stat Notification System - Visual feedback for stat gains (Global.show_stat_notification)
1. [!] Logging and Debug System - Debug console, error logging, performance monitoring
1. [!] Error Handling - Global error handling and crash recovery
1. [!] Version Management - Game version tracking for save compatibility
1. [!] Settings Persistence - Player settings (volume, resolution, etc.) separate from game save
1. [!] Save System Local Storage - JSON-based local save/load with player progress persistence
1. [!] Nakama Server - Server setup for cloud features
1. [!] Save System Cloud Storage - Cloud backup integration for cross-device play
1. [!] Auth Screen - Authentication UI and background loading during auth
1. [!] Game Menu - Dev speed mode, save reset, SFX/music volume sliders

## 2. copper era
1. core-loop - Complete one work day with satisfying coal-shoveling feel
1. permanent-progression - Prestige system with skill tree and persistent upgrades
1. roguelite-techniques - Run-based mechanics with meta-progression
1. [!] Breaks & Demand Events - Timed breaks, rush orders, and pressure mechanics
1. Discovery Mechanics - Hidden systems revealed through experimentation
1. content-and-balance - Tuning for difficulty curve and engagement
1. [!] Tutorial and FTUE - First-time user experience and onboarding
1. [!] Coal Resource - Basic coal tracking variable and display
1. [!] Manual Coal Shoveling - In play area, drag coal from pile to furnace
1. [!] Furnace Visualization - Visual representation of furnace and heat
1. [!] Stat Progression Mechanics - How stats increase during copper era gameplay (STR from shoveling, DEX from accuracy, etc.)
1. [!] Feedback Systems - Particles, screen shake, sound effects for player actions
1. [!] Tooltip System - UI help text and explanations
1. [!] Pay Conversion - Copper converts to Silver when exceeding threshold
1. [!] Shop - Dedicated shop scene for purchasing shoveling upgrades
1. [!] Manual Shovel Upgrade - Increase coal per drag (multiple tiers)
1. Offline Earnings - Automatic coal generation over time when away
1. [!] Break Timer System - Time-based work/break cycle
1. [!] Break Activities - What happens during breaks (shop access, stamina recovery, etc.)
1. [!] Victory Condition - Goal or achievement system for copper era
1. [!] Prestige System - Lifetime equipment value tracking, reputation currency, clear progress, retain upgrades, skill tree in dorm scene
1. [!] Timestamp Tracking - Save last_played timestamp on save, load on game start
1. [!] Time Away Calculation - Calculate elapsed time since last play session

## 3. economy
1. [!] ATM Scene - Dedicated currency exchange interface
1. [!] Market Rate System - Dynamic exchange rates for copper/silver/gold
1. [!] Bell Curve Volatility - Normal distribution within ±30% range of base rates
1. [!] Market Update Timer - Rates change every 15-30 minutes (randomized)
1. [!] Transaction Fee System - 8% base fee reducing to 1% floor based on volume
1. [!] Charisma Fee Reduction - 0.25% fee reduction per Charisma level
1. [!] Market Notification System - 18 classist grimdark messages for extreme market events
1. [!] Currency Unlock Progression - each currency unlocks when the player has 800 of the previous currency
1. [!] Platinum Stability - Platinum has no market volatility (anchor currency)
1. [!] Inverted Rate Display - Shows "1 silver = X copper" format for clarity

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
1. [!] Food Distribution Network - City-wide food supply affecting worker desperation and costs
1. [!] Guard Patrol Intensity - Security level affecting freedom and suspicion mechanics
1. [!] Discovery-Based Learning - No explicit tutorials, players learn through observation
1. [!] Stat-Based Knowledge Reveals - Int/Wis/Dex/Con/Str/Cha provide different insights into hidden systems
1. [!] Environmental Pattern Recognition - Players discover optimal combinations through experimentation
1. [!] Worker Treatment Morality System - Poor/Fair/Good treatment with mechanical consequences
1. [!] Harmful Furnace Upgrades - High-productivity upgrades with moral costs (worker harm, environmental damage)
1. [!] Moral Choice Framework - system rewards efficiency over ethics, player chooses path

## 7. escape
1. [!] Nobility Credit System - Endgame currency for train escape prerequisites
1. [!] Train Escape Sequence - Final challenge to leave the train city
1. [!] Level 2 Transition - New location/era after escaping train