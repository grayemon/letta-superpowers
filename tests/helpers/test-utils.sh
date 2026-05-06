#!/usr/bin/env bash
# Shared utilities for brainstorm server tests
# Source this file: source tests/helpers/test-utils.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log file setup (relative to tests/ directory)
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$UTILS_DIR/../test-results.log"
LOG_CLOSED=false

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Write timestamped message to log file and console
# Usage: log "LEVEL" "message"
log() {
    local level="$1"
    local message="$2"
    
    # Don't log after end_log is called
    if [[ "$LOG_CLOSED" == "true" ]]; then
        return
    fi
    
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Initialize log file with header
start_log() {
    # Create/clear log file
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
    echo "" > "$LOG_FILE"
    
    local start_time
    start_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    {
        echo "====================================="
        echo "TEST RUN: $start_time"
        echo "====================================="
    } >> "$LOG_FILE"
}

# Finalize log file with summary footer
end_log() {
    LOG_CLOSED=true
    
    {
        echo "====================================="
        echo "TEST SUMMARY"
        echo "====================================="
        echo "Tests run: $TESTS_RUN"
        echo "Tests passed: $TESTS_PASSED"
        echo "Tests failed: $TESTS_FAILED"
        echo "====================================="
    } >> "$LOG_FILE"
}

# Server state (set by start_brainstorm_server)
SERVER_URL=""
SCREEN_DIR=""
STATE_DIR=""
SESSION_DIR=""
SERVER_PID=""

# Log test result
pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    log "PASS" "$1"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    local message="$1"
    local details="${2:-}"
    
    echo -e "${RED}✗ FAIL${NC}: $message"
    if [[ -n "$details" ]]; then
        echo "  Details: $details"
        log "FAIL" "$message - $details"
    else
        log "FAIL" "$message"
    fi
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

info() {
    echo -e "${YELLOW}ℹ INFO${NC}: $1"
    log "INFO" "$1"
}

# Start brainstorm server and capture output
# Sets: SERVER_URL, SCREEN_DIR, STATE_DIR, SESSION_DIR, SERVER_PID
start_brainstorm_server() {
    local project_dir="${1:-$(pwd)}"
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    local start_script="$script_dir/skills/brainstorming/scripts/start-server.sh"

    if [[ ! -f "$start_script" ]]; then
        fail "start-server.sh not found at $start_script"
        return 1
    fi

    info "Starting brainstorm server..."
    local output
    output=$("$start_script" --project-dir "$project_dir" 2>&1) || {
        fail "start-server.sh exited with error" "$output"
        return 1
    }

    # Parse JSON output
    if ! parse_server_json "$output"; then
        fail "Failed to parse server output" "$output"
        return 1
    fi

    # Extract PID from state dir if available
    local pid_file="$STATE_DIR/server.pid"
    if [[ -f "$pid_file" ]]; then
        SERVER_PID=$(cat "$pid_file")
    fi

    info "Server started at $SERVER_URL"
    info "Screen dir: $SCREEN_DIR"
    info "State dir: $STATE_DIR"

    return 0
}

# Parse server JSON output
# Sets: SERVER_URL, SCREEN_DIR, STATE_DIR, SESSION_DIR
parse_server_json() {
    local json="$1"

    # Extract fields from JSON
    SERVER_URL=$(echo "$json" | grep -o '"url":"[^"]*"' | cut -d'"' -f4) || return 1
    SCREEN_DIR=$(echo "$json" | grep -o '"screen_dir":"[^"]*"' | cut -d'"' -f4) || return 1
    STATE_DIR=$(echo "$json" | grep -o '"state_dir":"[^"]*"' | cut -d'"' -f4) || return 1

    # SESSION_DIR is parent of STATE_DIR
    SESSION_DIR=$(dirname "$STATE_DIR")

    # Validate we got values
    [[ -n "$SERVER_URL" && -n "$SCREEN_DIR" && -n "$STATE_DIR" ]] || return 1

    return 0
}

# Wait for server to respond (up to 5 seconds)
wait_for_server() {
    local url="${1:-$SERVER_URL}"
    local max_wait=5
    local waited=0

    info "Waiting for server at $url..."
    while [[ $waited -lt $max_wait ]]; do
        if curl -s --max-time 1 "$url" > /dev/null 2>&1; then
            return 0
        fi
        sleep 1
        ((waited++))
    done

    fail "Server did not respond within ${max_wait}s"
    return 1
}

# Stop brainstorm server
stop_brainstorm_server() {
    if [[ -z "${SESSION_DIR:-}" ]]; then
        info "No session directory set, skipping stop"
        return 0
    fi

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    local stop_script="$script_dir/skills/brainstorming/scripts/stop-server.sh"

    if [[ ! -f "$stop_script" ]]; then
        fail "stop-server.sh not found at $stop_script"
        return 1
    fi

    info "Stopping brainstorm server..."
    local output
    output=$("$stop_script" "$SESSION_DIR" 2>&1) || {
        fail "stop-server.sh exited with error" "$output"
        return 1
    }

    info "Server stopped: $output"
    return 0
}

# Cleanup trap handler - call on script exit
cleanup_on_exit() {
    local exit_code=$?

    if [[ -n "${SESSION_DIR:-}" && -n "${SERVER_PID:-}" ]]; then
        info "Cleaning up server (PID: $SERVER_PID)..."
        stop_brainstorm_server || true
    fi

    exit $exit_code
}

# Check prerequisites
check_prerequisites() {
    local missing=0

    info "Checking prerequisites..."

    # Check Node.js
    if ! command -v node &> /dev/null; then
        fail "Node.js not found"
        missing=1
    else
        info "Node.js: $(node --version)"
    fi

    # Check curl
    if ! command -v curl &> /dev/null; then
        fail "curl not found"
        missing=1
    else
        info "curl: $(curl --version | head -1)"
    fi

    # Check bash version (need 4+ for associative arrays if used)
    if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
        info "Warning: Bash version < 4 ($(bash --version | head -1))"
    fi

    return $missing
}

# Print test summary
print_summary() {
    echo ""
    echo "====================================="
    echo "TEST SUMMARY"
    echo "====================================="
    echo "Tests run:    $TESTS_RUN"
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
    echo "====================================="

    if [[ $TESTS_FAILED -gt 0 ]]; then
        return 1
    fi
    return 0
}
