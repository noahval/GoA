# Skill: Defense-in-Depth Validation

**Use when:** Implementing validation, preventing bugs, or hardening code against invalid data.

---

## Core Principle

**Validate at EVERY layer data passes through. Make the bug structurally impossible.**

---

## The Four-Layer Framework

### Layer 1: Entry Point Validation
Reject invalid input at API boundaries:
- Check for empty/null values
- Verify existence
- Validate correct types

### Layer 2: Business Logic Validation
Ensure data makes semantic sense:
- Valid for specific operation
- Meets domain constraints
- Satisfies business rules

### Layer 3: Environment Guards
Prevent dangerous operations based on context:
- Refuse certain actions during testing
- Check environment-specific constraints
- Validate runtime conditions

### Layer 4: Debug Instrumentation
Capture diagnostic information:
- Log validation failures
- Capture stack traces
- Record forensic data for analysis

---

## Implementation Strategy

1. **Trace** where invalid data originates and flows
2. **Identify** every checkpoint the data passes
3. **Add** validation checks at each layer
4. **Test** whether bypassing one layer gets caught by another

---

## Key Principle

Multiple validation layers are necessary because:
- Different code paths may bypass individual checks
- Mocks can skip validation
- Edge cases may avoid single checkpoints

Comprehensive layered validation ensures structural correctness.

---

**Keywords:** validation, defense-in-depth, guards, error prevention, hardening
