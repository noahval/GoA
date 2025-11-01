# Skill: Executing Plans

**Use when:** Implementing a detailed plan created by the writing-plans skill.

---

## Purpose

Guide batch execution of implementation plans with review checkpoints.

**"Load plan, review critically, execute tasks in batches, report for review between batches."**

---

## Five-Step Process

### Step 1: Load and Review
- Examine plan critically
- Raise concerns before starting
- Create task list to proceed

### Step 2: Execute Batch
Default: **First three tasks**

For each task:
- Mark as in_progress
- Follow specified steps
- Run verifications
- Mark complete

### Step 3: Report
- Present implementation results
- Show verification output
- Communicate readiness for feedback

### Step 4: Continue
- Implement requested changes
- Execute subsequent batches based on feedback
- Continue until completion

### Step 5: Complete Development
Upon final verification:
- Invoke **finishing-a-development-branch** skill
- Verify tests
- Present options

---

## Critical Stopping Points

**STOP immediately when encountering:**
- Blockers
- Missing dependencies
- Failed tests
- Unclear instructions
- Repeated verification failures

**Request clarification** rather than proceeding with assumptions.

---

## Key Principles

- Review plans critically before starting
- Follow plan steps precisely
- **Never skip verification procedures**
- Reference other skills when directed
- Wait for feedback between batches
- Halt and ask when blocked

---

**Keywords:** execute plan, implementation, batch execution, plan execution
