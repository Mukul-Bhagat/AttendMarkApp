# AttendMark Branding Widgets

## ✅ **Widgets Created**

### 1. AppBrandLogo Widget
**File:** `lib/widgets/app_brand_logo.dart`

**Purpose:** Primary AttendMark branding

**Features:**
- ✅ Theme-aware using `Theme.of(context).brightness`
- ✅ Light Mode → `app_logo_black.png`
- ✅ Dark Mode → `app_logo_white.png`
- ✅ Stateless widget
- ✅ Size parameter (default: 80px)
- ✅ Preserves original colors (no tinting)
- ✅ No hardcoded colors

**Usage:**
```dart
import 'package:attend_mark/core/branding/brand_widgets.dart';

// Default size (80px)
const AppBrandLogo()

// Custom size
const AppBrandLogo(size: 120)

// Custom dimensions
const AppBrandLogo(width: 200, height: 80)
```

**Where to use:**
- Login screen (top)
- Dashboard header (small)
- Profile header (optional)

---

### 2. PoweredByAiAlly Widget
**File:** `lib/widgets/powered_by_ai_ally.dart`

**Purpose:** Secondary branding only - matches website behavior

**Features:**
- ✅ Theme-aware using `Theme.of(context).brightness`
- ✅ Light Mode → `aiallyblacklogo.png`
- ✅ Dark Mode → `aiallywhitelogo.png`
- ✅ Text: "Powered by"
- ✅ Small font size (11px)
- ✅ Logo height: 14-16px (default: 15px)
- ✅ Secondary text color (low opacity)
- ✅ Low visual priority
- ✅ Stateless widget
- ✅ Preserves original colors (no tinting)
- ✅ No hardcoded colors

**IMPORTANT:**
- This widget is **NOT global**
- Used **ONLY on selected screens** (Login, Profile)
- Does NOT overpower AttendMark logo

**Usage:**
```dart
import 'package:attend_mark/core/branding/brand_widgets.dart';

// Default (centered, 15px logo)
const PoweredByAiAlly()

// Custom size and alignment
const PoweredByAiAlly(
  logoHeight: 16,
  alignment: MainAxisAlignment.center,
)
```

**Where to use:**
- Login screen (bottom)
- Profile screen (footer)

---

## 📁 File Structure

```
lib/
├── widgets/
│   ├── app_brand_logo.dart          ← NEW: Primary branding widget
│   └── powered_by_ai_ally.dart     ← UPDATED: Secondary branding widget
└── core/
    └── branding/
        ├── brand_logo_paths.dart    ← Centralized logo paths
        └── brand_widgets.dart       ← Centralized exports
```

---

## 🎨 Design Specifications

### AppBrandLogo
- **Default Size:** 80px
- **Theme Detection:** `Theme.of(context).brightness`
- **Color Preservation:** `color: null` (no tinting)
- **Color Usage:** Uses `ColorScheme` for fallback text

### PoweredByAiAlly
- **Logo Height:** 14-16px (default: 15px)
- **Font Size:** 11px (small)
- **Text Color:** Secondary (opacity: 0.5)
- **Visual Priority:** Low (does not overpower primary brand)
- **Theme Detection:** `Theme.of(context).brightness`
- **Color Preservation:** `color: null` (no tinting)

---

## ✅ Implementation Checklist

- [x] AppBrandLogo widget created
- [x] PoweredByAiAlly widget updated
- [x] Theme-aware logo selection
- [x] Original colors preserved (no tinting)
- [x] No hardcoded colors
- [x] Stateless widgets
- [x] Proper file structure
- [x] Centralized exports
- [x] Documentation complete

---

## 📋 Usage Examples

### Login Screen
```dart
Column(
  children: [
    // Primary brand (top)
    const AppBrandLogo(size: 88),
    const SizedBox(height: 24),
    // Form...
    const Spacer(),
    // Secondary brand (bottom)
    const PoweredByAiAlly(logoHeight: 15),
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
    const PoweredByAiAlly(logoHeight: 15),
  ],
)
```

---

## 🔒 Rules Compliance

### ✅ Theme Switching
- Both widgets use `Theme.of(context).brightness`
- Automatic logo selection based on theme
- No manual theme checks needed

### ✅ Color Preservation
- `color: null` explicitly set on all Image.asset widgets
- Original logo colors preserved
- No tinting or recoloring

### ✅ No Hardcoded Colors
- All text colors use `ColorScheme`
- Theme-aware styling throughout
- No hardcoded color values

### ✅ Widget Scope
- AppBrandLogo: Primary branding (can be used anywhere)
- PoweredByAiAlly: Secondary branding (selected screens only)

---

## 📚 Import Guide

### Recommended Import
```dart
import 'package:attend_mark/core/branding/brand_widgets.dart';
```

This imports both:
- `AppBrandLogo`
- `PoweredByAiAlly`

### Direct Import (if needed)
```dart
import 'package:attend_mark/widgets/app_brand_logo.dart';
import 'package:attend_mark/widgets/powered_by_ai_ally.dart';
```

---

**Status:** ✅ **COMPLETE**
**Files Created:** 1 new, 1 updated
**All Specifications Met:** Yes
**Production Ready:** Yes

