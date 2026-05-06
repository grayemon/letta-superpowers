#!/usr/bin/env bash
# One-time setup of Superpowers git hooks
# Idempotent — safe to run multiple times
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"

if [[ -z "$REPO_ROOT" ]]; then
  echo "Not a git repository. Skipping git hooks setup."
  exit 0
fi

HOOKS_DIR="$REPO_ROOT/.githooks"
PRE_COMMIT="$HOOKS_DIR/pre-commit"

# Check if our hook is already installed
if [[ -f "$PRE_COMMIT" ]] && grep -q "Superpowers" "$PRE_COMMIT" 2>/dev/null; then
  # Already installed, just ensure hooksPath is set
  git config core.hooksPath "$HOOKS_DIR" 2>/dev/null || true
  exit 0
fi

# Create .githooks directory and install hook
mkdir -p "$HOOKS_DIR"
cat > "$PRE_COMMIT" << 'HOOK'
#!/usr/bin/env bash
# Superpowers: Prevent accidental commits to main/master branches
# Installed by using-superpowers skill on first invocation

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  cat >&2 <<EOF
⛔ Direct commits to '$branch' are blocked by Superpowers.

Use a feature branch instead:
  git checkout -b feature/your-feature-name

Or use the using-git-worktrees skill for isolated development.
EOF
  exit 1
fi

exit 0
HOOK

chmod +x "$PRE_COMMIT"

# Set hooksPath to our directory
git config core.hooksPath "$HOOKS_DIR"

echo "✅ Superpowers git hooks installed. Commits to main/master are now blocked."
