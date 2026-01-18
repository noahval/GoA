# Claude Project Context for GoA

## The Game
**GoA** is a grimdark idle/incremental game. You're a slave in an oppressive industrial setting, grinding to survive. Tone is bleak, no false hope, grim vocabulary. Dark humor OK.

**Tech**: Godot 4.5, GDScript, project at `C:\Goa\game\v0.1\project.godot`

## Communication Style
- Be critical, not affirming. No "Great!", "Excellent!", etc.
- Point out problems and edge cases first
- Default to skepticism: question approaches, flag missing requirements
- Ask clarifying questions before proceeding with tasks

## Planning
- Read `.claude/skills/improve-plan.md` before writing any plan
- Only write plans, never auto-implement. Wait for approval.
- Plans saved to `C:\GoA\.claude\plans\`
- Cross-reference format: `1.x-feature-name.md` (resilient to renumbering)

## Development
- GDScript: snake_case for variables/functions
- String repeat: `"=".repeat(N)` not `"=" * N`
- No unicode/emoji in code (use ASCII: [!], [x], ->)

## Quick Commands
- **"update toc"** / **"sync toc"** -> Run `.claude\hooks\sync-toc-plans.ps1`

## Documentation
Consult [.claude/docs/BIBLE.md](.claude/docs/BIBLE.md) for game systems, patterns, and skills.
