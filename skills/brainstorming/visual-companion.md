# Visual Companion for Letta Code

A browser-based companion for showing mockups, diagrams, and visual options during brainstorming sessions.

## How It Works

1. **Start the server** via Bash tool
2. **User opens URL** in their browser
3. **Agent pushes content** to the browser via file system
4. **User clicks choices** → Continue button appears
5. **User clicks Continue** → Agent receives "done" event
6. **Agent reads selection** from server state

## Starting the Server

```bash
# Start the brainstorm server
./skills/brainstorming/scripts/start-server.sh --project-dir /path/to/project

# Returns JSON with URL:
# {"url": "http://localhost:53124", "pid": 12345, "state_dir": "/path/to/project/.superpowers/brainstorm/session-id/state", "screen_dir": "/path/to/project/.superpowers/brainstorm/session-id/content"}
#
# Note: state_dir is $STATE_DIR (contains events file), its parent is $SESSION_DIR (needed for stop-server.sh)
```

**Options:**
- `--project-dir <path>` - Store session files in project (persists after server stops)
- `--host <bind-host>` - Bind to specific interface (default: 127.0.0.1)
- `--url-host <host>` - Hostname shown in URL
- `--foreground` - Run in foreground (for environments that reap background processes)

> **Note:** The server starts via nohup and runs independently. The start script exits within seconds, returning a JSON object with the server URL and paths. The --foreground flag should NOT be used with Letta Code Bash tool, as it would block until the 120-second timeout kills the process.

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

## Waiting for User Selection

The Continue button appears automatically when user makes a selection. Use `wait_for_done` to block until the user clicks Continue:

```bash
# Wait for user to click Continue (polls events file)
# Usage: wait_for_done "$STATE_DIR"
wait_for_done() {
    local state_dir="$1"
    local events_file="$state_dir/events"
    local timeout=300  # 5 minutes
    local elapsed=0
    
    while [[ $elapsed -lt $timeout ]]; do
        if [[ -f "$events_file" ]]; then
            local last_event
            last_event=$(tail -1 "$events_file" 2>/dev/null)
            if echo "$last_event" | grep -q '"type":"done"'; then
                echo "$last_event"
                return 0
            fi
        fi
        sleep 1
        ((elapsed++))
    done
    
    echo '{"error": "timeout waiting for user selection"}'
    return 1
}

# Usage:
selection=$(wait_for_done "$STATE_DIR")
```

**Event format:**
```json
{
  "type": "done",
  "choice": "microservices",
  "selections": ["microservices"],
  "text": "Microservices",
  "timestamp": 1712345678901
}
```

## Reading User Selection (Legacy)

For backward compatibility, you can still read click events directly:

```bash
# Read the latest click event
tail -1 "$STATE_DIR/events"

# Returns:
# {"type":"click","text":"Microservices","choice":"A","timestamp":1712345678901}
```

## Stopping the Server

```bash
./skills/brainstorming/scripts/stop-server.sh "$SESSION_DIR"
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
```bash
cd /path/to/project && ./skills/brainstorming/scripts/start-server.sh --project-dir $(pwd)
# Parse output to get SERVER_URL, SCREEN_DIR, STATE_DIR, SESSION_DIR
```

**2. Tell user to open URL:**
> "I've started a visual companion at http://localhost:53124 - please open that URL in your browser."

**3. Push content:**
```bash
cat > "$SCREEN_DIR/01-approach.html" << 'EOF'
<h2>Choose your architecture</h2>
<p class="subtitle">Which approach fits your needs?</p>
<div class="options">
  <div class="option" data-choice="microservices" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Microservices</h3>
      <p>Independent services, maximum flexibility, complex ops</p>
    </div>
  </div>
  <div class="option" data-choice="monolith" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>Modular Monolith</h3>
      <p>Simpler deployment, easier development, less flexibility</p>
    </div>
  </div>
</div>
EOF
```

**4. Wait for selection (polls until user clicks Continue):**
```bash
# Block until user clicks Continue button
selection=$(wait_for_done "$STATE_DIR")

# Parse the result
choice=$(echo "$selection" | grep -o '"choice":"[^"]*"' | cut -d'"' -f4)
echo "User chose: $choice"
```

**5. Stop server (optional):**
```bash
./skills/brainstorming/scripts/stop-server.sh "$SESSION_DIR"
```

## Tips

- **One visual per question** - Don't overwhelm the user
- **Clear choices** - Use data-choice values that are easy to parse
- **Clean up** - Stop the server when done if using /tmp
- **Persist sessions** - Use --project-dir for important sessions
- **Auto-reload** - Browser reloads when you write new files
- **Continue button** - Appears automatically when user makes a selection
