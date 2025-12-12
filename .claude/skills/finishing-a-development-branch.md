# Skill: Finishing a Development Branch

**Use when:** Completing feature development and ready to integrate changes.

---

## Core Purpose

Guide completion of development work by verifying tests, presenting structured integration options, executing chosen workflow, and cleaning up resources.

---

## Process Steps

### Step 1: Test Verification
Run project's test suite.

**If tests fail:** STOP and display failures.
**Only continue if tests pass.**

---

### Step 2: Base Branch Determination
Identify the base branch (typically `main` or `master`) that feature branch originated from.

---

### Step 3: Present Four Options

Offer exactly these choices **without explanation**:

1. **Merge back to base branch locally**
2. **Push and create a Pull Request**
3. **Keep the branch as-is for later**
4. **Discard this work entirely**

---

### Step 4: Execute the Selected Choice

#### Option 1: Merge Locally
- Merge to base branch
- Verify tests
- Delete feature branch

#### Option 2: Push and Create PR
- Push branch to remote
- Create PR via GitHub CLI (`gh pr create`)

#### Option 3: Keep Branch
- Preserve branch and worktree
- No action taken

#### Option 4: Discard
- **Require typed confirmation:** "discard"
- Delete branch and worktree

---

### Step 5: Cleanup Worktree

**Remove worktree for:** Options 1 and 4
**Preserve worktree for:** Options 2 and 3

---

## Critical Rules

**Never:**
- Proceed with failing tests
- Skip presenting all four options
- Allow destructive actions without typed confirmation
- Cleanup worktrees inappropriately

---

**Keywords:** finish branch, merge, pull request, PR, branch cleanup, integration
