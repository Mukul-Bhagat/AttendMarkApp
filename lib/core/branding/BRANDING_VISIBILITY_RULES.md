# Branding Visibility Rules

## ✅ **ENFORCED RULES**

---

## PoweredByAiAlly Widget Visibility

### ✅ **ALLOWED Screens**
- **Login Screen** - Bottom section (secondary brand)
- **Profile Screen** - Footer (subtle, secondary brand)

### ❌ **PROHIBITED Screens**
- **Dashboard** - Functional screen, no branding
- **Sessions List** - Functional screen, no branding
- **Session Details** - Functional screen, no branding
- **QR Scan Screen** - Functional screen, no branding
- **Attendance History** - Functional screen, no branding
- **Leaves Screen** - Functional screen, no branding

---

## Rationale

### Why Prohibited on Functional Screens?
1. **Reduces Visual Noise**
   - Functional screens focus on data and actions
   - Branding adds unnecessary visual elements
   - Users need clear, distraction-free interfaces

2. **Matches Website Pattern**
   - Website follows same branding rules
   - Consistency across platforms
   - Professional, enterprise-grade UX

3. **Performance & Focus**
   - Users are actively working on these screens
   - Branding can distract from primary tasks
   - Clean, functional design is priority

---

## AppBrandLogo Widget Visibility

### ✅ **ALLOWED Screens**
- **Login Screen** - Top section (primary brand, 80-96px)
- **Dashboard** - Header (small, 28px)
- **Profile Screen** - Header (optional, small, 24px)
- **Splash Screen** - Center (large, 120px)

### ❌ **PROHIBITED Screens**
- **Sessions List** - No logo in content area
- **Session Details** - No logo in content area
- **QR Scan Screen** - No logo (camera view)
- **Attendance History** - No logo in content area
- **Leaves Screen** - No logo in content area

**Note:** AppBrandLogo in AppBar headers is acceptable (Dashboard, Profile).

---

## Implementation Checklist

### Screens Verified (No PoweredByAiAlly)
- [x] Dashboard - ✅ No PoweredByAiAlly
- [x] Sessions List - ✅ No PoweredByAiAlly
- [x] Session Details - ✅ No PoweredByAiAlly
- [x] QR Scan Screen - ✅ No PoweredByAiAlly
- [x] Attendance History - ✅ No PoweredByAiAlly
- [x] Leaves Screen - ✅ No PoweredByAiAlly

### Screens Verified (Has PoweredByAiAlly)
- [x] Login Screen - ✅ PoweredByAiAlly at bottom
- [x] Profile Screen - ✅ PoweredByAiAlly at footer

---

## Code Enforcement

### ✅ Current Status
All screens comply with branding visibility rules:
- Prohibited screens: No PoweredByAiAlly found
- Allowed screens: PoweredByAiAlly present only on Login and Profile

### 🔒 Prevention Guidelines

**DO NOT:**
```dart
// ❌ DO NOT add PoweredByAiAlly to functional screens
// Dashboard, Sessions, QR Scan, Attendance, Leaves

// ❌ DO NOT add multiple instances
const PoweredByAiAlly() // At top
const PoweredByAiAlly() // At bottom - WRONG!
```

**DO:**
```dart
// ✅ ONLY on Login and Profile screens
// Login Screen - bottom
const PoweredByAiAlly(logoHeight: 15)

// Profile Screen - footer
const PoweredByAiAlly(logoHeight: 15)
```

---

## Verification Commands

### Check for PoweredByAiAlly Usage
```bash
# Search for all instances
grep -r "PoweredByAiAlly" lib/screens/

# Should only find:
# - lib/screens/auth/login_screen.dart
# - lib/screens/profile/profile_screen.dart
```

### Verify No Branding in Functional Screens
```bash
# Check prohibited screens
grep -r "PoweredByAiAlly" lib/screens/dashboard/
grep -r "PoweredByAiAlly" lib/screens/sessions/
grep -r "PoweredByAiAlly" lib/screens/attendance/
grep -r "PoweredByAiAlly" lib/screens/leaves/

# Should return: No matches found
```

---

## Maintenance

### When Adding New Screens

1. **Determine Screen Type:**
   - **Functional Screen** (data/actions) → NO PoweredByAiAlly
   - **Branding Screen** (Login, Profile) → PoweredByAiAlly allowed

2. **Follow Pattern:**
   - Functional screens: Focus on content, no secondary branding
   - Branding screens: Subtle secondary branding at bottom/footer

3. **Verify:**
   - Run grep to check for PoweredByAiAlly
   - Ensure only Login and Profile have it
   - Document any exceptions (should be rare)

---

## Summary

**Status:** ✅ **RULES ENFORCED**

- ✅ Prohibited screens: No PoweredByAiAlly
- ✅ Allowed screens: PoweredByAiAlly only on Login and Profile
- ✅ AppBrandLogo: Appropriate usage in headers
- ✅ All screens verified and compliant

**Last Verified:** Branding Visibility Rules Enforcement
**Compliance:** 100%

