# USER Login Failure - Root Cause & Fix

## 🎯 **ROOT CAUSE IDENTIFIED**

### Primary Issue: User Not in UserOrganizationMap Collection

**Problem**: The login flow requires users to exist in the `UserOrganizationMap` collection. If a user is missing from this collection, login fails with:
```
"User not found. Please run the migration script to populate user data."
```

**Why Admin Works but User Doesn't**:
- Admin users were likely created/migrated earlier
- User (EndUser) records might have been created directly in organization collections without updating `UserOrganizationMap`
- The migration script may not have been run after creating EndUser accounts

---

## 🔍 **VERIFICATION STEPS**

### Step 1: Check Backend Logs
Look for this error in backend console:
```
[LOGIN] User not found. Please run the migration script...
```

### Step 2: Verify UserOrganizationMap
```javascript
// In MongoDB
db.userorganizationmaps.findOne({ email: "user@example.com" })
```

**If this returns `null`**: User is missing from UserOrganizationMap → **ROOT CAUSE**

### Step 3: Verify User in Organization Collection
```javascript
// Replace 'org_prefix' with actual organization prefix
db.org_prefix_users.findOne({ email: "user@example.com" })
```

**If this returns user data**: User exists but not mapped → **CONFIRMED ROOT CAUSE**

---

## ✅ **SOLUTION**

### Fix #1: Run Migration Script (Recommended)

**Option A: Via API Endpoint**
```bash
# Make authenticated request (as admin)
GET /api/auth/run-migration
```

**Option B: Via Script**
```bash
# In backend directory
node src/scripts/migrateUsers.ts
```

**Option C: Via npm script** (if configured)
```bash
npm run migrate-users
```

This will:
1. Scan all organization collections
2. Find all users (including EndUser)
3. Add them to `UserOrganizationMap`
4. Map their organizations correctly

---

### Fix #2: Manual Database Update (If Migration Fails)

If migration script doesn't work, manually add user to UserOrganizationMap:

```javascript
// In MongoDB
db.userorganizationmaps.insertOne({
  email: "user@example.com",
  organizations: [
    {
      orgName: "Organization Name",
      prefix: "org_prefix",
      role: "EndUser",  // ← Must be exactly "EndUser" (case-sensitive)
      userId: "user_id_from_org_collection"
    }
  ],
  createdAt: new Date(),
  updatedAt: new Date()
})
```

**To get userId**:
```javascript
// Find user in organization collection
const user = db.org_prefix_users.findOne({ email: "user@example.com" });
// Use user._id.toString() as userId
```

---

### Fix #3: Verify Role Value

**Critical**: Role must be exactly `"EndUser"` (not `"user"`, `"User"`, or `"USER"`)

**Check user role**:
```javascript
db.org_prefix_users.findOne(
  { email: "user@example.com" },
  { role: 1 }
)
```

**If role is incorrect, update it**:
```javascript
db.org_prefix_users.updateOne(
  { email: "user@example.com" },
  { $set: { role: "EndUser" } }
)
```

**Then update UserOrganizationMap**:
```javascript
db.userorganizationmaps.updateOne(
  { email: "user@example.com" },
  { $set: { "organizations.0.role": "EndUser" } }
)
```

---

## 🔧 **CODE-LEVEL FIXES**

### Backend: Enhanced Error Messages

**File**: `backend/src/controllers/authController.ts`

**Current Code** (line 227-231):
```typescript
if (!userMap) {
  return res.status(401).json({ 
    msg: 'User not found. Please run the migration script to populate user data.',
    requiresMigration: true 
  });
}
```

**Enhanced Version** (adds diagnostic info):
```typescript
if (!userMap) {
  // Check if user exists in any organization collection
  const allOrgs = await Organization.find({});
  let userFoundInOrg = false;
  let foundOrgPrefix = null;
  
  for (const org of allOrgs) {
    const UserCollection = createUserModel(`${org.collectionPrefix}_users`);
    const userInOrg = await UserCollection.findOne({ email: email.toLowerCase() });
    if (userInOrg) {
      userFoundInOrg = true;
      foundOrgPrefix = org.collectionPrefix;
      break;
    }
  }
  
  if (userFoundInOrg) {
    return res.status(401).json({ 
      msg: 'User exists but is not mapped. Please run the migration script.',
      requiresMigration: true,
      diagnostic: {
        userExists: true,
        organizationPrefix: foundOrgPrefix,
        action: 'Run migration script to map user to UserOrganizationMap'
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

### Frontend: Better Error Handling

**File**: `attend_mark/lib/providers/auth_provider.dart`

**Current Code** (line 114-120):
```dart
} catch (e) {
  _error = e.toString().replaceAll('Exception: ', '');
  _isLoading = false;
  notifyListeners();
  Logger.e('AuthProvider', 'Login failed', e);
  rethrow;
}
```

**Enhanced Version** (shows migration hint):
```dart
} catch (e) {
  final errorMessage = e.toString().replaceAll('Exception: ', '');
  
  // Check if error indicates migration needed
  if (errorMessage.contains('migration') || errorMessage.contains('User not found')) {
    _error = 'User account not properly configured. Please contact your administrator to run the migration script.';
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

## 📋 **COMPLETE FIX CHECKLIST**

- [ ] **Step 1**: Check backend logs for exact error
- [ ] **Step 2**: Verify user exists in `UserOrganizationMap`
  - If missing → Run migration script
- [ ] **Step 3**: Verify user role is `"EndUser"` (case-sensitive)
  - If incorrect → Update role in database
- [ ] **Step 4**: Verify organization status is `"ACTIVE"`
  - If suspended → Update organization status
- [ ] **Step 5**: Verify password hash is correct
  - If incorrect → Reset user password
- [ ] **Step 6**: Test login again
- [ ] **Step 7**: If still failing, check Flutter app logs for filtering issues

---

## 🎯 **EXPECTED BEHAVIOR AFTER FIX**

### Successful Login Flow for EndUser:

1. **POST /api/auth/login**
   - ✅ Finds user in `UserOrganizationMap`
   - ✅ Verifies password
   - ✅ Returns `tempToken` and `organizations` array

2. **Flutter App**
   - ✅ Receives organizations (including EndUser organizations)
   - ✅ Filters out only Platform Owner (EndUser should pass)
   - ✅ Shows organization selection or auto-selects if single org

3. **POST /api/auth/select-organization**
   - ✅ Verifies tempToken
   - ✅ Finds user in selected organization
   - ✅ Returns final token and user data

4. **App Navigation**
   - ✅ Stores token
   - ✅ Navigates to Dashboard
   - ✅ EndUser can access app features

---

## 🐛 **COMMON ISSUES & SOLUTIONS**

### Issue 1: "User not found" Error
**Cause**: User missing from `UserOrganizationMap`
**Fix**: Run migration script

### Issue 2: "Invalid credentials" Error
**Cause**: Password mismatch
**Fix**: Reset user password

### Issue 3: "All organizations suspended" Error
**Cause**: Organization status is `SUSPENDED`
**Fix**: Update organization status to `ACTIVE`

### Issue 4: "User has no associated organizations" Error
**Cause**: `UserOrganizationMap.organizations` array is empty
**Fix**: Run migration script or manually add organization

### Issue 5: Role Filtering in Flutter
**Cause**: Flutter app filtering out EndUser (should NOT happen)
**Fix**: Verify Flutter filter only blocks Platform Owner

---

## 📝 **TESTING CHECKLIST**

After applying fixes:

- [ ] EndUser can login successfully
- [ ] EndUser receives organizations list
- [ ] EndUser can select organization
- [ ] EndUser receives final token
- [ ] EndUser can access dashboard
- [ ] EndUser role is correctly identified as `"EndUser"`
- [ ] No errors in backend logs
- [ ] No errors in Flutter app logs

---

## 🔍 **DEBUGGING COMMANDS**

### Check User in UserOrganizationMap
```javascript
db.userorganizationmaps.findOne({ email: "user@example.com" })
```

### Check User in Organization Collection
```javascript
db.org_prefix_users.findOne({ email: "user@example.com" })
```

### Check All Users in Organization
```javascript
db.org_prefix_users.find({ role: "EndUser" })
```

### Check Organization Status
```javascript
db.organizations.findOne({ collectionPrefix: "org_prefix" })
```

### Run Migration (if API endpoint exists)
```bash
curl -X GET http://localhost:5000/api/auth/run-migration \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

---

**Status**: ✅ **ROOT CAUSE IDENTIFIED**
**Fix**: Run migration script to populate `UserOrganizationMap`
**Priority**: 🔴 **HIGH** - Blocks all EndUser logins

