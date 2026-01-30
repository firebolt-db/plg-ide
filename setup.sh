#!/bin/bash
# PLG-IDE Setup Script
# Installs prerequisites - MCP configuration happens in the IDE

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║               PLG-IDE: Prerequisites Setup                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check Docker
echo -e "${YELLOW}[1/3] Checking Docker...${NC}"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}  ✓ Docker installed${NC}"
    
    # Pre-pull images
    echo "  Pulling Firebolt images (this may take a moment)..."
    docker pull ghcr.io/firebolt-db/firebolt-core:latest 2>/dev/null && \
        echo -e "${GREEN}  ✓ Firebolt Core image ready${NC}" || \
        echo -e "${YELLOW}  ⚠ Could not pull Core image${NC}"
    
    docker pull ghcr.io/firebolt-db/mcp-server:0.6.0 2>/dev/null && \
        echo -e "${GREEN}  ✓ Firebolt MCP Server image ready${NC}" || \
        echo -e "${YELLOW}  ⚠ Could not pull MCP Server image${NC}"
else
    echo -e "${YELLOW}  ⚠ Docker not found - required for Firebolt Core and MCP Server${NC}"
    echo "  Install from: https://docker.com"
fi

# Check Python (optional, for benchmark scripts)
echo -e "${YELLOW}[2/3] Checking Python (optional)...${NC}"
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    echo -e "${GREEN}  ✓ $PYTHON_VERSION${NC}"
    
    echo "  Installing Python dependencies..."
    pip3 install -q -r requirements.txt 2>/dev/null && \
        echo -e "${GREEN}  ✓ Dependencies installed${NC}" || \
        echo -e "${YELLOW}  ⚠ Could not install dependencies${NC}"
else
    echo -e "${YELLOW}  ⚠ Python not found - optional, for benchmark scripts${NC}"
fi

# Check if Core is already running
echo -e "${YELLOW}[3/3] Checking Firebolt Core...${NC}"
if curl -s --max-time 2 http://localhost:3473/ > /dev/null 2>&1; then
    echo -e "${GREEN}  ✓ Firebolt Core is running on localhost:3473${NC}"
else
    echo -e "${YELLOW}  ⚠ Firebolt Core not detected${NC}"
    echo "  Start it with: docker run -d -p 3473:3473 ghcr.io/firebolt-db/firebolt-core:latest"
fi

# Done
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗"
echo "║                    Prerequisites Ready                        ║"
echo "╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Next step: Open this repo in Cursor"
echo ""
echo "The AI will guide you through:"
echo "  1. Selecting your runtime (Core or Cloud)"
echo "  2. Configuring the Firebolt MCP Server"
echo "  3. Running interactive demos"
echo ""
echo "Just ask: 'Help me get started with Firebolt'"
echo ""
