# Changelog

All notable changes to this Letta Code adaptation will be documented in this file.

## [Letta-1.0.0] - 2026-04-09

### Added
- Letta Code compatible skill set
- `.letta/INSTALL.md` for easy installation instructions
- `skills/using-superpowers/references/letta-code-tools.md` for Letta Code tool reference

### Changed
- All Task() tool calls updated to Letta Code structured parameter syntax: `Task({ subagent_type, description, prompt, model })`
- Removed `superpowers:` namespace prefix from all skill references
- Updated code review workflow to use `subagent_type: "general-purpose"` (no custom agent definition needed)
- Visual Companion adapted for Letta Code

### Removed
- Platform-specific directories: `.claude-plugin/`, `.cursor-plugin/`, `.opencode/`, `.codex/`
- Platform-specific files: `hooks/`, `agents/`, `GEMINI.md`, `AGENTS.md`
- Platform-specific docs: `docs/`, `RELEASE-NOTES.md`, `ezra-discord-chat.md`
- Plugin infrastructure: `scripts/bump-version.sh`, `package.json`, `.version-bump.json`
- Original contributor guidelines: `CLAUDE.md`

### Original Project

This is a Letta Code port of [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent.

For the original project's history and release notes, see the upstream repository.
