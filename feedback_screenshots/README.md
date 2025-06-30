# Feedback Screenshots

This folder contains screenshots from iOS app feedback system.

## How it works

1. User submits feedback with screenshot in iOS app
2. Screenshot is sent to feedback server (https://lms-feedback-server.onrender.com)
3. Server uploads screenshot directly to this folder via GitHub API
4. Screenshot URL is embedded in the created GitHub issue

## File naming convention

Files are named: `YYYYMMDD_HHMMSS_feedback-id.png`

Example: `20250630_111013_9167e9a4-38e7-4cc9-b330-85d2accbc85e.png`

## Storage details

- Screenshots are stored as PNG files
- No external dependencies (Imgur, etc.)
- Automatically referenced in GitHub issues
- Part of the repository history

## Current screenshots

This folder contains real feedback screenshots from users testing the LMS iOS app.
