# Letta Code Tool Reference

Tool names and syntax for Superpowers skills in Letta Code.

## Tool Name Mapping

| Tool | Behavior |
|------|----------|
| Task | Dispatch subagent with structured params: `subagent_type`, `description`, `prompt`, `model` |
| TodoWrite | Track task progress |
| Skill | Invoke a skill |
| Read, Write, Edit, Bash, Grep, Glob | Standard file/shell operations |
| EnterPlanMode / ExitPlanMode | Plan mode workflow |

## Subagent Types

| subagent_type | Use Case | Access |
|---------------|----------|--------|
| `"general-purpose"` | Full implementation - read/write | Read/write |
| `"explore"` | Codebase search, file finding | Read-only |
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

## Task Tool Syntax

### Basic Dispatch
```typescript
Task({
  subagent_type: "general-purpose",
  description: "Fix abort test failures",
  prompt: "Fix the 3 failing tests in agent-tool-abort.test.ts..."
})
```

### With Model Selection
```typescript
Task({
  subagent_type: "explore",
  description: "Find auth code",
  prompt: "Find all authentication-related code in src/...",
  model: "auto-fast"
})
```

### Prompt Templates in Skills

When a skill references a prompt template file (like `code-reviewer.md`), fill the placeholders and use as the prompt:

```typescript
Task({
  subagent_type: "general-purpose",
  description: "Review {DESCRIPTION}",
  prompt: <filled template content>
})
```

## Notes

- `subagent_type` is required - determines capabilities
- `prompt` accepts the full task instructions as a string
- Use `"explore"` for read-only subagents
- `model` parameter is optional - defaults based on subagent type
