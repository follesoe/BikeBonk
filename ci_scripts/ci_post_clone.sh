#!/bin/sh

# ci_post_clone.sh
# Runs after Xcode Cloud clones the repository.
#
# Available environment variables:
#   CI_BUILD_NUMBER             - Xcode Cloud build number
#   CI_WORKFLOW                 - Workflow name
#   CI_PRIMARY_REPOSITORY_PATH  - Path to cloned repository
#   CI_BRANCH                   - Git branch name
#   CI_COMMIT                   - Git commit SHA

set -e

echo "🚴 BikeBonk CI: Post-clone script running..."
echo "   Build number: ${CI_BUILD_NUMBER:-local}"
echo "   Branch: ${CI_BRANCH:-unknown}"
echo "   Commit: ${CI_COMMIT:-unknown}"

# Build number is set via CURRENT_PROJECT_VERSION in Xcode Cloud workflow settings
# Export compliance is set via INFOPLIST_KEY_ITSAppUsesNonExemptEncryption in build settings

echo "✅ Post-clone complete"
