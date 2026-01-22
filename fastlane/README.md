# App Store Metadata

This folder contains App Store metadata in [fastlane](https://fastlane.tools/) format. This structure can be used for:

1. **Manual submission** - Copy/paste content from the text files
2. **Fastlane automation** - Run `fastlane deliver` to upload metadata
3. **Xcode Cloud** - Add a fastlane step to your workflow

## Directory Structure

```
fastlane/
└── metadata/
    ├── en-US/                    # English (US)
    │   ├── name.txt              # App name (30 chars max)
    │   ├── subtitle.txt          # Subtitle (30 chars max)
    │   ├── description.txt       # Full description (4000 chars max)
    │   ├── keywords.txt          # Search keywords (100 chars max, comma-separated)
    │   ├── promotional_text.txt  # Promotional text (170 chars max)
    │   ├── release_notes.txt     # What's New (4000 chars max)
    │   ├── privacy_url.txt       # Privacy policy URL
    │   ├── support_url.txt       # Support URL
    │   └── marketing_url.txt     # Marketing URL
    └── nb-NO/                    # Norwegian (Bokmål)
        └── ... (same files)
```

## Character Limits

| Field | Limit |
|-------|-------|
| Name | 30 characters |
| Subtitle | 30 characters |
| Keywords | 100 characters |
| Promotional Text | 170 characters |
| Description | 4000 characters |
| Release Notes | 4000 characters |
| Privacy URL | Valid URL |
| Support URL | Valid URL |
| Marketing URL | Valid URL |

## Quick Reference

### English

**Name:** BikeBonk
**Subtitle:** Roof Rack Reminder
**Promotional Text:** Don't let a garage door ruin your day! BikeBonk reminds you when bikes are on your roof with widgets, Siri, and Apple Watch.

### Norwegian

**Name:** BikeBonk
**Subtitle:** Takstativ-påminnelse
**Promotional Text:** Ikke la garasjeporten ødelegge dagen! BikeBonk minner deg på når syklene er på taket med widgets, Siri og Apple Watch.

## Using with Fastlane

### Initial Setup

```bash
# Install fastlane
brew install fastlane

# Initialize in project (if not already done)
cd /path/to/BikeBonk
fastlane init
```

### Download Existing Metadata

```bash
# Download current App Store metadata to this folder
fastlane deliver download_metadata
```

### Upload Metadata

```bash
# Upload metadata to App Store Connect (without submitting)
fastlane deliver --skip_binary_upload --skip_screenshots

# Upload and submit for review
fastlane deliver
```

## Using with Xcode Cloud

Add a custom build script that runs fastlane:

```bash
#!/bin/bash
# ci_scripts/ci_post_xcodebuild.sh

if [ "$CI_WORKFLOW" = "Release" ]; then
    brew install fastlane
    fastlane deliver --skip_binary_upload
fi
```

## Updating Release Notes

Before each release, update the `release_notes.txt` files in both language folders:

1. Edit `metadata/en-US/release_notes.txt`
2. Edit `metadata/nb-NO/release_notes.txt`
3. Commit the changes
4. Build and submit

## App Store Connect URLs

- [App Store Connect](https://appstoreconnect.apple.com/)
- [App Analytics](https://appstoreconnect.apple.com/analytics)

## URLs

The following URLs are configured for both locales:

| Field | URL |
|-------|-----|
| Privacy Policy | https://github.com/follesoe/BikeBonk#privacy-policy |
| Support | https://github.com/follesoe/BikeBonk/issues |
| Marketing | https://github.com/follesoe/BikeBonk |

## Screenshots

Screenshots can be added to:

```
fastlane/screenshots/
├── en-US/
│   ├── iPhone 15 Pro Max-1.png
│   ├── iPhone 15 Pro Max-2.png
│   └── ...
└── nb-NO/
    └── ...
```

Use `fastlane snapshot` to automate screenshot generation.
