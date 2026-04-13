---
name: using-superpowers
description: Use when starting any conversation - establishes how to find and use skills, requiring Skill tool invocation before ANY response including clarifying questions
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Instruction Priority

Superpowers skills override default system prompt behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (direct requests, project rules) — highest priority
2. **Superpowers skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

If the user says "don't use TDD" and a skill says "always use TDD," follow the user's instructions. The user is in control.

## How to Access Skills

**In Letta Code:** Use the `Skill` tool. When you invoke a skill, its content is loaded and presented to you—follow it directly. Never use the Read tool on skill files.

**Tool mapping reference:** See `references/letta-code-tools.md` for Letta Code-specific tool names and syntax.

# Using Skills

## The Rule

**Invoke relevant or requested skills BEFORE any response or action.** Even a 1% chance a skill might apply means that you should invoke the skill to check. If an invoked skill turns out to be wrong for the situation, you don't need to use it.

```dot
digraph skill_flow {
    "User message received" [shape=doublecircle];
    "About to EnterPlanMode?" [shape=doublecircle];
    "Already brainstormed?" [shape=diamond];
    "Invoke brainstorming skill" [shape=box];
    "Might any skill apply?" [shape=diamond];
    "Invoke Skill tool" [shape=box];
    "Announce: 'Using [skill] to [purpose]'" [shape=box];
    "Has checklist?" [shape=diamond];
    "Create TodoWrite todo per item" [shape=box];
    "Follow skill exactly" [shape=box];
    "Respond (including clarifications)" [shape=doublecircle];

    "About to EnterPlanMode?" -> "Already brainstormed?";
    "Already brainstormed?" -> "Invoke brainstorming skill" [label="no"];
    "Already brainstormed?" -> "Might any skill apply?" [label="yes"];
    "Invoke brainstorming skill" -> "Might any skill apply?";

    "User message received" -> "Might any skill apply?";
    "Might any skill apply?" -> "Invoke Skill tool" [label="yes, even 1%"];
    "Might any skill apply?" -> "Respond (including clarifications)" [label="definitely not"];
    "Invoke Skill tool" -> "Announce: 'Using [skill] to [purpose]'";
    "Announce: 'Using [skill] to [purpose]'" -> "Has checklist?";
    "Has checklist?" -> "Create TodoWrite todo per item" [label="yes"];
    "Has checklist?" -> "Follow skill exactly" [label="no"];
    "Create TodoWrite todo per item" -> "Follow skill exactly";
}
```

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Thought                             | Reality                                                |
| ----------------------------------- | ------------------------------------------------------ |
| "This is just a simple question"    | Questions are tasks. Check for skills.                 |
| "I need more context first"         | Skill check comes BEFORE clarifying questions.         |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first.           |
| "I can check git/files quickly"     | Files lack conversation context. Check for skills.     |
| "Let me gather information first"   | Skills tell you HOW to gather information.             |
| "This doesn't need a formal skill"  | If a skill exists, use it.                             |
| "I remember this skill"             | Skills evolve. Read current version.                   |
| "This doesn't count as a task"      | Action = task. Check for skills.                       |
| "The skill is overkill"             | Simple things become complex. Use it.                  |
| "I'll just do this one thing first" | Check BEFORE doing anything.                           |
| "This feels productive"             | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means"            | Knowing the concept ≠ using the skill. Invoke it.      |

## Skill Priority

When multiple skills could apply, use this order:

1. **Process skills first** (brainstorming, debugging) - these determine HOW to approach the task
2. **Implementation skills second** (test-driven-development, systematic-debugging) - these guide execution
3. **Completion skills last** (finishing-a-development-branch, releasing) - these finalize work

"Let's build X" → brainstorming first, then implementation skills.
"Fix this bug" → debugging first, then domain-specific skills.
"Done with feature" → finishing-a-development-branch, optionally releasing.

## Canonical Skill Sequence

The superpowers workflow is a strict sequential chain:

1. **brainstorming** → Design through Q&A, outputs `docs/specs/*.md`
2. **using-git-worktrees** → Isolated workspace (requires design approval)
3. **writing-plans** → Break into 2-5 min tasks, outputs `docs/plans/*.md`
4. **executing-plans** OR **subagent-driven-development** → Implement tasks
5. **test-driven-development** → RED-GREEN-REFACTOR (used throughout)
6. **requesting-code-review** → Quality gate
7. **finishing-a-development-branch** → Merge/PR/keep decision
8. **releasing** → (Optional) Semantic versioning, changelog

## Which Skill to Use?

| Task Type | First Skill | Followed By |
|-----------|-------------|-------------|
| "Build X" / "Add feature" | brainstorming | writing-plans → executing |
| "Fix bug" / "Tests failing" | systematic-debugging | TDD to fix |
| "Design approved, ready to code" | using-git-worktrees | writing-plans |
| "Have plan, implement it" | subagent-driven-development | (or executing-plans) |
| "Tests pass, what next?" | finishing-a-development-branch | releasing (optional) |
| "Multiple independent failures" | dispatching-parallel-agents | Then debug each |

## Hard Gates (Non-Negotiable)

- ⛔ **No code before design** — brainstorming MUST complete first
- ⛔ **No execution without worktree** — using-git-worktrees required before execution skills
- ⛔ **Spec compliance review before code quality** — wrong order = red flag
- ⛔ **3 failed fixes → stop** — question architecture, don't keep patching

## When to Parallelize

**Use `dispatching-parallel-agents` when:**
- ✅ 2+ independent tasks (no shared state)
- ✅ Different files/subsystems
- ✅ Each problem understood without other context

**Do NOT parallelize:**
- ❌ Implementation tasks touching same files
- ❌ Sequential skill chain (brainstorming → plans → execute)
- ❌ Tasks with dependencies between them

## Built-in Skill Overlap

Letta Code has built-in skills with similar purposes. Use these guidelines:

| Overlap | Use This | Why |
|---------|----------|-----|
| Creating skills | `skill-authoring-tdd` | TDD methodology for skill verification. Built-in `creating-skills` is for structure/packaging. |
| Git worktrees | `using-git-worktrees` | Canonical workflow step 2. Built-in `working-in-parallel` is an alternative with different directory convention. |
| Parallel dispatch | `dispatching-parallel-agents` | For internal Task subagents. Built-in `dispatching-coding-agents` is for external CLIs (`claude`, `codex`) — different purpose, no conflict. |

## Skill Types

**Rigid** (TDD, debugging): Follow exactly. Don't adapt away discipline.

**Flexible** (patterns): Adapt principles to context.

The skill itself tells you which.

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.
