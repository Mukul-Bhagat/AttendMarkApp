# Windows Developer Mode - Enable Symlink Support

## 🔍 **PROBLEM**

Flutter requires symlink support to build apps with plugins. On Windows, this requires **Developer Mode** to be enabled.

**Error Message**:
```
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

---

## ✅ **SOLUTION**

### Step 1: Open Developer Settings

**Option A: Via Command** (Already executed):
```powershell
start ms-settings:developers
```

**Option B: Manually**:
1. Press `Windows Key + I` to open Settings
2. Go to **Privacy & Security** → **For developers**
3. Or search for "Developer" in Settings

---

### Step 2: Enable Developer Mode

1. In the **For developers** settings page
2. Find **"Developer Mode"** toggle
3. **Turn it ON**
4. Windows may ask for confirmation - click **Yes**

**Note**: This may require administrator privileges or a restart.

---

### Step 3: Verify Symlink Support

After enabling Developer Mode, try building again:

```bash
flutter run
```

**Expected**: Build should proceed without symlink errors.

---

## 🔧 **ALTERNATIVE: Enable Symlinks Without Developer Mode**

If you cannot enable Developer Mode, you can enable symlinks manually:

**Run PowerShell as Administrator**:
```powershell
# Check current policy
Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -Name SymlinkEvaluation

# Enable symlinks for current user (if you have admin rights)
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "SymlinkEvaluation" -Value 1 -PropertyType DWord -Force
```

**However**: Enabling Developer Mode is the **recommended and easier** solution.

---

## 📋 **VERIFICATION**

After enabling Developer Mode:

1. **Restart your terminal** (or restart computer if needed)
2. **Try building again**:
   ```bash
   flutter run
   ```
3. **Expected**: No symlink errors, build proceeds normally

---

## ⚠️ **IMPORTANT NOTES**

- **Developer Mode** is safe to enable - it's a Windows feature for developers
- It allows apps to create symlinks without administrator privileges
- Required for Flutter plugins that use symlinks (like `mobile_scanner`, `geolocator`, etc.)
- You may need to restart your terminal or computer after enabling

---

## ✅ **STATUS**

**Action Required**: Enable Developer Mode in Windows Settings

**After enabling**: Flutter build should work without symlink errors.

