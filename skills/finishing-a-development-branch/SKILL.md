---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Verify tests → Review diff → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## The Process

### Step 1: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Run the project's test suite (use appropriate command)
npm test
# or: cargo test
# or: pytest
# or: go test ./...
```

**If tests fail:**

```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 2.

### Step 2: Determine Base Branch

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Or ask: "This branch split from main - is that correct?"

### Step 3: Review the Diff

**Before presenting options, review the full diff against the base branch:**

```bash
git diff <base-branch>...HEAD
```

This is a quick sanity check — not a deep review. You're checking *what actually changed*, not *what you intended to change*. Look for:

- **Unexpected files** — files touched that shouldn't have been
- **Scope creep** — changes beyond what the spec/plan required
- **Leftover debug code** — console.log, print statements, TODO comments
- **Accidental commits** — config files, secrets, generated files
- **Cross-task conflicts** — changes in Task A that contradict Task B

**If something looks wrong:** Fix it now, before offering options. Commit the fix.

**If the diff looks clean:** Continue to Step 4.

**Why this matters:** Per-task reviews catch issues within each task. This review catches issues that only emerge when you see the full picture — the same reason you'd review your own PR in a browser before clicking "Create Pull Request."

### Step 4: Present Options

Present exactly these 5 options:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Merge and create a Release
4. Keep the branch as-is (I'll handle it later)
5. Discard this work

Which option?
```

**Don't add explanation** - keep options concise.

### Step 5: Execute Choice

#### Option 1: Merge Locally

```bash
# Switch to base branch
git checkout <base-branch>

# Pull latest
git pull

# Merge feature branch
git merge <feature-branch>

# Verify tests on merged result
<test command>

# If tests pass
git branch -d <feature-branch>
```

Then: Cleanup worktree (Step 6)

#### Option 2: Push and Create PR

```bash
# Push branch
git push -u origin <feature-branch>

# Create PR (add --milestone if a milestone exists for this work)
gh pr create --title "<title>" --milestone "<milestone-name>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

## Test Plan
- [ ] <verification steps>
EOF
)"
```

**If no milestone exists** for this work, omit the `--milestone` flag.

Worktree preserved for PR iteration.

#### Option 3: Merge and Create Release

First complete Option 1 (Merge Locally), then:

**Invoke releasing skill:**
```
I'll now use the releasing skill to create a release.
```

Follow `skills/releasing/SKILL.md` workflow:
- Pre-release checklist
- CHANGELOG verification
- Tag creation
- GitHub release

After release completes, cleanup worktree (Step 6).

#### Option 4: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

**Don't cleanup worktree.**

#### Option 5: Discard

**Confirm first:**

```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for exact confirmation.

If confirmed:

```bash
git checkout <base-branch>
git branch -D <feature-branch>
```

Then: Cleanup worktree (Step 6)

### Step 6: Cleanup Worktree

**For Options 1, 3, 5:**

Check if in worktree:

```bash
git worktree list | grep $(git branch --show-current)
```

If yes:

```bash
git worktree remove <worktree-path>
```

**For Options 2, 4:** Keep worktree.

## Quick Reference

| Option           | Merge | Push | Release | Keep Worktree | Cleanup Branch |
| ---------------- | ----- | ---- | ------- | ------------- | -------------- |
| 1. Merge locally | ✓     | -    | -       | -             | ✓              |
| 2. Create PR     | -     | ✓    | -       | ✓             | -              |
| 3. Merge+Release | ✓     | -    | ✓       | -             | ✓              |
| 4. Keep as-is    | -     | -    | -       | ✓             | -              |
| 5. Discard       | -     | -    | -       | -             | ✓ (force)      |

## Common Mistakes

**Skipping test verification**

- **Problem:** Merge broken code, create failing PR
- **Fix:** Always verify tests before offering options

**Skipping diff review**

- **Problem:** Push unexpected changes, scope creep, leftover debug code
- **Fix:** Always review the full diff before presenting options

**Open-ended questions**

- **Problem:** "What should I do next?" → ambiguous
- **Fix:** Present exactly 5 structured options

**Automatic worktree cleanup**

- **Problem:** Remove worktree when might need it (Option 2: PR may need iteration)
- **Fix:** Only cleanup for Options 1, 3, and 5

**No confirmation for discard**

- **Problem:** Accidentally delete work
- **Fix:** Require typed "discard" confirmation

## Red Flags

**Never:**

- Proceed with failing tests
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request
- Skip the diff review before presenting options

**Always:**

- Verify tests before offering options
- Review the full diff before presenting options
- Present exactly 5 options
- Get typed confirmation for Option 5
- Clean up worktree for Options 1, 3 & 5 only

## Integration

**Called by:**

- **subagent-driven-development** (after all tasks complete) - Final step in per-task loop
- **executing-plans** (Step 3) - After all tasks complete

**Pairs with:**

- **using-git-worktrees** - Cleans up worktree created by that skill
- **releasing** - Invoked by Option 3 (Merge and Create Release)
