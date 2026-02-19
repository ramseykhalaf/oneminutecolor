# OneMinuteColor iOS App

A minimal SwiftUI iOS app with two actions:

- `Start 1 Minute Color`: runs a shortcut named `One Minute Color`
- `Install Shortcut`: opens your published iCloud Shortcut link so users can install it in one tap

## What this app does

iOS does not allow third-party apps to force grayscale directly. This app delegates that behavior to Apple Shortcuts.

Your shortcut should do:

1. `Set Color Filters` -> `Off`
2. `Wait` -> `60 seconds`
3. `Set Color Filters` -> `On` (with Grayscale configured in Accessibility)

## One-time setup for the app developer

1. Build the shortcut in the Shortcuts app.
2. Share it to get an iCloud link.
3. Replace `shortcutInstallURLString` in:
   - `OneMinuteColor/ContentView.swift`

## End-user flow

1. Open app and tap `Install Shortcut` (one-time).
2. Tap `Start 1 Minute Color`.
3. In Shortcuts app, add that shortcut to Control Center for fast access.

## Project

- Xcode project: `OneMinuteColor.xcodeproj`
- App sources: `OneMinuteColor/`

## Run tests

```bash
env SWIFTPM_MODULECACHE_OVERRIDE=/tmp/swift-module-cache CLANG_MODULE_CACHE_PATH=/tmp/swift-module-cache swift test --disable-sandbox --scratch-path /tmp/oneminutecolor-build
```
