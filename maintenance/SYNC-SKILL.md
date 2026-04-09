---
name: upstream-sync
description: Sync new features/skills from upstream obra/superpowers and adapt for Letta Code. Use when checking for upstream updates or integrating new skills.
model: auto
---

# Upstream Sync Skill

Use this skill to check for and integrate new features/skills from the upstream [obra/superpowers](https://github.com/obra/superpowers) repository.

**Important:** This skill is for maintaining the Letta Code fork. Users copying skills to their projects do not need this.

## Prerequisites

The upstream remote must be configured:

```bash
git remote -v
# Should show:
# origin    → https://github.com/grayemon/letta-superpowers.git
# upstream  → https://github.com/obra/superpowers.git

# If upstream is missing:
git remote add upstream https://github.com/obra/superpowers.git
```

## When to Use

- Periodically check for upstream updates (weekly recommended)
- When user mentions "new features from upstream" or "sync with obra"
- When updating skills from the original repo

## Sync Workflow

### Phase 1: Check for Updates

```bash
# Fetch latest from upstream
git fetch upstream

# See what changed since last sync
git log HEAD..upstream/main --oneline

# See what changed in skills/ specifically
git diff HEAD upstream/main --name-status -- skills/
```

### Phase 2: Categorize Changes

**New skills (A = Added):**
```bash
git diff HEAD upstream/main --name-status -- skills/ | grep "^A"
```

**Modified skills (M = Modified):**
```bash
git diff HEAD upstream/main --name-status -- skills/ | grep "^M"
```

**Deleted skills (D = Deleted):**
```bash
git diff HEAD upstream/main --name-status -- skills/ | grep "^D"
```

### Phase 3: Selective Integration

**For new skills:**

1. Checkout the skill from upstream:
   ```bash
   git checkout upstream/main -- skills/new-skill/
   ```

2. Adapt for Letta Code:
   - Review all .md files for Task() syntax
   - Replace `Task("...")` with `Task({ subagent_type, description, prompt })`
   - Remove `superpowers:` namespace prefix
   - Replace Claude Code/Codex/Cursor references with Letta Code equivalents
   - Update model params: use `auto-fast` or `auto`

3. Test and commit:
   ```bash
   git add skills/new-skill/
   git commit -m "feat: Add new-skill from upstream (adapted for Letta Code)"
   ```

**For modified skills:**

1. See the diff:
   ```bash
   git diff HEAD upstream/main -- skills/some-skill/SKILL.md
   ```

2. If changes are platform-specific (hooks, agents, namespace), manually apply only the relevant parts.

3. If changes are generic improvements, checkout and re-adapt:
   ```bash
   git checkout upstream/main -- skills/some-skill/
   # Then adapt for Letta Code
   ```

### Phase 4: Adaptation Checklist

When adapting a skill, check for:

| Issue | Fix |
|-------|-----|
| `Task("...")` string syntax | Convert to `Task({ subagent_type, description, prompt })` |
| `superpowers:skill-name` | Change to `skill-name` |
| `subagent_type: "code-reviewer"` | Use `subagent_type: "general-purpose"` with template |
| `model: "haiku"` | Change to `model: "auto-fast"` |
| `model: "sonnet"` | Change to `model: "auto"` |
| Claude Code, Codex, Cursor references | Replace with Letta Code |
| hooks/, agents/, scripts/ references | Remove (not needed for Letta Code) |

### Phase 5: Update SYNC.md

After completing sync, update the "Last Sync" table in this file:

| Date | Upstream Commit | Changes Integrated |
|------|-----------------|---------------------|
| YYYY-MM-DD | `abc1234` | Description of changes |

## What We DON'T Sync

Platform-specific files are NOT synced from upstream:

- `hooks/`
- `agents/`
- `scripts/`
- `docs/`
- `.claude-plugin/`
- `.cursor-plugin/`
- `.opencode/`
- `.codex/`
- `package.json`
- `RELEASE-NOTES.md`
- `CLAUDE.md`

These are specific to the Claude Code plugin system and have Letta Code equivalents in this fork.

## Example Session

```
User: Check for updates from upstream obra/superpowers

Agent: I'll check for upstream updates.

[Runs: git fetch upstream && git diff HEAD upstream/main --name-status -- skills/]

Found 2 new skills and 3 modified skills:
- NEW: skills/advanced-parallel/
- NEW: skills/automated-refactoring/
- MODIFIED: skills/brainstorming/SKILL.md
- MODIFIED: skills/writing-plans/SKILL.md
- MODIFIED: skills/subagent-driven-development/SKILL.md

Would you like me to:
1. Show diffs for specific files
2. Integrate a specific skill
3. Integrate all changes

User: Integrate skills/advanced-parallel/

Agent: I'll integrate skills/advanced-parallel/ from upstream.

[Runs: git checkout upstream/main -- skills/advanced-parallel/]

Now adapting for Letta Code...

[Reviews and edits files to adapt Task() syntax, remove superpowers: prefix, update platform references]

Adaptation complete. Changes:
- Fixed Task() syntax in SKILL.md
- Removed superpowers: namespace prefix
- Updated model params to Letta Code format

Ready to commit. Commit message:
"feat: Add advanced-parallel skill from upstream (adapted for Letta Code)"

Shall I commit and push?
```

## Output Format

When reporting sync status, use:

```markdown
## Upstream Sync Report

**Last sync:** YYYY-MM-DD
**Upstream status:** X commits behind

### New Skills (N)
- `skill-name/` - Brief description

### Modified Skills (M)
- `skill-name/SKILL.md` - What changed

### Deleted Skills (D)
- `skill-name/` - Note if relevant

### Recommendation
[What action to take]
```
