# Skill: Writing Implementation Plans (GoA Project)

**Use when:** Creating detailed implementation plans for GoA features following the complete rewrite standards.

---

## GoA Planning Standards

### Plan Location & Naming
- **Location**: `.claude/plans/`
- **Naming**: `[section].[subsection]-[feature-name].md`
  - Example: `1.8-stats-and-experience.md`
  - Example: `2.1-core-loop.md`
  - Example: `5.3-worker-management.md`

### Template Reference
- **Follow**: `.claude/plans/TEMPLATE.md`
- **Study examples**: `1.5-currencies.md`, `1.6-currency-manager.md`, `1.8-stats-and-experience.md`

### Cross-Referencing Plans
When referencing other plans in documentation, use the glob pattern format:
- **Format**: `1.x-feature-name.md`
- **Example**: "See 1.x-settings-panel.md for details"
- **Example**: "Coordinate with 1.x-global-autoload.md"

**Why this format:**
- Resilient to plan renumbering (plans may be reordered for dependency reasons)
- AI-friendly: Claude can use `Glob pattern="*-settings-panel.md"` to find files
- Human-readable: Descriptive filename part makes purpose clear
- No maintenance: References stay valid even when plan numbers change

**Where to use:**
- Dependencies sections
- Integration notes
- Code comments referencing plans
- Success criteria
- Implementation checklist items

**Don't use:**
- ❌ "plan 1.16" (breaks when renumbered)
- ❌ "the settings panel plan" (ambiguous, harder to glob)
- ✅ "1.x-settings-panel.md" (resilient and clear)

---

## Planning Process

### Step 1: Load Context and Understand Requirements

**CRITICAL: Always load project documentation first**

1. **Read BIBLE.md** (`.claude/docs/BIBLE.md`) - Load critical requirements:
   - TDD methodology (RED-GREEN-REFACTOR cycle) - MUST be in Testing Strategy
   - Knowledge as Progression design philosophy - applies to ALL features
   - Grimdark theme requirements - applies to ALL content
   - Technical APIs and patterns to follow
   - Check for existing documentation on systems mentioned in the plan
2. **Read CLAUDE.md** for development guidelines and communication style
3. **Read TOC** (`.claude/docs/TOC.md`) - Find the feature's section/line number
4. **Check existing plans** - Look for related/dependent features
5. **Explore codebase** - Use Explore agent to understand current implementation
6. **Ask clarifying questions** - User preferences on design decisions

### Step 2: Design Decisions Checklist

**Always ask user about:**
- [ ] Combined vs separate plans (if multiple related systems)
- [ ] Scope boundaries (what's IN this plan vs other plans)
- [ ] Backend only vs UI included
- [ ] Design constraints (caps, limits, resets, etc.)
- [ ] Integration points with existing systems

**Key principle**: Core structure in base plans, gameplay hooks in feature plans

### Step 3: Plan Structure

Use TEMPLATE.md sections:

1. **Header**
   - Goal (one sentence)
   - Success Criteria (checklist)
   - Prerequisites (other phases)

2. **Overview**
   - Brief description (2-4 sentences)
   - Key Design Principles (constraints/guidelines)
   - Note: "IMPORTANT: Complete Rewrite Context"

3. **Architecture Overview**
   - Data flow diagram (text)
   - Component separation (what's where)

4. **Implementation Tasks**
   - Numbered subsections per component
   - Variables needed (with gdscript blocks)
   - Implementation details (bullet points)

5. **Code Examples**
   - Key functions with full gdscript implementations
   - Explanations of behavior

6. **Testing Strategy**
   - **TDD Methodology** (CRITICAL - from BIBLE.md):
     - Specify RED-GREEN-REFACTOR cycle for each component
     - Write failing test FIRST, then implementation
     - Verify tests fail before implementing (RED phase)
     - No production code without failing test first
   - Unit tests (headless tests with gdscript examples)
   - Integration tests (scenario table)
   - Manual test criteria (checkbox list)

7. **Files to Create/Modify**
   - Exact file paths
   - What changes in each file

8. **Design Values**
   - All magic numbers, formulas, constants
   - Tuning guidance

9. **Dependencies & Integration**
   - Depends on (what must exist first)
   - Used by (what uses this)
   - Provides APIs for (public interface)

10. **Phase Status**
    - Status, estimated time, dependencies complete
    - Previous/next phase links

11. **Notes & Decisions**
    - Document key decisions with rationale
    - Alternatives considered and rejected

12. **Implementation Checklist**
    - Complete task list for verification

---

## Core Principles for GoA Plans

### Separation of Concerns
- **Base system plans** (1.x): Core data structures, APIs, mechanics
- **Feature plans** (2.x, 5.x, etc.): Gameplay hooks, progression, balance

**Example**:
- `1.8-stats-and-experience.md`: Defines stat variables, XP formulas, level-up mechanics
- `2.9-stat-progression-mechanics.md`: Defines which actions award XP during copper era

### Backend First
- Focus on data and logic first
- UI can come later in separate plans
- Test core mechanics without visual presentation

### Complete Rewrite Mindset
- Write once, write clean
- No backward compatibility needed
- Fresh architecture, modern patterns

### User-Driven Design
- Ask about preferences before documenting
- Capture decisions in "Notes & Decisions" section
- Document rejected alternatives

---

## Writing Style

### Code Blocks
- Always use triple backticks with `gdscript` language tag
- Include complete, runnable examples
- Add comments for clarity

### Tables
- Use markdown tables for comparisons, scenarios, progression
- Example: Level progression tables, test scenarios

### Rationale
- Every design decision needs "Why?"
- Document alternatives considered
- Explain trade-offs

### No Unicode
- Use ASCII only: [!], [x], ->, etc.
- No emoji or special symbols (display issues on web)

---

## Example Plan Creation Flow

1. **User identifies TOC line** needing a plan
2. **Load BIBLE.md and CLAUDE.md** to understand critical requirements
3. **Launch Explore agent** to understand current implementation
4. **Ask design questions** (caps? resets? UI? combined?)
5. **Create plan** following TEMPLATE.md structure
6. **Verify BIBLE alignment** before completing (see checklist below)
7. **Update TOC.md** to reference new plan
8. **Update related plans** if needed (cross-references)

## BIBLE Alignment Checklist (Run Before Completing Plan)

**CRITICAL: Verify plan follows all BIBLE requirements**

Before marking a plan as complete, check:

- [ ] **TDD Methodology**: Testing Strategy section includes RED-GREEN-REFACTOR cycle
- [ ] **Knowledge as Progression**: If designing player-facing features, follows discovery-based design principles
- [ ] **Grimdark Theme**: If plan includes content/narrative/mood, follows oppressive atmosphere guidelines
- [ ] **Technical APIs**: Plan references correct Global APIs (add_stat_exp, change_scene_with_check, etc.)
- [ ] **Existing BIBLE Docs**: If relevant docs exist for systems in plan, they are referenced
- [ ] **No Unicode**: Plan uses ASCII only ([!], [x], ->, not emoji/special symbols)
- [ ] **Cross-References**: All plan references use `1.x-name.md` format, not "plan 1.16"
- [ ] **Pattern Compliance**: Plan follows established project conventions from BIBLE
- [ ] **Contradictions Documented**: If deviating from BIBLE patterns, rationale is documented

**If any checks fail**: Update plan before completing

---

## Key Learnings from Stats & Experience Plan

### What Worked Well
- **Loaded BIBLE.md first** to understand critical requirements
- **Included TDD methodology** in Testing Strategy section
- Combined intimately-related systems into one plan
- Clear separation: core mechanics vs gameplay hooks
- Asked user preferences up front (caps, resets, UI)
- Backend-only approach (no UI in base plan)
- Comprehensive testing strategy with RED-GREEN-REFACTOR cycle
- Design Values section for tuning
- Verified BIBLE alignment before completion

### Template Adherence
- Followed TEMPLATE.md structure exactly
- ~520 lines, comprehensive but focused
- All sections completed with real content

### Integration
- Clear dependency chains
- Documented what provides/uses this system
- Cross-referenced related plans

---

## Common Pitfalls to Avoid

- ❌ Don't skip reading BIBLE.md before writing the plan (critical requirements!)
- ❌ Don't omit TDD methodology from Testing Strategy (RED-GREEN-REFACTOR required)
- ❌ Don't include gameplay hooks in base system plans
- ❌ Don't skip design rationale sections
- ❌ Don't use unicode symbols
- ❌ Don't forget testing strategy
- ❌ Don't leave design values undocumented
- ❌ Don't mix backend and UI in same plan (unless user requests)
- ❌ Don't contradict established BIBLE patterns without documenting rationale
- ❌ Don't forget to check for existing BIBLE docs on systems being modified

---

## Execution (After Plan Approved)

Plans document WHAT to build, not step-by-step HOW.

**For implementation:**
1. Read the plan thoroughly
2. Follow Implementation Checklist order
3. Write tests first (TDD)
4. Implement incrementally
5. Verify against Success Criteria

---

**Keywords:** plan, implementation plan, roadmap, GoA, complete rewrite, TEMPLATE.md, base systems
