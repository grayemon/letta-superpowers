# Maintenance Directory

This directory contains tools for maintaining the Letta Code fork of Superpowers.

## Files

| File | Purpose |
|------|---------|
| `SYNC-SKILL.md` | Guide for syncing new features/skills from upstream obra/superpowers |

## How to Use

When working on this fork repository:

```
User: Check for updates from upstream obra/superpowers

Agent: [Reads maintenance/SYNC-SKILL.md and follows instructions]
```

The sync skill will guide the agent to:
1. Fetch upstream changes
2. Identify new/modified skills
3. Adapt them for Letta Code
4. Commit the changes

## For Fork Maintainers

1. **Watch the upstream repo** at https://github.com/obra/superpowers
2. **Periodically sync** using the sync skill workflow
3. **Update the "Last Sync" table** in SYNC-SKILL.md after each sync

## Upstream Remote Setup

```bash
git remote add upstream https://github.com/obra/superpowers.git
```
