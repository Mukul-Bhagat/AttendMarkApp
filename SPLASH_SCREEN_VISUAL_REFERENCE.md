# AttendMark Splash Screen - Visual Reference

## 🎨 **VISUAL COMPOSITION**

### Layout Structure
```
┌─────────────────────────────────┐
│                                 │
│                                 │
│         [AttendMark Logo]       │
│            (140px)               │
│                                 │
│              ✓                  │
│         (Red Tick - 40px)       │
│                                 │
│                                 │
└─────────────────────────────────┘
```

### Element Positioning
- **Logo**: Center of screen (horizontal + vertical)
- **Tick Mark**: Top-right of logo area
  - Offset: ~25-30px from logo edge
  - Position: Above and to the right

---

## 🎨 **COLOR SPECIFICATIONS**

### Primary Red (Tick Mark)
- **Hex**: `#f04129`
- **RGB**: `rgb(240, 65, 41)`
- **Usage**: Tick mark stroke, glow effect
- **Opacity Variations**:
  - Tick mark: 100% opacity
  - Glow effect: 8-12% opacity

### Background Colors
- **Light Mode**: `#f8f7f5`
  - RGB: `rgb(248, 247, 245)`
  - Warm, clean off-white
- **Dark Mode**: `#0f172a`
  - RGB: `rgb(15, 23, 42)`
  - Deep, professional dark blue

### Logo Colors
- **Light Mode**: Black (from `app_logo_black.png`)
- **Dark Mode**: White (from `app_logo_white.png`)
- **No tinting**: Original colors preserved

---

## 📐 **SIZE SPECIFICATIONS**

### Logo
- **Size**: 140px × 140px (or proportional)
- **Position**: Center of screen
- **Aspect Ratio**: Maintained (no distortion)

### Tick Mark
- **Size**: 40px × 40px
- **Stroke Width**: 5px
- **Position**: Top-right of logo area
- **Offset**: 25-30px from logo edge

### Glow Effect
- **Blur Radius**: 20px (at full intensity)
- **Spread Radius**: 5px (at full intensity)
- **Color**: `#f04129` at 10% opacity (at full intensity)

---

## 🎬 **ANIMATION TIMELINE**

### Visual Timeline
```
0.0s ────────────────────────────────────────────── 3.0s
│                                                    │
│ Scene 1: Logo Entry                               │
│ [Scale: 0.95→1.0] [Opacity: 0→1]                  │
│                                                    │
│         Scene 2: Brand Emphasis                  │
│         [Glow: 0→1]                               │
│                                                    │
│                  Scene 3: Red Tick                │
│                  [Stroke: 0→1] [Scale: 0.8→1.0]    │
│                                                    │
│                           Scene 4: Exit          │
│                           [Opacity: 1.0→0.95]     │
```

### Keyframes
- **0.0s**: Animation starts, logo begins scale-in
- **0.5s**: Logo at ~50% scale, ~50% opacity
- **1.0s**: Logo fully visible, scale complete
- **1.5s**: Glow at ~50% intensity
- **2.0s**: Glow complete, tick starts drawing
- **2.4s**: Tick stroke ~50% complete
- **2.8s**: Tick complete, all elements visible
- **3.0s**: Fade out, transition to app

---

## 🎨 **VISUAL STYLE GUIDE**

### Typography
- **No text**: Logo is image-based
- **No labels**: Visual-only communication

### Spacing
- **Logo**: Centered (equal margins on all sides)
- **Tick**: 25-30px offset from logo edge
- **Padding**: Generous whitespace around elements

### Visual Hierarchy
1. **Primary**: AttendMark logo (largest, center)
2. **Secondary**: Red tick mark (smaller, accent)
3. **Tertiary**: Glow effect (subtle, supporting)

### Composition Rules
- **Center alignment**: Logo centered
- **Balance**: Tick mark provides visual balance
- **Whitespace**: Generous padding, no crowding
- **Symmetry**: Logo centered, tick positioned for balance

---

## 🎭 **ANIMATION STYLE REFERENCE**

### Motion Characteristics
- **Smooth**: No jerky movements
- **Elegant**: Refined, graceful
- **Confident**: Decisive, purposeful
- **Natural**: Human-perceived smoothness

### Easing Curves
- **Entry**: `easeOut` - Smooth deceleration
  - Starts fast, ends slow
  - Natural feeling
- **Emphasis**: `easeInOut` - Balanced
  - Smooth acceleration and deceleration
  - Stable, centered
- **Tick**: `easeOut` - Confident
  - Decisive motion
  - Purposeful completion
- **Exit**: `easeIn` - Smooth fade
  - Gentle transition
  - No abrupt cut

### Speed Profile
- **Scene 1**: Medium-fast (1s)
- **Scene 2**: Slow, stable (1s)
- **Scene 3**: Medium-fast (0.8s)
- **Scene 4**: Fast (0.2s)

---

## 🎨 **BRAND ELEMENT DETAILS**

### AttendMark Logo
- **Asset**: `app_logo_black.png` (light) / `app_logo_white.png` (dark)
- **Size**: 140px (large, prominent)
- **Position**: Center
- **Animation**: Scale-in + fade-in
- **No modifications**: Original colors, no tinting

### Red Tick Mark
- **Type**: Custom drawn checkmark
- **Color**: `#f04129` (Primary Red)
- **Size**: 40px × 40px
- **Stroke**: 5px width, rounded caps
- **Style**: Smooth, confident curve
- **Animation**: Progressive stroke drawing
- **Position**: Top-right of logo area

### Glow Effect
- **Color**: `#f04129` (Primary Red)
- **Opacity**: 8-12% (very subtle)
- **Blur**: 20px radius
- **Spread**: 5px
- **Purpose**: Subtle emphasis, not distraction

---

## 🎯 **REFERENCE INSPIRATION**

### Similar Products
- **Enterprise SaaS apps**: Clean, professional
- **Banking apps**: Trust, verification
- **Productivity apps**: Modern, minimal
- **B2B software**: Enterprise-grade feel

### Design Principles
- **Apple**: Clean, minimal, purposeful
- **Google Material**: Smooth motion, clear hierarchy
- **Enterprise SaaS**: Professional, trustworthy
- **Modern web apps**: Clean, tech-forward

---

## ✅ **VISUAL CHECKLIST**

### Composition
- [x] Logo centered (horizontal + vertical)
- [x] Tick mark positioned top-right
- [x] Generous whitespace
- [x] Balanced layout

### Colors
- [x] Background: Theme-appropriate
- [x] Logo: Theme-aware (black/white)
- [x] Tick: Brand red `#f04129`
- [x] Glow: Subtle red tint

### Sizes
- [x] Logo: 140px (prominent)
- [x] Tick: 40px (accent size)
- [x] Stroke: 5px (visible, confident)
- [x] Glow: 20px blur (subtle)

### Animation
- [x] Smooth motion curves
- [x] Appropriate timing
- [x] Purposeful movement
- [x] No jarring cuts

---

**Status**: ✅ **VISUAL REFERENCE DEFINED**

**Purpose**: Guide implementation

**Brand Compliance**: ✅ **100% ALIGNED**

