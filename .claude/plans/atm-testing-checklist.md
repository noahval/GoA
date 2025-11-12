# ATM Currency Exchange - Testing Checklist

## Test Environment Setup
1. Start with fresh save or use console commands to set test conditions
2. Use the following commands to test various scenarios:
   - Add copper: `Level1Vars.currency.copper += X`
   - Add silver: `Level1Vars.currency.silver += X`
   - Force market update: `CurrencyManager.update_market_rates()`

---

## Phase 1: Basic UI and Scene Loading

### Test 1.1: Scene Loads Successfully
- [ ] Navigate to ATM scene from Coppersmith Carriage
- [ ] No script errors in console
- [ ] All UI elements visible (title, market rates, break timer, coins panel, exchange panel, buttons)
- [ ] Exchange button starts disabled

### Test 1.2: Currency Display
- [ ] CoinsPanel shows current copper amount correctly
- [ ] Display updates when currency changes
- [ ] Icons display correctly for each currency type

---

## Phase 2: Market Volatility System

### Test 2.1: Market Rates Display
- [ ] Market rates panel shows "Current Rates:" header
- [ ] Shows inverted format: "1 silver = X copper" (not "X copper = 1 silver")
- [ ] Initial rates shown on scene load
- [ ] Rates update every 15-30 minutes (test with wait or force update)

### Test 2.2: Bell Curve Distribution
**Manual Testing** (run multiple updates to verify distribution):
- [ ] Force market update 20+ times: `CurrencyManager.update_market_rates()`
- [ ] Most rates should be near baseline (±0-10%)
- [ ] Occasional moderate swings (±10-20%)
- [ ] Rare extreme swings (±20-30%)
- [ ] Extremes should feel rare (not every update)

### Test 2.3: Market Modifiers
- [ ] Copper modifier affects copper-to-silver exchange
- [ ] Silver modifier affects silver-to-gold exchange
- [ ] Gold modifier affects gold-to-platinum exchange
- [ ] Platinum always stable (modifier = 1.0)

### Test 2.4: Extreme Volatility Notifications
**Test extreme notifications** (may need to force update multiple times):
- [ ] High copper volatility (>20%): Laborers doing well notifications
  - "Furnace accident: labor shortage drives copper rates"
  - "Infection culls the workforce: survivors demand more"
  - "Mass conscription: fewer hands, higher wages"
- [ ] Low copper volatility (<-20%): Laborers desperate notifications
  - "Coal quotas doubled: labor value plummets"
  - "New work camp opened: copper floods the vaults"
  - "Vagrant roundup successful: desperate hands abundant"
- [ ] Similar patterns for silver (merchants) and gold (nobles)
- [ ] Notifications only show for ±20-30% extremes, not moderate swings

---

## Phase 3: Currency Exchange Mechanics

### Test 3.1: Exchange Form Validation
Starting condition: 0 copper, 0 silver
- [ ] From dropdown shows only "Copper" (silver locked)
- [ ] To dropdown shows only "Copper" (silver locked)
- [ ] Amount input accepts numeric input
- [ ] Preview shows "Enter amount to exchange" when empty
- [ ] Exchange button disabled when amount is 0

### Test 3.2: Insufficient Funds
Starting condition: 50 copper
- [ ] Enter 100 copper to exchange
- [ ] Preview shows "Insufficient funds"
- [ ] Exchange button disabled
- [ ] No error when clicking disabled button

### Test 3.3: Basic Exchange (Copper to Silver)
Starting condition: 1000 copper, 0 silver, baseline market rates (1.0 modifiers)
- [ ] From: Copper, To: Silver, Amount: 100
- [ ] Preview calculation:
  - Fee = 8 copper (8% base fee for small transaction)
  - Net = 92 copper
  - Received = 0.92 silver (92 copper / 100 = 0.92 silver)
  - Preview text: "100.0 copper -> 0.92 silver\n(broker takes 8.0 copper)"
- [ ] Click Exchange button
- [ ] Success notification shows received amount
- [ ] Copper decreases by 100 (full amount)
- [ ] Silver increases by ~0.92
- [ ] Form resets (amount cleared, preview resets)
- [ ] Currency display updates

### Test 3.4: Reverse Exchange (Silver to Copper)
Starting condition: 10 silver, baseline rates
- [ ] From: Silver, To: Copper, Amount: 1
- [ ] Fee = 0.08 silver (8% base)
- [ ] Net = 0.92 silver
- [ ] Received = ~92 copper (0.92 silver * 100)
- [ ] Preview shows correct calculation
- [ ] Exchange succeeds
- [ ] Silver decreases by 1.0
- [ ] Copper increases by ~92

### Test 3.5: Large Transaction Fee Scaling
Starting condition: 100,000 copper
- [ ] Exchange 10,000 copper to silver
- [ ] Fee should be lower than 8% (scales logarithmically)
- [ ] Fee should not go below 1%
- [ ] Calculate: Base 8%, reduced by log scaling, clamped to 1-8%
- [ ] Verify net amount = amount - fee
- [ ] Exchange succeeds with correct fee deduction

### Test 3.6: Charisma Fee Reduction
**If Global.charisma > 1:**
Starting condition: 1000 copper, charisma = 2
- [ ] Exchange 100 copper to silver
- [ ] Base fee = 8 copper
- [ ] Charisma reduction = 2% per level = 2% for charisma 2
- [ ] Modified fee = 8 * (1 - 0.02) = 7.84 copper
- [ ] Verify fee is reduced correctly
- [ ] Still respects 1% minimum

### Test 3.7: Market Volatility Impact
**High copper rate (copper valuable):**
Starting condition: Copper modifier = 1.3, Silver modifier = 1.0
- [ ] Exchange 100 copper to silver
- [ ] Net after fee = 92 copper
- [ ] Calculation: (92 * 1 * 1.3) / (100 * 1.0) = 1.196 silver
- [ ] Should receive MORE silver than baseline (copper is valuable)

**Low copper rate (copper weak):**
Starting condition: Copper modifier = 0.7, Silver modifier = 1.0
- [ ] Exchange 100 copper to silver
- [ ] Net after fee = 92 copper
- [ ] Calculation: (92 * 1 * 0.7) / (100 * 1.0) = 0.644 silver
- [ ] Should receive LESS silver than baseline (copper is weak)

---

## Phase 4: Currency Unlock System

### Test 4.1: Initial State
Starting condition: Fresh game
- [ ] unlocked_gold = false
- [ ] unlocked_platinum = false
- [ ] From/To dropdowns only show Copper and Silver
- [ ] Gold and Platinum hidden from dropdowns

### Test 4.2: Gold Unlock
Starting condition: 59.9 silver
- [ ] Add 0.1 silver: `CurrencyManager.add_currency(CurrencyManager.CurrencyType.SILVER, 0.1)`
- [ ] Notification: "Trading in gold now permitted"
- [ ] unlocked_gold becomes true
- [ ] From/To dropdowns now show Copper, Silver, Gold
- [ ] Market rates panel shows silver-to-gold rate
- [ ] Can now exchange silver for gold

### Test 4.3: Platinum Unlock
Starting condition: 59.9 gold
- [ ] Add 0.1 gold: `CurrencyManager.add_currency(CurrencyManager.CurrencyType.GOLD, 0.1)`
- [ ] Notification: "Trading in platinum bonds now permitted"
- [ ] unlocked_platinum becomes true
- [ ] From/To dropdowns now show all 4 currencies
- [ ] Market rates panel shows gold-to-platinum rate
- [ ] Can now exchange gold for platinum

### Test 4.4: Unlock Persistence
- [ ] Unlock gold and platinum
- [ ] Save game (manual or autosave)
- [ ] Exit and reload
- [ ] unlocked_gold and unlocked_platinum still true
- [ ] Dropdowns show all 4 currencies
- [ ] No re-unlock notifications on load

---

## Phase 5: Save/Load Integration

### Test 5.1: Local Save
Starting condition: Modified currency amounts, some unlocks
- [ ] Save game
- [ ] Check save file contains:
  - currency.copper, silver, gold, platinum
  - unlocked_gold, unlocked_platinum
  - market modifiers (if implemented in save)
- [ ] Load game
- [ ] All values restored correctly

### Test 5.2: Cloud Save (Nakama)
**If using cloud save:**
- [ ] Save to cloud
- [ ] Check cloud storage contains unlock states
- [ ] Load from cloud
- [ ] Unlocks restored correctly

---

## Phase 6: Balance Testing

### Test 6.1: Fee Curve Validation
Test fee calculation at various amounts:

| Copper Amount | Expected Fee % | Notes |
|---------------|----------------|-------|
| 10            | ~8%            | Very small transaction |
| 100           | ~8%            | Small transaction |
| 1,000         | ~6-7%          | Medium transaction |
| 10,000        | ~3-5%          | Large transaction |
| 100,000       | ~1-2%          | Very large transaction |
| 1,000,000     | 1%             | Massive (floor reached) |

- [ ] Test each amount tier
- [ ] Verify fee scales logarithmically
- [ ] Fee never exceeds 8%
- [ ] Fee never goes below 1%
- [ ] Curve feels fair (not too punishing, not too exploitable)

### Test 6.2: Market Arbitrage Prevention
- [ ] Test rapid exchanges during volatile markets
- [ ] Verify fees prevent easy profit from market swings
- [ ] 8% fee on small transactions should make micro-arbitrage unprofitable
- [ ] Player needs significant market movement to profit from timing

### Test 6.3: Progression Testing
Simulate player progression:
- [ ] Start with 0 copper
- [ ] Earn ~5000 copper from furnace work
- [ ] Convert to ~46-48 silver (after fees)
- [ ] Continue earning to reach 60 silver
- [ ] Unlock gold
- [ ] Verify feels achievable but not trivial
- [ ] Test platinum unlock at 60 gold (longer term goal)

---

## Phase 7: Edge Cases and Error Handling

### Test 7.1: Same Currency Exchange
- [ ] From: Copper, To: Copper
- [ ] Should work (1:1 minus fee - basically burns currency)
- [ ] Or block if not intended

### Test 7.2: Zero Amount
- [ ] Enter 0 in amount
- [ ] Preview shows "Enter amount to exchange"
- [ ] Button disabled
- [ ] No crash

### Test 7.3: Negative Amount
- [ ] Try entering negative number
- [ ] Should be blocked by input validation or handled gracefully

### Test 7.4: Very Large Numbers
- [ ] Enter extremely large amount (e.g., 999999999)
- [ ] Preview calculates correctly
- [ ] If insufficient funds, shows proper error
- [ ] No overflow or crash

### Test 7.5: Locked Currency Exchange Attempt
**Manual test via console:**
- [ ] Force unlocked_gold = false
- [ ] Try to exchange to gold via script
- [ ] Should return error: "currency_locked"
- [ ] No currency deducted

### Test 7.6: Break Timer Expiration
- [ ] Start exchange form
- [ ] Let break timer run out
- [ ] Scene should change to furnace
- [ ] No crash or stuck state

---

## Phase 8: UI/UX Polish

### Test 8.1: Responsive Layout
- [ ] Test at different window sizes
- [ ] UI elements scale appropriately
- [ ] No overlapping text or buttons
- [ ] All elements readable

### Test 8.2: Preview Updates
- [ ] Change From dropdown -> preview updates
- [ ] Change To dropdown -> preview updates
- [ ] Change amount -> preview updates immediately
- [ ] No lag or delay in preview calculation

### Test 8.3: Notifications
- [ ] Exchange success notification appears
- [ ] Shows correct received amount
- [ ] Notification dismisses after timeout
- [ ] Multiple exchanges show sequential notifications

### Test 8.4: Market Rates Display Updates
- [ ] Rates display updates when market changes
- [ ] Updates while ATM scene is active
- [ ] Updates on scene enter if rates changed while away

---

## Phase 9: Integration Testing

### Test 9.1: Furnace Integration
- [ ] Earn copper/silver at furnace
- [ ] Go to ATM
- [ ] Currency displays correctly
- [ ] Exchange works with earned currency
- [ ] Return to furnace
- [ ] Currency persists

### Test 9.2: Shop Integration
- [ ] Have mixed currency (copper + silver)
- [ ] Go to shop
- [ ] Verify shop recognizes all currency types
- [ ] Purchase works correctly
- [ ] Currency deducted properly

### Test 9.3: Global Stats Integration
- [ ] Exchange currency
- [ ] Charisma gains XP (based on fee paid)
- [ ] XP amount = fee * conversion rate to copper
- [ ] Verify in stats panel

---

## Known Issues / Notes

### Fixed in Testing:
- [x] exchange_currency_with_fee now properly deducts full amount including fee
- [x] Preview calculation now uses both currency modifiers for accurate rates

### To Monitor:
- [ ] Market update timing (15-30 min) - long test required
- [ ] Extreme volatility frequency - need statistical sampling
- [ ] Fee curve balance - may need tuning based on gameplay

### Future Enhancements:
- Quick convert buttons (e.g., "Max", "Half")
- Exchange history log
- Market trend indicators
- Exchange rate history chart

---

## Test Summary

**Total Tests:** 60+
**Critical Path:** Tests 1.1, 3.3, 3.4, 4.2, 4.3, 5.1
**Balance Tests:** 6.1, 6.2, 6.3

**Testing Priority:**
1. Phase 1-3: Core functionality
2. Phase 4: Unlock system
3. Phase 6: Balance validation
4. Phase 7-9: Polish and integration

**Estimated Testing Time:** 2-3 hours for full suite
**Quick Smoke Test:** Tests 1.1, 3.3, 4.2 (~10 minutes)
