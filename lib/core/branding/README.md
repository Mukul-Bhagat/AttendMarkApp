# AttendMark Brand Logo System

## Overview

Centralized brand logo system for AttendMark Flutter app. Provides reusable, theme-aware widgets for consistent branding across the app.

## Available Widgets

### 1. AppBrandLogo

Main AttendMark branding widget.

**Usage:**
```dart
import 'package:attend_mark/core/branding/brand_widgets.dart';

// Default size (80px)
const AppBrandLogo()

// Custom size
const AppBrandLogo(size: 120)

// Custom width/height
const AppBrandLogo(width: 200, height: 80)
```

**Features:**
- Automatically switches between light/dark mode logos
- Light mode: `app_logo_black.png`
- Dark mode: `app_logo_white.png`
- Preserves original colors (no tinting)
- Default size: 80px

**Where to use:**
- Login screen (top branding)
- Dashboard header (small size: 28px)
- Profile header (optional)
- Splash/loading screen (large: 120px)

---

### 2. PoweredByAiAlly

Secondary branding widget - subtle and professional.

**Usage:**
```dart
import 'package:attend_mark/core/branding/brand_widgets.dart';

// Default (centered, 20px logo)
const PoweredByAiAlly()

// Custom size and alignment
const PoweredByAiAlly(
  logoHeight: 24,
  alignment: MainAxisAlignment.start,
)
```

**Features:**
- Shows "Powered by" text with Ai Ally logo
- Automatically switches between light/dark mode logos
- Light mode: `aiallyblacklogo.png`
- Dark mode: `aiallywhitelogo.png`
- Preserves original colors (no tinting)
- Default logo height: 20px

**Where to use:**
- Login screen (bottom)
- Profile screen (footer)
- About section (if added later)

---

## Logo Assets

All logo assets are located in `assets/logo/`:

- `app_logo_black.png` - AttendMark logo for LIGHT MODE
- `app_logo_white.png` - AttendMark logo for DARK MODE
- `aiallyblacklogo.png` - Ai Ally logo for LIGHT MODE
- `aiallywhitelogo.png` - Ai Ally logo for DARK MODE
- `app_Icon.png` - App launcher icon (DO NOT use in UI)

**Important:**
- DO NOT rename these files
- DO NOT recolor or tint logos
- DO NOT use `app_Icon.png` inside app UI (launcher only)

---

## Design Rules

1. **Theme Awareness**
   - All widgets automatically detect theme using `Theme.of(context).brightness`
   - No hardcoded theme checks needed

2. **Color Preservation**
   - Logos preserve original colors
   - No tinting or recoloring
   - `color: null` is explicitly set

3. **No Hardcoded Colors**
   - All text colors use `ColorScheme`
   - Theme-aware styling throughout

4. **Brand Hierarchy**
   - AppBrandLogo: Primary branding (larger, prominent)
   - PoweredByAiAlly: Secondary branding (smaller, subtle)

---

## Centralized System

### Brand Logo Paths

Logo paths are centralized in `brand_logo_paths.dart`:

```dart
import 'package:attend_mark/core/branding/brand_logo_paths.dart';

BrandLogoPaths.attendMarkLight  // 'assets/logo/app_logo_black.png'
BrandLogoPaths.attendMarkDark   // 'assets/logo/app_logo_white.png'
BrandLogoPaths.aiAllyLight      // 'assets/logo/aiallyblacklogo.png'
BrandLogoPaths.aiAllyDark       // 'assets/logo/aiallywhitelogo.png'
```

### Brand Widgets Export

Import all brand widgets from a single location:

```dart
import 'package:attend_mark/core/branding/brand_widgets.dart';

// Now you can use:
// - AppBrandLogo
// - PoweredByAiAlly
```

---

## Migration Guide

### Old Code (Deprecated)
```dart
// Old file removed - use app_brand_logo.dart instead
import '../../widgets/app_brand_logo.dart';
const AppBrandLogo(size: 80)
```

### New Code (Recommended)
```dart
import '../../core/branding/brand_widgets.dart';
const AppBrandLogo(size: 80)
```

**Note:** `AppLogo` is still available as a deprecated alias for backward compatibility, but `AppBrandLogo` is recommended for new code.

---

## Examples

### Login Screen
```dart
Column(
  children: [
    const AppBrandLogo(size: 80),
    const SizedBox(height: 24),
    // Login form...
    const Spacer(),
    const PoweredByAiAlly(),
  ],
)
```

### Dashboard Header
```dart
AppBar(
  title: Row(
    children: [
      const AppBrandLogo(size: 28),
      const SizedBox(width: 12),
      const Text('Dashboard'),
    ],
  ),
)
```

### Profile Footer
```dart
Column(
  children: [
    // Profile content...
    const SizedBox(height: 32),
    const PoweredByAiAlly(),
  ],
)
```

---

## Best Practices

1. **Always use centralized widgets** - Don't create custom logo implementations
2. **Use appropriate sizes** - Follow size guidelines for each screen
3. **Maintain brand hierarchy** - AppBrandLogo should be more prominent than PoweredByAiAlly
4. **Theme awareness** - Widgets handle theme switching automatically
5. **Error handling** - Widgets include fallback text if images fail to load

---

**Status:** ✅ Production Ready
**Last Updated:** Brand Logo System Implementation

