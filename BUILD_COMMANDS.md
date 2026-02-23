# AttendMark - Build Commands Reference

## 🚀 Quick Build Commands

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

---

## 📋 Detailed Build Steps

### 1. Pre-Build Setup

```bash
# Navigate to project directory
cd attend_mark

# Clean previous builds
flutter clean

# Get all dependencies
flutter pub get

# Verify Flutter setup
flutter doctor
```

### 2. Build APK

```bash
# Standard release APK
flutter build apk --release

# Split APKs by ABI (smaller size)
flutter build apk --release --split-per-abi

# With specific build number
flutter build apk --release --build-number=2
```

### 3. Build AAB (Recommended for Play Store)

```bash
# Standard release AAB
flutter build appbundle --release

# With specific build number
flutter build appbundle --release --build-number=2
```

### 4. Install and Test

```bash
# Install APK on connected device
adb install build/app/outputs/flutter-apk/app-release.apk

# Or use Flutter install
flutter install --release
```

---

## 🔧 Build Options

### Build Number
```bash
# Increment build number
flutter build apk --release --build-number=2
flutter build appbundle --release --build-number=2
```

### Build with Profile
```bash
# Profile build (for performance testing)
flutter build apk --profile
flutter build appbundle --profile
```

### Build with Debug
```bash
# Debug build (for development)
flutter build apk --debug
```

---

## 📊 Build Outputs

### APK Files
- **Location**: `build/app/outputs/flutter-apk/`
- **Files**:
  - `app-release.apk` - Universal APK
  - `app-armeabi-v7a-release.apk` - ARM 32-bit
  - `app-arm64-v8a-release.apk` - ARM 64-bit
  - `app-x86_64-release.apk` - x86 64-bit

### AAB Files
- **Location**: `build/app/outputs/bundle/release/`
- **File**: `app-release.aab`

---

## ✅ Verification Commands

### Check APK Size
```bash
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

### Check AAB Size
```bash
ls -lh build/app/outputs/bundle/release/app-release.aab
```

### Verify APK
```bash
# List APK contents
unzip -l build/app/outputs/flutter-apk/app-release.apk | head -20
```

### Check Version
```bash
# APK version info
aapt dump badging build/app/outputs/flutter-apk/app-release.apk | grep version
```

---

## 🔒 Signing Configuration

### Create Keystore (One-time)
```bash
keytool -genkey -v -keystore ~/attendmark-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias attendmark
```

### Configure Signing in build.gradle.kts
```kotlin
signingConfigs {
    create("release") {
        storeFile = file("path/to/keystore.jks")
        storePassword = System.getenv("KEYSTORE_PASSWORD")
        keyAlias = System.getenv("KEY_ALIAS")
        keyPassword = System.getenv("KEY_PASSWORD")
    }
}
```

---

## 📱 Testing Builds

### Install on Device
```bash
# Via ADB
adb install build/app/outputs/flutter-apk/app-release.apk

# Via Flutter
flutter install --release
```

### Test Features
- [ ] Login flow
- [ ] Token persistence
- [ ] QR scanning
- [ ] GPS location
- [ ] All screens navigation
- [ ] Theme toggle
- [ ] Error handling

---

## 🐛 Troubleshooting

### Build Fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

### Signing Issues
```bash
# Verify keystore
keytool -list -v -keystore ~/attendmark-keystore.jks
```

### Large APK Size
```bash
# Build split APKs
flutter build apk --release --split-per-abi
```

---

**Quick Reference**: See `PRODUCTION_RELEASE.md` for complete checklist

