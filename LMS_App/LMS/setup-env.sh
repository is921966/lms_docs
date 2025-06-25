#!/bin/bash

# Setup environment variables for TestFlight upload

echo "🔧 Setting up environment variables for TestFlight..."
echo ""

# Read from .env file if exists
if [ -f .env ]; then
    echo "📄 Loading from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "⚠️  No .env file found"
    echo ""
    echo "Creating template .env file..."
    
    cat > .env.template <<EOF
# App Store Connect API credentials
APP_STORE_CONNECT_API_KEY_ID=your_key_id_here
APP_STORE_CONNECT_API_KEY_ISSUER_ID=your_issuer_id_here

# Path to .p8 key file (optional, defaults to ~/.private_keys/)
# APP_STORE_CONNECT_API_KEY_PATH=/path/to/AuthKey_XXXXX.p8
EOF

    echo "✅ Created .env.template"
    echo ""
    echo "📝 Next steps:"
    echo "1. Copy .env.template to .env"
    echo "2. Fill in your API credentials"
    echo "3. Run this script again"
    echo ""
    echo "To get API credentials:"
    echo "1. Go to https://appstoreconnect.apple.com/access/api"
    echo "2. Create a new API key with 'App Manager' role"
    echo "3. Download the .p8 file and save it to ~/.private_keys/"
    echo "4. Copy the Key ID and Issuer ID to .env"
    
    exit 0
fi

# Check if variables are set
if [ -z "$APP_STORE_CONNECT_API_KEY_ID" ] || [ -z "$APP_STORE_CONNECT_API_KEY_ISSUER_ID" ]; then
    echo "❌ API credentials not set in .env file"
    echo ""
    echo "Please edit .env and add:"
    echo "APP_STORE_CONNECT_API_KEY_ID=your_key_id"
    echo "APP_STORE_CONNECT_API_KEY_ISSUER_ID=your_issuer_id"
    exit 1
fi

# Check for .p8 key file
KEY_FILE="$HOME/.private_keys/AuthKey_${APP_STORE_CONNECT_API_KEY_ID}.p8"
ALT_KEY_FILE="./private_keys/AuthKey_${APP_STORE_CONNECT_API_KEY_ID}.p8"

if [ -f "$KEY_FILE" ]; then
    echo "✅ Found API key file at: $KEY_FILE"
elif [ -f "$ALT_KEY_FILE" ]; then
    echo "✅ Found API key file at: $ALT_KEY_FILE"
else
    echo "❌ API key file not found"
    echo ""
    echo "Expected locations:"
    echo "1. $KEY_FILE"
    echo "2. $ALT_KEY_FILE"
    echo ""
    echo "Please download the .p8 file from App Store Connect and save it to one of these locations"
    exit 1
fi

echo ""
echo "✅ Environment configured successfully!"
echo ""
echo "API Key ID: $APP_STORE_CONNECT_API_KEY_ID"
echo "Issuer ID: $APP_STORE_CONNECT_API_KEY_ISSUER_ID"
echo ""
echo "You can now run ./build-testflight.sh" 