#!/usr/bin/env bash
# Test script for tmux session cleanup functionality

set -e

echo "=== Testing WezTerm Tmux Session Cleanup ==="
echo

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if tmux is available
if ! command -v tmux &> /dev/null; then
    echo -e "${RED}Error: tmux not found${NC}"
    exit 1
fi

echo -e "${BLUE}1. Creating test sessions...${NC}"
tmux new-session -d -s cleanup-test1 2>/dev/null || echo "Session cleanup-test1 already exists"
tmux new-session -d -s cleanup-test2 2>/dev/null || echo "Session cleanup-test2 already exists"
echo -e "${GREEN}✓ Created test sessions${NC}"
echo

echo -e "${BLUE}2. Current tmux sessions:${NC}"
tmux list-sessions
echo

echo -e "${YELLOW}Instructions:${NC}"
echo "1. Open WezTerm and attach to 'cleanup-test1' and 'cleanup-test2'"
echo "   (Use your tmux session selector)"
echo ""
echo "2. You should see view sessions created (e.g., cleanup-test1-view-XXXXX)"
echo "   Run: tmux list-sessions"
echo ""
echo "3. CLOSE the WezTerm terminals (not just tabs)"
echo ""
echo "4. Wait 30 seconds for periodic cleanup, or trigger it manually"
echo ""
echo "5. Check sessions again: tmux list-sessions"
echo "   The view sessions should be gone!"
echo ""
echo "6. Only cleanup-test1 and cleanup-test2 should remain"
echo

echo -e "${BLUE}3. Manual cleanup test (simulating orphaned views):${NC}"
# Create fake view sessions
tmux new-session -d -s "cleanup-test1-view-1234567890-1234" 2>/dev/null || true
tmux new-session -d -s "cleanup-test2-view-9876543210-5678" 2>/dev/null || true
echo -e "${GREEN}✓ Created fake orphaned view sessions${NC}"
echo

echo -e "${BLUE}Sessions before cleanup:${NC}"
tmux list-sessions
echo

echo -e "${YELLOW}These fake views should be cleaned up by WezTerm within 30 seconds${NC}"
echo -e "${YELLOW}Or you can manually trigger cleanup by reloading WezTerm config${NC}"
echo

echo -e "${BLUE}Cleanup commands:${NC}"
echo "# List all sessions (check for orphaned views)"
echo "tmux list-sessions"
echo ""
echo "# Manually kill orphaned views"
echo "tmux kill-session -t cleanup-test1-view-1234567890-1234"
echo "tmux kill-session -t cleanup-test2-view-9876543210-5678"
echo ""
echo "# Kill test sessions when done"
echo "tmux kill-session -t cleanup-test1"
echo "tmux kill-session -t cleanup-test2"
echo

echo -e "${GREEN}=== Test Setup Complete ===${NC}"
