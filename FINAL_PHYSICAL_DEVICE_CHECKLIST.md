# Physical Device Setup - Final Checklist

## ✅ **ALL FIXES COMPLETED**

### 1. ✅ **API Base URL Fixed**
- **File**: `lib/config/api_config.dart`
- **Changed**: `http://10.0.2.2:5000/api` → `http://192.168.0.100:5000/api`
- **Status**: ✅ **FIXED**

### 2. ✅ **API Config Hardened**
- **File**: `lib/config/api_config.dart`
- **Added**: Clear comments for Emulator, Physical Device, and Production
- **Status**: ✅ **HARDENED**

### 3. ✅ **Dio Client Verified**
- **File**: `lib/core/network/dio_client.dart`
- **Verified**: Uses `ApiConfig.baseUrl`, timeouts are 30 seconds
- **Status**: ✅ **VERIFIED**

### 4. ✅ **Diagnostic Logging Added**
- **File**: `lib/app.dart`
- **Added**: Logs baseUrl at startup: `[API CONFIG] Base URL: <value>`
- **Status**: ✅ **ADDED**

### 5. ✅ **Backend Accessibility Verified**
- **File**: `backend/src/server.ts`
- **Verified**: Health endpoint exists at `/api/health`
- **Status**: ✅ **VERIFIED**

---

## 📋 **PRE-TEST CHECKLIST**

### Before Testing:

- [ ] **Backend is running** on laptop (port 5000)
- [ ] **Laptop IP is 192.168.0.100** (verify with `ipconfig` or `ifconfig`)
- [ ] **Phone and laptop on same WiFi** network
- [ ] **Firewall allows port 5000** on laptop
- [ ] **Flutter app rebuilt** after baseUrl change

---

## 🧪 **TESTING STEPS**

### Step 1: Test Health Endpoint

**From Phone Browser**:
```
http://192.168.0.100:5000/api/health
```

**Expected Response**:
```json
{ "status": "OK" }
```

**If this fails**: Check firewall, network, or backend status

---

### Step 2: Check App Logs

**When Flutter app starts**, look for:
```
[API CONFIG] Base URL: http://192.168.0.100:5000/api
```

**If this log is missing**: App didn't initialize properly

---

### Step 3: Test Login

**Try logging in from Flutter app**

**Expected**:
- ✅ No connection timeout
- ✅ Login request succeeds
- ✅ User can authenticate

**If timeout occurs**: See troubleshooting section below

---

## 🔧 **TROUBLESHOOTING**

### Issue: Still Getting Connection Timeout

#### 1. Verify Laptop IP Address

**Windows**:
```bash
ipconfig
# Look for "IPv4 Address" under your WiFi adapter
# Should be: 192.168.0.100
```

**Linux/Mac**:
```bash
ifconfig
# or
ip addr show
# Look for your WiFi adapter's inet address
```

**If IP is different**: Update `api_config.dart` with correct IP

---

#### 2. Verify Backend is Running

**Check if backend is listening on port 5000**:

**Windows**:
```bash
netstat -an | findstr 5000
```

**Linux/Mac**:
```bash
netstat -an | grep 5000
# or
lsof -i :5000
```

**Expected**: Should see `LISTENING` or `0.0.0.0:5000`

**If not running**: Start backend (see restart commands below)

---

#### 3. Test from Phone Browser

**Open phone browser**:
- Navigate to: `http://192.168.0.100:5000/api/health`
- Should see: `{"status":"OK"}`

**If this fails**:
- ✅ Check firewall settings
- ✅ Verify same WiFi network
- ✅ Verify backend is running
- ✅ Try laptop's IP from `ipconfig`

---

#### 4. Check Firewall

**Windows**:
1. Open Windows Defender Firewall
2. Advanced Settings
3. Inbound Rules → New Rule
4. Port → TCP → 5000
5. Allow connection

**Linux**:
```bash
sudo ufw allow 5000
```

**Mac**:
1. System Preferences → Security → Firewall
2. Firewall Options
3. Add port 5000

---

#### 5. Verify Same Network

**Check WiFi SSID**:
- Phone WiFi: Should match laptop WiFi
- Both devices must be on same network

**If different networks**: Connect both to same WiFi

---

## 🚀 **RESTART COMMANDS**

### Backend Restart:

```bash
# Navigate to backend directory
cd backend

# Stop current server (if running)
# Press Ctrl+C in terminal

# Restart server
npm start
# OR
node dist/src/server.js
# OR (if using nodemon)
npm run dev
```

**Expected Output**:
```
Server started on port 5000
✅ Loaded .env from: ...
```

---

### Flutter App Restart:

```bash
# Navigate to Flutter app directory
cd attend_mark

# Clean build (optional but recommended)
flutter clean

# Get dependencies
flutter pub get

# Rebuild and run
flutter run
```

**Expected Output**:
```
[API CONFIG] Base URL: http://192.168.0.100:5000/api
LocalStorage initialized
...
```

---

## 📊 **CONFIGURATION SUMMARY**

| Item | Value | Status |
|------|-------|--------|
| **Base URL** | `http://192.168.0.100:5000/api` | ✅ Fixed |
| **Backend Port** | `5000` | ✅ Verified |
| **Laptop IP** | `192.168.0.100` | ⚠️ Verify with ipconfig |
| **Connect Timeout** | `30 seconds` | ✅ Verified |
| **Receive Timeout** | `30 seconds` | ✅ Verified |
| **Send Timeout** | `30 seconds` | ✅ Verified |
| **Health Endpoint** | `/api/health` | ✅ Verified |

---

## ✅ **FINAL STATUS**

**All Tasks Completed**:
- ✅ API base URL fixed for physical device
- ✅ API config hardened with comments
- ✅ Dio client verified
- ✅ Diagnostic logging added
- ✅ Backend accessibility verified
- ✅ Health endpoint confirmed

**Ready for Testing**: ✅

**Next Steps**:
1. Restart backend (if needed)
2. Rebuild Flutter app
3. Test health endpoint from phone
4. Test login from Flutter app

---

## 🎯 **QUICK REFERENCE**

### Find Your Laptop IP:
```bash
# Windows
ipconfig

# Linux/Mac
ifconfig
```

### Test Backend Health:
```
http://YOUR_LAPTOP_IP:5000/api/health
```

### Update Base URL:
Edit: `attend_mark/lib/config/api_config.dart`
Change: `static const String baseUrl = 'http://YOUR_IP:5000/api';`

---

**Status**: ✅ **ALL FIXES APPLIED - READY FOR TESTING**

