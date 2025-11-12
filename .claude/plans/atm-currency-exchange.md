# ATM Currency Exchange System Implementation Plan

**Status**: Ready for Implementation
**Created**: 2025-01-12
**Priority**: Medium

## Overview

Transform ATM scene into dynamic currency exchange with bell-curve market volatility, volume-based fees, and classist grimdark themes. Players discover market conditions through actual exchange rates shown in the exchange preview.

## Core Features

1. **Bell curve market volatility**: ±30% range with normal distribution (extremes rare)
2. **Volume-based transaction fees**: 8% base scaling down to 1% floor
3. **Classist grimdark flavor**: Social hierarchy reflected in extreme market descriptions
4. **Simplified unlock system**: Based on current holdings (60 silver/gold)
5. **Simple market rates display**: At-a-glance panel showing current conversion rates on scene entry

---

## Phase 1: Core Market System (currency_manager.gd)

### Market Volatility with Bell Curve Distribution

**Implementation:**
```gdscript
# Normal distribution centered at 0, standard deviation 0.1
var deviation = randfn(0.0, 0.1)
deviation = clamp(deviation, -0.3, 0.3)
conversion_rate_modifiers[currency_type] = 1.0 + deviation
```

**Characteristics:**
- ~68% of rates within ±10% of standard
- ~95% of rates within ±20% of standard
- Extreme ±20-30% deviations are rare but possible
- Update interval: Random 15-30 minutes (900-1800 seconds)

**Variables to add:**
```gdscript
var market_update_timer: float = 0.0
var next_market_update_interval: float = 900.0
var market_volatility: Dictionary = {
    CurrencyType.COPPER: 0.0,   # Fluctuates vs silver
    CurrencyType.SILVER: 0.0,   # Fluctuates vs gold
    CurrencyType.GOLD: 0.0      # Fluctuates vs platinum
    # Platinum is stable anchor (no volatility)
}
```

### Transaction Fee System

**Fee curve:**
- Base: 8% for small transactions
- Logarithmic scaling down to 1% floor for large volumes
- Optional charisma integration (2% reduction per level)

**Implementation:**
```gdscript
func calculate_transaction_fee(amount: float, from_type: int) -> float:
    var copper_value = amount * CONVERSION_RATES[from_type]
    var base_fee_percent = 0.08  # 8% base
    var scaling_factor = log(copper_value + 1) / 100000.0
    var fee_percent = base_fee_percent - (scaling_factor * 0.07)
    fee_percent = clamp(fee_percent, 0.01, 0.08)  # 1% to 8% range

    # Optional: Charisma reduces fees
    if Global.charisma > 1:
        var charisma_reduction = (Global.charisma - 1) * 0.02
        fee_percent *= (1.0 - charisma_reduction)
        fee_percent = max(fee_percent, 0.01)  # Minimum 1% fee

    return amount * fee_percent
```

### Exchange Function

**New function:**
```gdscript
func exchange_currency_with_fee(from_type: int, to_type: int, amount: float) -> Dictionary:
    # Validate player has enough
    var player_amount = _get_player_currency(from_type)
    if player_amount < amount:
        return {"success": false, "error": "insufficient_funds"}

    # Check if target currency is unlocked
    if not is_currency_unlocked(to_type):
        return {"success": false, "error": "currency_locked"}

    # Calculate fee
    var fee = calculate_transaction_fee(amount, from_type)
    var net_amount = amount - fee

    # Perform conversion using existing system
    var received = convert_currency(from_type, to_type, net_amount)

    if received > 0:
        # Award experience based on transaction value
        var xp_amount = fee * CONVERSION_RATES[from_type]
        Global.add_stat_exp("charisma", xp_amount)

        return {
            "success": true,
            "fee": fee,
            "received": received,
            "market_rate": conversion_rate_modifiers[to_type]
        }
    else:
        return {"success": false, "error": "conversion_failed"}
```

### Classist Market Descriptions

**Only shown for extreme deviations (±20-30%):**
**18 variants total (3 high + 3 low for each of 3 currency types)**
**Viewpoint: Wealthy bank operators explaining market conditions**
**High modifier = currency/class is powerful (valuable), Low = desperate (weak)**

```gdscript
func get_extreme_market_notification(currency_type: int) -> String:
    var volatility = market_volatility.get(currency_type, 0.0)

    # Only return text for extremes
    if abs(volatility) < 0.2:
        return ""

    var is_high = volatility > 0.2
    var variant = randi() % 3  # Random variant (0, 1, or 2)

    match currency_type:
        CurrencyType.COPPER:  # Laborers/destitute (fluctuates vs silver)
            if is_high:  # Laborers doing WELL, copper VALUABLE
                match variant:
                    0: return "Furnace accident: labor shortage drives copper rates"
                    1: return "Infection culls the workforce: survivors demand more"
                    2: return "Mass conscription: fewer hands, higher wages"
            else:  # Laborers DESPERATE, copper WEAK
                match variant:
                    0: return "Coal quotas doubled: labor value plummets"
                    1: return "New work camp opened: copper floods the vaults"
                    2: return "Vagrant roundup successful: desperate hands abundant"

        CurrencyType.SILVER:  # Merchants/artisans (fluctuates vs gold)
            if is_high:  # Merchants doing WELL, silver VALUABLE
                match variant:
                    0: return "Resupply delayed: merchants hoard reserves"
                    1: return "Black market disrupted: silver gains legitimacy"
                    2: return "Guild masters bribe the Council: rates improve"
            else:  # Merchants DESPERATE, silver WEAK
                match variant:
                    0: return "Guild regulations tightened: merchant desperation grows"
                    1: return "Trade permits revoked: silver devalues rapidly"
                    2: return "Factory owners demand tribute: middle class squeezed"

        CurrencyType.GOLD:  # Nobles/gentry (fluctuates vs platinum)
            if is_high:  # Nobles doing WELL, gold VALUABLE
                match variant:
                    0: return "Military contract awarded: nobles enriched"
                    1: return "Housing rights restricted: gold becomes scarce"
                    2: return "Council favor shifts: titled families consolidate"
            else:  # Nobles DESPERATE, gold WEAK
                match variant:
                    0: return "Estate taxes raised: nobility liquidating assets"
                    1: return "War bonds called: old money bleeds gold"
                    2: return "Succession crisis: desperate lords sell holdings"

        # Platinum has no volatility (stable anchor currency)

    return ""

func update_market_rates():
    # Set next update interval (15-30 minutes)
    next_market_update_interval = randf_range(900.0, 1800.0)

    # Update rates with bell curve (Copper, Silver, Gold only)
    # Platinum is the stable anchor (no volatility)
    for currency_type in [CurrencyType.COPPER, CurrencyType.SILVER, CurrencyType.GOLD]:
        var deviation = randfn(0.0, 0.1)
        deviation = clamp(deviation, -0.3, 0.3)
        market_volatility[currency_type] = deviation
        conversion_rate_modifiers[currency_type] = 1.0 + deviation

        # Show notification for extremes
        var notification = get_extreme_market_notification(currency_type)
        if notification != "":
            Global.show_stat_notification(notification)

    # Debug logging
    DebugLogger.log_info("MarketUpdate", "Rates: C=%.2f, S=%.2f, G=%.2f, P=1.00" % [
        conversion_rate_modifiers[CurrencyType.COPPER],
        conversion_rate_modifiers[CurrencyType.SILVER],
        conversion_rate_modifiers[CurrencyType.GOLD]
    ])
```

**Market update in _process:**
```gdscript
func _process(delta):
    market_update_timer += delta
    if market_update_timer >= next_market_update_interval:
        market_update_timer = 0.0
        update_market_rates()
```

---

## Phase 2: Level1Vars Unlock System (level_1_vars.gd)

### New Variables

```gdscript
# Currency tier unlocks (simpler than CurrencyManager system)
var unlocked_gold: bool = false
var unlocked_platinum: bool = false
```

### Unlock Logic

```gdscript
func check_currency_unlocks():
    # Gold unlocks at 60 silver
    if not unlocked_gold and currency.silver >= 60:
        unlocked_gold = true
        Global.show_stat_notification("Trading in gold now permitted")
        save_game()

    # Platinum unlocks at 60 gold
    if not unlocked_platinum and currency.gold >= 60:
        unlocked_platinum = true
        Global.show_stat_notification("Trading in platinum is now permitted")
        save_game()
```

**Call after currency changes:**
```gdscript
# In add_currency or wherever currency is modified
func add_currency_wrapper(type: String, amount: float):
    currency[type] += amount
    check_currency_unlocks()
    save_game()
```

### Save/Load Integration

```gdscript
# In save_game()
save_data["unlocked_gold"] = unlocked_gold
save_data["unlocked_platinum"] = unlocked_platinum

# In load_game()
unlocked_gold = save_data.get("unlocked_gold", false)
unlocked_platinum = save_data.get("unlocked_platinum", false)
```

---

## Phase 3: ATM UI (atm.gd + atm.tscn)

### Scene Structure

```
ATM (Control)
├── HBoxContainer
│   ├── LeftVBox
│   │   ├── MarketRatesPanel (NEW - at-a-glance rates)
│   │   │   └── RatesLabel
│   │   ├── BreakTimerPanel (existing)
│   │   └── CoinsPanel (existing)
│   └── RightVBox
│       ├── ExchangePanel (NEW)
│       │   ├── FromLabel
│       │   ├── FromCurrencyOption (OptionButton)
│       │   ├── AmountLabel
│       │   ├── AmountInput (LineEdit)
│       │   ├── ToLabel
│       │   ├── ToCurrencyOption (OptionButton)
│       │   └── PreviewLabel (RichTextLabel)
│       ├── ExchangeButton (Button)
│       └── BackButton (existing)
```

### ATM Script Variables

```gdscript
# Exchange state
var from_currency_type: int = CurrencyManager.CurrencyType.COPPER
var to_currency_type: int = CurrencyManager.CurrencyType.SILVER
var exchange_amount: float = 0.0

# Node references
@onready var market_rates_label = $HBoxContainer/LeftVBox/MarketRatesPanel/RatesLabel
@onready var from_option = $HBoxContainer/RightVBox/ExchangePanel/FromCurrencyOption
@onready var to_option = $HBoxContainer/RightVBox/ExchangePanel/ToCurrencyOption
@onready var amount_input = $HBoxContainer/RightVBox/ExchangePanel/AmountInput
@onready var preview_label = $HBoxContainer/RightVBox/ExchangePanel/PreviewLabel
@onready var exchange_button = $HBoxContainer/RightVBox/ExchangeButton
```

### Market Rates Display

**Shows current conversion rates in inverted format (1 expensive = X cheap):**

```gdscript
func update_market_rates_display():
    var rates_text = "Current Rates:\n"

    # Calculate how much copper for 1 silver
    # Copper has volatility, silver has volatility - both affect the rate
    var copper_modifier = CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.COPPER]
    var silver_modifier = CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.SILVER]
    var copper_per_silver = (100.0 * copper_modifier) / silver_modifier
    rates_text += "1 silver = %.0f copper\n" % copper_per_silver

    # Gold (if unlocked)
    if Level1Vars.unlocked_gold:
        var gold_modifier = CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.GOLD]
        var silver_per_gold = (100.0 * silver_modifier) / gold_modifier
        rates_text += "1 gold = %.0f silver\n" % silver_per_gold

    # Platinum (if unlocked) - Platinum is stable (modifier always 1.0)
    if Level1Vars.unlocked_platinum:
        var gold_modifier = CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.GOLD]
        var gold_per_platinum = 100.0 / gold_modifier  # Gold fluctuates vs stable platinum
        rates_text += "1 platinum = %.0f gold\n" % gold_per_platinum

    market_rates_label.text = rates_text
```

**Display examples:**
- Strong copper (modifier 1.3): "1 silver = 130 copper" (copper valuable)
- Standard market (modifier 1.0): "1 silver = 100 copper"
- Weak copper (modifier 0.7): "1 silver = 70 copper" (copper weak)

**When to update:**
- On scene entry (`_ready()`)
- Optionally in `_process()` if rates change while player is in scene

### Dropdown Population

```gdscript
func setup_currency_options():
    from_option.clear()
    to_option.clear()

    var currency_names = ["Copper", "Silver", "Gold", "Platinum"]
    var currency_types = [
        CurrencyManager.CurrencyType.COPPER,
        CurrencyManager.CurrencyType.SILVER,
        CurrencyManager.CurrencyType.GOLD,
        CurrencyManager.CurrencyType.PLATINUM
    ]

    for i in range(4):
        var can_show = true

        # Filter based on Level1Vars unlocks
        if i == 2:  # Gold
            can_show = Level1Vars.unlocked_gold
        elif i == 3:  # Platinum
            can_show = Level1Vars.unlocked_platinum

        if can_show:
            from_option.add_item(currency_names[i], currency_types[i])
            to_option.add_item(currency_names[i], currency_types[i])

    # Set default selection
    from_currency_type = CurrencyManager.CurrencyType.COPPER
    to_currency_type = CurrencyManager.CurrencyType.SILVER
```

### Exchange Preview

```gdscript
func update_preview():
    if exchange_amount <= 0:
        preview_label.text = "Enter amount to exchange"
        exchange_button.disabled = true
        return

    # Check if player has enough
    var player_amount = CurrencyManager._get_player_currency(from_currency_type)
    if player_amount < exchange_amount:
        preview_label.text = "Insufficient funds"
        exchange_button.disabled = true
        return

    # Calculate preview
    var fee = CurrencyManager.calculate_transaction_fee(exchange_amount, from_currency_type)
    var net_amount = exchange_amount - fee

    var from_rate = CurrencyManager.CONVERSION_RATES[from_currency_type]
    var to_rate = CurrencyManager.CONVERSION_RATES[to_currency_type]
    var market_modifier = CurrencyManager.conversion_rate_modifiers[to_currency_type]

    var received = (net_amount * from_rate) / (to_rate * market_modifier)

    # Format preview text (show actual exchange)
    var from_name = get_currency_name(from_currency_type)
    var to_name = get_currency_name(to_currency_type)

    preview_label.text = "%.1f %s -> %.2f %s\n(broker takes %.1f %s)" % [
        exchange_amount, from_name,
        received, to_name,
        fee, from_name
    ]

    exchange_button.disabled = false

func get_currency_name(type: int) -> String:
    match type:
        CurrencyManager.CurrencyType.COPPER:
            return "copper"
        CurrencyManager.CurrencyType.SILVER:
            return "silver"
        CurrencyManager.CurrencyType.GOLD:
            return "gold"
        CurrencyManager.CurrencyType.PLATINUM:
            return "platinum"
    return ""
```

### Exchange Execution

```gdscript
func _on_exchange_button_pressed():
    var result = CurrencyManager.exchange_currency_with_fee(
        from_currency_type,
        to_currency_type,
        exchange_amount
    )

    if result.success:
        var to_name = get_currency_name(to_currency_type)
        Global.show_stat_notification("Exchange complete: received %.2f %s" % [result.received, to_name])

        # Reset form
        amount_input.text = ""
        exchange_amount = 0.0
        update_preview()
        update_labels()
    else:
        match result.get("error", "unknown"):
            "insufficient_funds":
                Global.show_stat_notification("Insufficient funds for exchange")
            "currency_locked":
                Global.show_stat_notification("Currency not yet accessible")
            _:
                Global.show_stat_notification("Exchange failed")
```

### Signal Connections

```gdscript
func _ready():
    # ... existing code ...

    # Connect signals
    from_option.item_selected.connect(_on_from_currency_selected)
    to_option.item_selected.connect(_on_to_currency_selected)
    amount_input.text_changed.connect(_on_amount_text_changed)
    exchange_button.pressed.connect(_on_exchange_button_pressed)

    setup_currency_options()
    update_market_rates_display()  # Show rates on scene entry
    update_preview()

func _on_from_currency_selected(index: int):
    from_currency_type = from_option.get_item_id(index)
    update_preview()

func _on_to_currency_selected(index: int):
    to_currency_type = to_option.get_item_id(index)
    update_preview()

func _on_amount_text_changed(new_text: String):
    exchange_amount = new_text.to_float()
    update_preview()
```

---

## Phase 4: Testing Requirements

### Unit Tests

**Test file: `tests/test_currency_exchange.gd`**

```gdscript
extends GutTest

func test_bell_curve_distribution():
    # Generate 1000 samples
    var samples = []
    for i in range(1000):
        var deviation = randfn(0.0, 0.1)
        deviation = clamp(deviation, -0.3, 0.3)
        samples.append(deviation)

    # Count distribution
    var within_10_percent = 0
    var within_20_percent = 0

    for sample in samples:
        if abs(sample) <= 0.1:
            within_10_percent += 1
        if abs(sample) <= 0.2:
            within_20_percent += 1

    # Should be approximately 68% within ±10%, 95% within ±20%
    assert_true(within_10_percent >= 600 and within_10_percent <= 750, "~68% within ±10%")
    assert_true(within_20_percent >= 900, "~95% within ±20%")

func test_fee_calculation():
    var manager = CurrencyManager.new()

    # Small transaction (8% fee)
    var fee_small = manager.calculate_transaction_fee(10.0, CurrencyManager.CurrencyType.COPPER)
    assert_almost_eq(fee_small, 0.8, 0.1, "Small transaction ~8% fee")

    # Large transaction (closer to 1% floor)
    var fee_large = manager.calculate_transaction_fee(100000.0, CurrencyManager.CurrencyType.COPPER)
    assert_true(fee_large < 100000.0 * 0.02, "Large transaction < 2% fee")
    assert_true(fee_large >= 100000.0 * 0.01, "Fee never below 1%")

func test_currency_unlocks():
    Level1Vars.currency.silver = 50
    Level1Vars.unlocked_gold = false
    Level1Vars.check_currency_unlocks()
    assert_false(Level1Vars.unlocked_gold, "Gold not unlocked at 50 silver")

    Level1Vars.currency.silver = 60
    Level1Vars.check_currency_unlocks()
    assert_true(Level1Vars.unlocked_gold, "Gold unlocked at 60 silver")

    Level1Vars.currency.gold = 60
    Level1Vars.unlocked_platinum = false
    Level1Vars.check_currency_unlocks()
    assert_true(Level1Vars.unlocked_platinum, "Platinum unlocked at 60 gold")

func test_exchange_with_fee():
    var manager = CurrencyManager.new()
    Level1Vars.currency.copper = 1000

    var result = manager.exchange_currency_with_fee(
        CurrencyManager.CurrencyType.COPPER,
        CurrencyManager.CurrencyType.SILVER,
        100.0
    )

    assert_true(result.success, "Exchange succeeded")
    assert_true(result.received < 1.0, "Fee was applied (less than 1 silver)")
    assert_true(result.received > 0.9, "Fee not too high (more than 0.9 silver)")
```

### Integration Tests

1. **Full exchange flow**: Input -> Preview -> Execute -> Currency update
2. **Dropdown filtering**: Verify gold/platinum hidden until unlocked
3. **Market updates**: Verify rates change on timer
4. **Extreme notifications**: Trigger ±25% rates, verify notifications appear
5. **Save/load**: Exchange currencies, save, reload, verify state persists

### Balance Testing

1. **Fee curve feel**: Test at various transaction sizes (10, 100, 1000, 10000 copper)
2. **Market volatility**: Play for 1+ hour, observe rate changes feel natural
3. **Unlock progression**: Verify 60 silver/gold thresholds are achievable
4. **Exchange vs earning**: Ensure exchange is useful but not exploitable

---

## Implementation Checklist

### Phase 1: CurrencyManager
- [ ] Add market volatility variables
- [ ] Implement `update_market_rates()` with bell curve
- [ ] Add `_process()` with market update timer
- [ ] Implement `calculate_transaction_fee()` (8% -> 1%)
- [ ] Create `exchange_currency_with_fee()` function
- [ ] Add `get_extreme_market_notification()` for classist flavor
- [ ] Write unit tests for fees and distribution

### Phase 2: Level1Vars
- [ ] Add `unlocked_gold` and `unlocked_platinum` variables
- [ ] Implement `check_currency_unlocks()` (60 silver/gold)
- [ ] Integrate unlock checking into currency updates
- [ ] Add unlock vars to save/load functions
- [ ] Write tests for unlock triggers

### Phase 3: ATM UI
- [ ] Modify `atm.tscn` to add market rates panel
- [ ] Add RatesLabel to show current conversion rates
- [ ] Implement `update_market_rates_display()` with inverted format
- [ ] Modify `atm.tscn` to add exchange panel
- [ ] Add FromCurrency and ToCurrency option buttons
- [ ] Add amount input field
- [ ] Add preview label
- [ ] Add exchange button
- [ ] Implement `setup_currency_options()` with filtering
- [ ] Implement `update_preview()` with fee display
- [ ] Implement `_on_exchange_button_pressed()`
- [ ] Connect all signals
- [ ] Call `update_market_rates_display()` in `_ready()`
- [ ] Apply ResponsiveLayout to new elements

### Phase 4: Polish
- [ ] Add grimdark flavor text for extreme rates
- [ ] Test notification timing
- [ ] Add sound effects (optional)
- [ ] Verify ASCII-only text throughout
- [ ] Playtest for balance

### Phase 5: Testing
- [ ] Run all unit tests
- [ ] Run integration tests
- [ ] Manual playtest full flow
- [ ] Verify save/load compatibility
- [ ] Test on different screen sizes

---

## Design Principles Applied

✓ **Bell curve volatility**: Most changes moderate, extremes rare
✓ **Simple at-a-glance rates**: Shows inverted format (1 expensive = X cheap)
✓ **Classist grimdark themes**: Social hierarchy in extreme descriptions
✓ **Knowledge as progression**: Players discover patterns by observing
✓ **Higher fees with floor**: 8% → 1% prevents micro-arbitrage
✓ **Simplified unlocks**: Based on current holdings (60 silver/gold)
✓ **ASCII only**: No unicode/emoji anywhere
✓ **Use Global APIs**: `add_stat_exp()`, `show_stat_notification()`

---

## Files to Modify

1. **currency_manager.gd** (~200 lines added)
   - Market system with bell curve
   - Fee calculation
   - Exchange function with fees
   - Extreme market notifications

2. **level_1_vars.gd** (~50 lines added)
   - Unlock variables
   - Unlock checking function
   - Save/load integration

3. **atm.gd** (~160 lines added)
   - Market rates display (inverted format)
   - Exchange UI logic
   - Dropdown filtering
   - Preview calculation

4. **atm.tscn** (UI modifications)
   - Add market rates panel with label
   - Add exchange panel
   - Add currency dropdowns
   - Add input field and preview
   - Add action buttons

5. **tests/test_currency_exchange.gd** (new file)
   - Unit tests for all new systems
   - Integration test scenarios

---

## Dependencies

- Existing CurrencyManager system (`conversion_rate_modifiers`)
- Level1Vars currency dictionary
- Global notification system (`show_stat_notification()`)
- Global stat experience system (`add_stat_exp()`)
- Save/load system (local and cloud)
- ResponsiveLayout system for UI scaling

---

## Estimated Effort

- **Phase 1 (CurrencyManager)**: 3-4 hours
- **Phase 2 (Level1Vars)**: 1-2 hours
- **Phase 3 (ATM UI)**: 4-5 hours
- **Phase 4 (Polish)**: 1-2 hours
- **Phase 5 (Testing)**: 2-3 hours

**Total**: 11-16 hours

---

## Future Enhancements (Not in Scope)

- Market trend graphs (show historical rates)
- Reputation upgrades affecting fees/rates
- Intelligence stat revealing more market info
- Wisdom stat hinting at upcoming changes
- Advanced stats tracking (total exchanges, best rates)
- Market manipulation events (overseer mood affects rates)
- Multi-currency item costs in shop
