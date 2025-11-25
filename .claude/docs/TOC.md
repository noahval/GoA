# GoA - Complete Feature Implementation Roadmap

This document lists every feature in sequential implementation order for rebuilding the game from scratch. Each feature is numbered for tracking and reference.

---

## 1. FOUNDATION SYSTEMS
1. Project Setup - Godot 4.5 project with GL Compatibility renderer
1. Main Scene Architecture - Loading screen as main entry point (level1/loading_screen.tscn)
1. Global Autoload - Global.gd with stats system and game state management
1. Level Variables Autoload - level_1_vars.gd for level-specific state
1. Nakama Server
1. Save System Local Storage - JSON-based local save/load with player progress persistence
1. Save System Cloud Storage - Cloud backup integration for cross-device play
1. Default Theme - UI theme resource (default_theme.tres) for consistent styling
1. Scene Management - Global scene changing with validation and transition effects

---

## 2. PHASE 1 - FURNACE WORKER
1. Coal Resource - Basic coal tracking variable and display
1. Manual Coal Shoveling - Click-to-add coal mechanic with visual feedback
1. Copper Currency - Base currency for Phase 1 economy
1. Coal-to-Copper Conversion - Manual button to convert coal to copper
1. Conversion Price Scaling - Price increases by +1 coal per conversion
1. Overseer NPC - Character that manages conversion process
1. Overseer Mood System - Dynamic mood with adjective descriptions affecting conversion rates
1. Multi-Currency Foundation - Silver, gold, and platinum currencies with tracking
1. Currency Conversion Ratios - 1000:1 ratios (1 silver = 1000 copper, 1 gold = 1000 silver, 1 platinum = 1000 gold)
1. Shop Scene - Dedicated shop UI for purchasing upgrades
1. Manual Shovel Upgrade - Increase coal per click (multiple tiers)
1. Plow Upgrade - Further increase coal per click efficiency
1. Auto-Shovel System - Automatic coal generation over time
1. Auto-Shovel Upgrades - Multiple tiers increasing auto-generation rate
1. Auto-Conversion Mode - Automatic coal-to-copper with 70% efficiency penalty
1. Six-Stat System - Strength, Dexterity, Constitution, Intelligence, Wisdom, Charisma
1. Experience System - XP tracking per stat with level-up mechanics
1. Stat Notification System - Visual feedback for stat gains (Global.show_stat_notification)
1. Add Stat Experience Function - Centralized stat XP addition (Global.add_stat_exp)
1. Break Timer System - Time-based work/break cycle
1. Equipment Value Tracking - Lifetime coins and equipment value for prestige calculations
1. Victory Condition - Victory scene with progression tracking
1. Storage Capacity System - 12-tier upgrades (200 -> 10,000 cap)
1. Coal Tracking Cap System - 7-tier upgrades (1000 -> 35,000 cap)

---

## 3. PHASE 2 - OFFLINE PROGRESSION
1. Timestamp Tracking - Save last_played timestamp on save, load on game start
1. Time Away Calculation - Calculate elapsed time since last play session
1. Offline Earnings Formula - 50% efficiency multiplier for offline production
1. Overtime Base Duration - 8-hour base cap for offline earnings
1. Overtime Upgrade System - 9 tiers: 8h -> 12h -> 16h -> 20h -> 24h -> 26h -> 28h -> 30h -> 36h
1. Overtime Purchase Logic - Shop integration with cost scaling (300 -> 3375 coins)
1. Overtime Persistence - Upgrades persist through prestige (QoL feature)
1. Welcome Back Notification - Summary of offline earnings and time away
1. Missed Hours Warning - Alert when offline time exceeds current cap

---

## 4. PHASE 3 - ECONOMIC SYSTEMS
1. ATM Scene - Dedicated currency exchange interface
1. Market Rate System - Dynamic exchange rates for copper/silver/gold
1. Bell Curve Volatility - Normal distribution within ±30% range of base rates
1. Market Update Timer - Rates change every 15-30 minutes (randomized)
1. Transaction Fee System - 8% base fee reducing to 1% floor based on volume
1. Charisma Fee Reduction - 0.5% fee reduction per Charisma level
1. Market Notification System - 18 classist grimdark messages for extreme market events
1. Currency Unlock Progression - Silver always available, gold at 50 silver, platinum at 50 gold
1. Platinum Stability - Platinum has no market volatility (anchor currency)
1. Inverted Rate Display - Shows "1 silver = X copper" format for clarity
1. ATM Deposit System - 12% base fee (reduces to 1% with Charisma)
1. ATM Withdrawal System - Instant, no fee
1. Unlimited ATM Storage - Store currency beyond pocket capacity
1. Exchange Deposited Currency - Can trade currency in ATM storage
1. Storage vs Deposit Strategy - Balance one-time storage upgrades vs repeated deposit fees

---

## 5. PHASE 4 - PRESTIGE FRAMEWORK
1. Reputation Currency - Spendable currency for skill trees
1. Lifetime Reputation Tracking - Total reputation earned across all prestiges
1. Prestige Reset Mechanics - Clear currency and progress, retain upgrades
1. Skill Tree Tab UI - Three tabbed interface in dormitory scene
1. Laborer's Wisdom Tree - Phase 1 focus, 8-12 nodes, 1-5 reputation cost
1. Overseer's Cunning Tree - Phase 2 focus, 8-12 nodes, 3-8 reputation cost, requires Phase 2 unlock
1. Magnate's Empire Tree - Phase 3 focus, 8-12 nodes, 5-12 reputation cost, requires Phase 3 unlock
1. Skill Node Purchase System - Spend reputation to unlock nodes with permanent benefits
1. Phase Gate Phase 1 to Phase 2 - Requirements: 800 copper + Rep 5 + Stats 30 + Quest + Overseer Relations
1. Phase Gate Phase 2 to Phase 3 - Requirements: 800 silver + Rep 15 + Stats 45 + Leadership Exam + Furnace Deed
1. Phase Gate Validation - Check all requirements before allowing phase transition
1. Platinum Persistence Rule - Clarify if platinum persists through prestige (conflicting docs)

---

## 6. PHASE 2B - OVERSEER FOR HIRE
1. Shift Work System - Time-limited assignments covering for other overseers
1. Silver-Based Economy - Distinct from Phase 1 copper, earned through shifts
1. Overseer Personality System - 5-8 unique overseers on cruelty spectrum
1. Neutral Overseers - Hard shifts, low pay, moral high ground option
1. Cruel Overseers - Easy shifts, high pay, moral compromise required
1. Ultra-Cruel Overseers - Trivial shifts, very high pay, moral event horizon
1. Bribery System - Pay to unlock access to specific overseers
1. Referral System - Progressive unlocking of overseer network through relationships

---

## 7. PHASE 5 - OWN FURNACE
1. Furnace Purchase Option - Available in Overseer's Office for 1 gold (10,000 copper)
1. Purchase Validation - Check lifetime coins >= 10,000 before allowing purchase
1. One-Time Purchase Lock - Cannot be reversed once purchased
1. owned_furnace Scene - Manager perspective replacing furnace.tscn after purchase
1. owned_dorm Scene - Worker management hub replacing dorm.tscn after purchase
1. Bar Navigation Updates - "To Blackbore Furnace" -> "To Your Furnace" when owned
1. Dormitory Navigation Updates - "To Dormitory" -> "To Your Dormitory" when owned
1. Furnace Heat System - Intermediate resource between coal and steam production
1. Heat Generation Manual Shoveling - Player can still shovel coal to generate heat
1. Heat Generation Workers - Hired workers generate heat automatically
1. Heat Generation Coal Burning - Direct coal-to-heat conversion system
1. Heat Decay System - 0.5/sec base decay rate (reducible via firemen)
1. Maximum Heat Capacity - Determined by furnace material and construction tier
1. Steam Production System - Heat converts to steam measured in pounds per hour (lb/h)
1. Base Steam Production - 10 lb/h baseline rate
1. Direct Payment Conversion - No initial storage - steam converts directly to gold
1. Steam Storage Purchase - Available ~3h into phase, enables strategic reserve
1. Steam Storage Capacity Tiers - 5 tiers: 300 lb -> 800 lb -> 1,500 lb -> 2,500 lb -> 5,000 lb
1. Steam Storage Efficiency Tiers - 5 tiers: 50% -> 60% -> 70% -> 80% -> 90% -> 100%
1. Active Diversion System - Manually route % of steam to storage during low demand
1. Overflow Capture System - Automatic storage when main reservoir full
1. Manual Release System - Release 10% increments from storage
1. Auto-Release Triggers - Threshold-based automatic storage release
1. Dynamic Demand System - 5 states affecting payment multiplier
1. Very Low Demand State - 0.0x - 0.45x multiplier (train coasting, rare opportunity)
1. Low Demand State - 0.45x - 0.75x multiplier (light load, reduced payment)
1. Medium Demand State - 0.75x - 1.35x multiplier (baseline operation)
1. High Demand State - 1.35x - 2.65x multiplier (climbing grade, bonus revenue)
1. Critical Demand State - 2.65x - 3.75x multiplier (emergency, maximum revenue/stress)
1. Demand Transition Timer - State changes every 1-5 minutes (triangular distribution)
1. Environmental Reason Display - Narrative context for demand changes (train conditions, terrain, districts)
1. Steam-to-Gold Payment - Direct conversion: production rate × demand multiplier × constant
1. Fractional Gold Accumulation - Progress bar showing partial gold before full coin earned
1. Worker Type Stoker - Coal shoveler generating heat, 1.2 fatigue/sec
1. Worker Type Fireman - Heat manager reducing decay, 0.8 fatigue/sec
1. Worker Type Engineer - Steam optimizer +10% efficiency, 0.6 fatigue/sec
1. Worker Quality Sickly Youth - Tier 1: 60% productivity, +60% fatigue, 25 morale, always available
1. Worker Quality Green Recruit - Tier 2: 75% productivity, +30% fatigue, 35 morale
1. Worker Quality Ordinary Laborer - Tier 3: 90% productivity, +10% fatigue, 45 morale
1. Worker Quality Steady Hand - Tier 4: 100% baseline, 0% fatigue mod, 55 morale, unlocks at 15h runtime
1. Worker Quality Capable Hand - Tier 5: 115% productivity, -15% fatigue, 65 morale, unlocks at 35h runtime
1. Worker Quality Practiced Worker - Tier 6: 130% productivity, -30% fatigue, 75 morale, unlocks at 55h runtime
1. Worker Quality Skilled Worker - Tier 7: 150% productivity, -45% fatigue, 85 morale, unlocks at 75h runtime + 20% self-rest
1. Individual Worker Tracking - Each worker has name, type, quality, fatigue, status
1. Procedural Worker Names - Steampunk fantasy name generation for attachment
1. Hidden Fatigue System - 0-100 scale, completely hidden from player, affects performance
1. Fatigue Performance Curve - 8 fatigue ranges from Peak (120%) to Collapsed (15%)
1. Fatigue Drivers Demand State - 0.7x (low demand) to 2.3x (critical demand) fatigue multiplier
1. Fatigue Drivers Management Style - 0.5x (comfortable) to 2.1x (ruthless) fatigue multiplier
1. Fatigue Drivers Quality Tier - -45% to +60% fatigue modifier based on worker quality
1. Fatigue Drivers Charisma Bonus - Up to -40% fatigue at Charisma 20
1. Fatigue Drivers Food Quality - 0.75x to 1.25x fatigue multiplier based on food tier
1. Fatigue Drivers Facility Bonuses - -5% to -30% from dormitory amenities
1. Shared Morale Pool - 0-100 scale affecting all workers, starts at 50
1. Morale Effect Recovery Speed - 0.5x to 1.6x recovery rate based on morale level
1. Morale Effect Productivity - 0.7x to 1.25x productivity based on morale level
1. Morale Effect Notification Tone - Messages shift from polite to hostile based on morale
1. Morale Positive Factors - Charisma, quality workers, amenities, breaks, low fatigue, good food
1. Morale Negative Factors - High fatigue, collapses, ruthless management, critical demand, firings, poor food
1. Individual Break System - 5 min duration, 5x recovery rate, +2.5 morale, no cooldown
1. Group Break System - 5 min duration, 8x recovery rate, +5 morale, 15 min cooldown, social notifications
1. Auto-Break Policy - 5 settings: Never/Conservative/Balanced/Aggressive/Preventive
1. Dormitory Base Capacity - 2 beds included with furnace purchase
1. Dormitory Capacity Upgrades - 7 tiers expanding to 20 workers max (40 silver -> 4.5 gold + components)
1. Dormitory Visual System - Scene shows actual beds, empty vs occupied states
1. Dormitory Amenities System - 10 tiers with vague descriptions (discovery-based)
1. Amenities Water Barrels - Tier 1: Minimal effect, low cost
1. Amenities Simple Cots - Tier 2: Basic comfort improvement
1. Amenities Tool Storage - Tier 3: Organization benefits
1. Amenities Ventilation - Tier 4: Air quality improvement
1. Amenities Benches - Tier 5: Rest area addition
1. Amenities Lockers - Tier 6: Personal space and security
1. Amenities Bedding - Tier 7: Sleep quality improvement
1. Amenities Lamps - Tier 8: Lighting and atmosphere
1. Amenities Insulation - Tier 9: Temperature control
1. Amenities Premium Furnishings - Tier 10: Maximum comfort and efficiency (30 silver -> 18 gold + components)
1. Amenity Effects Range - -5% to -30% fatigue, +0.2 to +3.0/sec recovery, +1 to +28 morale, +1 to +15 reputation
1. Food Consumption System - Workers consume 1 unit per 10 minutes (active workers only)
1. Food Stale Bread - Tier 1: 0.2 silver/10 units, +15% fatigue, -0.3 morale/min
1. Food Basic Rations - Tier 2: 0.5 silver/10 units, neutral effects
1. Food Decent Meal - Tier 3: 1.2 silver/10 units, -8% fatigue, +0.2 morale/min
1. Food Quality Food - Tier 4: 2.5 silver/10 units, -15% fatigue, +0.4 morale/min, +0.2/sec recovery
1. Food Premium Provisions - Tier 5: 5 silver/10 units, -25% fatigue, +0.6 morale/min, +0.4/sec recovery
1. Food Supply Tracking - Display remaining units and consumption rate
1. Hunger Penalty System - Penalties when food supply reaches 0
1. Dynamic Hiring Pool - 3-8 candidates based on reputation (hidden 0-100 score)
1. Hiring Pool Low Reputation - Rep 0-25: Mostly Tier 1-3 workers available
1. Hiring Pool Medium Reputation - Rep 25-50: Tier 1-5 workers available
1. Hiring Pool Good Reputation - Rep 50-75: Tier 2-6 workers available
1. Hiring Pool Excellent Reputation - Rep 75-100: Tier 3-7 workers, 10% chance for Skilled Workers
1. Manual Hiring Pool Refresh - 200 silver cost to manually refresh candidates
1. Auto Hiring Pool Refresh - Automatic refresh every 2 hours
1. Hidden Reputation System - 0-100 score affecting hiring pool, never displayed directly
1. Reputation Increases - High morale, good amenities, low fatigue, quality food, charisma, no firings, skilled workers
1. Reputation Decreases - Low morale, high fatigue, collapses, firings, poor food, ruthless management
1. Worker Notification Individual Fatigue - Contextual messages using worker names and current state
1. Worker Notification Group Breaks - Social bonuses and worker interaction messages
1. Worker Notification Food Warnings - Low supply and hunger penalty alerts
1. Worker Notification Reputation Hints - Narrative-only hints about facility reputation
1. Furnace Material Cast Iron - Tier 1: 700°C max, included with purchase
1. Furnace Material Wrought Iron - Tier 2: 900°C max, 80 silver, unlocks at 20h runtime
1. Furnace Material Mild Steel - Tier 3: 1,100°C max, 250 silver, unlocks at 50h runtime
1. Furnace Material Cupola Design - Tier 4: 1,550°C max, 8 gold + 50 components, unlocks at 100h runtime
1. Furnace Material Blast Furnace - Tier 5: 1,600°C max, 20 gold + 150 components + 100 mechanisms, unlocks at 200h
1. Furnace Material Electric Induction - Tier 6: 1,800°C max, 50 gold + 300 components + 200 mechanisms + 100 pipes, unlocks at 300h
1. Furnace Material Electric Arc - Tier 7: 3,000°C max, 150 gold + 500 components + 500 mechanisms + 300 pipes, unlocks at 500h
1. Wall Thickness Thin - Tier 1: 1.0x multiplier, included
1. Wall Thickness Standard - Tier 2: 1.15x multiplier, +15% heat, -10% decay
1. Wall Thickness Heavy - Tier 3: 1.3x multiplier, +30% heat, -20% decay
1. Wall Thickness Reinforced - Tier 4: 1.5x multiplier, +50% heat, -30% decay, requires Material Tier 4+
1. Refractory Lining None - Tier 1: 1.0x multiplier, Material Tier 1-2 only
1. Refractory Lining Firebrick - Tier 2: 1.3x multiplier, 960°C cap, 30 silver, 100h durability
1. Refractory Lining High-Alumina - Tier 3: 1.6x multiplier, 1,788°C cap, 120 silver, 200h durability
1. Refractory Lining Mullite-Zirconia - Tier 4: 1.9x multiplier, 2,072°C cap, 5 gold + 20 components, 300h durability
1. Refractory Lining Magnesia - Tier 5: 2.2x multiplier, 2,852°C cap, 15 gold + 100 components + 50 mechanisms, 400h durability
1. Refractory Lining Silicon Carbide - Tier 6: 2.5x multiplier, 1,650°C cap, 25 gold + 200 components + 100 mechanisms, 500h durability
1. Lining Degradation System - Durability countdown requiring replacement/repair
1. Steam Reservoir Capacity Upgrade - Increases buffer size for strategic storage
1. Steam Generation Efficiency Upgrade - +20% per level improvement to production
1. Cooling System Upgrade - -30% heat decay, requires Material Tier 3+
1. Forced Air Injection Upgrade - +25% heat from coal, requires Material Tier 4+
1. Temperature Monitoring Upgrade - Exact readout instead of vague indicators, warnings for danger zones
1. Hired Overseer Base - Included with furnace purchase, 30% efficiency, 1h duration
1. Hired Overseer Quality Apprentice - Tier 1: 30% efficiency, included
1. Hired Overseer Quality Junior - Tier 2: 50% efficiency, 15 silver
1. Hired Overseer Quality Experienced - Tier 3: 65% efficiency, 60 silver
1. Hired Overseer Quality Senior - Tier 4: 80% efficiency, 3 gold + 10 components
1. Hired Overseer Quality Master - Tier 5: 90% efficiency, 8 gold + 30 mechanisms + 20 components
1. Hired Overseer Quality Executive - Tier 6: 98% efficiency, 15 gold + 75 mechanisms + 50 components
1. Hired Overseer Duration 1 Hour - Tier 1: Included with base
1. Hired Overseer Duration 2 Hours - Tier 2: 10 silver
1. Hired Overseer Duration 4 Hours - Tier 3: 30 silver
1. Hired Overseer Duration 8 Hours - Tier 4: 100 silver
1. Hired Overseer Duration 12 Hours - Tier 5: 3 gold
1. Hired Overseer Duration 18 Hours - Tier 6: 7 gold + 10 components
1. Hired Overseer Duration 24 Hours - Tier 7: 12 gold + 30 components
1. Hired Overseer Duration 36 Hours - Tier 8: 20 gold + 60 mechanisms + 30 components
1. Hired Overseer Duration 48 Hours - Tier 9: 30 gold + 80 mechanisms + 40 components
1. Hired Overseer Duration 72 Hours - Tier 10: 40 gold + 100 mechanisms + 50 components
1. Management Style Slider - Continuous 0% (Comfortable) to 100% (Ruthless)
1. Management Style 8 Descriptive Labels - Qualitative descriptions for slider positions
1. Management Style Visible Cost Modifier - -20% to -10% cost shown to player
1. Management Style Hidden Production Multiplier - 0.5x to 1.4x production (discovery-based)
1. Management Style Hidden Charisma Gain - Peaks at ~30% "Orderly" position: +1.0 charisma/hour (discovery-based optimization)
1. Overseer Short-Term vs Long-Term Trade-off - Strategic choice between immediate profit and long-term efficiency

---

## 8. PHASE 6 - ENVIRONMENTAL COMPLEXITY
1. Phase 6 Progressive Introduction - 2 systems per prestige cycle increase to avoid overwhelming
1. Coal Quality Types - 3 types: Regular, Fine, Coarse with different properties
1. Temperature Regulation System - 800-1500°F range with performance sweet spots
1. Hidden Coal Synergy Combinations - 5 secret combinations for bonus effects (discovery-based)
1. Dynamic Temperature Sweet Spots - Optimal ranges vary by time, coal type, worker treatment, speed, weather
1. Time of Day Cycling - 6-hour phases: Dawn/Midday/Dusk/Night with different effects
1. Airflow Control System - Closed/Partial/Open vents affecting combustion and temperature
1. Hidden Environmental Calendar - Week-long weather patterns affecting operations
1. Monthly Temperature Cycles - Seasonal-style temperature shifts over 30-day cycles
1. 3-Day Electricity Tides - Ground electricity fluctuations on 3-day cycle
1. Train Route Landmarks - 14-day circular journey with recognizable locations
1. Train Speed Variations - Racing/Normal/Crawling affecting coal demand and other systems
1. Speed Effect Coal Demand - Faster trains need more steam, higher demand
1. Speed Effect Guard Scrutiny - Train speed affects security patrol intensity
1. Ground Electricity Fluctuations - High/Normal/Low/Fluctuating states affecting electrical systems
1. Sandstorm Warning System - 5 minute advance warning before event
1. Sandstorm Event - 10-15 minute duration, prepare/brace decision point
1. Heat Wave Event - Extended high temperature period requiring adaptation
1. Cold Snap Event - Low temperature challenge affecting efficiency
1. Electrical Surge Event - Sudden electricity spike with damage/benefit potential
1. Equipment Failure Event - Random breakdowns requiring repair decisions
1. Water Supply System - Affects worker health and performance
1. Population Pressure System - Train city population affecting worker availability and quotas
1. Food Distribution Network - City-wide food supply affecting worker desperation and costs
1. Guard Patrol Intensity - Security level affecting freedom and suspicion mechanics
1. Discovery-Based Learning - No explicit tutorials, players learn through observation
1. Stat-Based Knowledge Reveals - Int/Wis/Dex/Con/Str/Cha provide different insights into hidden systems
1. Environmental Pattern Recognition - Players discover optimal combinations through experimentation
1. Community Discovery Expectation - Complex hidden mechanics designed for community collaboration (Reddit/Discord)

---

## 9. ENDGAME & FUTURE CONTENT
1. Worker Treatment Moral System - Poor/Fair/Good treatment with mechanical consequences and skill-based balance
1. Harmful Furnace Upgrades - High-productivity upgrades with moral costs (worker harm, environmental damage)
1. Moral Choice Framework - "It's very hard to be good" - system rewards efficiency over ethics, player chooses path
1. Nobility Credit System - Endgame currency for train escape prerequisites
1. Train Escape Sequence - Final challenge to leave the train city
1. Level 2 Transition - New location/era after escaping train


### Known Conflicts to Resolve

1. **Phase 2 Identity**: Current offline earnings vs "Overseer for Hire" shift work
2. **Platinum Persistence**: Conflicting docs on whether it persists through prestige
3. **Worker Treatment Integration**: How Phase 6 moral system integrates with Phase 5 worker management