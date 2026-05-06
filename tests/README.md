# Tests for Letta Superpowers

Automated tests for brainstorming Visual Companion, git hooks, and other skills.

## Running Tests

```bash
# Run brainstorm server tests
bash tests/test-brainstorm-server.sh

# Run git hooks tests
bash tests/test-git-hooks.sh

# Or from project root:
./tests/test-brainstorm-server.sh
./tests/test-git-hooks.sh
```

## Test Requirements

- **Node.js** - For the brainstorming server
- **curl** - For HTTP requests
- **Bash 4+** - For test scripts
- **Git** - For git hooks tests

## Test Structure

```
tests/
├── test-brainstorm-server.sh    # Brainstorm server tests
├── test-git-hooks.sh            # Git hooks tests
├── fixtures/
│   └── sample-options.html      # Test HTML content
├── helpers/
│   └── test-utils.sh            # Shared test utilities
└── README.md                    # This file
```

## What Gets Tested

### Brainstorm Server (`test-brainstorm-server.sh`)

| Test | Description |
|------|-------------|
| Prerequisites | Node.js and curl available |
| Server Startup | start-server.sh returns valid JSON |
| HTTP Waiting | Server responds with waiting page |
| Content Push | Content files are served correctly |
| Frame Template | helper.js injection works |
| Server Shutdown | stop-server.sh cleans up properly |

### Git Hooks (`test-git-hooks.sh`)

| Test | Description |
|------|-------------|
| Setup script | Runs without error |
| Hook exists | pre-commit hook file exists and is executable |
| Superpowers marker | Hook contains "Superpowers" identifier |
| hooksPath | core.hooksPath is configured |
| Branch blocking | Hook blocks commits on main/master |
| Idempotent | Second setup run succeeds |
| Subdirectory | Hook works from a subdirectory |

## Adding New Tests

1. Create new test file following `test-*.sh` pattern
2. Source `helpers/test-utils.sh` for utilities
3. Use `pass()`, `fail()`, `info()` for output
4. Call `print_summary` at end

## Troubleshooting

### Permission Denied

If scripts are not executable, run:
```bash
chmod +x tests/test-brainstorm-server.sh
chmod +x tests/test-git-hooks.sh
```

On WSL with Windows filesystem, use:
```bash
bash tests/test-brainstorm-server.sh
bash tests/test-git-hooks.sh
```

### Server Won't Start

Check Node.js is installed:
```bash
node --version
```

Check port availability:
```bash
# Kill any lingering servers
pkill -f "node server.cjs"
```
