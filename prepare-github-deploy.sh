#!/bin/bash

echo "🚀 Preparing GitHub Actions Deployment"
echo "====================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -d ".github/workflows" ]; then
    echo -e "${RED}❌ Error: .github/workflows directory not found${NC}"
    echo "Please run this script from the project root"
    exit 1
fi

echo -e "\n${YELLOW}📋 Checking GitHub Secrets...${NC}"
echo "Please ensure you have added the following secrets to your GitHub repository:"
echo "  - BUILD_CERTIFICATE_BASE64"
echo "  - P12_PASSWORD"
echo "  - KEYCHAIN_PASSWORD"
echo "  - BUILD_PROVISION_PROFILE_BASE64"
echo "  - PROVISION_PROFILE_UUID"
echo "  - APP_STORE_CONNECT_API_KEY_ID"
echo "  - APP_STORE_CONNECT_API_KEY_ISSUER_ID"
echo "  - APP_STORE_CONNECT_API_KEY_KEY"

echo -e "\n${YELLOW}📊 Current Git Status:${NC}"
git status --short

echo -e "\n${YELLOW}🔍 Checking for uncommitted changes...${NC}"
if [[ -n $(git status -s) ]]; then
    echo -e "${YELLOW}Found uncommitted changes. Creating commit...${NC}"
    
    # Stage all iOS-related changes
    git add LMS_App/LMS/LMS.xcodeproj/
    git add LMS_App/LMS/LMS/
    git add LMS_App/LMS/LMSUITests/
    git add LMS_App/LMS/fastlane/
    git add .github/workflows/
    git add GITHUB_ACTIONS_DEPLOYMENT_GUIDE.md
    git add TESTFLIGHT_UPLOAD_READY.md
    
    # Show what will be committed
    echo -e "\n${YELLOW}📝 Files to be committed:${NC}"
    git status --short --cached
    
    # Create commit message
    COMMIT_MSG="feat: Add feedback system and prepare for GitHub Actions deployment

- Integrated custom feedback system with shake gesture
- Added screenshot annotation capability
- Fixed UserRole.moderator compilation issues
- Updated build number to 40
- Prepared for automated TestFlight deployment"
    
    echo -e "\n${YELLOW}💬 Commit message:${NC}"
    echo "$COMMIT_MSG"
    
    # Ask for confirmation
    echo -e "\n${YELLOW}Continue with commit? (y/n)${NC}"
    read -r response
    
    if [[ "$response" == "y" ]]; then
        git commit -m "$COMMIT_MSG"
        echo -e "${GREEN}✅ Commit created successfully${NC}"
    else
        echo -e "${RED}❌ Commit cancelled${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ No uncommitted changes${NC}"
fi

echo -e "\n${YELLOW}🌿 Current branch:${NC}"
CURRENT_BRANCH=$(git branch --show-current)
echo "  $CURRENT_BRANCH"

if [[ "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "master" ]]; then
    echo -e "${YELLOW}⚠️  Warning: You're not on main/master branch${NC}"
    echo "GitHub Actions will deploy only from main/master branch"
    echo -e "\n${YELLOW}Switch to main branch? (y/n)${NC}"
    read -r response
    
    if [[ "$response" == "y" ]]; then
        git checkout main || git checkout master
        echo -e "${GREEN}✅ Switched to main branch${NC}"
    fi
fi

echo -e "\n${GREEN}📋 Next Steps:${NC}"
echo "1. Push to GitHub to trigger deployment:"
echo "   ${YELLOW}git push origin main${NC}"
echo ""
echo "2. Monitor the deployment:"
echo "   ${YELLOW}https://github.com/ishirokov/lms_docs/actions${NC}"
echo ""
echo "3. Check TestFlight in 10-15 minutes:"
echo "   ${YELLOW}https://appstoreconnect.apple.com${NC}"
echo ""
echo -e "${GREEN}🎯 Ready for deployment!${NC}"

# Option to push immediately
echo -e "\n${YELLOW}Push to GitHub now? (y/n)${NC}"
read -r response

if [[ "$response" == "y" ]]; then
    echo -e "${YELLOW}🚀 Pushing to GitHub...${NC}"
    git push origin "$CURRENT_BRANCH"
    echo -e "${GREEN}✅ Pushed successfully!${NC}"
    echo -e "\n${GREEN}📊 View deployment progress:${NC}"
    echo "https://github.com/ishirokov/lms_docs/actions"
    
    # Try to open in browser
    if command -v open &> /dev/null; then
        open "https://github.com/ishirokov/lms_docs/actions"
    fi
else
    echo -e "${YELLOW}ℹ️  Remember to push when ready:${NC}"
    echo "   git push origin main"
fi 