# Visual Companion for Letta Code

A browser-based companion for showing mockups, diagrams, and visual options during brainstorming sessions.

## How It Works

1. **Start the server** via Bash tool
2. **User opens URL** in their browser
3. **Agent pushes content** to the browser via file system
4. **User clicks choices** and returns to terminal
5. **Agent reads selection** from server state

## Starting the Server

```bash
# Start the brainstorm server
./skills/brainstorming/scripts/start-server.sh --project-dir /path/to/project

# Returns JSON with URL:
# {"url": "http://localhost:53124", "pid": 12345, "screen_dir": "/path/to/project/.superpowers/brainstorm/session-id/content"}
```

**Options:**
- `--project-dir <path>` - Store session files in project (persists after server stops)
- `--host <bind-host>` - Bind to specific interface (default: 127.0.0.1)
- `--url-host <host>` - Hostname shown in URL
- `--foreground` - Run in foreground (for environments that reap background processes)

> **Warning:** Letta Code's Bash tool has a 120-second hard timeout even for background processes. The server may be killed after 2 minutes. For longer sessions, consider starting the server manually outside of Letta Code, or be prepared to restart it.

## Pushing Content

Write HTML files to the `screen_dir` returned by start-server.sh:

```bash
# Write a screen
cat > "$SCREEN_DIR/01-options.html" << 'EOF'
<h2>Choose an approach</h2>
<div class="options">
  <div class="option" data-choice="A" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Microservices</h3>
      <p>Independent services, maximum flexibility</p>
    </div>
  </div>
  <div class="option" data-choice="B" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>Monolith</h3>
      <p>Simpler deployment, easier development</p>
    </div>
  </div>
</div>
EOF
```

The browser auto-reloads when new files are written.

## Reading User Selection

Read the state file to get the user's choice:

```bash
# Read the latest click event
cat "$STATE_DIR/latest-click.json"

# Returns:
# {"type":"click","text":"Microservices","choice":"A","timestamp":1712345678901}
```

## Stopping the Server

```bash
./skills/brainstorming/scripts/stop-server.sh --project-dir /path/to/project
```

## UI Components

The frame template provides pre-styled components:

### Options (A/B/C choices)
```html
<div class="options">
  <div class="option" data-choice="A" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Option Title</h3>
      <p>Option description</p>
    </div>
  </div>
</div>
```

### Cards (for showing designs/mockups)
```html
<div class="cards">
  <div class="card" data-choice="design1" onclick="toggleSelect(this)">
    <div class="card-image">
      <img src="mockup.png" />
    </div>
    <div class="card-body">
      <h3>Design 1</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

### Mockup Container
```html
<div class="mockup">
  <div class="mockup-header">App Header</div>
  <div class="mockup-body">
    <!-- Your mockup content -->
  </div>
</div>
```

### Split View (side-by-side)
```html
<div class="split">
  <div class="mockup">
    <div class="mockup-header">Option A</div>
    <div class="mockup-body">...</div>
  </div>
  <div class="mockup">
    <div class="mockup-header">Option B</div>
    <div class="mockup-body">...</div>
  </div>
</div>
```

### Pros/Cons
```html
<div class="pros-cons">
  <div class="pros">
    <h4>Pros</h4>
    <ul><li>Advantage 1</li><li>Advantage 2</li></ul>
  </div>
  <div class="cons">
    <h4>Cons</h4>
    <ul><li>Disadvantage 1</li><li>Disadvantage 2</li></ul>
  </div>
</div>
```

## Complete Example

**1. Start server:**
```typescript
Bash({
  command: "cd /path/to/project && ./skills/brainstorming/scripts/start-server.sh --project-dir $(pwd)",
  description: "Start brainstorm visual companion server",
  run_in_background: true  // REQUIRED - server needs to run indefinitely
})
```

**2. Tell user to open URL:**
> "I've started a visual companion at http://localhost:53124 - please open that URL in your browser."

**3. Push content:**
```bash
Bash({
  command: "cat > $SCREEN_DIR/01-approach.html << 'EOF'
<h2>Choose your architecture</h2>
<p class=\"subtitle\">Which approach fits your needs?</p>
<div class=\"options\">
  <div class=\"option\" data-choice=\"microservices\" onclick=\"toggleSelect(this)\">
    <div class=\"letter\">A</div>
    <div class=\"content\">
      <h3>Microservices</h3>
      <p>Independent services, maximum flexibility, complex ops</p>
    </div>
  </div>
  <div class=\"option\" data-choice=\"monolith\" onclick=\"toggleSelect(this)\">
    <div class=\"letter\">B</div>
    <div class=\"content\">
      <h3>Modular Monolith</h3>
      <p>Simpler deployment, easier development, less flexibility</p>
    </div>
  </div>
</div>
EOF",
  description: "Push architecture options to visual companion"
})
```

**4. Wait for user:**
> "Click your choice in the browser, then return here and type 'done'."

**5. Read selection:**
```bash
Bash({
  command: "cat $STATE_DIR/latest-click.json",
  description: "Read user's visual companion selection"
})
```

**6. Stop server (optional):**
```bash
Bash({
  command: "./skills/brainstorming/scripts/stop-server.sh --project-dir $(pwd)",
  description: "Stop brainstorm visual companion server"
})
```

## Tips

- **One visual per question** - Don't overwhelm the user
- **Clear choices** - Use data-choice values that are easy to parse
- **Clean up** - Stop the server when done if using /tmp
- **Persist sessions** - Use --project-dir for important sessions
- **Auto-reload** - Browser reloads when you write new files
