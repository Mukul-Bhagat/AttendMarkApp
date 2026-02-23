# Dashboard Branding Rules

## ✅ **RULES FOR DASHBOARD BRANDING**

---

## If Branding is Needed on Dashboard

### Rules:
1. ✅ **Use AppBrandLogo ONLY**
   - Do NOT use PoweredByAiAlly
   - AppBrandLogo is the primary brand

2. ✅ **Very Small Size (32-40px)**
   - Current: 36px (within range)
   - Must not be larger than 40px
   - Must not be smaller than 32px

3. ✅ **Top-Left or Header Area**
   - AppBar header is acceptable
   - Do NOT place in content area
   - Do NOT place at bottom

4. ✅ **No PoweredByAiAlly**
   - Dashboard is a functional screen
   - Secondary branding is prohibited
   - Only AppBrandLogo allowed (if needed)

5. ✅ **Do Not Distract from Content**
   - Keep it small and subtle
   - Header placement is preferred
   - Content area must remain clean

---

## Preferred Approach

### ⚠️ **If Branding Feels Unnecessary: OMIT IT (Preferred)**

**Rationale:**
- Dashboard is a **functional screen**
- Users need to focus on data and actions
- Branding can add visual noise
- Clean, distraction-free interface is priority

**Current Implementation:**
- AppBrandLogo in AppBar (36px)
- This is acceptable but optional
- Can be removed if preferred

---

## Implementation Options

### Option 1: Keep AppBrandLogo (Current)
```dart
AppBar(
  title: Row(
    children: [
      const AppBrandLogo(size: 36), // 32-40px range
      const SizedBox(width: 12),
      const Text('Dashboard'),
    ],
  ),
)
```

### Option 2: Remove Branding (Preferred for Functional Screens)
```dart
AppBar(
  title: const Text('Dashboard'),
)
```

---

## Verification

### ✅ Current Status
- **AppBrandLogo:** Present in AppBar (36px) ✅
- **PoweredByAiAlly:** Absent ✅ (Correct)
- **Size:** 36px (within 32-40px range) ✅
- **Location:** Header area ✅
- **Distraction:** Minimal (header placement) ✅

### Compliance Checklist
- [x] AppBrandLogo ONLY (no PoweredByAiAlly)
- [x] Size: 32-40px (current: 36px)
- [x] Header area placement
- [x] Does not distract from content
- [x] Optional (can be removed if preferred)

---

## Recommendation

**For Functional Screens (Dashboard):**
- **Preferred:** Remove branding entirely
- **Acceptable:** Small AppBrandLogo in header (32-40px)
- **Prohibited:** PoweredByAiAlly, large logos, content area branding

**Current Implementation:**
- AppBrandLogo at 36px in header is acceptable
- But removing it would be preferred for cleaner UX

---

**Last Updated:** Dashboard Branding Rules
**Status:** ✅ Rules Enforced
**Current Implementation:** AppBrandLogo 36px in header (acceptable)

