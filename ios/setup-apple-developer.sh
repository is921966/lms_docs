#!/bin/bash

# Setup script for Apple Developer configuration
# Usage: ./setup-apple-developer.sh

set -e

echo "🍎 Apple Developer Setup for LMS"
echo "================================"

# Function to prompt for input
prompt_for_input() {
    local prompt=$1
    local var_name=$2
    local default=$3
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " input
        input=${input:-$default}
    else
        read -p "$prompt: " input
    fi
    
    eval "$var_name='$input'"
}

# Collect information
echo -e "\n📝 Please provide the following information:"
prompt_for_input "Your Apple Developer Team ID (10 characters)" TEAM_ID ""
prompt_for_input "Your Bundle ID" BUNDLE_ID "com.yourcompany.lms"
prompt_for_input "Your Apple ID email" APPLE_EMAIL ""
prompt_for_input "App name" APP_NAME "LMS"

# Update Configuration.xcconfig
echo -e "\n🔧 Updating Configuration.xcconfig..."
if [ -f "LMS/Configuration.xcconfig" ]; then
    sed -i '' "s/YOUR_TEAM_ID/$TEAM_ID/g" LMS/Configuration.xcconfig
    sed -i '' "s/com.yourcompany.lms/$BUNDLE_ID/g" LMS/Configuration.xcconfig
    echo "✅ Configuration.xcconfig updated"
else
    echo "❌ Configuration.xcconfig not found"
fi

# Update Fastlane Appfile
echo -e "\n🚀 Updating Fastlane configuration..."
if [ -f "LMS/fastlane/Appfile" ]; then
    sed -i '' "s/your-email@example.com/$APPLE_EMAIL/g" LMS/fastlane/Appfile
    sed -i '' "s/YOUR_TEAM_ID/$TEAM_ID/g" LMS/fastlane/Appfile
    sed -i '' "s/com.yourcompany.lms/$BUNDLE_ID/g" LMS/fastlane/Appfile
    echo "✅ Fastlane Appfile updated"
else
    echo "❌ Fastlane Appfile not found"
fi

# Install dependencies
echo -e "\n📦 Installing dependencies..."
cd LMS

# Check if bundler is installed
if ! command -v bundle &> /dev/null; then
    echo "Installing bundler..."
    sudo gem install bundler
fi

# Install fastlane if needed
if [ -f "Gemfile" ]; then
    bundle install
else
    echo "Creating Gemfile..."
    cat > Gemfile << EOF
source "https://rubygems.org"

gem "fastlane"
gem "cocoapods"
EOF
    bundle install
fi

# Initialize match if requested
echo -e "\n🔐 Certificate Management"
read -p "Do you want to set up Fastlane Match for certificate management? (y/n): " setup_match

if [ "$setup_match" = "y" ]; then
    echo "Setting up Match..."
    bundle exec fastlane match init
fi

# Create App Store Connect API key
echo -e "\n🔑 App Store Connect API"
echo "For automated uploads, you'll need an API key."
echo "1. Go to https://appstoreconnect.apple.com/access/api"
echo "2. Create a new API key with 'App Manager' role"
echo "3. Download the .p8 file"
echo ""
read -p "Have you created an API key? (y/n): " has_api_key

if [ "$has_api_key" = "y" ]; then
    prompt_for_input "API Key ID" API_KEY_ID ""
    prompt_for_input "API Issuer ID" API_ISSUER_ID ""
    prompt_for_input "Path to .p8 file" P8_FILE_PATH ""
    
    # Create env file for API credentials
    cat > fastlane/.env << EOF
APP_STORE_CONNECT_API_KEY_ID=$API_KEY_ID
APP_STORE_CONNECT_API_KEY_ISSUER_ID=$API_ISSUER_ID
APP_STORE_CONNECT_API_KEY_KEY_FILEPATH=$P8_FILE_PATH
EOF
    echo "✅ API credentials saved to fastlane/.env"
fi

# Final instructions
echo -e "\n✅ Setup Complete!"
echo "==================="
echo ""
echo "Next steps:"
echo "1. Open Xcode and verify the project settings"
echo "2. Create your app in App Store Connect"
echo "3. Run 'fastlane test' to run tests"
echo "4. Run 'fastlane beta' to upload to TestFlight"
echo ""
echo "📖 See APPLE_DEVELOPER_SETUP.md for detailed instructions"

# Make sure Xcode command line tools are installed
echo -e "\n🛠 Checking Xcode command line tools..."
if xcode-select -p &> /dev/null; then
    echo "✅ Xcode command line tools are installed"
else
    echo "⚠️  Installing Xcode command line tools..."
    xcode-select --install
fi

echo -e "\n🎉 Happy coding!" 