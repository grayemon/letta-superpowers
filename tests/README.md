# Tests for Letta Superpowers

Automated tests for brainstorming Visual Companion and other skills.

## Running Tests

```bash
# Run brainstorm server tests
bash tests/test-brainstorm-server.sh

# Or from project root:
./tests/test-brainstorm-server.sh
```

## Test Requirements

- **Node.js** - For the brainstorming server
- **curl** - For HTTP requests
- **Bash 4+** - For test scripts

## Test Structure

```
tests/
├── test-brainstorm-server.sh    # Main test script
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

## Adding New Tests

1. Create new test file following `test-*.sh` pattern
2. Source `helpers/test-utils.sh` for utilities
3. Use `pass()`, `fail()`, `info()` for output
4. Increment `TESTS_RUN` for each test
5. Call `print_summary` at end

## Troubleshooting

### Permission Denied

If scripts are not executable, run:
```bash
chmod +x tests/test-brainstorm-server.sh
```

On WSL with Windows filesystem, use:
```bash
bash tests/test-brainstorm-server.sh
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
