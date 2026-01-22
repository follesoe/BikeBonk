#!/bin/sh

# ci_post_clone.sh
# Runs after Xcode Cloud clones the repository.
#
# Available environment variables:
#   CI_BUILD_NUMBER      - Xcode Cloud build number
#   CI_WORKFLOW          - Workflow name
#   CI_XCODE_PROJECT     - Path to .xcodeproj
#   CI_BRANCH            - Git branch name
#   CI_COMMIT            - Git commit SHA

set -e

echo "🚴 BikeBonk CI: Post-clone script running..."
echo "   Build number: ${CI_BUILD_NUMBER:-local}"
echo "   Branch: ${CI_BRANCH:-unknown}"
echo "   Commit: ${CI_COMMIT:-unknown}"

# Automatically set build number from Xcode Cloud build number
if [ -n "$CI_BUILD_NUMBER" ]; then
    echo "📝 Setting build number to $CI_BUILD_NUMBER..."

    # Update iOS app
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $CI_BUILD_NUMBER" "$CI_WORKSPACE/BikeBonk/Info.plist" 2>/dev/null || true

    # Update watchOS app
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $CI_BUILD_NUMBER" "$CI_WORKSPACE/BikeBonkWatch/Info.plist" 2>/dev/null || true

    # For projects using CURRENT_PROJECT_VERSION in build settings (more common):
    cd "$CI_WORKSPACE"
    agvtool new-version -all "$CI_BUILD_NUMBER" 2>/dev/null || echo "   agvtool not configured, skipping"
fi

echo "✅ Post-clone complete"
