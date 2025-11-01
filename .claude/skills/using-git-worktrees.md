# Skill: Using Git Worktrees

**Use when:** Need to work on multiple branches simultaneously, or setting up isolated workspace for feature development.

---

## Core Purpose

Establish isolated workspaces within a shared repository, enabling parallel branch work without switching contexts.

---

## Directory Selection

Three-step hierarchy:
1. Check for existing `.worktrees/` or `worktrees/` directories
2. Review CLAUDE.md for preferences
3. Ask the user (project-local vs global storage)

---

## Safety Requirements

### Project-local directories:
- **MUST** be verified in `.gitignore` before use
- **"Fix broken things immediately"** - add missing entries and commit first

### Global directories:
- `~/.config/superpowers/worktrees`
- Bypass `.gitignore` check entirely

---

## Implementation Steps

### 1. Detection
Identify project name via git

### 2. Creation
Establish worktree with appropriate branching

### 3. Setup
Auto-detect and install dependencies:
- Node: `npm install`
- Rust: `cargo build`
- Python: `pip install -r requirements.txt`
- Go: `go mod download`

### 4. Verification
Run baseline tests to ensure clean starting point

### 5. Reporting
Confirm readiness with location and test results

---

## Critical Safety Rules

**Never:**
- Skip `.gitignore` verification for project-local worktrees
- Proceed with failing tests without explicit permission
- Assume locations instead of following established directory priority
- Hardcode setup commands instead of auto-detecting

---

**Keywords:** git worktree, parallel development, isolated workspace, branch workspace
