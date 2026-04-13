# Changelog

All notable changes to this Letta Code adaptation will be documented in this file.

## [v1.0.2] - 2026-04-13

### Fixed
- visual-companion.md: Changed `latest-click.json` → `tail -1 $STATE_DIR/events` (server writes NDJSON)
- visual-companion.md: Fixed stop-server.sh argument from `--project-dir` to `$SESSION_DIR`
- visual-companion.md: Added note explaining `state_dir` vs `SESSION_DIR` relationship
- code-quality-reviewer-prompt.md: Changed subagent_type from `explore` to `general-purpose` (needs Bash for git diff)
- brainstorming/SKILL.md: Removed non-existent `frontend-design`, `mcp-builder` references
- using-superpowers/SKILL.md: Changed skill examples to existing skills
- render-graphs.js: Changed "your human partner" → "the user"

### Impact
- Full brainstorming workflow (start server → push content → read selection → stop server) now works end-to-end

## [v1.0.1] - 2026-04-13

### Fixed
- Removed incorrect `run_in_background: true` from visual-companion.md (start-server.sh handles backgrounding via nohup)
- Updated Visual Companion documentation with accurate Note about nohup behavior and --foreground flag warning
- Changed frame-template.html header link from obra/superpowers to grayemon/letta-superpowers
- Added `**/diagrams/` to .gitignore for render-graphs.js output

### Changed
- Updated Known Limitations: Visual Companion server runs independently via nohup (not subject to 120s timeout)

## [v1.0.0] - 2026-04-13

First stable release of Letta Code adaptation.

### Added
- 14 Letta Code compatible skills
- `skills/using-superpowers/references/letta-code-tools.md` for Letta Code tool reference
- `history-analyzer` subagent type to tools reference
- `.superpowers/` to .gitignore (session files)

### Changed
- All Task() tool calls updated to Letta Code structured parameter syntax: `Task({ subagent_type, description, prompt, model })`
- Removed `superpowers:` namespace prefix from all skill references
- Updated code review workflow to use `subagent_type: "general-purpose"` (no custom agent definition needed)
- Visual Companion adapted for Letta Code with `run_in_background: true` guidance
- `docs/superpowers/specs/` → `docs/specs/` (5 skills updated)
- `docs/superpowers/plans/` → `docs/plans/` (2 skills updated)
- `~/.config/superpowers/` → `~/.config/letta-superpowers/` (config paths)

### Fixed
- Removed non-existent `"fork"` subagent type from letta-code-tools.md
- Fixed `"inherit"` model param (should omit param, not pass literal)
- Replaced Claude Code `@` file syntax with explicit Read instructions
- Removed reference to missing `.letta/INSTALL.md`
- Replaced Jesse-specific paths with generic `/home/user/` paths
- Removed Jesse person references from skill docs
- Added cloud interface caveate to Visual Companion documentation
- Removed reference to missing `elements-of-style:writing-clearly-and-concisely` skill
- Clarified `@` syntax explanation for Letta Code context
- Fixed "Lace" project reference in condition-based-waiting-example.ts

### Removed
- Platform-specific directories: `.claude-plugin/`, `.cursor-plugin/`, `.opencode/`, `.codex/`
- Platform-specific files: `hooks/`, `agents/`, `GEMINI.md`, `AGENTS.md`
- Plugin infrastructure: `scripts/bump-version.sh`, `package.json`, `.version-bump.json`
- Original contributor guidelines: `CLAUDE.md`

### Known Limitations
- Visual Companion requires local Letta Code CLI execution
- Brainstorm server runs via nohup (independent of Bash timeout)

### Credits
- Original: [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent
- Letta Code adaptation: Raymond
- Review feedback: Ezra (Letta/MemGPT Team)
