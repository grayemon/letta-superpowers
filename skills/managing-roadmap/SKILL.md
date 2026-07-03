---
name: managing-roadmap
description: Use when creating or updating project phases in roadmap.md, tracking issues by phase labels, or marking phases complete — replaces GitHub milestones with a portable, offline-friendly roadmap file
---

# Managing Roadmap

## Overview

Track project phases, sub-projects, and issue progress using a `roadmap.md` file in the repo plus GitHub labels for issue grouping. Portable across git hosts, works offline, and richer than GitHub milestones.

**Core principle:** roadmap.md is the source of truth — labels provide GitHub-side filtering.

## When to Use

- After saving a plan, to create a phase and file issues
- After a release, to mark a phase complete
- Standalone, when the user asks to "create a phase" or "track issues by phase"
- When the user wants to see progress across project phases

**When NOT to use:**
- Single-task fixes that don't warrant phase tracking
- Projects that don't use GitHub issues (roadmap.md still works, just skip the label commands)

## roadmap.md Format

```markdown
# Roadmap

## Phase 1: [Phase Name]
**Label:** `phase/[kebab-case-name]`
**Status:** Planned | In Progress | Complete
**Issues:** #12, #15, #18

- [x] #12 — [Issue title]
- [ ] #15 — [Issue title]
- [ ] #18 — [Issue title]

[Open issues](https://github.com/OWNER/REPO/issues?q=label%3Aphase%2Fkebab-case-name+is%3Aopen)
[Closed issues](https://github.com/OWNER/REPO/issues?q=label%3Aphase%2Fkebab-case-name+is%3Aclosed)

## Phase 2: [Next Phase Name]
...
```

**Status values:** `Planned` (phase created, no work started), `In Progress` (issues being worked), `Complete` (all issues closed, phase released).

## Operations

### 1. Initialize

Bootstrap `roadmap.md` if it doesn't exist:

```bash
if [ ! -f roadmap.md ]; then
  cat > roadmap.md << 'EOF'
# Roadmap

EOF
fi
```

Use the template in `references/roadmap-template.md` for a richer starting point.

### 2. Create Phase

Add a new phase section to `roadmap.md` and create a GitHub label for issue grouping.

**Ask the user:** "What should this phase be called?"

**Add section to roadmap.md** (append after existing phases or after the `# Roadmap` header if empty):

```markdown
## Phase N: [Phase Name]
**Label:** `phase/[kebab-case-name]`
**Status:** Planned
**Issues:** _(none yet)_
```

**Create the GitHub label:**

```bash
gh label create "phase/[kebab-case-name]" \
  --description "[Phase description from user]" \
  --color FBCA04
```

**Label naming:** `phase/` prefix + kebab-case name (e.g., `phase/auth-refactor`, `phase/api-gateway`). The `phase/` prefix distinguishes phase labels from other labels.

**Skip label creation if:** The project doesn't use GitHub, or the label already exists.

### 3. File Issues

Create GitHub issues for each task in a plan, tagged with the phase label.

```bash
gh issue create \
  --title "Task N: [Component Name]" \
  --body "[Task description from plan]" \
  --label "phase/[kebab-case-name]"
```

**Issue body** should contain the task's files, steps, and acceptance criteria — enough for a human to understand the scope without reading the plan file.

**After creating each issue**, update `roadmap.md`:
- Add the issue number to the `**Issues:**` line
- Add a checklist entry: `- [ ] #N — [Issue title]`

### 4. Mark Phase Complete

After a release, update the phase status in `roadmap.md`:

1. Change `**Status:**` from `In Progress` to `Complete`
2. Check all checklist items: `- [x]` for closed issues
3. Verify all issues are closed:

```bash
OPEN_COUNT=$(gh issue list --label "phase/[kebab-case-name]" --state open | wc -l)
if [[ "$OPEN_COUNT" -gt 0 ]]; then
  echo "Warning: $OPEN_COUNT open issues remain for this phase."
fi
```

**If open issues remain:** Warn the user. Don't mark as Complete until resolved or explicitly waived.

### 5. View Progress

Query GitHub for open/closed issue counts per phase:

```bash
# For a specific phase
gh issue list --label "phase/[kebab-case-name]" --state open
gh issue list --label "phase/[kebab-case-name]" --state closed

# Summary counts
echo "Open: $(gh issue list --label 'phase/[kebab-case-name]' --state open  | wc -l)"
echo "Closed: $(gh issue list --label 'phase/[kebab-case-name]' --state closed | wc -l)"
```

Or read `roadmap.md` directly for a full overview — no network needed.

## Label Conventions

| Convention | Example | Purpose |
|-----------|---------|---------|
| `phase/` prefix | `phase/auth-refactor` | Distinguishes phase labels from other labels |
| Kebab-case | `phase/api-gateway` | Consistent, URL-safe naming |
| Yellow color (`FBCA04`) | — | Visual consistency in GitHub UI |

## Quick Reference

| Operation | What it does | Key command |
|-----------|-------------|-------------|
| Initialize | Bootstrap roadmap.md | `cat > roadmap.md` |
| Create phase | Add section + create label | `gh label create "phase/X"` |
| File issues | Create issues with phase label | `gh issue create --label "phase/X"` |
| Mark complete | Update roadmap.md status | Edit `**Status:** Complete` |
| View progress | Query issue counts | `gh issue list --label "phase/X"` |

## Common Mistakes

**Forgetting to update roadmap.md after filing issues**
- **Problem:** roadmap.md and GitHub drift out of sync
- **Fix:** Always update the Issues line and checklist after each `gh issue create`

**Using milestone API instead of labels**
- **Problem:** Milestones are GitHub-specific, require API calls, and only track open/closed
- **Fix:** Use phase labels for grouping — portable, queryable, and work on any git host

**Not creating the label before filing issues**
- **Problem:** `gh issue create --label` fails if the label doesn't exist
- **Fix:** Always run `gh label create` first, or check with `gh label list`

**Marking a phase complete with open issues**
- **Problem:** roadmap.md says Complete but work remains
- **Fix:** Always verify with `gh issue list --state open` before marking Complete

## Integration

**Called by:**
- `writing-plans` — after plan is saved, optionally creates a phase and files issues
- `releasing` — after release, marks the phase as complete in roadmap.md

**Followed by:**
- `finishing-a-development-branch` — can reference the phase label for PR creation (`--label phase/X`)
