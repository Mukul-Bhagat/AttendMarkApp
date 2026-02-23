# USER Login Failure - Root Cause & Complete Fix

## 🎯 **EXACT ROOT CAUSE**

### Primary Issue: User Missing from UserOrganizationMap Collection

**Breaking Point**: Line 224 in `backend/src/controllers/authController.ts`

```typescript
const userMap = await UserOrganizationMap.findOne({ email: email.toLowerCase() });
```

**If `userMap` is `null`**: Login fails immediately with error:
```
"User not found. Please run the migration script to populate user data."
```

**Why Admin Works but User Doesn't**:
- Admin users were likely created through the registration flow which automatically adds them to `UserOrganizationMap`
- EndUser accounts might have been:
  - Created directly in organization collections (bulk import, manual creation)
  - Created before the migration script was implemented
  - Not properly synced to `UserOrganizationMap`

---

## 🔍 **VERIFICATION**

### Check 1: UserOrganizationMap
```javascript
// MongoDB Query
db.userorganizationmaps.findOne({ email: "user@example.com" })
```

**Expected Result**: Document with user's organizations
**If `null`**: ✅ **ROOT CAUSE CONFIRMED**

### Check 2: User in Organization Collection
```javascript
// Replace 'org_prefix' with actual prefix
db.org_prefix_users.findOne({ email: "user@example.com" })
```

**Expected Result**: User document with role `"EndUser"`
**If found**: User exists but not mapped → **CONFIRMED ROOT CAUSE**

---

## ✅ **COMPLETE FIX**

### Solution: Run Migration Script

**The migration script will**:
1. Scan all organization collections
2. Find all users (including EndUser)
3. Add/update them in `UserOrganizationMap`
4. Map their organizations correctly

**How to Run**:

**Option 1: Via API Endpoint** (Recommended)
```bash
# As authenticated admin
curl -X GET http://localhost:5000/api/auth/run-migration \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

**Option 2: Via Script**
```bash
# In backend directory
node src/scripts/migrateUsers.ts
```

**Option 3: Via npm** (if configured)
```bash
npm run migrate-users
```

---

## 🔧 **CODE-LEVEL FIXES**

### Backend Enhancement: Better Error Messages

**File**: `backend/src/controllers/authController.ts`

**Replace lines 227-231** with:

```typescript
// ENHANCED: Check if userMap exists and provide diagnostic info
if (!userMap) {
  // Check if user exists in any organization collection
  const allOrgs = await Organization.find({});
  let userFoundInOrg = false;
  let foundOrgPrefix = null;
  let foundUserRole = null;
  
  for (const org of allOrgs) {
    try {
      const UserCollection = createUserModel(`${org.collectionPrefix}_users`);
      const userInOrg = await UserCollection.findOne({ email: email.toLowerCase() }).select('role');
      if (userInOrg) {
        userFoundInOrg = true;
        foundOrgPrefix = org.collectionPrefix;
        foundUserRole = userInOrg.role;
        break;
      }
    } catch (err) {
      // Continue checking other organizations
      continue;
    }
  }
  
  if (userFoundInOrg) {
    console.log(`[LOGIN] User exists in ${foundOrgPrefix} but not in UserOrganizationMap. Role: ${foundUserRole}`);
    return res.status(401).json({ 
      msg: 'User exists but is not mapped. Please run the migration script.',
      requiresMigration: true,
      diagnostic: {
        userExists: true,
        organizationPrefix: foundOrgPrefix,
        userRole: foundUserRole,
        action: 'Run migration script: GET /api/auth/run-migration'
      }
    });
  }
  
  return res.status(401).json({ 
    msg: 'User not found. Please verify email address or contact administrator.',
    requiresMigration: false
  });
}
```

---

### Frontend Enhancement: Better Error Display

**File**: `attend_mark/lib/providers/auth_provider.dart`

**Replace lines 114-120** with:

```dart
} catch (e) {
  final errorMessage = e.toString().replaceAll('Exception: ', '');
  
  // Check if error indicates migration needed
  if (errorMessage.contains('migration') || 
      errorMessage.contains('User not found') ||
      errorMessage.contains('not mapped')) {
    _error = 'Your account needs to be configured. Please contact your administrator.';
    Logger.w('AuthProvider', 'User account requires migration');
  } else {
    _error = errorMessage;
  }
  
  _isLoading = false;
  notifyListeners();
  Logger.e('AuthProvider', 'Login failed', e);
  rethrow;
}
```

---

## 📋 **STEP-BY-STEP FIX PROCEDURE**

### Step 1: Verify the Issue
```bash
# Check backend logs when user tries to login
# Look for: "User not found. Please run the migration script..."
```

### Step 2: Run Migration Script
```bash
# In backend directory
node src/scripts/migrateUsers.ts
```

**Expected Output**:
```
🚀 Starting UserOrganizationMap migration...
✅ Connected to MongoDB
📋 Found X organization(s)
📦 Processing organization: ...
   Found Y user(s) in this organization
   ✅ Mapped user: user@example.com -> Organization Name (EndUser)
✅ Migration completed!
```

### Step 3: Verify User is Now Mapped
```javascript
// MongoDB Query
db.userorganizationmaps.findOne({ email: "user@example.com" })
```

**Expected**: Document with organizations array containing user's organization

### Step 4: Test Login
- Try logging in as EndUser
- Should now succeed

---

## 🎯 **WHY THIS FIXES THE ISSUE**

### Before Fix:
1. User tries to login
2. Backend looks up `UserOrganizationMap` → **NOT FOUND** ❌
3. Returns error: "User not found"
4. Login fails

### After Fix:
1. Migration script runs
2. Finds user in organization collection
3. Adds user to `UserOrganizationMap` with correct organization mapping
4. User tries to login
5. Backend looks up `UserOrganizationMap` → **FOUND** ✅
6. Verifies password
7. Returns organizations
8. Login succeeds

---

## 🔍 **ADDITIONAL CHECKS**

### Check Role Value
**Critical**: Role must be exactly `"EndUser"` (case-sensitive)

```javascript
// Verify role
db.org_prefix_users.findOne(
  { email: "user@example.com" },
  { role: 1 }
)
```

**If role is incorrect**:
```javascript
// Update role
db.org_prefix_users.updateOne(
  { email: "user@example.com" },
  { $set: { role: "EndUser" } }
)

// Then update UserOrganizationMap
db.userorganizationmaps.updateOne(
  { email: "user@example.com" },
  { $set: { "organizations.0.role": "EndUser" } }
)
```

### Check Organization Status
```javascript
// Verify organization is active
db.organizations.findOne({ collectionPrefix: "org_prefix" })
```

**If status is `SUSPENDED`**:
```javascript
// Update status
db.organizations.updateOne(
  { collectionPrefix: "org_prefix" },
  { $set: { status: "ACTIVE" } }
)
```

---

## 📊 **VALIDATION CHECKLIST**

After applying fix:

- [ ] Migration script runs successfully
- [ ] User appears in `UserOrganizationMap`
- [ ] User's role is `"EndUser"` (case-sensitive)
- [ ] Organization status is `"ACTIVE"`
- [ ] User can login successfully
- [ ] User receives organizations list
- [ ] User can select organization
- [ ] User receives final token
- [ ] User can access dashboard
- [ ] No errors in backend logs
- [ ] No errors in Flutter app

---

## 🎯 **FINAL CORRECTED LOGIC**

### Backend Login Flow (After Fix):

```
1. Check Platform Owner → Skip if not Platform Owner
2. Look up UserOrganizationMap by email
   ✅ If found → Continue
   ❌ If not found → Check if user exists in org collections
      - If exists → Return "User not mapped" error with diagnostic info
      - If not exists → Return "User not found" error
3. Verify user has organizations
4. Get first organization to verify password
5. Find user in organization collection
6. Verify password (bcrypt)
7. Get all user's organizations (filter suspended)
8. Generate tempToken
9. Return tempToken + organizations
```

### Frontend Login Flow (After Fix):

```
1. Call POST /api/auth/login
2. Receive tempToken + organizations
3. Filter out Platform Owner organizations
4. If single org → Auto-select
5. If multiple orgs → Show selection
6. Call POST /api/auth/select-organization
7. Receive final token + user data
8. Store token
9. Navigate to Dashboard
```

---

## ✅ **SUMMARY**

**Root Cause**: User missing from `UserOrganizationMap` collection

**Fix**: Run migration script to populate `UserOrganizationMap`

**Why Admin Works**: Admin users were likely created through registration flow which auto-maps them

**Why User Fails**: EndUser accounts created directly in org collections without mapping

**Solution**: Migration script maps all users (including EndUser) to `UserOrganizationMap`

**Status**: ✅ **FIX IDENTIFIED AND DOCUMENTED**

