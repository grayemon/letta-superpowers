# Skill Authoring Best Practices

> Learn how to write effective Skills that agents can discover and use successfully.

Good Skills are concise, well-structured, and tested with real usage. This guide provides practical authoring decisions to help you write Skills that agents can use effectively.

## Core Principles

### Concise is Key

The context window is a public good. Your Skill shares the context window with everything else the agent needs to know, including:

- The system prompt
- Conversation history
- Other Skills' metadata
- Your actual request

Not every token in your Skill has an immediate cost. At startup, only the metadata (name and description) from all Skills is pre-loaded. The agent reads SKILL.md only when the Skill becomes relevant, and reads additional files only as needed. However, being concise in SKILL.md still matters: once loaded, every token competes with conversation history and other context.

**Default assumption**: The agent is already very capable

Only add context the agent doesn't already have. Challenge each piece of information:

- "Does the agent really need this explanation?"
- "Can I assume the agent knows this?"
- "Does this paragraph justify its token cost?"

**Good example: Concise** (approximately 50 tokens):

````markdown
## Extract PDF text

Use pdfplumber for text extraction:

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

**Bad example: Too verbose** (approximately 150 tokens):

```markdown
## Extract PDF text

PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library. There are many libraries available for PDF processing, but we
recommend pdfplumber because it's easy to use and handles most cases well.
First, you'll need to install it using pip. Then you can use the code below...
```

The concise version assumes the agent knows what PDFs are and how libraries work.

### Set Appropriate Degrees of Freedom

Match the level of specificity to the task's fragility and variability.

**High freedom** (text-based instructions):

Use when:

- Multiple approaches are valid
- Decisions depend on context
- Heuristics guide the approach

**Medium freedom** (pseudocode or scripts with parameters):

Use when:

- A preferred pattern exists
- Some variation is acceptable
- Configuration affects behavior

**Low freedom** (specific scripts, few or no parameters):

Use when:

- Operations are fragile and error-prone
- Consistency is critical
- A specific sequence must be followed

**Analogy**: Think of the agent as a robot exploring a path:

- **Narrow bridge with cliffs on both sides**: There's only one safe way forward. Provide specific guardrails and exact instructions (low freedom).
- **Open field with no hazards**: Many paths lead to success. Give general direction and trust the agent to find the best route (high freedom).

## Skill Structure

### Naming Conventions

Use consistent naming patterns to make Skills easier to reference and discuss. Use **gerund form** (verb + -ing) for Skill names.

**Good naming examples (gerund form)**:

- "Processing PDFs"
- "Analyzing spreadsheets"
- "Managing databases"
- "Testing code"
- "Writing documentation"

**Avoid**:

- Vague names: "Helper", "Utils", "Tools"
- Overly generic: "Documents", "Data", "Files"

### Writing Effective Descriptions

The `description` field enables Skill discovery and should include both what the Skill does and when to use it.

**Always write in third person**. The description is injected into the system prompt.

- **Good:** "Processes Excel files and generates reports"
- **Avoid:** "I can help you process Excel files"
- **Avoid:** "You can use this to process Excel files"

**Be specific and include key terms**. Include both what the Skill does and specific triggers/contexts for when to use it.

### Progressive Disclosure Patterns

SKILL.md serves as an overview that points to detailed materials as needed. Keep SKILL.md body under 500 lines for optimal performance.

**Pattern 1: High-level guide with references**

```markdown
## Quick start

Extract text with pdfplumber: [code example]

## Advanced features

**Form filling**: See [FORMS.md](FORMS.md) for complete guide
**API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
```

**Pattern 2: Domain-specific organization**

```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md (revenue metrics)
    ├── sales.md (pipeline data)
    └── product.md (usage analytics)
```

**Pattern 3: Conditional details**

```markdown
## Creating documents

Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).

## Editing documents

For simple edits, modify the XML directly.
**For tracked changes**: See [REDLINING.md](REDLINING.md)
```

### Avoid Deeply Nested References

Keep references one level deep from SKILL.md. All reference files should link directly from SKILL.md.

## Workflows and Feedback Loops

### Use Workflows for Complex Tasks

Break complex operations into clear, sequential steps. Provide a checklist that the agent can track.

**Example: Research synthesis workflow**

```markdown
## Research synthesis workflow

Copy this checklist and track your progress:

Task Progress:
- [ ] Step 1: Read all source documents
- [ ] Step 2: Identify key themes
- [ ] Step 3: Cross-reference claims
- [ ] Step 4: Create structured summary
- [ ] Step 5: Verify citations
```

### Implement Feedback Loops

**Common pattern**: Run validator → fix errors → repeat

This pattern greatly improves output quality.

## Content Guidelines

### Avoid Time-Sensitive Information

Don't include information that will become outdated. Use "old patterns" sections for historical context.

### Use Consistent Terminology

Choose one term and use it throughout the Skill:

- ✓ Good: Always "API endpoint", always "field", always "extract"
- ✗ Bad: Mix "API endpoint", "URL", "API route", "path"

## Common Patterns

### Template Pattern

Provide templates for output format. Match the level of strictness to your needs.

### Examples Pattern

For Skills where output quality depends on seeing examples, provide input/output pairs.

### Conditional Workflow Pattern

Guide the agent through decision points:

```markdown
## Document modification workflow

1. Determine the modification type:
   **Creating new content?** → Follow "Creation workflow"
   **Editing existing content?** → Follow "Editing workflow"
```

## Anti-Patterns to Avoid

### Avoid Windows-Style Paths

Always use forward slashes in file paths, even on Windows:

- ✓ **Good**: `scripts/helper.py`, `reference/guide.md`
- ✗ **Avoid**: `scripts\helper.py`, `reference\guide.md`

### Avoid Offering Too Many Options

Don't present multiple approaches unless necessary:

- **Bad**: "You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image, or..."
- **Good**: "Use pdfplumber for text extraction. For scanned PDFs requiring OCR, use pdf2image with pytesseract instead."

## Skills with Executable Code

### Solve, Don't Punt

When writing scripts for Skills, handle error conditions rather than punting to the agent.

**Good example: Handle errors explicitly**:

```python
def process_file(path):
    """Process a file, creating it if it doesn't exist."""
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        print(f"File {path} not found, creating default")
        with open(path, 'w') as f:
            f.write('')
        return ''
```

**Bad example: Punt to agent**:

```python
def process_file(path):
    # Just fail and let agent figure it out
    return open(path).read()
```

### Provide Utility Scripts

Even if the agent could write a script, pre-made scripts offer advantages:

- More reliable than generated code
- Save tokens (no need to include code in context)
- Save time (no code generation required)
- Ensure consistency across uses

### Create Verifiable Intermediate Outputs

When performing complex tasks, use the "plan-validate-execute" pattern:

1. Create a plan in a structured format
2. Validate the plan with a script
3. Execute the validated plan

This catches errors early.

## Checklist for Effective Skills

Before sharing a Skill, verify:

### Core Quality

- [ ] Description is specific and includes key terms
- [ ] Description includes both what the Skill does and when to use it
- [ ] SKILL.md body is under 500 lines
- [ ] Additional details are in separate files (if needed)
- [ ] No time-sensitive information (or in "old patterns" section)
- [ ] Consistent terminology throughout
- [ ] Examples are concrete, not abstract
- [ ] File references are one level deep
- [ ] Progressive disclosure used appropriately
- [ ] Workflows have clear steps

### Code and Scripts

- [ ] Scripts solve problems rather than punt to agent
- [ ] Error handling is explicit and helpful
- [ ] No "voodoo constants" (all values justified)
- [ ] Required packages listed in instructions
- [ ] Scripts have clear documentation
- [ ] No Windows-style paths (all forward slashes)
- [ ] Validation/verification steps for critical operations
- [ ] Feedback loops included for quality-critical tasks
