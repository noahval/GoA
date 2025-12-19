# Skill: Improve Plan

## Purpose
Analyze a plan document for technical issues, gaps, overcomplexity, and improvement opportunities. Provide structured feedback before implementation.

## Keywords
improve plan, review plan, check plan, plan review, enhance plan

## Procedure

### 1. Identify Target Plan
- If user has a plan open in IDE, use that file
- Otherwise, ask which plan to review
- Read the complete plan file

### 2. Load Context
- Read CLAUDE.md for development guidelines
- Check BIBLE.md for relevant documentation on systems mentioned in plan
- Review TOC.md to understand plan dependencies

### 3. Analysis Phase

Run comprehensive checks in parallel:

#### Technical Correctness
- GDScript syntax (use `"text".repeat(N)` not `"text" * N`)
- No unicode symbols/emoji in code blocks
- snake_case naming conventions
- Godot 4.5 API correctness
- Signal and node path syntax
- Type annotations where appropriate

#### Completeness Review
- Missing implementation details (vague steps like "handle error")
- Undefined edge cases
- Error handling gaps
- Missing test scenarios
- Unclear requirements needing clarification
- Assumptions not explicitly stated

#### Structure & Clarity
- Steps that are too vague or underspecified
- Implicit dependencies not called out
- Cross-references using wrong format (must be `1.x-name.md` not "plan 1.16")
- Missing references to related plans
- Confusing or ambiguous language

#### BIBLE Alignment
- Check if relevant BIBLE docs exist for systems being modified
- Identify if plan contradicts established patterns
- Flag missing references to existing documentation
- Verify plan follows project conventions

#### Complexity Assessment
- Overengineering beyond actual requirements
- Unnecessary abstractions or premature optimization
- Features not explicitly requested
- Simpler approaches that would work
- Steps that could be combined or eliminated

#### Risk Identification
- Breaking changes not clearly flagged
- Performance implications not mentioned
- Backward compatibility concerns
- Maintainability issues being introduced
- Technical debt creation
- Missing rollback/migration strategy

### 4. Generate Report

Output structured analysis with prioritized findings:

```markdown
## Critical Issues
[Blocking problems that MUST be fixed before implementation]
- Each issue with specific location reference (line numbers if applicable)
- Clear explanation of why it's critical
- Suggested fix

## Concerns
[Potential problems, edge cases, ambiguities that should be addressed]
- Specific concern with context
- Why it matters
- Possible solutions

## Simplification Opportunities
[Where to reduce complexity without losing functionality]
- Current approach
- Simpler alternative
- Trade-offs

## Enhancements
[Optional improvements, nice-to-haves]
- Enhancement suggestion
- Benefit it provides
- Effort estimate (trivial/minor/moderate)

## Questions Needing Clarification
[Ambiguities to resolve before implementation]
- Specific question
- Why it needs clarification
- Impact if not clarified
```

### 5. Interactive Refinement

After presenting analysis:
- Wait for user response
- Answer questions about findings
- If user requests, implement approved changes
- Re-run analysis on modified plan if changes were made

## Success Criteria

- All six analysis categories completed
- Findings are specific with file locations
- Critical issues clearly distinguished from optional improvements
- No generic/templated feedback - all findings are plan-specific
- User has actionable information to improve or approve plan

## Report Format

Start with executive summary:
- Total findings count by category
- Overall assessment (Ready/Needs Work/Major Issues)
- Top 3 most important items to address

Then provide detailed categorized findings as shown above.

## Best Practices

1. **Be specific**: Point to exact lines/sections, don't say "the plan has clarity issues"
2. **Prioritize ruthlessly**: Critical = blocks implementation, Concerns = should fix, Enhancements = nice to have
3. **Question assumptions**: If something seems unclear, flag it
4. **No sugarcoating**: Point out problems directly per CLAUDE.md guidelines
5. **Suggest alternatives**: Don't just criticize, offer better approaches
6. **Cross-reference BIBLE**: If documentation exists for a system, the plan should reference it
7. **Check cross-references**: All plan references should use `1.x-name.md` format for resilience to renumbering
