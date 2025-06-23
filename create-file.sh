#!/bin/bash

# Safe file creation script
# Usage: ./create-file.sh <filepath>
# Content is read from stdin

if [ $# -eq 0 ]; then
    echo "Usage: $0 <filepath>"
    echo "Content is read from stdin"
    exit 1
fi

FILEPATH="$1"
DIRNAME=$(dirname "$FILEPATH")

# Create directory if it doesn't exist
if [ ! -d "$DIRNAME" ]; then
    mkdir -p "$DIRNAME"
fi

# Create temporary file first
TMPFILE=$(mktemp)

# Read from stdin and save to temp file
cat > "$TMPFILE"

# Move temp file to target location
mv "$TMPFILE" "$FILEPATH"

# Verify file was created
if [ -f "$FILEPATH" ]; then
    echo "✅ File created successfully: $FILEPATH"
    echo "📄 Size: $(wc -c < "$FILEPATH") bytes"
else
    echo "❌ Failed to create file: $FILEPATH"
    exit 1
fi 