Emz  — Yesterday at 8:32 AM
@Ezra here is the url of my repo that I forked from obra/superpowers "<https://github.com/grayemon/letta-superpowers.git>". I vibecoded using a letta code agent to make some tweaks and adjustments to contents of the skills folder. My goal is to make the skills seamless to letta code agents workflow and architecture. Now I need you to explore the my repo to identify gaps and potential issues, Suggest fixes to it and give a review.
EzraRole icon, Letta / MemGPT Team
APP
 — Yesterday at 8:33 AM
Running
Clone Emz's forked letta-superpowers repo
Running
Clone original obra/superpowers repo for comparison
Running
find /private/tmp/letta-superpowers -type f | head -80
Running
cd /private/tmp/letta-superpowers && git log --oneline -20
Running
Diff between fork and original to see what changed
Running
cd /private/tmp/letta-superpowers && git diff HEAD~1..HEAD --stat
Reading
/private/tmp/letta-superpowers/skills/using-superpowers/SKILL.md
Reading
/private/tmp/letta-superpowers/skills/dispatching-parallel-agents/SKILL.md
Reading
/private/tmp/letta-superpowers/skills/executing-plans/SKILL.md
Reading
/private/tmp/letta-superpowers/skills/subagent-driven-development/SKILL.md
Reading
/private/tmp/letta-superpowers/skills/using-superpowers/references/letta-code-tools.md
Reading
/private/tmp/letta-superpowers/skills/writing-skills/SKILL.md
Reading
/private/tmp/letta-superpowers/skills/writing-skills/skill-authoring-best-practices.md
Reading
/private/tmp/letta-superpowers/skills/test-driven-development/SKILL.md
Reading
/private/tmp/letta-superpowers/skills/systematic-debugging/SKILL.md
Reading
/private/tmp/letta-superpowers/skills/finishing-a-development-branch/SKILL.md
Reading
/private/tmp/letta-superpowers/skills/verification-before-completion/SKILL.md
Reading
/private/tmp/letta-superpowers/skills/using-git-worktrees/SKILL.md
Reading
/private/tmp/letta-superpowers/skills/receiving-code-review/SKILL.md
Reading
/private/tmp/letta-superpowers/skills/requesting-code-review/SKILL.md
Reading
/private/tmp/letta-superpowers/skills/brainstorming/SKILL.md
Reading
/private/tmp/letta-superpowers/maintenance/SYNC-SKILL.md
Reading
/private/tmp/letta-superpowers/maintenance/README.md
Reading
/private/tmp/letta-superpowers/skills/writing-plans/SKILL.md
Reading
/private/tmp/letta-superpowers/skills/subagent-driven-development/implementer-prompt.md
Reading
/private/tmp/letta-superpowers/skills/requesting-code-review/code-reviewer.md
Reading
/private/tmp/letta-superpowers/README.md
Searching files
@[a-z].*.md
Searching files
Jesse|jesse|Claude Code|Codex|Cursor|CLAUDE.md|.claude
Searching files
superpowers:
Searching files
.letta/INSTALL.md|.letta/rules.md
Running
Check if .letta directory exists in the repo
Searching files
elements-of-style|writing-clearly
Searching files
fork
I've read through the entire repo, compared it against the upstream obra/superpowers, and checked every skill for Letta Code compatibility. Here's the review.

Overall: Solid adaptation. The major mechanical work is done -- Task() syntax, platform-specific file removal, SYNC-SKILL.md for ongoing maintenance. The skill content itself is high quality. Below are the issues I found, ordered by severity.

---

Critical -- will cause agent failures:

"fork" subagent_type doesn't exist in Letta Code

skills/using-superpowers/references/letta-code-tools.md line 21 lists "fork" as a valid subagent_type. Letta Code only supports: explore, general-purpose, history-analyzer, init, memory, recall, reflection. An agent trying subagent_type: "fork" will get an error. Remove it from the table.

@filename syntax from Claude Code survives in 2 places

In Claude Code, @file.md force-loads a file into context. Letta Code has no @ directive -- these references will be treated as literal text and the agent won't load the files:
skills/test-driven-development/SKILL.md:376 -- read @testing-anti-patterns.md
skills/writing-skills/SKILL.md:605 -- See @testing-skills-with-subagents.md

Fix: Change to Read testing-anti-patterns.md or explicit instructions like "Read the file testing-anti-patterns.md in this directory."

.letta/INSTALL.md referenced but missing

README line 28 says "See .letta/INSTALL.md for detailed installation options." No .letta/ directory exists in the repo. Either create the file or remove the reference.

---

Important -- causes incorrect behavior or confusion:
"inherit" model param is wrong

letta-code-tools.md line 33 lists "inherit" as a model param. In Letta Code, you don't pass model: "inherit" -- you simply omit the model parameter and it inherits from the parent. Passing the literal string "inherit" would attempt model handle resolution and fail. Fix the table entry to say "omit model param" instead.

Jesse-specific references remain (3 places)

skills/using-git-worktrees/SKILL.md:65 -- Per Jesse's rule "Fix broken things immediately" -- a Letta agent won't know who Jesse is or have his project rules
skills/systematic-debugging/root-cause-tracing.md:38 -- /Users/jesse/project/packages/core in an example path
skills/using-git-worktrees/SKILL.md:191 -- /Users/jesse/myproject/.worktrees/auth in an example

Replace "Jesse's rule" with just the principle directly, and swap example paths to generic ones.

Visual Companion may not work outside local CLI

The brainstorming skill's Visual Companion starts a local HTTP server (scripts/start-server.sh). This works when the agent runs via letta CLI on the user's machine. It will NOT work for users chatting via Cloud ADE, chat.letta.com, or LettaBot on a remote server. Worth adding a note in the brainstorming skill: "Visual Companion requires local execution (Letta Code CLI). Not available when running via cloud interfaces."

elements-of-style:writing-clearly-and-concisely referenced but not included

skills/brainstorming/SKILL.md:113 references this skill with a superpowers: namespace format ("Use elements-of-style:writing-clearly-and-concisely skill if available"). The skill doesn't exist in the repo. Either remove the reference or add the skill.

---

Minor -- polish and consistency:
.letta/rules.md referenced as a convention

skills/writing-skills/SKILL.md:60 and skills/using-git-worktrees/SKILL.md:34 reference .letta/rules.md for project-specific rules. This is actually a valid Letta Code convention (project rules can go there), so this is fine. Just confirming it checks out.

docs/superpowers/ path hardcoded

Brainstorming saves specs to docs/superpowers/specs/, writing-plans saves to docs/superpowers/plans/. The skills do note "User preferences override this default" which is good. Just be aware users may be confused by the superpowers/ subdirectory name in a non-superpowers project.

writing-skills/SKILL.md line 315 uses @ in a bad-example context

Line 315: @skills/testing/test-driven-development/SKILL.md -- this is inside a "Bad" example showing what NOT to do. The framing is correct since it warns against force-loading. But the explanation "force-loads files immediately" is Claude Code behavior -- Letta Code wouldn't force-load anything, the @ would just be literal text. The warning is still directionally right (don't paste full file contents), but the mechanism described is wrong for Letta Code.

---

What's done well:
Task() syntax correctly converted to { subagent_type, description, prompt } throughout
All platform-specific files cleanly removed (hooks/, agents/, scripts/, .claude-plugin/, .codex/, etc.)
SYNC-SKILL.md is a smart addition for ongoing maintenance
Skill frontmatter (name, description) matches Letta Code's SKILL.md format
Subagent prompt templates (implementer, spec-reviewer, code-quality-reviewer) are well-structured for Letta Code's Task tool
superpowers: namespace prefix fully cleaned out from all skills
letta-code-tools.md reference is a useful addition (just needs the fork/inherit fixes)
Known:
All issues above are confirmed by reading the source
Letta Code subagent_type list verified against current Letta Code v0.19.5 tool definitions
@ file-loading behavior verified as Claude Code specific, not Letta Code

Unknown:
Whether the visual companion server scripts work correctly on all platforms under Letta Code's Bash tool (I didn't test-run them)
Whether obra/superpowers has shipped new skills since your fork point that you'd want to sync
