# GoA Plans - Table of Contents

This document lists all implementation plans organized by phase. Plans use the format `X.Y-feature-name.md` where X is the phase number.

## Cross-Referencing Plans

When referencing other plans, use the format `X.Y-feature-name.md` (e.g., `1.8-default-theme.md`). This format is resilient to plan renumbering.

---

## Phase 0: Templates

- [0.0-TEMPLATE.md](0.0-TEMPLATE.md) - Plan template

---

## Phase 1: Foundation & Core Systems

### Project Setup
- [1.1-project-setup.md](1/1.1-project-setup.md)
- [1.2-project-architecture.md](1/1.2-project-architecture.md)
- [1.3-global-autoload.md](1/1.3-global-autoload.md)
- [1.4-level-1-variables-autoload.md](1/1.4-level-1-variables-autoload.md)

### Economy & Progression
- [1.5-currencies.md](1/1.5-currencies.md)
- [1.6-stats-and-experience.md](1/1.6-stats-and-experience.md)
- [1.26-currency-display.md](1/1.26-currency-display.md)
- [1.29-currency-manager.md](1/1.29-currency-manager.md)

### Scene & UI Systems
- [1.7-scene-management.md](1/1.7-scene-management.md)
- [1.8-default-theme.md](1/1.8-default-theme.md)
- [1.9-responsive-layout.md](1/1.9-responsive-layout.md)
- [1.10-ui-scale-slider.md](1/1.10-ui-scale-slider.md)
- [1.11-scene-template.md](1/1.11-scene-template.md)
- [1.12-button-hierarchy.md](1/1.12-button-hierarchy.md)
- [1.14-settings-panel.md](1/1.14-settings-panel.md)

### Notifications & Feedback
- [1.15-notifications.md](1/1.15-notifications.md)
- [1.16-notification-history-panel.md](1/1.16-notification-history-panel.md)

### Audio
- [1.13-audio-system.md](1/1.13-audio-system.md)

### Backend & Infrastructure
- [1.17-nakama-server.md](1/1.17-nakama-server.md)
- [1.18-save-system-cloud.md](1/1.18-save-system-cloud.md)
- [1.19-auth-screen.md](1/1.19-auth-screen.md)

### Debugging & Operations
- [1.20-simple-logging.md](1/1.20-simple-logging.md)
- [1.21-advanced-logging.md](1/1.21-advanced-logging.md)
- [1.22-error-handling.md](1/1.22-error-handling.md)
- [1.23-version-management.md](1/1.23-version-management.md)

### Deployment
- [1.24-deployment-pipeline.md](1/1.24-deployment-pipeline.md)
- [1.25-web-hosting.md](1/1.25-web-hosting.md)

---

## Phase 2: Copper Era (Train Furnace Work)

### Scene Structure
- [2.1-scene-network.md](2/2.1-scene-network.md)

### Core Shoveling Gameplay
- [2.2-physics-objects.md](2/2.2-physics-objects.md)
- [2.3-coal-spawning.md](2/2.3-coal-spawning.md)
- [2.4-dropped-coal.md](2/2.4-dropped-coal.md)
- [2.5-delivered-coal.md](2/2.5-delivered-coal.md)
- [2.6-furnace-bars.md](2/2.6-furnace-bars.md)
- [2.7-stamina-drain.md](2/2.7-stamina-drain.md)

### Day Cycle & Time
- [2.8-day-end.md](2/2.8-day-end.md)
- [2.9-evening-morning-cycle.md](2/2.9-evening-morning-cycle.md)
- [2.9b-daily_reset.md](2/2.9b-daily_reset.md)

### Progression & Upgrades
- [2.10-rage.md](2/2.10-rage.md)
- [2.11-shovel-experience.md](2/2.11-shovel-experience.md)
- [2.14-upgrade-pool.md](2/2.14-upgrade-pool.md)
- [2.35-manual-shovel-upgrade.md](2/2.35-manual-shovel-upgrade.md)

### Visual & Audio Feedback
- [2.12-train-shake.md](2/2.12-train-shake.md)
- [2.13-combo-display.md](2/2.13-combo-display.md)
- [2.33-feedback-systems.md](2/2.33-feedback-systems.md)

### Tutorial & Onboarding
- [2.15-tutorial.md](2/2.15-tutorial.md)

### Evening Activities & Economy
- [2.16-evening-ideas.md](2/2.16-evening-ideas.md)
- [2.17-offline-earnings.md](2/2.17-offline-earnings.md)
- [2.27-job-board.md](2/2.27-job-board.md) - Idle job assignment and mastery progression
- [2.37-atm-scene.md](2/2.37-atm-scene.md)

### Bar Work Minigames: Dishwashing
- [2.18-dishwash-scene-setup.md](2/2.18-dishwash-scene-setup.md) - Scene structure and UI
- [2.19-dishwash-click-to-bind.md](2/2.19-dishwash-click-to-bind.md) - Click interaction system
- [2.20-dishwash-state-machine-basin.md](2/2.20-dishwash-state-machine-basin.md) - Basin soaking with movement speedup
- [2.21-dishwash-basin-particles.md](2/2.21-dishwash-basin-particles.md) - Visual particle effects
- [2.22-dishwash-rack-validation.md](2/2.22-dishwash-rack-validation.md) - Rack placement validation
- [2.23-dishwash-rewards-currency.md](2/2.23-dishwash-rewards-currency.md) - Hole rewards and tracking
- [2.24-dishwash-auto-dry-timer.md](2/2.24-dishwash-auto-dry-timer.md) - Auto-dry timer system
- [2.25-dishwash-movement-drying.md](2/2.25-dishwash-movement-drying.md) - Movement-based drying acceleration
- [2.26-dishwash-mastery-unlock.md](2/2.26-dishwash-mastery-unlock.md) - Mastery progression system

### Permanent Progression
- [2.28-permanent-progression.md](2/2.28-permanent-progression.md)
- [2.38-prestige-system.md](2/2.38-prestige-system.md)
- [2.39-victory-condition.md](2/2.39-victory-condition.md)

### Resource Management
- [2.29-additional-resource-pools.md](2/2.29-additional-resource-pools.md)
- [2.30-breaks-and-demand.md](2/2.30-breaks-and-demand.md)
- [2.36-break-timer-system.md](2/2.36-break-timer-system.md)

### Discovery & Meta
- [2.31-discovery-mechanics.md](2/2.31-discovery-mechanics.md)
- [2.32-content-and-balance.md](2/2.32-content-and-balance.md)
- [2.34-tooltip-system.md](2/2.34-tooltip-system.md)

### Implementation Tracking
- [implementation_tracker.md](2/implementation_tracker.md)

---

## Phase 3: Market & Currency Systems

- [3.1-market-volatility.md](3/3.1-market-volatility.md)
- [3.2-currency-unlock-progression.md](3/3.2-currency-unlock-progression.md)

---

## Phase 4: Silver Era (Labor Relations)

### Core Systems
- [4-reputation.md](4/4-reputation.md)
- [4.1-shift-work-system.md](4/4.1-shift-work-system.md)
- [4.2-silver-based-economy.md](4/4.2-silver-based-economy.md)

### Overseer Personalities
- [4.3-overseer-personality-system.md](4/4.3-overseer-personality-system.md)
- [4.4-neutral-overseers.md](4/4.4-neutral-overseers.md)
- [4.5-cruel-overseers.md](4/4.5-cruel-overseers.md)
- [4.6-ultra-cruel-overseers.md](4/4.6-ultra-cruel-overseers.md)

### Social Systems
- [4.7-bribery-system.md](4/4.7-bribery-system.md)
- [4.8-referral-system.md](4/4.8-referral-system.md)

---

## Phase 5: Gold Era (Ownership)

- [5-silver-era.md](5/5-silver-era.md)
- [5.1-core-systems.md](5/5.1-core-systems.md)
- [5.2-scenes-navigation.md](5/5.2-scenes-navigation.md)
- [5.3-worker-management.md](5/5.3-worker-management.md)
- [5.4-worker-ui-formulas.md](5/5.4-worker-ui-formulas.md)
- [5.5-hired-overseer.md](5/5.5-hired-overseer.md)
- [5.6-furnace-upgrades.md](5/5.6-furnace-upgrades.md)

---

## Phase 6: Environmental & Discovery Systems

### Introduction & Core
- [6.1-phase-6-progressive-introduction.md](6/6.1-phase-6-progressive-introduction.md)
- [6.2-coal-quality-types.md](6/6.2-coal-quality-types.md)
- [6.3-temperature-regulation-system.md](6/6.3-temperature-regulation-system.md)

### Hidden Mechanics
- [6.4-hidden-coal-synergy-combinations.md](6/6.4-hidden-coal-synergy-combinations.md)
- [6.5-dynamic-temperature-sweet-spots.md](6/6.5-dynamic-temperature-sweet-spots.md)
- [6.7-airflow-control-system.md](6/6.7-airflow-control-system.md)
- [6.8-hidden-environmental-calendar.md](6/6.8-hidden-environmental-calendar.md)

### Time & Cycles
- [6.6-time-of-day-cycling.md](6/6.6-time-of-day-cycling.md)
- [6.9-monthly-temperature-cycles.md](6/6.9-monthly-temperature-cycles.md)
- [6.10-3-day-electricity-tides.md](6/6.10-3-day-electricity-tides.md)

### Train & Location
- [6.11-train-route-landmarks.md](6/6.11-train-route-landmarks.md)
- [6.12-train-speed-variations.md](6/6.12-train-speed-variations.md)
- [6.13-speed-effect-coal-demand.md](6/6.13-speed-effect-coal-demand.md)
- [6.14-speed-effect-guard-scrutiny.md](6/6.14-speed-effect-guard-scrutiny.md)

### Environmental Systems
- [6.15-ground-electricity-fluctuations.md](6/6.15-ground-electricity-fluctuations.md)
- [6.22-water-supply-system.md](6/6.22-water-supply-system.md)
- [6.23-population-pressure-system.md](6/6.23-population-pressure-system.md)
- [6.24-food-distribution-network.md](6/6.24-food-distribution-network.md)
- [6.25-guard-patrol-intensity.md](6/6.25-guard-patrol-intensity.md)

### Events
- [6.16-sandstorm-warning-system.md](6/6.16-sandstorm-warning-system.md)
- [6.17-sandstorm-event.md](6/6.17-sandstorm-event.md)
- [6.18-heat-wave-event.md](6/6.18-heat-wave-event.md)
- [6.19-cold-snap-event.md](6/6.19-cold-snap-event.md)
- [6.20-electrical-surge-event.md](6/6.20-electrical-surge-event.md)
- [6.21-equipment-failure-event.md](6/6.21-equipment-failure-event.md)

### Discovery & Learning
- [6.26-discovery-based-learning.md](6/6.26-discovery-based-learning.md)
- [6.27-stat-based-knowledge-reveals.md](6/6.27-stat-based-knowledge-reveals.md)
- [6.28-environmental-pattern-recognition.md](6/6.28-environmental-pattern-recognition.md)

### Morality Systems
- [6.24-worker-treatment-morality-system.md](6/6.24-worker-treatment-morality-system.md)
- [6.25-harmful-furnace-upgrades.md](6/6.25-harmful-furnace-upgrades.md)
- [6.26-moral-choice-framework.md](6/6.26-moral-choice-framework.md)

---

## Phase 7: Endgame & Transition

- [7.1-nobility-credit-system.md](7/7.1-nobility-credit-system.md)
- [7.2-train-escape-sequence.md](7/7.2-train-escape-sequence.md)
- [7.3-level-2-transition.md](7/7.3-level-2-transition.md)

---

## Archive

Superseded or deprecated plans moved to [archive/](archive/)

---

**Note**: Plan numbering may change as plans are added, removed, or reordered to reflect dependencies. Always use the `X.Y-feature-name.md` format when cross-referencing to maintain resilience.

**Last Updated**: 2026-01-14
