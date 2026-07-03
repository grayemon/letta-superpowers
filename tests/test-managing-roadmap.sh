#!/usr/bin/env bash
# Tests for managing-roadmap skill
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers/test-utils.sh"

start_log

info "Testing managing-roadmap skill..."

REPO_ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$REPO_ROOT/skills/managing-roadmap"

# Test 1: SKILL.md exists and has valid frontmatter
info "  Test 1: SKILL.md exists with valid frontmatter"
SKILL_FILE="$SKILL_DIR/SKILL.md"
[[ -f "$SKILL_FILE" ]] || fail "SKILL.md not found at $SKILL_FILE"
head -1 "$SKILL_FILE" | grep -q "^---" || fail "SKILL.md missing YAML frontmatter opening ---"
# Check frontmatter has name and description
FRONTMATTER=$(sed -n '1,/^---$/p' "$SKILL_FILE" | tail -n +2 | head -n -1)
echo "$FRONTMATTER" | grep -q "^name: managing-roadmap" || fail "Frontmatter missing name: managing-roadmap"
echo "$FRONTMATTER" | grep -q "^description:" || fail "Frontmatter missing description field"
pass "SKILL.md has valid frontmatter"

# Test 2: Description starts with "Use when"
info "  Test 2: Description starts with 'Use when'"
DESC_LINE=$(echo "$FRONTMATTER" | grep "^description:")
echo "$DESC_LINE" | grep -q "Use when" || fail "Description should start with 'Use when'"
pass "Description starts with 'Use when'"

# Test 3: No milestone API references in skill
info "  Test 3: No GitHub milestone API calls in skill"
if grep -q "gh api.*milestones" "$SKILL_FILE"; then
  fail "SKILL.md contains gh api milestones calls — should use labels instead"
else
  pass "No milestone API calls in skill"
fi

# Test 4: Template reference file exists
info "  Test 4: references/roadmap-template.md exists"
TEMPLATE_FILE="$SKILL_DIR/references/roadmap-template.md"
[[ -f "$TEMPLATE_FILE" ]] || fail "roadmap-template.md not found at $TEMPLATE_FILE"
pass "Template reference file exists"

# Test 5: Template contains required phase structure
info "  Test 5: Template has required phase structure"
grep -q "^# Roadmap" "$TEMPLATE_FILE" || fail "Template missing '# Roadmap' header"
grep -q "^\*\*Label:\*\*" "$TEMPLATE_FILE" || fail "Template missing Label field"
grep -q "^\*\*Status:\*\*" "$TEMPLATE_FILE" || fail "Template missing Status field"
grep -q "^\*\*Issues:\*\*" "$TEMPLATE_FILE" || fail "Template missing Issues field"
pass "Template has required phase structure"

# Test 6: Template uses phase/ label convention
info "  Test 6: Template uses phase/ label convention"
grep -q 'phase/kebab-case-name' "$TEMPLATE_FILE" || fail "Template should use phase/ label convention"
pass "Template uses phase/ label convention"

# Test 7: Template has GitHub query links
info "  Test 7: Template has GitHub query links for open/closed issues"
grep -q 'is%3Aopen' "$TEMPLATE_FILE" || fail "Template missing open issues query link"
grep -q 'is%3Aclosed' "$TEMPLATE_FILE" || fail "Template missing closed issues query link"
pass "Template has GitHub query links"

# Test 8: writing-plans delegates to managing-roadmap (no inline gh api)
info "  Test 8: writing-plans delegates to managing-roadmap"
WRITING_PLANS="$REPO_ROOT/skills/writing-plans/SKILL.md"
if grep -q "gh api.*milestones" "$WRITING_PLANS"; then
  fail "writing-plans still contains gh api milestone calls"
else
  pass "writing-plans has no milestone API calls"
fi
grep -q "managing-roadmap" "$WRITING_PLANS" || fail "writing-plans should reference managing-roadmap"

# Test 9: releasing delegates to managing-roadmap (no inline gh api)
info "  Test 9: releasing delegates to managing-roadmap"
RELEASING="$REPO_ROOT/skills/releasing/SKILL.md"
if grep -q "gh api.*milestones" "$RELEASING"; then
  fail "releasing still contains gh api milestone calls"
else
  pass "releasing has no milestone API calls"
fi
grep -q "managing-roadmap" "$RELEASING" || fail "releasing should reference managing-roadmap"

# Test 10: finishing-a-development-branch uses --label not --milestone
info "  Test 10: finishing-a-development-branch uses --label not --milestone"
FINISHING="$REPO_ROOT/skills/finishing-a-development-branch/SKILL.md"
if grep -q "\-\-milestone" "$FINISHING"; then
  fail "finishing-a-development-branch still references --milestone flag"
else
  pass "finishing-a-development-branch has no --milestone references"
fi
grep -q "\-\-label phase/" "$FINISHING" || fail "finishing-a-development-branch should reference --label phase/X"

# Test 11: Skill has Integration section
info "  Test 11: Skill has Integration section"
grep -q "^## Integration" "$SKILL_FILE" || fail "SKILL.md missing Integration section"
grep -q "writing-plans" "$SKILL_FILE" || fail "Integration section should reference writing-plans"
grep -q "releasing" "$SKILL_FILE" || fail "Integration section should reference releasing"
pass "Skill has proper Integration section"

# Test 12: Skill has Quick Reference and Common Mistakes
info "  Test 12: Skill has Quick Reference and Common Mistakes"
grep -q "^## Quick Reference" "$SKILL_FILE" || fail "SKILL.md missing Quick Reference section"
grep -q "^## Common Mistakes" "$SKILL_FILE" || fail "SKILL.md missing Common Mistakes section"
pass "Skill has Quick Reference and Common Mistakes"

# Test 13: Skill describes all 5 operations
info "  Test 13: Skill describes all 5 operations"
for op in "Initialize" "Create Phase" "File Issues" "Mark Phase Complete" "View Progress"; do
  grep -q "### .*${op}" "$SKILL_FILE" || fail "SKILL.md missing operation: $op"
done
pass "All 5 operations documented"

# Test 14: Label naming convention documented
info "  Test 14: Label naming convention documented"
grep -q 'phase/.*prefix' "$SKILL_FILE" || fail "SKILL.md should document phase/ prefix convention"
grep -q 'kebab-case' "$SKILL_FILE" || fail "SKILL.md should document kebab-case naming"
pass "Label naming convention documented"

end_log
print_summary
