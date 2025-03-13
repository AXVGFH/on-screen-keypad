#!/bin/bash

# Usage: ./update_version_and_publish.sh <new_version>
# Example: ./update_version_and_publish.sh 1.0.2+3

set -e  # Exit immediately if any command fails

# Check if a version argument was provided
if [ -z "$1" ]; then
    echo "Error: No version provided."
    echo "Usage: $0 <new_version>"
    exit 1
fi

NEW_VERSION=$1
PUBSPEC_FILE="pubspec.yaml"
CHANGELOG_FILE="CHANGELOG.md"

# Update version in pubspec.yaml
echo "Updating version in $PUBSPEC_FILE..."
sed -i '' "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC_FILE"

# Update CHANGELOG.md
echo "Updating CHANGELOG in $CHANGELOG_FILE..."
DATE=$(date +"%Y-%m-%d")
sed -i '' "s/^## \[Unreleased\]/## [$NEW_VERSION] - $DATE/" "$CHANGELOG_FILE"
echo -e "\n- Updated package to version $NEW_VERSION\n" >> "$CHANGELOG_FILE"

# Commit changes
echo "Committing changes..."
git add "$PUBSPEC_FILE" "$CHANGELOG_FILE"
git commit -m "chore: bump version to $NEW_VERSION"
git push origin master  # Change branch name if needed

# Publish to pub.dev
echo "Publishing package to pub.dev..."
dart pub publish --force

echo "✅ Version updated and package published successfully!"
