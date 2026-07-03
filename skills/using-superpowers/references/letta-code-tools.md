# Letta Code Tool Reference

Tool names and syntax for Superpowers skills in Letta Code v0.27+.

## Default Toolset (Claude)

The following tools are available by default in Letta Code with Anthropic models:

| Tool | Behavior |
|------|----------|
| Agent | Dispatch subagent with structured params: `subagent_type`, `description`, `prompt`, `model` |
| TaskCreate | Create a task: `subject`, `description`, `activeForm` |
| TaskGet | Fetch a single task by ID: `taskId` |
| TaskList | List all tasks in the session |
| TaskUpdate | Update a task: `taskId`, `status`, `subject`, `description`, `addBlocks`, `addBlockedBy` |
| TaskOutput | Retrieve output from background tasks: `task_id`, `block`, `timeout` |
| TaskStop | Stop a running background task: `task_id` |
| Skill | Invoke a skill |
| AskUserQuestion | Ask user for clarification: `questions` array with options |
| EnterWorktree | Create or switch into a git worktree: `name`, `branch_name`, `base_ref` |
| Read, Write, Edit, Bash | Standard file/shell operations |
| memory | Modify agent memory files: `command`, `file_path`, `reason` |

**Note:** `Agent` and `Task` are aliases — both dispatch subagents. `Agent` is the name shown in current system prompts; `Task` is the canonical name in the codebase. Use `Agent` in skill examples for consistency with what the model sees.

**Glob and Grep** are not in the default toolset but may be available in some configurations. If unavailable, use `Bash` with `find` and `rg` (ripgrep) for file search and content search respectively.

## Subagent Types

| subagent_type | Use Case | Access |
|---------------|----------|--------|
| `"general-purpose"` | Full implementation - read/write | Read/write |
| `"fork"` | Fork of parent agent with full context and tools | Read/write |
| `"history-analyzer"` | Analyze conversation history, update memory | Read/write |
| `"memory"` | Reorganize memory blocks | Read/write |
| `"init"` | Initialize agent memory | Read/write |
| `"recall"` | Search conversation history | Read-only |
| `"reflection"` | Background memory consolidation | Read/write |

## Model Selection

| model param | Use Case |
|-------------|----------|
| `"auto-fast"` | Quick, straightforward tasks |
| `"auto"` | Default - complex reasoning |
| (omit param) | Inherit from parent agent |
| Explicit handle | Use specific model |

## Agent Tool Syntax

### Basic Dispatch
```typescript
Agent({
  subagent_type: "general-purpose",
  description: "Fix abort test failures",
  prompt: "Fix the 3 failing tests in agent-tool-abort.test.ts..."
})
```

### With Model Selection
```typescript
Agent({
  subagent_type: "general-purpose",
  description: "Find auth code",
  prompt: "Find all authentication-related code in src/...",
  model: "auto-fast"
})
```

### Background Dispatch
```typescript
Agent({
  subagent_type: "general-purpose",
  description: "Long-running analysis",
  prompt: "Analyze the full codebase for security issues...",
  run_in_background: true
})
```

### Prompt Templates in Skills

When a skill references a prompt template file (like `code-reviewer.md`), fill the placeholders and use as the prompt:

```typescript
Agent({
  subagent_type: "general-purpose",
  description: "Review {DESCRIPTION}",
  prompt: <filled template content>
})
```

## Notes

- `subagent_type` is required - determines capabilities
- `prompt` accepts the full task instructions as a string
- `model` parameter is optional - defaults based on subagent type
- `run_in_background` is optional - use for long-running tasks; check output with `TaskOutput`
