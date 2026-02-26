# Week Wallpaper for iOS

A minimalistic dynamic wallpaper that visualizes your year as **52 small circles** — one per week. Past weeks fill in, the current week glows mint green, and future weeks remain as subtle outlines.

---

## Preview (conceptual layout)

```
            2 0 2 6
         WEEK 9 OF 52

           ● ● ● ●      ← filled (weeks 1-4)
           ● ● ● ●      ← filled (weeks 5-8)
           ◉ ○ ○ ○      ← current + future
           ○ ○ ○ ○
           ○ ○ ○ ○
           ○ ○ ○ ○
           ○ ○ ○ ○
           ○ ○ ○ ○
           ○ ○ ○ ○
           ○ ○ ○ ○
           ○ ○ ○ ○
           ○ ○ ○ ○
           ○ ○ ○ ○

         ━━━━━░░░░░░░░   ← progress bar
```

- **●** Solid white — week passed  
- **◉** Mint green with glow — current week  
- **○** Dim outline — future week  

---

## Setup Instructions

### 1. Create Xcode Project

1. Open **Xcode 15+** on your Mac
2. File → New → Project → **App**
3. Product Name: `WeekWallpaper`
4. Interface: **SwiftUI**
5. Language: **Swift**
6. Minimum Deployment: **iOS 16.0**

### 2. Add Source Files

Replace the auto-generated files with the ones from this folder:

| File | Purpose |
|---|---|
| `WeekWallpaperApp.swift` | App entry point |
| `ContentView.swift` | Main screen with preview + save button |
| `WallpaperView.swift` | The wallpaper rendering (circles grid) |
| `Color+Hex.swift` | Hex color extension |

### 3. Configure Info.plist

Add this key to your `Info.plist` (or in Target → Info → Custom iOS Target Properties):

| Key | Value |
|---|---|
| `NSPhotoLibraryAddUsageDescription` | `WeekWallpaper needs access to save wallpapers to your Photos.` |

### 4. Build & Run

1. Select an iPhone simulator or connect a device
2. Build and run (⌘R)
3. Tap **"Save to Photos"** to export the wallpaper
4. Go to **Settings → Wallpaper → Add New → Choose Photo** and select the saved image

---

## How It Works

- Uses `Calendar.iso8601` to determine the current ISO week number
- Renders a **4 × 13 grid** of circles (52 weeks)
- `ImageRenderer` exports the view at **1179 × 2556 px** (iPhone 15 Pro native resolution)
- Saved to Photos via `PHPhotoLibrary`

## Customization

In `WallpaperView.swift`, you can tweak:

```swift
let accentHex = "34D399"   // Change accent color
let columns = 4            // Grid columns
let rows = 13              // Grid rows
```

**Background color:** Change `"0A0A0A"` to any dark hex value.

---

## Requirements

- Xcode 15+
- iOS 16.0+ (for `ImageRenderer`)
- Swift 5.9+
