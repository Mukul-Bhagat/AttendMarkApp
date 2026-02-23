# AttendMark Production Release Checklist

## 🔴 CRITICAL: Before Building

### 1. API Configuration ⚠️
- [ ] **Update baseUrl to HTTPS** in `lib/config/api_config.dart`
  ```dart
  // CHANGE THIS:
  static const String baseUrl = 'https://your-production-api.com/api';
  ```
- [ ] **Verify HTTPS certificate**: Ensure backend has valid SSL certificate
- [ ] **Test API connectivity**: Verify app can connect to production API

### 2. App Identity
- [x] **App Name**: "AttendMark" (configured in AndroidManifest.xml)
- [x] **Application ID**: "com.attendmark.app" (configured in build.gradle.kts)
- [ ] **App Icon**: Replace default icons with AttendMark logo (optional)
- [ ] **Version**: Update in pubspec.yaml if needed

### 3. Signing Configuration
- [ ] **Create Keystore**: Generate release keystore
  ```bash
  keytool -genkey -v -keystore ~/attendmark-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 -alias attendmark
  ```
- [ ] **Configure Signing**: Update build.gradle.kts with keystore path
- [ ] **Store Credentials**: Save keystore password securely

---

## ✅ Security Verification

### Debug Logs
- [x] **Logger uses kDebugMode**: All logs disabled in release
- [x] **No print() statements**: All logging uses Logger utility
- [x] **No debugPrint() in release**: Safe for production

### API Security
- [ ] **HTTPS Base URL**: ⚠️ **MUST UPDATE BEFORE RELEASE**
- [x] **Token in headers**: Secure transmission
- [x] **No token in logs**: Token masked in logs
- [x] **401 handling**: Auto-logout on token expiry

### Token Management
- [x] **Secure storage**: SharedPreferences
- [x] **Token validation**: On app startup
- [x] **Auto-cleanup**: Invalid tokens cleared
- [x] **Expiry handling**: 401 errors handled gracefully

---

## ✅ Feature Verification

### Platform Owner Blocking
- [x] **Login filter**: Platform Owner organizations filtered out
- [x] **Startup check**: Platform Owner detected and logged out
- [x] **Org selection check**: Platform Owner blocked after org selection
- [x] **Error message**: Clear message shown to user

### QR Code Logic
- [x] **Backend-controlled**: Uses `canShowQr` from backend
- [x] **Time-based**: Uses `qrExpiresAt` from backend
- [x] **No frontend calculation**: Flutter doesn't calculate QR availability
- [x] **Role-based**: Only Admin/Manager can show QR
- [x] **Auto-hide**: QR hides after expiry

---

## 🚀 Build Commands

### Build Release APK
```bash
cd attend_mark
flutter clean
flutter pub get
flutter build apk --release
```

**Output**: `build/app/outputs/flutter-apk/app-release.apk`

### Build Release AAB (App Bundle)
```bash
cd attend_mark
flutter clean
flutter pub get
flutter build appbundle --release
```

**Output**: `build/app/outputs/bundle/release/app-release.aab`

### Build with Version Code
```bash
# APK
flutter build apk --release --build-number=2

# AAB
flutter build appbundle --release --build-number=2
```

---

## 📋 Pre-Release Testing

### Functional Testing
- [ ] Login with valid credentials
- [ ] Token persists after app restart
- [ ] Token expiry handled (401 auto-logout)
- [ ] Platform Owner blocked
- [ ] QR code scanning works
- [ ] GPS location capture works
- [ ] Attendance marking works
- [ ] Sessions list displays correctly
- [ ] My Attendance displays correctly
- [ ] Theme toggle works
- [ ] Profile screen displays correctly
- [ ] Logout works

### Device Testing
- [ ] Android 5.0 (minSdk 21)
- [ ] Android 10+
- [ ] Android 12+
- [ ] Different screen sizes
- [ ] Permissions requests work
- [ ] App behavior in background

### Error Scenarios
- [ ] No internet connection
- [ ] Invalid credentials
- [ ] Expired token
- [ ] Invalid QR code
- [ ] Location permission denied
- [ ] Camera permission denied

---

## 📦 Release Steps

1. **Update API URL** to HTTPS
2. **Update version** in pubspec.yaml
3. **Configure signing** (if not done)
4. **Build APK** for testing
5. **Test APK** on real devices
6. **Build AAB** for Play Store
7. **Upload AAB** to Google Play Console
8. **Submit for review**

---

## ⚠️ Critical Reminders

1. **HTTPS Base URL**: Must be updated before release
2. **Signing Config**: Configure before production build
3. **Version Number**: Increment for each release
4. **Test Thoroughly**: Test on real devices before release
5. **App Icon**: Replace default icons (optional but recommended)

---

**Last Updated**: Production Release Preparation
**Status**: Ready for Build (after API URL update)

