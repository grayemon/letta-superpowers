#!/usr/bin/env bash
# Test script for brainstorming Visual Companion server
# Usage: bash tests/test-brainstorm-server.sh [--project-dir /path/to/project]
#
# Tests:
#   1. Prerequisites check (Node.js, curl)
#   2. Server startup
#   3. HTTP waiting page
#   4. Content push and serving
#   5. Server shutdown
#   6. Cleanup

set -euo pipefail

# Resolve script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source test utilities
source "$SCRIPT_DIR/helpers/test-utils.sh"

# Parse arguments
PROJECT_DIR=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --project-dir)
            PROJECT_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Usage: $0 [--project-dir /path/to/project]"
            exit 1
            ;;
    esac
done

# Default to project root if not specified
PROJECT_DIR="${PROJECT_DIR:-$PROJECT_ROOT}"

# Set up cleanup trap
trap cleanup_on_exit EXIT

echo "====================================="
echo "Brainstorm Visual Companion Tests"
echo "====================================="
echo ""

# ========================================
# Test 1: Prerequisites
# ========================================
echo "--- Test 1: Prerequisites ---"
TESTS_RUN=$((TESTS_RUN + 1))
if check_prerequisites; then
    pass "Prerequisites check"
else
    fail "Prerequisites check"
    print_summary
    exit 1
fi

# ========================================
# Test 2: Server Startup
# ========================================
echo ""
echo "--- Test 2: Server Startup ---"
TESTS_RUN=$((TESTS_RUN + 1))
if start_brainstorm_server "$PROJECT_DIR"; then
    pass "Server startup"

    # Verify server directory structure
    if [[ -d "$SCREEN_DIR" && -d "$STATE_DIR" ]]; then
        pass "Directory structure created"
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        fail "Directory structure" "SCREEN_DIR=$SCREEN_DIR, STATE_DIR=$STATE_DIR"
        TESTS_RUN=$((TESTS_RUN + 1))
    fi
else
    fail "Server startup"
    print_summary
    exit 1
fi

# ========================================
# Test 3: HTTP Waiting Page
# ========================================
echo ""
echo "--- Test 3: HTTP Waiting Page ---"
TESTS_RUN=$((TESTS_RUN + 1))
if wait_for_server "$SERVER_URL"; then
    pass "Server responding"

    # Check that waiting page is served
    TESTS_RUN=$((TESTS_RUN + 1))
    response=$(curl -s "$SERVER_URL") || {
        fail "HTTP request failed"
    }

    if echo "$response" | grep -q "Brainstorm Companion"; then
        pass "Waiting page content"
    else
        fail "Waiting page content" "Expected 'Brainstorm Companion' in response"
    fi
else
    fail "HTTP waiting page" "Server not responding"
fi

# ========================================
# Test 4: Content Push and Serving
# ========================================
echo ""
echo "--- Test 4: Content Push ---"
TESTS_RUN=$((TESTS_RUN + 1))

# Copy fixture to screen directory
fixture="$SCRIPT_DIR/fixtures/sample-options.html"
dest_file="$SCREEN_DIR/01-test.html"

if [[ ! -f "$fixture" ]]; then
    fail "Fixture not found" "$fixture"
    print_summary
    exit 1
fi

cp "$fixture" "$dest_file" || {
    fail "Failed to copy fixture"
    print_summary
    exit 1
}

info "Content pushed to $dest_file"

# Wait a moment for file watcher
sleep 0.5

# Verify content is served
TESTS_RUN=$((TESTS_RUN + 1))
response=$(curl -s "$SERVER_URL") || {
    fail "HTTP request after content push"
}

if echo "$response" | grep -q "Test Options"; then
    pass "Content served correctly"
else
    fail "Content served" "Expected 'Test Options' in response"
fi

# Verify frame template is applied
TESTS_RUN=$((TESTS_RUN + 1))
if echo "$response" | grep -q "toggleSelect"; then
    pass "Frame template applied (helper.js injected)"
else
    fail "Frame template" "toggleSelect not found in response"
fi

# ========================================
# Test 5: Server Shutdown
# ========================================
echo ""
echo "--- Test 5: Server Shutdown ---"
TESTS_RUN=$((TESTS_RUN + 1))
if stop_brainstorm_server; then
    pass "Server shutdown"

    # Verify PID file removed
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ ! -f "$STATE_DIR/server.pid" ]]; then
        pass "PID file removed"
    else
        fail "PID file removal" "$STATE_DIR/server.pid still exists"
    fi

    # Verify server process is dead (if we had PID)
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ -n "${SERVER_PID:-}" ]]; then
        if ! kill -0 "$SERVER_PID" 2>/dev/null; then
            pass "Server process terminated"
        else
            fail "Server process termination" "PID $SERVER_PID still running"
        fi
    else
        info "Skipping process check (no PID captured)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
else
    fail "Server shutdown"
fi

# ========================================
# Summary
# ========================================
print_summary
