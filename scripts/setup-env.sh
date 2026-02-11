#!/bin/bash
set -euo pipefail

# ============================================
# Setup Environment File - Interactive
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"
ENV_EXAMPLE="$PROJECT_ROOT/.env.example"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  n8n Infrastructure - Setup .env      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if .env already exists
if [ -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}⚠️  Warning: .env already exists${NC}"
    read -p "Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    echo ""
fi

# ============================================
# Collect Secrets
# ============================================

# 1. Infisical
echo -e "${BLUE}🔑 1. Infisical Configuration${NC}"
echo "Get your token at: https://app.infisical.com/ (Machine Identities → Terraform)"
read -sp "Client Secret: " CLIENT_SECRET
echo ""
if [[ ! "$CLIENT_SECRET" =~ ^[a-f0-9]{32,}$ ]]; then
    echo -e "${YELLOW}⚠️  Warning: Client Secret usually is at least 32 hex characters.${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi
fi
echo ""

# 2. Cloudflare / R2
echo -e "${BLUE}☁️  2. Cloudflare / R2 Configuration${NC}"
echo "Required for Terraform Remote Backend (State)"

read -p "Cloudflare Account ID: " CF_ACCOUNT_ID
if [[ ! "$CF_ACCOUNT_ID" =~ ^[a-f0-9]{32}$ ]]; then
    echo -e "${YELLOW}⚠️  Error: Cloudflare Account ID must be 32 hexadecimal characters.${NC}"
    exit 1
fi

read -p "R2 Access Key ID: " R2_ACCESS_KEY
if [ -z "$R2_ACCESS_KEY" ]; then
    echo -e "${YELLOW}⚠️  Access Key cannot be empty${NC}"
    exit 1
fi

read -sp "R2 Secret Access Key: " R2_SECRET_KEY
echo ""
if [ -z "$R2_SECRET_KEY" ]; then
    echo -e "${YELLOW}⚠️  Secret Key cannot be empty${NC}"
    exit 1
fi
echo ""

# ============================================
# Create .env File from Template
# ============================================

echo -e "${GREEN}Creating .env file...${NC}"

# Copy template
cat "$ENV_EXAMPLE" > "$ENV_FILE"

# Use a temporary file for replacements to avoid sed issues across OSs
TEMP_FILE=$(mktemp)

# Replace all values
cat "$ENV_FILE" | \
sed "s|your_client_secret_here|$CLIENT_SECRET|g" | \
sed "s|your_account_id_here|$CF_ACCOUNT_ID|g" | \
sed "s|your_r2_access_key_id_here|$R2_ACCESS_KEY|g" | \
sed "s|your_r2_secret_access_key_here|$R2_SECRET_KEY|g" > "$TEMP_FILE"

mv "$TEMP_FILE" "$ENV_FILE"
chmod 600 "$ENV_FILE"

echo -e "${GREEN}✓ Created managed .env file${NC}"
echo ""

# ============================================
# Show Summary
# ============================================

echo -e "${BLUE}📋 Configuration Summary:${NC}"
echo "  Infisical Secret: ${CLIENT_SECRET:0:6}..."
echo "  CF Account ID : ${CF_ACCOUNT_ID:0:6}..."
echo "  R2 Access Key : ${R2_ACCESS_KEY:0:6}..."
echo ""

# ============================================
# Next Steps
# ============================================

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Next Steps                            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo "1. Export environment variables:"
echo -e "   ${BLUE}source .env${NC}"
echo ""
echo "2. Initialize Terraform Backend (R2):"
echo -e "   ${BLUE}cd terraform${NC}"
echo -e "   ${BLUE}terraform init -backend-config=\"endpoint=https://\$TF_VAR_cloudflare_account_id.r2.cloudflarestorage.com\"${NC}"
echo ""
echo "3. Run your first apply:"
echo -e "   ${BLUE}terraform apply${NC}"
echo ""
echo -e "${GREEN}✓ Setup complete! Enjoy your infrastructure.${NC}"
echo ""
