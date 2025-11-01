# Skill: Sharing Skills

**Use when:** Contributing broadly applicable skills back to upstream repository.

---

## Sharing Criteria

### Share When:
- ✓ Skill applies broadly (not project-specific)
- ✓ Well-tested and documented

### Keep Local If:
- ✗ Project-specific or organization-specific
- ✗ Contains sensitive information

---

## Prerequisites

- GitHub CLI installed and authenticated
- Working from `~/.config/superpowers/skills/` directory
- Skill tested using writing-skills TDD process

---

## Core Workflow

### 1. Sync with upstream
```bash
git checkout main
git pull upstream main
```

### 2. Create feature branch
```bash
git checkout -b feature/skill-name
```

### 3. Create/edit skill file
```bash
mkdir -p skills/skill-name
# Edit skills/skill-name/SKILL.md
```

### 4. Commit with descriptive message
```bash
git add skills/skill-name/
git commit -m "Add [skill-name] skill for [purpose]"
```

### 5. Push to personal fork
```bash
git push origin feature/skill-name
```

### 6. Create Pull Request via CLI
```bash
gh pr create --title "Add skill-name skill" --body "Description"
```

---

## Important Practices

**Each skill should:**
- Have its own feature branch
- Have its own PR
- Be independently reviewable

**Never batch multiple skills into single pull requests.**

---

## Post-Merge Process

After approval and merging:
1. Sync local main branch
2. Delete feature branch locally and remotely

```bash
git checkout main
git pull upstream main
git branch -d feature/skill-name
git push origin --delete feature/skill-name
```

---

## Troubleshooting

### Missing GitHub CLI
Install: `gh` via package manager

### SSH authentication problems
Configure SSH keys in GitHub settings

### Existing skills
Check for duplicates before creating

### Merge conflicts
Sync with upstream main before creating PR

---

**Keywords:** skill sharing, contributing skills, upstream contribution, skill PR
