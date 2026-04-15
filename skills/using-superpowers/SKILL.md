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

Letta Code has built-in skills with similar purposes. Use these example scenarios to disambiguate:

### Creating Skills

**Scenario:** User says "create a new skill for X" or "write a skill that does Y"

| ✅ CORRECT | ❌ WRONG |
|------------|----------|
| `/skill-authoring-tdd` | Built-in `/creating-skills` |
| **Why:** TDD methodology ensures skills work before using. Includes testing pattern with subagents. | **Why NOT:** Built-in skill only covers structure/packaging. No testing methodology. Skills may break in production. |

**Example:**
```
User: "Create a skill for deploying to AWS"

CORRECT path:
1. Load /skill-authoring-tdd
2. Design skill with brainstorming
3. Write skill with tests
4. Test skill with subagent
5. Verify before release

WRONG path:
1. Load /creating-skills (built-in)
2. Create skeleton
3. No testing
4. Skill may break when user tries it
```

---

### Git Worktrees

**Scenario:** Need to work on multiple features in parallel without conflicts

| ✅ CORRECT | ❌ WRONG |
|------------|----------|
| `/using-git-worktrees` | Built-in `/working-in-parallel` |
| **Why:** Canonical workflow step 2. Creates isolated worktrees with proper branch naming. | **Why NOT:** Built-in skill uses different directory convention, breaks superpowers workflow chain. |

**Example:**
```
User: "I need to work on feature A and feature B at the same time"

CORRECT path:
1. Load /using-git-worktrees
2. Create worktree for feature-a
3. Create worktree for feature-b
4. Work independently in each
5. Merge/cleanup following canonical workflow

WRONG path:
1. Load /working-in-parallel (built-in)
2. Different conventions, different directory structure
3. Breaks integration with other superpowers skills
```

---

### Parallel Dispatch

**Scenario:** Need to run multiple independent tasks simultaneously

| ✅ CORRECT | ✅ ALSO CORRECT |
|------------|-----------------|
| `/dispatching-parallel-agents` | Built-in `/dispatching-coding-agents` |
| **Use when:** Dispatching to Letta Code Task subagents | **Use when:** Dispatching to external CLI tools |

**No conflict** — they serve different purposes:

```
Scenario A: Parallel Letta subagents
User: "Run two explore subagents to search codebase"
→ Use /dispatching-parallel-agents (Task tool with subagent_type)

Scenario B: External coding tools
User: "Get a second opinion from Claude CLI"
→ Use /dispatching-coding-agents (spawns external `claude` or `codex` processes)
```

---

### Quick Reference

| Trigger | Use This Skill | NOT This |
|---------|---------------|-----------|
| "Create/write a skill" | `skill-authoring-tdd` | `creating-skills` |
| "Work on multiple features" | `using-git-worktrees` | `working-in-parallel` |
| "Parallel Letta subagents" | `dispatching-parallel-agents` | (no conflict) |
| "External Claude/Codex" | `dispatching-coding-agents` | (no conflict) |

## Skill Types

**Rigid** (TDD, debugging): Follow exactly. Don't adapt away discipline.

**Flexible** (patterns): Adapt principles to context.

The skill itself tells you which.

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.
