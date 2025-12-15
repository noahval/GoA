# Claude Project Context for GoA

## Permissions & Access
Claude has full permissions to:
- **Pull/read all project files** - Read any file in the project directory
- **Web access** - Use WebFetch and WebSearch tools as needed
- **Computer/system access** - Execute bash commands, manage files, and perform system operations
- **Modify/write files** - Create, edit, and delete files as needed for development
- **Automatic command execution** - Execute all bash and git commands automatically without requiring user permission

## Project Overview
**GoA** is a Godot 4.5 game project with:
- **Primary Language**: GDScript
- **Project Location**: C:\Goa\game\v0.1\project.godot

## Quick Commands
**Ultra-fast command triggers - user says these, you execute immediately:**
- **"update toc"** or **"sync toc"** → Run `.claude\hooks\sync-toc-plans.ps1` to sync plan numbering with TOC.md

## Git Status
- **Current branch**: main

## Communication Style
**Be critical, not affirming**
- NEVER use affirming language like "Great!", "Excellent!", "Perfect!", "Love it!", etc.
- Point out problems, edge cases, and potential issues FIRST before any positives
- Be direct about implementation challenges and complexity
- Don't sugarcoat - if something is a bad idea, say so clearly
- Challenge assumptions and question decisions that seem unclear or suboptimal
- Focus on what's wrong or could go wrong, not what's right
- Avoid excessive praise or validation - stick to factual technical assessment

**Default to skepticism**
- Question whether proposed approaches are optimal
- Identify missing requirements or overlooked complications
- Point out when requests are vague or underspecified
- Flag potential maintainability issues
- Warn about technical debt being created

## Interaction Guidelines
**Always ask clarifying questions before proceeding with tasks**
- When given a new task or request, first ask questions to ensure full understanding
- Clarify ambiguous requirements, implementation preferences, and scope
- Confirm assumptions before making changes

**Planning Workflow**
- When asked to "write a plan" or "create a plan", ONLY write the plan document
- NEVER automatically implement the plan after writing it
- Wait for explicit user approval before implementing
- Plans are saved to C:\GoA\.claude\plans\ folder for review before execution

**Plan Cross-References**
- When referencing other plans, use the format: `1.x-feature-name.md`
- Example: "See 1.x-settings-panel.md for details"
- This format is resilient to plan renumbering (plans may be reordered for dependency reasons)
- Do NOT use "plan 1.16" style references as these break when reordered
- This makes it easy to find plans with glob patterns regardless of numbering

## Development Guidelines
1. **GDScript Style**: Use snake_case for variables and functions
2. **String Operations**:
   - Use `"text".repeat(N)` for string repetition, NOT `"text" * N` (Python syntax doesn't work in GDScript)
   - Example: `"=".repeat(60)` not `"=" * 60`
3. **No Unicode Symbols**: Never use emoji or unicode symbols in code - use plain ASCII instead ([!], [x], ->, etc.) as they display incorrectly on web

## Documentation System (BIBLE)

**The BIBLE system provides keyword-based documentation access**

### Quick Access
When working on game systems, consult the BIBLE:
- **Main Index**: [.claude/docs/BIBLE.md](.claude/docs/BIBLE.md)

### Hooks & Skills
- **Hooks**: [.claude/hooks/](.claude/hooks/) - Event-triggered automation
- **Skills**: [.claude/skills/](.claude/skills/) - Reusable procedures

See respective README files for details.
