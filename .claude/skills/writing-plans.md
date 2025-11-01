# Skill: Writing Implementation Plans

**Use when:** Creating detailed implementation roadmaps for features or complex changes.

---

## Purpose

Generate comprehensive implementation plans for engineers with minimal codebase familiarity. Break down features into granular, testable tasks following TDD principles.

---

## Core Approach

**"Assume the engineer is skilled but knows almost nothing about our toolset or problem domain."**

Plans include:
- Exact file paths
- Complete code examples
- Verification steps

---

## Task Granularity

Each step = **2-5 minutes of work**

Separate discrete actions:
- Writing tests
- Running them
- Implementing code
- Committing

---

## Required Structure

Each task follows TDD:
1. Failing test first
2. Verification the test fails
3. Minimal implementation
4. Verification tests pass
5. Git commit with semantic messaging

---

## Documentation Format

Save to: `docs/plans/YYYY-MM-DD-<feature-name>.md`

**Mandatory headers:**
- Goal
- Architecture
- Tech stack

---

## Execution Options

After plan completion, offer two paths:

1. **Subagent-driven** (current session)
   Fresh subagent per task with code reviews

2. **Parallel session** (separate)
   New session using executing-plans skill with checkpoint batching

---

## Core Principles

- DRY (Don't Repeat Yourself)
- YAGNI (You Aren't Gonna Need It)
- TDD (Test-Driven Development)
- Frequent commits
- Assume zero domain knowledge

---

**Keywords:** plan, implementation plan, roadmap, task breakdown, feature plan
