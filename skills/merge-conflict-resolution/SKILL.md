---
name: merge-conflict-resolution
description: Use when git merge produces conflict markers — classifies conflicts by type, applies per-type resolution strategies, and verifies the result
---

# Merge Conflict Resolution

## Overview

Merge conflicts are a signal to slow down and understand intent before editing files.

**Core principle:** Classify first, then resolve. Never guess intent — understand what each side changed and why before merging.

**Announce at start:** "I'm using the merge-conflict-resolution skill to resolve this merge conflict."

## The Process

### Step 1: Detect & Classify

Start by identifying every conflicted file:

```bash
git diff --name-only --diff-filter=U
```

For each conflicted file, inspect the merge state and both sides of the conflict:

```bash
git diff --merge <file>
git show :1:<file>   # common ancestor
git show :2:<file>   # ours
git show :3:<file>   # theirs
```

Classify each conflict before editing it:

| Type | How to recognize it | Initial response |
|------|---------------------|------------------|
| Both modified | Both branches changed the same region | Read both sides and determine intent |
| Delete/modify | One side deleted a file the other modified | Determine whether the file should exist |
| Generated file | Lockfiles, compiled output, generated artifacts | Regenerate instead of hand-editing |
| Semantic conflict | No marker overlap, but behavior/logic now disagrees | Treat as a design problem, not a text problem |

### Step 2: Resolve Per Type

Apply the strategy that matches the conflict type:

- **Both modified:** Read both sides, understand intent, merge intelligently, and escalate if the correct result is ambiguous.
- **Delete/modify:** Ask which intent wins: keep the deletion or preserve the modification.
- **Generated file:** Auto-resolve by regenerating the file from source or build tooling.
- **Semantic conflict:** Use `systematic-debugging` to trace behavior, compare assumptions, and resolve the underlying logic mismatch.

Do not use `--ours` or `--theirs` as a default answer. Those flags are only correct when they match the intended outcome.

### Step 3: Mark Resolved & Verify

After resolving a file, stage it:

```bash
git add <file>
```

Then verify there are no remaining unresolved conflicts:

```bash
git diff --name-only --diff-filter=U
```

If conflicts remain, continue resolving them before proceeding.

Run the relevant tests after staging the resolved file(s). If tests fail, return to **Step 2** and re-check whether the issue is actually a **semantic conflict**.

### Step 4: Complete the Merge

When all conflicts are resolved and tests pass, finish the merge:

```bash
git merge --continue
```

Final verification must confirm:

- Tests pass
- No conflict markers remain in the tree
- Working tree is clean or only contains intentional, unrelated changes

## Auto-Resolve Rules & Escalation

### CAN auto-resolve

| Situation | Safe action |
|-----------|-------------|
| Generated file | Regenerate from source, then stage the result |
| Whitespace-only differences | Normalize formatting and keep the intended content |
| Superset change | Combine both changes when one branch is a strict superset of the other |
| Same change on both sides | Keep the shared result if both sides made the same edit |

### MUST escalate

| Situation | Why it must escalate |
|-----------|----------------------|
| Both sides changed the same logic differently | Intent is unclear without review |
| Delete/modify conflict | File existence itself is in dispute |
| Resolution might break invariants | Needs design-level judgment |
| 3+ files conflict in the same area | Likely a broader design or refactor issue |

### Escalation format template

```text
Merge conflict needs human decision.

Files:
- <file 1>
- <file 2>

Conflict type:
- <both modified | delete/modify | generated | semantic>

What changed on each side:
- ours: <brief summary>
- theirs: <brief summary>

Recommended options:
1. <option>
2. <option>

Question:
- Which intent should win?
```

## Quick Reference

| Step | Goal | Key command |
|------|------|-------------|
| Detect & Classify | Find all conflicted files and identify conflict type | `git diff --name-only --diff-filter=U` |
| Resolve Per Type | Apply the correct strategy for the conflict type | `git show :1:<file>`, `:2`, `:3` |
| Mark & Verify | Stage resolved files and confirm conflicts are gone | `git add <file>` + `git diff --name-only --diff-filter=U` |
| Complete | Finish the merge and confirm success | `git merge --continue` |

## Common Mistakes

1. **Taking `--ours` / `--theirs` as the default** — Fast, but often wrong when intent matters.
2. **Resolving without understanding intent** — Text may merge cleanly while behavior becomes incorrect.
3. **Forgetting generated files** — Hand-editing lockfiles or build output usually creates drift.
4. **Skipping post-merge tests** — A resolved merge is not complete until behavior is verified.
5. **Aborting instead of resolving** — Aborting is only for backing out of the merge, not for avoiding a hard conflict.

## Red Flags

### Never list

- Never guess which side is correct without reading both sides
- Never use `--ours` or `--theirs` blindly
- Never hand-edit generated artifacts when regeneration is available
- Never skip tests after resolving conflicts
- Never leave conflict markers in committed code

### Always list

- Always classify the conflict type first
- Always inspect both sides of the change
- Always regenerate generated files when possible
- Always stage resolved files before continuing the merge
- Always verify the result with tests and conflict-marker checks

## Integration

**Called by:**

- **finishing-a-development-branch** - When merge conflicts appear during local merge completion
- **subagent-driven-development** - When a task branch or per-task merge hits conflicts
- **dispatching-parallel-agents** - When parallel work converges and needs reconciliation

**Pairs with:**

- **systematic-debugging** - For semantic conflicts and behavior-level disagreements
- **verification-before-completion** - For final checks before claiming the merge is done
