#!/bin/bash
#
# capture-screenshots.sh
# Captures App Store screenshots for BikeBonk on multiple devices and languages.
#
# Usage: ./scripts/capture-screenshots.sh [ios|watch|widget|all]
#

set -e

# Configuration
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="$PROJECT_DIR/fastlane/screenshots"
DERIVED_DATA="$PROJECT_DIR/.screenshots-derived-data"

# iOS Device configurations for App Store (2026)
IOS_DEVICES=(
    "iPhone 17 Pro Max"
    "iPad Pro 13-inch (M5)"
)

# watchOS Device configurations
WATCH_DEVICES=(
    "Apple Watch Ultra 3 (49mm)"
)

# Language configurations
# Format: "locale_folder|AppleLanguages|AppleLocale"
LANGUAGES=(
    "en-US|en|en_US"
    "nb-NO|nb|nb_NO"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}BikeBonk Screenshot Automation${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Create output directories for all languages
for lang_config in "${LANGUAGES[@]}"; do
    IFS='|' read -r locale_folder _ _ <<< "$lang_config"
    mkdir -p "$OUTPUT_DIR/$locale_folder"
done

# Clean derived data
rm -rf "$DERIVED_DATA"

# Function to capture iOS screenshots for a device in a specific language
capture_ios() {
    local simulator_name="$1"
    local locale_folder="$2"
    local apple_languages="$3"
    local apple_locale="$4"
    local safe_name="${simulator_name// /-}"

    echo -e "${YELLOW}📱 $simulator_name (${locale_folder})${NC}"

    # Shutdown any running simulators first
    xcrun simctl shutdown all 2>/dev/null || true
    sleep 1

    # Boot simulator
    xcrun simctl boot "$simulator_name" 2>/dev/null || true
    sleep 3

    # Build the app (only needed once per device, but keeping it simple)
    if [ ! -d "$DERIVED_DATA/Build/Products/Debug-iphonesimulator/BikeBonk.app" ]; then
        echo "  Building..."
        xcodebuild build \
            -project "$PROJECT_DIR/BikeBonk.xcodeproj" \
            -scheme "BikeBonk" \
            -destination "platform=iOS Simulator,name=$simulator_name" \
            -derivedDataPath "$DERIVED_DATA" \
            -quiet \
            2>/dev/null
    fi

    # Get the app path
    local app_path=$(find "$DERIVED_DATA" -name "BikeBonk.app" -path "*/Debug-iphonesimulator/*" -type d | head -1)

    if [ -n "$app_path" ]; then
        # Install the app
        xcrun simctl install booted "$app_path"

        # Language arguments
        local lang_args="-AppleLanguages ($apple_languages) -AppleLocale $apple_locale"

        # Screenshot: Safe state
        xcrun simctl terminate booted "no.follesoe.BikeBonkApp" 2>/dev/null || true
        xcrun simctl launch booted "no.follesoe.BikeBonkApp" -SCREENSHOT_MODE -BIKES_MOUNTED NO $lang_args
        sleep 2
        xcrun simctl io booted screenshot "$OUTPUT_DIR/$locale_folder/${safe_name}-1-safe.png" --type png
        echo -e "  ${GREEN}✓${NC} Safe state"

        # Screenshot: Warning state
        xcrun simctl terminate booted "no.follesoe.BikeBonkApp"
        xcrun simctl launch booted "no.follesoe.BikeBonkApp" -SCREENSHOT_MODE -BIKES_MOUNTED YES $lang_args
        sleep 2
        xcrun simctl io booted screenshot "$OUTPUT_DIR/$locale_folder/${safe_name}-2-warning.png" --type png
        echo -e "  ${GREEN}✓${NC} Warning state"

        # Terminate
        xcrun simctl terminate booted "no.follesoe.BikeBonkApp" 2>/dev/null || true
    else
        echo -e "  ${RED}✗${NC} Failed to find app bundle"
    fi

    # Shutdown simulator
    xcrun simctl shutdown "$simulator_name" 2>/dev/null || true
}

# Function to capture watchOS screenshots
capture_watch() {
    local watch_name="$1"
    local locale_folder="$2"
    local apple_languages="$3"
    local apple_locale="$4"
    local safe_name="${watch_name// /-}"

    echo -e "${YELLOW}⌚ $watch_name (${locale_folder})${NC}"

    # Shutdown all simulators
    xcrun simctl shutdown all 2>/dev/null || true
    sleep 1

    # Boot the watch simulator
    xcrun simctl boot "$watch_name" 2>/dev/null || true

    # Wait for the simulator to fully boot
    echo "  Waiting for simulator to boot..."
    xcrun simctl bootstatus "$watch_name" -b 2>/dev/null || sleep 10
    sleep 5

    # Build the watch app
    if [ ! -d "$DERIVED_DATA/Build/Products/Debug-watchsimulator/BikeBonkWatch.app" ]; then
        echo "  Building..."
        xcodebuild build \
            -project "$PROJECT_DIR/BikeBonk.xcodeproj" \
            -scheme "BikeBonkWatch" \
            -destination "platform=watchOS Simulator,name=$watch_name" \
            -derivedDataPath "$DERIVED_DATA" \
            -quiet \
            2>/dev/null || true
    fi

    # Get the watch app path
    local app_path=$(find "$DERIVED_DATA" -name "BikeBonkWatch.app" -path "*/Debug-watchsimulator/*" -type d | head -1)

    if [ -n "$app_path" ]; then
        # Install the app
        xcrun simctl install booted "$app_path"

        # Language arguments
        local lang_args="-AppleLanguages ($apple_languages) -AppleLocale $apple_locale"

        # Screenshot: Safe state
        xcrun simctl terminate booted "no.follesoe.BikeBonkApp.watchkitapp" 2>/dev/null || true
        xcrun simctl launch booted "no.follesoe.BikeBonkApp.watchkitapp" -SCREENSHOT_MODE -BIKES_MOUNTED NO $lang_args
        sleep 5
        xcrun simctl io booted screenshot "$OUTPUT_DIR/$locale_folder/${safe_name}-1-safe.png" --type png
        echo -e "  ${GREEN}✓${NC} Safe state"

        # Screenshot: Warning state
        xcrun simctl terminate booted "no.follesoe.BikeBonkApp.watchkitapp"
        xcrun simctl launch booted "no.follesoe.BikeBonkApp.watchkitapp" -SCREENSHOT_MODE -BIKES_MOUNTED YES $lang_args
        sleep 5
        xcrun simctl io booted screenshot "$OUTPUT_DIR/$locale_folder/${safe_name}-2-warning.png" --type png
        echo -e "  ${GREEN}✓${NC} Warning state"

        # Terminate
        xcrun simctl terminate booted "no.follesoe.BikeBonkApp.watchkitapp" 2>/dev/null || true
    else
        echo -e "  ${RED}✗${NC} Failed to find watch app bundle"
    fi

    # Shutdown simulator
    xcrun simctl shutdown "$watch_name" 2>/dev/null || true
}

# Function to show widget screenshot instructions
widget_instructions() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Widget Screenshots (Manual Steps)${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "Widgets cannot be automatically captured via UI tests."
    echo "To capture widget screenshots:"
    echo ""
    echo "1. Run the simulator:"
    echo "   xcrun simctl boot 'iPhone 17 Pro Max'"
    echo "   open -a Simulator"
    echo ""
    echo "2. Change language (for Norwegian):"
    echo "   Settings → General → Language & Region → Add Norwegian"
    echo ""
    echo "3. Add the BikeBonk widget to the home screen:"
    echo "   - Long press on home screen"
    echo "   - Tap '+' button"
    echo "   - Search for 'BikeBonk'"
    echo "   - Add the widget"
    echo ""
    echo "4. Capture the screenshot:"
    echo "   xcrun simctl io booted screenshot widget-screenshot.png"
    echo ""
    echo "Alternatively, use Xcode's SwiftUI Preview canvas:"
    echo "   - Open BikeBonkWidget.swift"
    echo "   - Use the preview canvas"
    echo "   - Right-click preview → 'Export...'"
    echo ""
}

# Main execution
MODE="${1:-all}"

echo "Output directory: $OUTPUT_DIR"
echo "Mode: $MODE"
echo "Languages: English (en-US), Norwegian (nb-NO)"
echo ""

case "$MODE" in
    ios)
        for lang_config in "${LANGUAGES[@]}"; do
            IFS='|' read -r locale_folder apple_languages apple_locale <<< "$lang_config"
            echo -e "${BLUE}=== iOS Screenshots ($locale_folder) ===${NC}"
            echo ""
            for device in "${IOS_DEVICES[@]}"; do
                capture_ios "$device" "$locale_folder" "$apple_languages" "$apple_locale"
                echo ""
            done
        done
        ;;
    watch)
        for lang_config in "${LANGUAGES[@]}"; do
            IFS='|' read -r locale_folder apple_languages apple_locale <<< "$lang_config"
            echo -e "${BLUE}=== watchOS Screenshots ($locale_folder) ===${NC}"
            echo ""
            for device in "${WATCH_DEVICES[@]}"; do
                capture_watch "$device" "$locale_folder" "$apple_languages" "$apple_locale"
                echo ""
            done
        done
        ;;
    widget)
        widget_instructions
        ;;
    all)
        for lang_config in "${LANGUAGES[@]}"; do
            IFS='|' read -r locale_folder apple_languages apple_locale <<< "$lang_config"

            echo -e "${BLUE}=== iOS Screenshots ($locale_folder) ===${NC}"
            echo ""
            for device in "${IOS_DEVICES[@]}"; do
                capture_ios "$device" "$locale_folder" "$apple_languages" "$apple_locale"
                echo ""
            done

            echo -e "${BLUE}=== watchOS Screenshots ($locale_folder) ===${NC}"
            echo ""
            for device in "${WATCH_DEVICES[@]}"; do
                capture_watch "$device" "$locale_folder" "$apple_languages" "$apple_locale"
                echo ""
            done
        done

        widget_instructions
        ;;
    *)
        echo "Usage: $0 [ios|watch|widget|all]"
        exit 1
        ;;
esac

# Cleanup
rm -rf "$DERIVED_DATA"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Screenshots saved to:${NC}"
echo "$OUTPUT_DIR/"
echo ""
for lang_config in "${LANGUAGES[@]}"; do
    IFS='|' read -r locale_folder _ _ <<< "$lang_config"
    echo -e "${BLUE}$locale_folder:${NC}"
    ls "$OUTPUT_DIR/$locale_folder/"*.png 2>/dev/null | wc -l | xargs echo "  " "files"
done
echo -e "${GREEN}========================================${NC}"
