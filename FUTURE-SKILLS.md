# Future Skills TODO

> **Status:** NOT TO BE IMPLEMENTED NOW. This is a planning document for future skill development.

Identified gaps from the letta-superpowers skillset audit (2026-04-20).

---

## HIGH Priority

### 1. `documentation-writing`
**Workflow:** Write → Review → Publish docs

**Coverage Gap:**
- `brainstorming` writes design docs/specs
- `releasing` handles release notes/changelog
- Missing: User guides, README updates, API docs, general documentation workflow

**Use Cases:**
- Writing user-facing documentation
- Updating README files
- Creating API documentation
- Documentation review/edit/publish workflow

---

### 2. `merge-conflict-resolution` ✅ IMPLEMENTED
**Status:** Implemented in v1.5.0. See `skills/merge-conflict-resolution/SKILL.md`.

---

## MEDIUM Priority

### 3. `dependency-updates`
**Workflow:** Bump → Test → Fix → Release

**Coverage Gap:**
- Testing/verifying are covered by TDD and verification-before-completion
- Missing: Dependency update-specific workflow

**Use Cases:**
- Dependency bump planning
- Compatibility checks
- Lockfile/package manager handling
- Security/semantic version considerations
- Migration notes

---

### 4. `project-environment-setup`
**Workflow:** Bootstrap new project

**Coverage Gap:**
- `using-git-worktrees` has project setup auto-detection
- Missing: Full project bootstrap workflow

**Use Cases:**
- Clone repo
- Install dependencies
- Configure env vars/secrets
- Run first test/build
- Initialize local services
- Developer onboarding checklist

---

### 5. `local-vs-ci-testing`
**Workflow:** What to run locally vs CI

**Coverage Gap:**
- Skills mention running tests but not local-vs-CI distinctions

**Use Cases:**
- What to run locally
- What to rely on CI for
- Fast smoke vs full suite
- Flaky test handling
- CI failure triage

---

## LOW Priority

### 6. `tech-debt-triage`
**Workflow:** Identify → Prioritize → Address → Verify

**Coverage Gap:**
- Identifying issues can be done via debugging/exploration
- Missing: Tech debt triage/prioritization skill

**Use Cases:**
- Distinguish tech debt from feature work
- Create remediation plans
- Debt registers
- Staged cleanup

---

### 7. `refactoring-workflow`
**Workflow:** Safe incremental refactors

**Coverage Gap:**
- Refactoring covered by TDD implicitly
- Missing: Dedicated refactoring workflow

**Use Cases:**
- Safe incremental refactoring
- Large-scale code reorganization
- Preserving behavior during refactors

---

### 8. `incident-response`
**Workflow:** Hotfix → Deploy → Rollback

**Coverage Gap:**
- Hotfix coding covered by debugging + TDD
- Missing: Deployment and incident response

**Use Cases:**
- Emergency hotfix workflow
- Deployment verification
- Rollback procedures
- Incident communications

---

## Implementation Notes

When implementing these skills, follow the patterns established in existing skills:
- YAML frontmatter with `name` and `description`
- Clear "When to Use" section
- Step-by-step process
- Cross-references to related skills
- Supporting files (templates, references) as needed
