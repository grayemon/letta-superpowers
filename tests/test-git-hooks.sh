#!/usr/bin/env bash
# Tests for Superpowers git hooks
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers/test-utils.sh"

start_log

info "Testing git hooks setup..."

REPO_ROOT="$(git rev-parse --show-toplevel)"

# Test 1: Setup script runs without error
info "  Test 1: Setup script runs without error"
bash "$REPO_ROOT/skills/using-superpowers/scripts/setup-git-hooks.sh"
pass "Setup script succeeds"

# Test 2: Hook file exists and is executable
info "  Test 2: pre-commit hook exists and is executable"
HOOK="$REPO_ROOT/.githooks/pre-commit"
[[ -f "$HOOK" ]] || fail "pre-commit hook not found at $HOOK"
[[ -x "$HOOK" ]] || fail "pre-commit hook is not executable"
pass "pre-commit hook exists and is executable"

# Test 3: Hook contains Superpowers marker
info "  Test 3: Hook contains Superpowers marker"
grep -q "Superpowers" "$HOOK" || fail "Hook missing Superpowers marker"
pass "Hook contains Superpowers marker"

# Test 4: core.hooksPath is set
info "  Test 4: core.hooksPath is configured"
HOOKS_PATH="$(git config core.hooksPath)"
[[ -n "$HOOKS_PATH" ]] || fail "core.hooksPath not set"
pass "core.hooksPath is set to: $HOOKS_PATH"

# Test 5: Hook blocks commits on main (simulated)
info "  Test 5: Hook blocks commits on main branch"
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
  # We're on main — the hook should block
  if "$HOOK" 2>/dev/null; then
    fail "Hook should block commits on $CURRENT_BRANCH"
  else
    pass "Hook correctly blocks commits on $CURRENT_BRANCH"
  fi
else
  # We're on a feature branch — the hook should allow
  if "$HOOK" 2>/dev/null; then
    pass "Hook correctly allows commits on $CURRENT_BRANCH"
  else
    fail "Hook should allow commits on $CURRENT_BRANCH"
  fi
fi

# Test 6: Idempotent — running setup twice doesn't fail
info "  Test 6: Setup is idempotent"
bash "$REPO_ROOT/skills/using-superpowers/scripts/setup-git-hooks.sh"
pass "Second setup run succeeds"

# Test 7: Hook works in a subdirectory
info "  Test 7: Hook works from a subdirectory"
cd "$REPO_ROOT/skills" || fail "Cannot cd to skills/"
SUBDIR_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$SUBDIR_BRANCH" == "main" || "$SUBDIR_BRANCH" == "master" ]]; then
  if "$HOOK" 2>/dev/null; then
    fail "Hook should block from subdirectory on $SUBDIR_BRANCH"
  else
    pass "Hook blocks from subdirectory on $SUBDIR_BRANCH"
  fi
else
  if "$HOOK" 2>/dev/null; then
    pass "Hook allows from subdirectory on $SUBDIR_BRANCH"
  else
    fail "Hook should allow from subdirectory on $SUBDIR_BRANCH"
  fi
fi
cd "$REPO_ROOT"

end_log
print_summary
