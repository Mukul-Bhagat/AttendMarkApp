# Web UI Reference - Light & Dark Mode

Complete UI information extracted from the AttendMark web application for Flutter app implementation.

## Color Palette

### Primary Colors (Used in Both Modes)
- **Primary Red**: `#f04129` (RGB: 240, 65, 41)
- **Primary Hover**: `#d63a25` (RGB: 214, 58, 37)
- **Landing Page Red**: `#D61C22` (RGB: 214, 28, 34) - Used in landing page
- **Landing Page Red Gradient**: `linear-gradient(135deg, #D61C22 0%, #A61217 100%)`

### Light Mode Colors (White & Gold Theme)
- **Background**: `#f8f7f5` (Off-white/Beige background)
- **Surface/Card**: `#ffffff` (Pure white for cards and surfaces)
- **Text Primary**: `#181511` (Dark brown/black text)
- **Text Secondary**: `#8a7b60` (Brown/gold secondary text)
- **Border**: `#e6e2db` (Light beige border)
- **Input Border**: `#e6e2db` (Light mode input borders)
- **Input Focus Border**: `#f04129` (Primary red on focus)
- **Input Focus Ring**: `rgba(240, 65, 41, 0.2)` (20% opacity red ring)

### Dark Mode Colors (Slate/Gray Theme)
- **Background**: `#0f172a` (Slate-900 - Very deep slate for main background)
- **Surface/Card**: `#1e293b` (Slate-800 for sidebar, navbar, and cards)
- **Text Primary**: `#f1f5f9` (Slate-100 - Light slate text)
- **Text Secondary**: `#cbd5e1` (Slate-300 - Secondary text)
- **Border**: `#334155` (Slate-700 - Dark borders)
- **Input Background**: `#1e293b` (Slate-800 - Dark input background)
- **Input Border**: `#475569` (Slate-600 - Dark mode input borders)
- **Input Focus Border**: `#f04129` (Primary red on focus)
- **Input Focus Ring**: `rgba(240, 65, 41, 0.2)` (20% opacity red ring)

### Additional Colors
- **Success Green**: `#10b981` (Emerald-500)
- **Warning Orange**: `#f59e0b` (Amber-500)
- **Error Red**: `#ef4444` (Red-500)
- **Info Blue**: `#3b82f6` (Blue-500)
- **Slate Colors** (used in dark mode):
  - Slate-100: `#f1f5f9`
  - Slate-300: `#cbd5e1`
  - Slate-400: `#94a3b8`
  - Slate-500: `#64748b`
  - Slate-600: `#475569`
  - Slate-700: `#334155`
  - Slate-800: `#1e293b`
  - Slate-900: `#0f172a`

## Typography

### Font Family
- **Primary**: `'Manrope', 'Hero New', 'system-ui', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'Helvetica', 'Arial', 'sans-serif'`
- Default fallback to system fonts

### Font Sizes
- **Display Large**: 32px (2rem)
- **Display Medium**: 28px (1.75rem)
- **Display Small**: 24px (1.5rem)
- **Headline**: 20px (1.25rem)
- **Title Large**: 18px (1.125rem)
- **Title Medium**: 16px (1rem)
- **Body Large**: 16px (1rem)
- **Body Medium**: 14px (0.875rem)
- **Body Small**: 12px (0.75rem)
- **Caption**: 12px (0.75rem)

### Font Weights
- **Normal**: 400
- **Medium**: 500
- **Semibold**: 600
- **Bold**: 700

## Component Styles

### Buttons

#### Primary Button
```css
/* Light & Dark Mode */
background: #f04129
color: white
hover: #d63a25
border-radius: 0.5rem (8px)
padding: 0.75rem 1rem (12px 16px)
font-weight: 600
font-size: 14px
transition: all 0.2s ease
```

#### Secondary Button (Outlined)
```css
/* Light Mode */
background: transparent
border: 1px solid #e6e2db
color: #181511
hover: background #f8f7f5

/* Dark Mode */
background: transparent
border: 1px solid #334155
color: #f1f5f9
hover: background #1e293b
```

#### Text Button
```css
/* Light Mode */
color: #f04129
hover: #d63a25

/* Dark Mode */
color: #f04129
hover: #d63a25
```

### Input Fields

#### Text Input
```css
/* Light Mode */
background: #ffffff
border: 1px solid #e6e2db
color: #181511
placeholder: #8a7b60
focus-border: #f04129
focus-ring: rgba(240, 65, 41, 0.2)
border-radius: 0.5rem (8px)
padding: 0.75rem 1rem (12px 16px)

/* Dark Mode */
background: #1e293b
border: 1px solid #475569
color: #f1f5f9
placeholder: #94a3b8
focus-border: #f04129
focus-ring: rgba(240, 65, 41, 0.2)
border-radius: 0.5rem (8px)
padding: 0.75rem 1rem (12px 16px)
```

### Cards

#### Standard Card
```css
/* Light Mode */
background: #ffffff
border: 1px solid #e6e2db
border-radius: 0.75rem (12px)
padding: 1rem (16px)
box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1)

/* Dark Mode */
background: #1e293b
border: 1px solid #334155
border-radius: 0.75rem (12px)
padding: 1rem (16px)
box-shadow: 0 1px 3px rgba(0, 0, 0, 0.3)
```

#### Glass Card (Landing Page)
```css
background: rgba(255, 255, 255, 0.03)
border: 1px solid rgba(255, 255, 255, 0.1)
backdrop-filter: blur(10px)
border-radius: 1rem (16px)
transition: all 0.3s ease

/* Hover Effect */
transform: translateY(-4px)
border-color: rgba(255, 255, 255, 0.2)
box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3), 0 0 20px rgba(255, 255, 255, 0.05)
```

### Navigation

#### Sidebar Navigation
```css
/* Light Mode */
background: #ffffff
border-right: 1px solid #e6e2db

/* Dark Mode */
background: #1e293b
border-right: 1px solid #334155
```

#### Active Nav Link
```css
/* Light Mode */
background: rgba(240, 65, 41, 0.1) /* #f04129 with 10% opacity */
color: #f04129
border-left: 4px solid #f04129

/* Dark Mode */
background: rgba(240, 65, 41, 0.1) /* #f04129 with 10% opacity */
color: #f04129
border-left: 4px solid #f04129
```

#### Inactive Nav Link
```css
/* Light Mode */
color: #8a7b60
hover-background: #f8f7f5
hover-color: #181511
border-left: 4px solid transparent

/* Dark Mode */
color: #cbd5e1
hover-background: rgba(30, 41, 59, 0.5) /* #1e293b with 50% opacity */
hover-color: #f1f5f9
border-left: 4px solid transparent
```

### Badges & Chips

#### Status Badge (Approved)
```css
background: rgba(16, 185, 129, 0.2) /* Success green with 20% opacity */
color: #10b981
border: 1px solid rgba(16, 185, 129, 0.5)
border-radius: 0.5rem (8px)
padding: 0.25rem 0.5rem (4px 8px)
```

#### Status Badge (Pending)
```css
background: rgba(245, 158, 11, 0.2) /* Warning orange with 20% opacity */
color: #f59e0b
border: 1px solid rgba(245, 158, 11, 0.5)
border-radius: 0.5rem (8px)
padding: 0.25rem 0.5rem (4px 8px)
```

#### Status Badge (Rejected)
```css
background: rgba(239, 68, 68, 0.2) /* Error red with 20% opacity */
color: #ef4444
border: 1px solid rgba(239, 68, 68, 0.5)
border-radius: 0.5rem (8px)
padding: 0.25rem 0.5rem (4px 8px)
```

### Alerts & Messages

#### Error Alert
```css
background: rgba(239, 68, 68, 0.1) /* Error red with 10% opacity */
border: 1px solid rgba(239, 68, 68, 0.5)
color: #ef4444
border-radius: 0.5rem (8px)
padding: 0.75rem (12px)
```

#### Success Message
```css
background: rgba(16, 185, 129, 0.1) /* Success green with 10% opacity */
border: 1px solid rgba(16, 185, 129, 0.5)
color: #10b981
border-radius: 0.5rem (8px)
padding: 0.75rem (12px)
```

### Dividers
```css
/* Light Mode */
border-color: #e6e2db

/* Dark Mode */
border-color: #334155
```

## Spacing & Layout

### Padding
- **Small**: 0.5rem (8px)
- **Medium**: 1rem (16px)
- **Large**: 1.5rem (24px)
- **XLarge**: 2rem (32px)

### Margin
- **Small**: 0.5rem (8px)
- **Medium**: 1rem (16px)
- **Large**: 1.5rem (24px)
- **XLarge**: 2rem (32px)

### Border Radius
- **Small**: 0.5rem (8px)
- **Medium**: 0.75rem (12px)
- **Large**: 1rem (16px)
- **XLarge**: 1.5rem (24px)
- **Full**: 9999px (for pills/circles)

## Shadows

### Light Mode
```css
/* Card Shadow */
box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1)

/* Hover Shadow */
box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1)

/* Button Glow (Landing Page) */
box-shadow: 0 0 20px rgba(214, 28, 34, 0.5)
```

### Dark Mode
```css
/* Card Shadow */
box-shadow: 0 1px 3px rgba(0, 0, 0, 0.3)

/* Hover Shadow */
box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3)

/* Glass Card Hover */
box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3), 0 0 20px rgba(255, 255, 255, 0.05)
```

## Transitions & Animations

### Standard Transitions
```css
transition: all 0.2s ease
transition: all 0.3s ease
transition: colors 0.2s ease
```

### Button Hover
```css
transition: background-color 0.2s ease, transform 0.2s ease
hover: transform: scale(1.02)
```

### Card Hover
```css
transition: all 0.3s ease
hover: transform: translateY(-4px)
```

## Icons

### Material Symbols
- Uses Google Material Symbols icons
- Size: 20px (default), 24px (medium), 32px (large)
- Color follows text color scheme

## Form Elements

### Select/Dropdown
```css
/* Light Mode */
background: #ffffff
border: 1px solid #e6e2db
color: #181511
focus-border: #f04129

/* Dark Mode */
background: #1e293b
border: 1px solid #475569
color: #f1f5f9
focus-border: #f04129
```

### Checkbox/Radio
```css
/* Checked State */
accent-color: #f04129
```

### Date Picker
```css
/* Selected Date */
background: #f04129
color: white
hover: #d63a25

/* Hover State */
background: rgba(240, 65, 41, 0.1)
```

## Loading States

### Spinner
```css
/* Light Mode */
color: #f04129
border-color: rgba(240, 65, 41, 0.2)

/* Dark Mode */
color: #f04129
border-color: rgba(240, 65, 41, 0.2)
```

### Skeleton Loader
```css
/* Light Mode */
background: #e6e2db
animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite

/* Dark Mode */
background: #334155
animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite
```

## Theme Switching

### Implementation
- Uses class-based dark mode (`dark` class on `html` element)
- Stored in `localStorage` with key `'theme'`
- Default: Light mode
- Toggle available in Profile menu

### Theme Toggle Button
```css
/* Active (Dark Mode On) */
background: #f04129
toggle-position: right

/* Inactive (Light Mode) */
background: #d1d5db (light mode) / #4b5563 (dark mode)
toggle-position: left
```

## Responsive Breakpoints

- **Mobile**: < 640px
- **Tablet**: 640px - 1024px
- **Desktop**: > 1024px

## Special Effects (Landing Page)

### Background Orbs
```css
/* Orb 1 */
background: white
opacity: 0.1
size: 500px
filter: blur(120px)

/* Orb 2 */
background: #D61C22
opacity: 0.2
size: 600px
filter: blur(120px)
animation: animate-blob 25s ease-in-out infinite reverse
```

### Grid Pattern
```css
background-image: radial-gradient(#333 1px, transparent 1px)
background-size: 40px 40px
opacity: 0.3
```

## Flutter Implementation Notes

### Material 3 Theme Configuration

When implementing in Flutter, use these values:

```dart
// Light Mode
ColorScheme.light(
  primary: Color(0xFFf04129),
  onPrimary: Colors.white,
  secondary: Color(0xFFd63a25),
  surface: Color(0xFFFFFFFF),
  background: Color(0xFFf8f7f5),
  onSurface: Color(0xFF181511),
  onBackground: Color(0xFF181511),
)

// Dark Mode
ColorScheme.dark(
  primary: Color(0xFFf04129),
  onPrimary: Colors.white,
  secondary: Color(0xFFd63a25),
  surface: Color(0xFF1e293b),
  background: Color(0xFF0f172a),
  onSurface: Color(0xFFf1f5f9),
  onBackground: Color(0xFFf1f5f9),
)
```

### Border Radius
- Use `BorderRadius.circular(8)` for small elements
- Use `BorderRadius.circular(12)` for cards
- Use `BorderRadius.circular(16)` for large cards

### Elevation
- Cards: `elevation: 2`
- Buttons: `elevation: 0` (flat design)
- Hover states: `elevation: 4`

### Text Styles
- Match font sizes and weights as specified above
- Use appropriate text colors based on mode
- Ensure proper contrast ratios (WCAG AA minimum)

## Accessibility

### Color Contrast
- Light Mode: Text on white background meets WCAG AA
- Dark Mode: Text on dark background meets WCAG AA
- Primary buttons: White text on red background meets WCAG AA

### Focus States
- Always show focus ring with primary color
- Use 2px border or ring for focus indication
- Ensure keyboard navigation is visible

---

**Last Updated**: Based on current web application codebase
**Version**: 1.0

