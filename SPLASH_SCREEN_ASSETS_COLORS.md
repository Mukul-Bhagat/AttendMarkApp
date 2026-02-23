# AttendMark Splash Screen - Assets & Colors Specification

## 📦 **ASSET DEFINITION**

### Available Assets

#### Primary Brand Logo
**Location**: `assets/logo/`

| Asset File | Theme | Usage | Notes |
|------------|-------|-------|-------|
| `app_logo_black.png` | Light Mode | Primary brand display | Black logo for light backgrounds |
| `app_logo_white.png` | Dark Mode | Primary brand display | White logo for dark backgrounds |

**Asset Rules**:
- ✅ **DO NOT RENAME** - File names must remain exactly as specified
- ✅ **DO NOT TINT** - Logos must preserve original colors
- ✅ **DO NOT MODIFY** - Use assets as-is, no color adjustments
- ✅ **Theme-Aware** - Automatically switch based on system theme

**Asset Paths**:
```dart
// Light Mode
'assets/logo/app_logo_black.png'

// Dark Mode
'assets/logo/app_logo_white.png'
```

**Implementation Reference**:
- Use `AppBrandLogo` widget (already implemented)
- Widget automatically switches based on `Theme.of(context).brightness`
- No manual theme detection needed in splash screen

---

## 🎨 **COLOR SPECIFICATION**

### Primary Brand Color

#### Red Tick Mark Color
**Hex**: `#f04129`  
**RGB**: `rgb(240, 65, 41)`  
**Usage**: Red tick/checkmark (✔)  
**Theme Behavior**: **CONSTANT** - Same color in both light and dark mode

**Color Rules**:
- ✅ **MUST REMAIN RED** - Never change to match theme
- ✅ **NO TINTING** - Use exact color `#f04129`
- ✅ **CONSTANT ACROSS THEMES** - Same red in light and dark mode
- ✅ **BRAND IDENTITY** - This is the brand accent color

**Implementation**:
```dart
// Use AppTheme.primary constant
Color tickColor = AppTheme.primary; // #f04129

// Or direct color
Color tickColor = Color(0xFFf04129); // #f04129
```

**Meaning**:
- ✓ Attendance marked
- ✓ Verified
- ✓ Completed
- ✓ Trust

---

### Background Colors

#### Light Mode Background
**Hex**: `#f8f7f5`  
**RGB**: `rgb(248, 247, 245)`  
**Usage**: Splash screen background (light theme)  
**Description**: Warm, clean off-white

**Implementation**:
```dart
Color lightBackground = AppTheme.lightBackground; // #f8f7f5
```

#### Dark Mode Background
**Hex**: `#0f172a`  
**RGB**: `rgb(15, 23, 42)`  
**Usage**: Splash screen background (dark theme)  
**Description**: Deep, professional dark blue

**Implementation**:
```dart
Color darkBackground = AppTheme.darkBackground; // #0f172a
```

**Background Rules**:
- ✅ **Theme-Aware** - Automatically switch based on system theme
- ✅ **Solid Color** - No gradients, no patterns
- ✅ **Clean Canvas** - Provides clean backdrop for brand elements

---

### Logo Colors (From Assets)

#### Light Mode Logo
**Source**: `app_logo_black.png`  
**Color**: Black (from asset file)  
**Usage**: Displayed on light background (`#f8f7f5`)

#### Dark Mode Logo
**Source**: `app_logo_white.png`  
**Color**: White (from asset file)  
**Usage**: Displayed on dark background (`#0f172a`)

**Logo Color Rules**:
- ✅ **NO TINTING** - Use original asset colors
- ✅ **NO COLOR MODIFICATION** - Preserve original logo colors
- ✅ **Theme-Aware Selection** - Switch asset based on theme, not color
- ✅ **Asset-Based** - Colors come from PNG files, not code

---

## 🎨 **COLOR PALETTE SUMMARY**

### Complete Color Palette

| Element | Light Mode | Dark Mode | Constant? |
|---------|------------|-----------|-----------|
| **Background** | `#f8f7f5` | `#0f172a` | ❌ Theme-aware |
| **Logo** | Black (asset) | White (asset) | ❌ Theme-aware |
| **Tick Mark** | `#f04129` | `#f04129` | ✅ **CONSTANT** |
| **Glow Effect** | `#f04129` @ 10% | `#f04129` @ 10% | ✅ **CONSTANT** |

### Color Usage Rules

1. **Background**: Theme-aware (switches with system theme)
2. **Logo**: Theme-aware (switches asset file with theme)
3. **Tick Mark**: **CONSTANT** (always red `#f04129`)
4. **Glow Effect**: **CONSTANT** (always red `#f04129` at 10% opacity)

---

## 🎨 **THEME-AWARE BEHAVIOR**

### Automatic Theme Detection

**Method**: `Theme.of(context).brightness`

**Behavior**:
```dart
final brightness = Theme.of(context).brightness;
final isDark = brightness == Brightness.dark;

// Background
final backgroundColor = isDark 
    ? AppTheme.darkBackground  // #0f172a
    : AppTheme.lightBackground; // #f8f7f5

// Logo Asset
final logoPath = isDark
    ? 'assets/logo/app_logo_white.png'
    : 'assets/logo/app_logo_black.png';
```

### Theme-Specific Elements

| Element | Light Mode | Dark Mode | Behavior |
|---------|------------|-----------|----------|
| Background | `#f8f7f5` | `#0f172a` | ✅ Switches |
| Logo Asset | `app_logo_black.png` | `app_logo_white.png` | ✅ Switches |
| Tick Color | `#f04129` | `#f04129` | ❌ Constant |
| Glow Color | `#f04129` @ 10% | `#f04129` @ 10% | ❌ Constant |

---

## 🚫 **RULES & CONSTRAINTS**

### Asset Rules

#### ✅ DO
- ✅ Use `app_logo_black.png` for light mode
- ✅ Use `app_logo_white.png` for dark mode
- ✅ Preserve original logo colors (no tinting)
- ✅ Switch assets based on theme
- ✅ Use exact asset file names

#### ❌ DON'T
- ❌ Rename asset files
- ❌ Tint or recolor logos
- ❌ Modify logo assets
- ❌ Use one logo for both themes
- ❌ Hardcode asset paths in multiple places

### Color Rules

#### ✅ DO
- ✅ Use `#f04129` for tick mark (constant)
- ✅ Use `#f8f7f5` for light background
- ✅ Use `#0f172a` for dark background
- ✅ Keep tick red in both themes
- ✅ Use theme-aware background switching

#### ❌ DON'T
- ❌ Change tick color based on theme
- ❌ Tint logos to match theme
- ❌ Use gradients or patterns
- ❌ Add additional graphics
- ❌ Modify brand colors

### Graphics Rules

#### ✅ DO
- ✅ Use only AttendMark logo
- ✅ Use only red tick mark
- ✅ Keep design minimal
- ✅ Focus on brand elements

#### ❌ DON'T
- ❌ Add decorative graphics
- ❌ Add text or slogans
- ❌ Add patterns or gradients
- ❌ Add additional icons
- ❌ Overcomplicate design

---

## 📐 **ASSET SPECIFICATIONS**

### Logo Assets

#### File Specifications
- **Format**: PNG (with transparency)
- **Location**: `assets/logo/`
- **Naming**: Exact as specified (no changes)
- **Colors**: Original colors preserved

#### Usage Specifications
- **Size**: 140px × 140px (or proportional)
- **Position**: Center of screen
- **Theme Detection**: Automatic via `Theme.of(context).brightness`
- **Tinting**: **NONE** - `color: null` in Image.asset

### Tick Mark (Custom Drawn)

#### Specifications
- **Type**: Custom drawn (not an asset file)
- **Color**: `#f04129` (constant)
- **Size**: 40px × 40px
- **Stroke Width**: 5px
- **Style**: Smooth checkmark curve
- **Position**: Top-right of logo area

#### Implementation
- **Method**: CustomPaint with CustomPainter
- **Color**: `AppTheme.primary` or `Color(0xFFf04129)`
- **Theme Behavior**: **CONSTANT** (always red)

---

## 🎨 **COLOR REFERENCE TABLE**

### Exact Color Values

| Color Name | Hex | RGB | Usage |
|------------|-----|-----|-------|
| **Primary Red** | `#f04129` | `rgb(240, 65, 41)` | Tick mark, glow |
| **Light Background** | `#f8f7f5` | `rgb(248, 247, 245)` | Light mode background |
| **Dark Background** | `#0f172a` | `rgb(15, 23, 42)` | Dark mode background |
| **Logo (Light)** | Black | From asset | Light mode logo |
| **Logo (Dark)** | White | From asset | Dark mode logo |

### Color Constants (AppTheme)

```dart
// Primary Red (Tick Mark)
AppTheme.primary          // #f04129

// Backgrounds
AppTheme.lightBackground  // #f8f7f5
AppTheme.darkBackground   // #0f172a
```

---

## 📁 **ASSET FILE STRUCTURE**

### Directory Structure
```
assets/
└── logo/
    ├── app_logo_black.png  → Light mode logo
    └── app_logo_white.png  → Dark mode logo
```

### Asset Registration

**File**: `pubspec.yaml`
```yaml
flutter:
  assets:
    - assets/logo/
```

**Status**: ✅ Already registered

---

## ✅ **ASSET & COLOR CHECKLIST**

### Assets
- [x] `app_logo_black.png` exists in `assets/logo/`
- [x] `app_logo_white.png` exists in `assets/logo/`
- [x] Assets registered in `pubspec.yaml`
- [x] No asset renaming required
- [x] No asset modification required

### Colors
- [x] Primary red defined: `#f04129`
- [x] Light background defined: `#f8f7f5`
- [x] Dark background defined: `#0f172a`
- [x] Colors match AppTheme constants
- [x] Tick color constant across themes

### Rules
- [x] No logo tinting
- [x] Tick color remains red in both themes
- [x] No additional graphics
- [x] Theme-aware asset switching
- [x] Asset colors preserved

---

## 🎯 **IMPLEMENTATION GUIDANCE**

### Asset Usage
```dart
// Use AppBrandLogo widget (recommended)
const AppBrandLogo(size: 140)

// Or manual implementation
final brightness = Theme.of(context).brightness;
final logoPath = brightness == Brightness.dark
    ? 'assets/logo/app_logo_white.png'
    : 'assets/logo/app_logo_black.png';

Image.asset(
  logoPath,
  width: 140,
  height: 140,
  color: null, // NO TINTING
)
```

### Color Usage
```dart
// Background
final backgroundColor = Theme.of(context).brightness == Brightness.dark
    ? AppTheme.darkBackground   // #0f172a
    : AppTheme.lightBackground; // #f8f7f5

// Tick Mark (CONSTANT - always red)
final tickColor = AppTheme.primary; // #f04129

// Glow Effect (CONSTANT - always red)
final glowColor = AppTheme.primary.withValues(alpha: 0.1); // #f04129 @ 10%
```

---

**Status**: ✅ **ASSETS & COLORS DEFINED**

**Brand Compliance**: ✅ **100% ALIGNED**

**Ready for Implementation**: ✅ **YES**

