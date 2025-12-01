# Skill: Plan Scope Decisions (Combine vs Split)

**Use when:** Deciding whether to combine related features into one plan or split them into separate plans.

---

## Decision Tree

### Step 1: Are these features technically coupled?

**Question**: Does Feature A's implementation directly depend on Feature B's code?

**Examples of HIGH coupling:**
- Stats and Experience (stats trigger XP, XP triggers level-ups)
- Currency Manager and ATM Scene (manager provides API, ATM uses it)
- Notifications and Stat Notifications (stat uses notification system)

**Examples of LOW coupling:**
- Notifications and Notification History (history reads data, doesn't modify system)
- Theme and Layout (theme provides styles, layout uses them)
- Shop and Furnace (independent gameplay features)

**Decision:**
- **HIGH coupling** → Consider combining (go to Step 2)
- **LOW coupling** → Likely split (go to Step 3)

---

### Step 2: Would combining make implementation easier?

**For HIGH coupling features:**

**Question**: Would implementing these together reduce back-and-forth?

**Combine if:**
- [ ] Shared data structures (same variables/constants)
- [ ] Circular dependencies (A calls B, B calls A)
- [ ] Simultaneous changes (modifying one requires modifying other)
- [ ] Testing overlap (same test scenarios needed)
- [ ] Unified mental model (impossible to explain one without the other)

**Split if:**
- [ ] Clear API boundary exists between them
- [ ] One can be fully implemented before the other
- [ ] Testing can be isolated
- [ ] Different implementation timelines
- [ ] Implementation plan would exceed 700 lines

**Examples:**
- **Combine**: Stats + Experience (circular, same data, unified concept)
- **Split**: Currencies + Currency Manager (clear API, different timelines)

---

### Step 3: Would splitting improve clarity?

**For LOW coupling features:**

**Question**: Does each feature deserve focused attention?

**Split if:**
- [ ] Distinct user-facing purposes (different "what it does")
- [ ] Different complexity levels (one simple, one complex)
- [ ] Different implementation phases (now vs later)
- [ ] Separate testing needs
- [ ] Independent documentation value
- [ ] Plan readability (combined plan would be 500+ lines)

**Combine if:**
- [ ] Features are trivial when separated (< 100 lines each)
- [ ] Always implemented together (no value in isolation)
- [ ] Shared 80%+ of code/logic
- [ ] Same prerequisites and dependencies

**Examples:**
- **Split**: Notifications + Notification History (different purposes, different UI)
- **Combine**: Button Hover + Button Press (too trivial to separate)

---

## Red Flags for Over-Combining

**Warning signs you've combined too much:**

1. **Plan length > 700 lines**
   - Solution: Split into base system + feature usage
   - Example: Stats (base) + Stat Progression Mechanics (usage)

2. **"Implementation Tasks" has 10+ subsections**
   - Solution: Extract larger subsections into own plans
   - Example: Extract "UI Panel" from backend system plan

3. **Multiple distinct user stories**
   - Solution: One plan per user story
   - Example: "Display notifications" vs "Review notification history" = 2 plans

4. **Testing section covers 3+ completely different scenarios**
   - Solution: If tests don't overlap, features can probably split
   - Example: Testing notification display vs testing history filtering

5. **"This plan implements X and Y and Z"**
   - Solution: If you need "and" more than twice, consider splitting
   - Example: "Notifications and queueing" = OK, "Notifications and queueing and history and filtering" = too much

---

## Red Flags for Over-Splitting

**Warning signs you've split too much:**

1. **Plan length < 150 lines** (excluding template boilerplate)
   - Solution: Combine with related feature
   - Example: "Button Normal State" + "Button Hover State" + "Button Press State" → "Button States"

2. **Circular plan references** ("See Plan X.Y for...") appears 5+ times
   - Solution: These are probably one feature
   - Example: Currency + Currency Display + Currency Conversion → Currency System

3. **Duplicate implementation sections**
   - Solution: Extract shared code into parent plan
   - Example: Three plans all implement same data structure → move to base plan

4. **"This plan is a thin wrapper around Plan X.Y"**
   - Solution: Merge wrapper into parent
   - Example: "Stat Notification Wrapper" → merge into Stat System or Notification System

5. **No independent value** (feature useless without sibling plan)
   - Solution: Combine into unified feature
   - Example: "Save" without "Load" = useless → combine into "Save/Load System"

---

## Common Patterns

### Pattern 1: Backend + UI Split

**When to use:**
- Backend has complex logic/data structures
- UI is just presentation layer
- Backend useful without UI (for testing)

**Example:**
- Plan 1.8: Stats & Experience (backend only)
- Plan X.Y: Stat Screen UI (visual display)

**Benefits:**
- Test core mechanics without UI dependencies
- Can swap UI implementations
- Clear separation of concerns

---

### Pattern 2: Base System + Feature Usage Split

**When to use:**
- Base system provides generic API
- Features use API in specific ways
- Different features use same base differently

**Example:**
- Plan 1.5: Currencies (base data structures)
- Plan 1.6: Currency Manager (exchange/conversion)
- Plan 1.7: ATM Scene (UI for exchanges)

**Benefits:**
- Base system stays focused and reusable
- Feature plans show specific use cases
- Can add features without modifying base

---

### Pattern 3: Display + History Split

**When to use:**
- Display is temporary/transient
- History is persistent/reviewable
- Different interaction patterns

**Example:**
- Plan 1.13: Notifications (display, queue, auto-remove)
- Plan 1.14: Notification History (review, filter, persist)

**Benefits:**
- Display stays simple and performant
- History can be optional/added later
- Different UI paradigms (overlay vs panel)

---

### Pattern 4: Core + Extensions Split

**When to use:**
- Core feature is minimal viable
- Extensions add optional enhancements
- Extensions can be implemented later

**Example:**
- Plan X.Y: Shop (buy/sell basics)
- Plan X.Z: Shop Discounts (special pricing)
- Plan X.W: Shop Inventory (stock limits)

**Benefits:**
- Core implemented first (early value)
- Extensions independently toggleable
- Easier to scope/prioritize

---

## Decision Checklist

When unsure whether to combine or split, ask:

**Combine if 3+ are YES:**
- [ ] Same file(s) modified
- [ ] Same data structures used
- [ ] Same testing scenarios
- [ ] Implemented at same time
- [ ] Circular dependencies
- [ ] Combined plan < 600 lines
- [ ] Unified mental model
- [ ] Cannot explain one without the other

**Split if 3+ are YES:**
- [ ] Different purposes (different "what it does")
- [ ] Clear API boundary
- [ ] Can test independently
- [ ] Different timelines (now vs later)
- [ ] Different complexities
- [ ] Combined plan > 700 lines
- [ ] Independent documentation value
- [ ] Different user stories

---

## Special Cases

### Case 1: Three or more related features

**Question**: Should A, B, and C be 1 plan, 2 plans, or 3 plans?

**Approach:**
1. Find the core feature (smallest viable)
2. Identify extensions (add-ons)
3. Check coupling (which depend on which)

**Common outcomes:**
- 1 plan: All trivial, total < 500 lines (e.g., Button States)
- 2 plans: Core + combined extensions (e.g., Shop + Discounts+Inventory)
- 3 plans: Core + two independent extensions (e.g., Stats + UI + Progression)

### Case 2: Already combined, should we split?

**Indicators to split existing plan:**
- Plan exceeds 800 lines
- Implementation checklist has 30+ items
- Two completely different testing sections
- "Part 1" and "Part 2" language in plan
- Unclear what plan is "about" (too many topics)

**Process:**
1. Identify natural boundary (backend/UI, core/extension)
2. Extract into new plan
3. Add cross-references
4. Update dependencies

### Case 3: Already split, should we combine?

**Indicators to combine existing plans:**
- Constant back-and-forth between plans
- Duplicate code examples
- Circular "See Plan X.Y" references
- Both plans trivial (< 200 lines each)
- Always implemented together

**Process:**
1. Choose primary plan (larger or more foundational)
2. Merge smaller plan as subsection
3. Update TOC
4. Consolidate testing/checklist

---

## Examples from GoA

### Good Combines

**Plan 1.8: Stats & Experience**
- ✅ Circular (stats trigger XP, XP triggers level-ups)
- ✅ Same data (stat vars + XP vars in global.gd)
- ✅ Unified concept (character progression)
- ✅ Plan length: ~500 lines (manageable)

**Plan 1.13: Notifications**
- ✅ General notifications + stat notifications
- ✅ Share same display system
- ✅ Stat notifications just specialized use case
- ✅ Plan length: ~600 lines

### Good Splits

**Plan 1.10 (Theme) vs 1.11 (Layout)**
- ✅ Clear boundary (theme = styles, layout = positioning)
- ✅ Different purposes (visual vs structural)
- ✅ Independent value (can change theme without layout)

**Plan 1.13 (Notifications) vs 1.14 (History Panel)**
- ✅ Different UI paradigms (transient vs persistent)
- ✅ Different user stories (see message now vs review later)
- ✅ History optional (notifications work without it)

---

## Keywords

plan scope, combine plans, split plans, feature separation, plan organization

---

## Related Skills

- [writing-plans.md](writing-plans.md) - How to structure plans
- [executing-plans.md](executing-plans.md) - How to implement plans

---

**Last Updated**: 2025-11-30
**Created by**: Claude
