#!/bin/bash
# =============================================================================
# PLG-IDE: Test Setup Script
# =============================================================================
# This script helps you verify your environment is ready for the PLG-IDE demos.
# It will guide you through selecting your runtime and connection method.
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                           ║"
echo "║   ███████╗██╗██████╗ ███████╗██████╗  ██████╗ ██╗  ████████╗             ║"
echo "║   ██╔════╝██║██╔══██╗██╔════╝██╔══██╗██╔═══██╗██║  ╚══██╔══╝             ║"
echo "║   █████╗  ██║██████╔╝█████╗  ██████╔╝██║   ██║██║     ██║                ║"
echo "║   ██╔══╝  ██║██╔══██╗██╔══╝  ██╔══██╗██║   ██║██║     ██║                ║"
echo "║   ██║     ██║██║  ██║███████╗██████╔╝╚██████╔╝███████╗██║                ║"
echo "║   ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝                ║"
echo "║                                                                           ║"
echo "║                     PLG-IDE Test Setup                                    ║"
echo "║                                                                           ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# =============================================================================
# STEP 1: Select Runtime
# =============================================================================
echo -e "${CYAN}${BOLD}STEP 1: Select Your Firebolt Runtime${NC}"
echo ""
echo "  ${BOLD}[1]${NC} ${GREEN}Firebolt Core (Local)${NC}"
echo "      • Runs locally via Docker"
echo "      • Free, no account needed"
echo "      • Great for demos and development"
echo ""
echo "  ${BOLD}[2]${NC} ${YELLOW}Firebolt Cloud${NC}"
echo "      • Fully managed cloud service"
echo "      • Requires service account credentials"
echo "      • Production-ready, scalable"
echo ""
echo -e "  ${CYAN}Type ${BOLD}1${NC}${CYAN} or ${BOLD}2${NC}${CYAN} and press Enter${NC}"
echo ""
read -p "  Your choice: " RUNTIME_CHOICE

case $RUNTIME_CHOICE in
    1)
        RUNTIME="core"
        echo -e "\n${GREEN}✓ Selected: Firebolt Core (Local)${NC}\n"
        ;;
    2)
        RUNTIME="cloud"
        echo -e "\n${GREEN}✓ Selected: Firebolt Cloud${NC}\n"
        ;;
    *)
        echo -e "${RED}Invalid selection. Defaulting to Firebolt Core.${NC}"
        RUNTIME="core"
        ;;
esac

# =============================================================================
# STEP 2: Select Connection Method
# =============================================================================
echo -e "${CYAN}${BOLD}STEP 2: Select Your Connection Method${NC}"
echo ""
echo "  ${BOLD}[1]${NC} ${GREEN}MCP Server (Recommended)${NC}"
echo "      • Integrates with Cursor/Claude Desktop"
echo "      • AI-assisted SQL execution"
echo "      • Natural language queries"
echo ""
echo "  ${BOLD}[2]${NC} ${YELLOW}Direct SQL Connection${NC}"
echo "      • Use any SQL client"
echo "      • Python SDK scripts"
echo "      • Manual query execution"
echo ""
echo -e "  ${CYAN}Type ${BOLD}1${NC}${CYAN} or ${BOLD}2${NC}${CYAN} and press Enter${NC}"
echo ""
read -p "  Your choice: " CONNECTION_CHOICE

case $CONNECTION_CHOICE in
    1)
        CONNECTION="mcp"
        echo -e "\n${GREEN}✓ Selected: MCP Server (Recommended)${NC}\n"
        ;;
    2)
        CONNECTION="direct"
        echo -e "\n${GREEN}✓ Selected: Direct SQL Connection${NC}\n"
        ;;
    *)
        echo -e "${RED}Invalid selection. Defaulting to MCP Server.${NC}"
        CONNECTION="mcp"
        ;;
esac

# =============================================================================
# STEP 3: Check Prerequisites
# =============================================================================
echo -e "${CYAN}${BOLD}STEP 3: Checking Prerequisites${NC}\n"

PREREQ_PASSED=true

# Check Docker
echo -n "  Checking Docker... "
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
    echo -e "${GREEN}✓ Installed (v${DOCKER_VERSION})${NC}"
    
    # Check if Docker daemon is running
    if docker info &> /dev/null; then
        echo -e "  Docker daemon... ${GREEN}✓ Running${NC}"
    else
        echo -e "  Docker daemon... ${RED}✗ Not running${NC}"
        echo -e "  ${YELLOW}→ Please start Docker Desktop${NC}"
        PREREQ_PASSED=false
    fi
else
    echo -e "${RED}✗ Not installed${NC}"
    echo -e "  ${YELLOW}→ Install from https://docker.com${NC}"
    PREREQ_PASSED=false
fi

# Check Python (optional, for direct connection)
echo -n "  Checking Python... "
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    echo -e "${GREEN}✓ Installed (v${PYTHON_VERSION})${NC}"
else
    echo -e "${YELLOW}⚠ Not found (optional, needed for benchmark scripts)${NC}"
fi

# Check if Firebolt Core is running (if selected)
if [ "$RUNTIME" = "core" ]; then
    echo -n "  Checking Firebolt Core (localhost:3473)... "
    if curl -s --max-time 2 http://localhost:3473/ > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Running${NC}"
        CORE_RUNNING=true
    else
        echo -e "${YELLOW}⚠ Not running${NC}"
        CORE_RUNNING=false
    fi
fi

echo ""

# =============================================================================
# STEP 4: Setup Based on Selections
# =============================================================================
echo -e "${CYAN}${BOLD}STEP 4: Setup${NC}\n"

# --- Firebolt Core Setup ---
if [ "$RUNTIME" = "core" ]; then
    if [ "$CORE_RUNNING" = false ]; then
        echo -e "  ${YELLOW}Starting Firebolt Core...${NC}"
        docker pull ghcr.io/firebolt-db/firebolt-core:latest 2>/dev/null || true
        docker run -d --name firebolt-core -p 3473:3473 ghcr.io/firebolt-db/firebolt-core:latest 2>/dev/null || \
            docker start firebolt-core 2>/dev/null || true
        
        echo -n "  Waiting for Firebolt Core to start"
        for i in {1..30}; do
            if curl -s --max-time 1 http://localhost:3473/ > /dev/null 2>&1; then
                echo -e " ${GREEN}✓${NC}"
                break
            fi
            echo -n "."
            sleep 1
        done
        
        if ! curl -s --max-time 1 http://localhost:3473/ > /dev/null 2>&1; then
            echo -e " ${RED}✗ Failed to start${NC}"
            echo -e "  ${YELLOW}Try manually: docker run -d -p 3473:3473 ghcr.io/firebolt-db/firebolt-core:latest${NC}"
            exit 1
        fi
    fi
    
    # Test connection
    echo -n "  Testing Firebolt Core connection... "
    RESPONSE=$(curl -s -X POST "http://localhost:3473/?output_format=JSON_Compact" \
        -H "Content-Type: text/plain" \
        -d "SELECT 1" 2>/dev/null || echo "error")
    
    if [[ "$RESPONSE" != "error" ]] && [[ "$RESPONSE" != "" ]] && [[ "$RESPONSE" != *"errors"* ]]; then
        echo -e "${GREEN}✓ Connected${NC}"
    else
        echo -e "${RED}✗ Failed${NC}"
        PREREQ_PASSED=false
    fi
fi

# --- Firebolt Cloud Setup ---
if [ "$RUNTIME" = "cloud" ]; then
    echo -e "  ${YELLOW}Firebolt Cloud requires credentials.${NC}"
    echo -e "  ${CYAN}(Create a service account at https://go.firebolt.io/ if needed)${NC}"
    echo ""
    echo -e "  ${CYAN}Enter your Client ID and press Enter:${NC}"
    read -p "  Client ID: " CLIENT_ID
    echo -e "  ${CYAN}Enter your Client Secret and press Enter (input hidden):${NC}"
    read -s -p "  Client Secret: " CLIENT_SECRET
    echo ""
    
    if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
        echo -e "  ${RED}✗ Credentials required for Firebolt Cloud${NC}"
        echo -e "  ${YELLOW}→ Create a service account at https://go.firebolt.io/${NC}"
        PREREQ_PASSED=false
    else
        # Save to .env file
        echo "FIREBOLT_CLIENT_ID=$CLIENT_ID" > .env
        echo "FIREBOLT_CLIENT_SECRET=$CLIENT_SECRET" >> .env
        echo -e "  ${GREEN}✓ Credentials saved to .env${NC}"
    fi
fi

echo ""

# =============================================================================
# STEP 5: MCP Configuration
# =============================================================================
if [ "$CONNECTION" = "mcp" ]; then
    echo -e "${CYAN}${BOLD}STEP 5: MCP Server Configuration${NC}\n"
    
    # Pull MCP server image
    echo -n "  Pulling Firebolt MCP Server image... "
    docker pull ghcr.io/firebolt-db/mcp-server:0.6.0 > /dev/null 2>&1 && \
        echo -e "${GREEN}✓${NC}" || echo -e "${YELLOW}⚠ (may already exist)${NC}"
    
    echo ""
    echo -e "  ${BOLD}Add this configuration to your Cursor MCP settings:${NC}"
    echo ""
    
    if [ "$RUNTIME" = "core" ]; then
        echo -e "${CYAN}  ┌────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}  │${NC} Copy this to: Cursor Settings → MCP → mcpServers            ${CYAN}│${NC}"
        echo -e "${CYAN}  └────────────────────────────────────────────────────────────────┘${NC}"
        cat << 'EOF'

  {
    "mcpServers": {
      "firebolt": {
        "command": "docker",
        "args": [
          "run", "-i", "--rm", "--network", "host",
          "-e", "FIREBOLT_MCP_CORE_URL",
          "-e", "FIREBOLT_MCP_DISABLE_RESOURCES=true",
          "ghcr.io/firebolt-db/mcp-server:0.6.0"
        ],
        "env": {
          "FIREBOLT_MCP_CORE_URL": "http://localhost:3473"
        }
      }
    }
  }

EOF
    else
        echo -e "${CYAN}  ┌────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}  │${NC} Copy this to: Cursor Settings → MCP → mcpServers            ${CYAN}│${NC}"
        echo -e "${CYAN}  │${NC} Replace <your-client-id> and <your-client-secret>           ${CYAN}│${NC}"
        echo -e "${CYAN}  └────────────────────────────────────────────────────────────────┘${NC}"
        cat << 'EOF'

  {
    "mcpServers": {
      "firebolt": {
        "command": "docker",
        "args": [
          "run", "-i", "--rm", "--network", "host",
          "-e", "FIREBOLT_MCP_CLIENT_ID",
          "-e", "FIREBOLT_MCP_CLIENT_SECRET",
          "-e", "FIREBOLT_MCP_DISABLE_RESOURCES=true",
          "ghcr.io/firebolt-db/mcp-server:0.6.0"
        ],
        "env": {
          "FIREBOLT_MCP_CLIENT_ID": "<your-client-id>",
          "FIREBOLT_MCP_CLIENT_SECRET": "<your-client-secret>"
        }
      }
    }
  }

EOF
    fi
    
    echo -e "  ${BOLD}After adding the config:${NC}"
    echo "  1. Open Cursor Settings (Cmd+,)"
    echo "  2. Search for 'MCP'"
    echo "  3. Paste the configuration above"
    echo "  4. Restart Cursor"
    echo ""
fi

# =============================================================================
# STEP 6: Direct Connection Setup
# =============================================================================
if [ "$CONNECTION" = "direct" ]; then
    echo -e "${CYAN}${BOLD}STEP 5: Direct Connection Setup${NC}\n"
    
    # Install Python dependencies
    echo -n "  Installing Python dependencies... "
    pip3 install -q firebolt-sdk python-dotenv tabulate 2>/dev/null && \
        echo -e "${GREEN}✓${NC}" || echo -e "${YELLOW}⚠ (run: pip install -r requirements.txt)${NC}"
    
    echo ""
    echo -e "  ${BOLD}You can now run SQL files directly:${NC}"
    echo ""
    
    if [ "$RUNTIME" = "core" ]; then
        echo "  # Test connection"
        echo "  python3 -c \"from firebolt.db import connect; c=connect(engine_url='http://localhost:3473'); print('Connected!')\""
        echo ""
        echo "  # Run the demo SQL"
        echo "  # Open verticals/gaming/demo_full.sql in any SQL client"
        echo "  # Connect to: http://localhost:3473"
    else
        echo "  # Set environment variables"
        echo "  export FIREBOLT_CLIENT_ID='your-client-id'"
        echo "  export FIREBOLT_CLIENT_SECRET='your-client-secret'"
        echo ""
        echo "  # Run the demo"
        echo "  python verticals/gaming/features/aggregating_indexes/benchmark.py"
    fi
    echo ""
fi

# =============================================================================
# SUMMARY
# =============================================================================
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}                              SETUP SUMMARY                                 ${NC}"
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Runtime:     ${GREEN}$RUNTIME${NC}"
echo -e "  Connection:  ${GREEN}$CONNECTION${NC}"
echo ""

if [ "$PREREQ_PASSED" = true ]; then
    echo -e "  Status:      ${GREEN}✓ Ready to go!${NC}"
    echo ""
    echo -e "  ${BOLD}Next Steps:${NC}"
    
    if [ "$CONNECTION" = "mcp" ]; then
        echo "  1. Add the MCP configuration to Cursor (see above)"
        echo "  2. Restart Cursor"
        echo "  3. Ask: 'Help me get started with Firebolt'"
        echo "  4. Or ask: 'Run the gaming aggregating indexes demo'"
    else
        echo "  1. Open verticals/gaming/demo_full.sql"
        echo "  2. Connect to Firebolt (localhost:3473 or Cloud)"
        echo "  3. Run each stage sequentially"
    fi
else
    echo -e "  Status:      ${RED}✗ Prerequisites not met${NC}"
    echo ""
    echo -e "  ${BOLD}Please fix the issues above and run this script again.${NC}"
fi

echo ""
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# =============================================================================
# Quick Test (Optional)
# =============================================================================
if [ "$PREREQ_PASSED" = true ] && [ "$RUNTIME" = "core" ]; then
    echo -e "${CYAN}Would you like to run a quick test query to verify the connection?${NC}"
    echo -e "${CYAN}Type ${BOLD}y${NC}${CYAN} for yes or ${BOLD}n${NC}${CYAN} for no, then press Enter${NC}"
    echo ""
    read -p "  Run test? [y/n]: " RUN_TEST
    echo ""
    
    if [[ "$RUN_TEST" =~ ^[Yy] ]]; then
        echo -e "\n${CYAN}Running test query...${NC}\n"
        
        # Firebolt Core expects plain SQL with specific output format
        RESULT=$(curl -s -X POST "http://localhost:3473/?output_format=JSON_Compact" \
            -H "Content-Type: text/plain" \
            -d "SELECT version() AS firebolt_version")
        
        if [[ "$RESULT" == *"errors"* ]]; then
            echo -e "  ${YELLOW}⚠ Query returned an error${NC}"
            echo -e "  Response: $RESULT"
        else
            echo -e "  ${GREEN}✓ Query executed successfully!${NC}"
            # Extract version from JSON_Compact response
            VERSION=$(echo "$RESULT" | grep -o '\["[^"]*"\]' | head -1 | tr -d '[]"')
            if [ -n "$VERSION" ]; then
                echo -e "  Firebolt Version: ${GREEN}$VERSION${NC}"
            else
                echo -e "  Response: $RESULT"
            fi
        fi
        echo ""
    fi
fi

echo -e "${BLUE}Happy querying! 🚀${NC}"
echo ""
