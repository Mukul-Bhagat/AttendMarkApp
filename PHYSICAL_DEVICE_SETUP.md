# Physical Device Setup - Complete Checklist

## ✅ **FIXES APPLIED**

### 1. **API Base URL Fixed**

**File**: `lib/config/api_config.dart`

**Changed From**: `http://10.0.2.2:5000/api` (emulator-only)  
**Changed To**: `http://192.168.0.100:5000/api` (physical device)

**Status**: ✅ **FIXED**

---

### 2. **API Config Hardened**

**File**: `lib/config/api_config.dart`

**Added**:
- ✅ Clear comments for Emulator (10.0.2.2)
- ✅ Clear comments for Physical Device (LAN IP)
- ✅ Clear comments for Production (HTTPS required)
- ✅ Instructions to find IP address

**Status**: ✅ **HARDENED**

---

### 3. **Dio Client Verified**

**File**: `lib/core/network/dio_client.dart`

**Verified**:
- ✅ Uses `ApiConfig.baseUrl` (line 19)
- ✅ Timeouts are 30 seconds (from ApiConfig)
- ✅ No dynamic baseUrl override in normal flow
- ✅ `updateBaseUrl()` method exists but is not called automatically

**Status**: ✅ **VERIFIED**

---

### 4. **Diagnostic Logging Added**

**File**: `lib/app.dart`

**Added**:
- ✅ Logs baseUrl at app startup
- ✅ Format: `[API CONFIG] Base URL: <value>`

**Status**: ✅ **ADDED**

---

### 5. **Backend Accessibility Verified**

**File**: `backend/src/server.ts`

**Verified**:
- ✅ Server listens on `PORT` (default 5000 or from env)
- ✅ Health endpoint exists: `GET /api/health`
- ✅ Health endpoint returns: `{ status: "OK" }`
- ✅ No authentication required for health endpoint

**Status**: ✅ **VERIFIED**

---

## 📋 **FINAL CHECKLIST**

### Before Testing:

- [ ] **Backend is running** on laptop (port 5000)
- [ ] **Laptop IP is correct** (192.168.0.100)
- [ ] **Phone and laptop on same WiFi** network
- [ ] **Firewall allows port 5000** on laptop
- [ ] **Flutter app rebuilt** after baseUrl change

### Test Connectivity:

1. **Test Health Endpoint** (from phone browser or app):
   ```
   http://192.168.0.100:5000/api/health
   ```
   Expected: `{ "status": "OK" }`

2. **Check App Logs**:
   - Look for: `[API CONFIG] Base URL: http://192.168.0.100:5000/api`
   - Verify no connection timeout errors

3. **Test Login**:
   - Try logging in from Flutter app
   - Should connect successfully

---

## 🔧 **TROUBLESHOOTING**

### If Still Getting Timeout:

1. **Verify Laptop IP**:
   ```bash
   # Windows
   ipconfig
   # Look for IPv4 Address under your WiFi adapter
   
   # Linux/Mac
   ifconfig
   # or
   ip addr show
   ```

2. **Verify Backend is Running**:
   ```bash
   # Check if backend is listening
   netstat -an | findstr 5000  # Windows
   netstat -an | grep 5000     # Linux/Mac
   ```

3. **Test from Phone Browser**:
   - Open phone browser
   - Navigate to: `http://192.168.0.100:5000/api/health`
   - Should see: `{"status":"OK"}`

4. **Check Firewall**:
   - Windows: Allow port 5000 in Windows Firewall
   - Linux: `sudo ufw allow 5000`
   - Mac: System Preferences > Security > Firewall

5. **Verify Same Network**:
   - Phone and laptop must be on same WiFi
   - Check WiFi SSID on both devices

---

## 🚀 **RESTART COMMANDS**

### Backend (if needed):

```bash
# Navigate to backend directory
cd backend

# Stop current server (Ctrl+C if running)

# Restart server
npm start
# or
node dist/src/server.js
# or
npm run dev
```

### Flutter App:

```bash
# Navigate to Flutter app directory
cd attend_mark

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Rebuild and run
flutter run
```

---

## 📝 **CONFIGURATION SUMMARY**

| Item | Value |
|------|-------|
| **Base URL** | `http://192.168.0.100:5000/api` |
| **Backend Port** | `5000` |
| **Laptop IP** | `192.168.0.100` |
| **Connect Timeout** | `30 seconds` |
| **Receive Timeout** | `30 seconds` |
| **Send Timeout** | `30 seconds` |
| **Health Endpoint** | `/api/health` |

---

## ✅ **STATUS**

**All fixes applied**: ✅  
**Configuration hardened**: ✅  
**Diagnostics added**: ✅  
**Backend verified**: ✅  

**Ready for testing**: ✅

