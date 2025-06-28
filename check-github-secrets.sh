#!/bin/bash

echo "🔐 GitHub Secrets Checker"
echo "========================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) is not installed${NC}"
    echo "Install it with: brew install gh"
    echo "Then authenticate: gh auth login"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ Not authenticated with GitHub${NC}"
    echo "Run: gh auth login"
    exit 1
fi

echo -e "${GREEN}✅ GitHub CLI authenticated${NC}"

# Required secrets
REQUIRED_SECRETS=(
    "BUILD_CERTIFICATE_BASE64"
    "P12_PASSWORD"
    "KEYCHAIN_PASSWORD"
    "BUILD_PROVISION_PROFILE_BASE64"
    "PROVISION_PROFILE_UUID"
    "APP_STORE_CONNECT_API_KEY_ID"
    "APP_STORE_CONNECT_API_KEY_ISSUER_ID"
    "APP_STORE_CONNECT_API_KEY_KEY"
)

echo -e "\n${YELLOW}📋 Checking repository secrets...${NC}"

# Get list of secrets
EXISTING_SECRETS=$(gh secret list --json name -q '.[].name' 2>/dev/null)

if [ -z "$EXISTING_SECRETS" ]; then
    echo -e "${YELLOW}No secrets found or unable to access secrets${NC}"
    echo "Make sure you have admin access to the repository"
else
    echo -e "${GREEN}Found secrets in repository:${NC}"
    echo "$EXISTING_SECRETS" | while read -r secret; do
        echo "  ✓ $secret"
    done
fi

echo -e "\n${YELLOW}🔍 Checking required secrets:${NC}"

MISSING_SECRETS=()

for secret in "${REQUIRED_SECRETS[@]}"; do
    if echo "$EXISTING_SECRETS" | grep -q "^$secret$"; then
        echo -e "  ${GREEN}✅ $secret${NC}"
    else
        echo -e "  ${RED}❌ $secret (missing)${NC}"
        MISSING_SECRETS+=("$secret")
    fi
done

echo -e "\n${YELLOW}📊 Summary:${NC}"
echo "Total required: ${#REQUIRED_SECRETS[@]}"
echo "Missing: ${#MISSING_SECRETS[@]}"

if [ ${#MISSING_SECRETS[@]} -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All required secrets are configured!${NC}"
    echo "Your repository is ready for GitHub Actions deployment."
else
    echo -e "\n${RED}❌ Missing secrets need to be added${NC}"
    echo -e "\n${YELLOW}📝 How to add missing secrets:${NC}"
    echo "1. Go to: https://github.com/ishirokov/lms_docs/settings/secrets/actions"
    echo "2. Click 'New repository secret'"
    echo "3. Add each missing secret"
    
    echo -e "\n${YELLOW}🔑 Quick guide for each secret:${NC}"
    
    for secret in "${MISSING_SECRETS[@]}"; do
        case $secret in
            "BUILD_CERTIFICATE_BASE64")
                echo -e "\n${YELLOW}$secret:${NC}"
                echo "  1. Export your Distribution certificate from Keychain as .p12"
                echo "  2. Run: base64 -i certificate.p12 | pbcopy"
                echo "  3. Paste the result as the secret value"
                ;;
            "P12_PASSWORD")
                echo -e "\n${YELLOW}$secret:${NC}"
                echo "  Password you used when exporting the .p12 certificate"
                ;;
            "KEYCHAIN_PASSWORD")
                echo -e "\n${YELLOW}$secret:${NC}"
                echo "  Any password (e.g., 'tempPassword123')"
                echo "  Used for temporary keychain in CI"
                ;;
            "BUILD_PROVISION_PROFILE_BASE64")
                echo -e "\n${YELLOW}$secret:${NC}"
                echo "  1. Download provisioning profile from Apple Developer"
                echo "  2. Run: base64 -i YourProfile.mobileprovision | pbcopy"
                echo "  3. Paste the result as the secret value"
                ;;
            "PROVISION_PROFILE_UUID")
                echo -e "\n${YELLOW}$secret:${NC}"
                echo "  Run: /usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< \$(security cms -D -i YourProfile.mobileprovision)"
                ;;
            "APP_STORE_CONNECT_API_KEY_ID")
                echo -e "\n${YELLOW}$secret:${NC}"
                echo "  From App Store Connect → Users and Access → Keys"
                echo "  Example: 7JF867FY76"
                ;;
            "APP_STORE_CONNECT_API_KEY_ISSUER_ID")
                echo -e "\n${YELLOW}$secret:${NC}"
                echo "  From App Store Connect → Users and Access → Keys"
                echo "  Example: cd103a3c-5d58-4921-aafb-c220081abea3"
                ;;
            "APP_STORE_CONNECT_API_KEY_KEY")
                echo -e "\n${YELLOW}$secret:${NC}"
                echo "  1. Download the .p8 file from App Store Connect"
                echo "  2. Run: cat AuthKey_XXXXX.p8 | pbcopy"
                echo "  3. Paste the entire content (including BEGIN/END lines)"
                ;;
        esac
    done
fi

echo -e "\n${YELLOW}💡 Tips:${NC}"
echo "- Keep your secrets secure and never commit them to the repository"
echo "- Rotate secrets regularly for security"
echo "- Use separate API keys for CI/CD"

# Option to open settings page
if [ ${#MISSING_SECRETS[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}Open GitHub secrets page? (y/n)${NC}"
    read -r response
    
    if [[ "$response" == "y" ]]; then
        open "https://github.com/ishirokov/lms_docs/settings/secrets/actions"
    fi
fi 