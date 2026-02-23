# Login Troubleshooting Guide

## Issues Fixed

### 1. "Bad state: No element" Error
**Problem**: The app was trying to access `_organizations[0]` without proper null checks.

**Fix Applied**:
- Added safe access check: `_organizations.isNotEmpty ? _organizations[0] : null`
- Added state reset before login attempt
- Added validation for organization prefix before selection

**Status**: ✅ Fixed

### 2. Connection Timeout Error
**Problem**: App cannot connect to backend at `http://10.0.2.2:5000/api`

**Possible Causes**:
1. Backend server is not running
2. Wrong IP address for Android emulator
3. Network connectivity issues
4. Backend is running on different port

## Solutions

### For Android Emulator
The app is configured to use `http://10.0.2.2:5000/api` which is the default localhost proxy for Android emulator.

**Check**:
1. Is your backend server running on `localhost:5000`?
2. Is the backend accessible from your computer?

**To Test Backend**:
```bash
# Test if backend is running
curl http://localhost:5000/api/auth/login
```

### For Physical Device
If testing on a physical Android device, you need to change the base URL to your computer's IP address.

**Steps**:
1. Find your computer's IP address:
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr`
   
2. Update `lib/config/api_config.dart`:
   ```dart
   static const String baseUrl = 'http://YOUR_IP_ADDRESS:5000/api';
   // Example: 'http://192.168.1.100:5000/api'
   ```

3. Make sure your phone and computer are on the same WiFi network

4. Make sure your backend allows connections from your network (not just localhost)

### Backend Configuration
Make sure your backend server:
1. Is running on port 5000
2. Allows CORS from your app
3. Is accessible from the network (not just localhost)

### Testing Connection
You can test the connection by:
1. Opening browser on your device/emulator
2. Navigate to: `http://10.0.2.2:5000/api/auth/login` (for emulator)
3. Or: `http://YOUR_IP:5000/api/auth/login` (for physical device)

## Current Configuration

**File**: `lib/config/api_config.dart`
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

**Timeout Settings**:
- Connect timeout: 30 seconds
- Receive timeout: 30 seconds
- Send timeout: 30 seconds

## Next Steps

1. **Verify Backend is Running**:
   - Check if backend server is running
   - Test with curl or Postman

2. **Check Network**:
   - For emulator: Backend should be on `localhost:5000`
   - For device: Use computer's IP address

3. **Update Base URL** (if needed):
   - Edit `lib/config/api_config.dart`
   - Change `baseUrl` to match your setup

4. **Test Login Again**:
   - The "Bad state: No element" error is now fixed
   - Connection timeout will show clear error message

## Error Messages

### Connection Timeout
**Message**: "Request timeout. Please try again."

**Meaning**: App cannot reach the backend server within 30 seconds.

**Solutions**:
- Check if backend is running
- Verify IP address/URL is correct
- Check network connectivity
- Increase timeout if needed (not recommended)

### No Organizations Found
**Message**: "No organizations found for this user."

**Meaning**: Login succeeded but user has no accessible organizations.

**Solutions**:
- Check user has valid organizations
- Verify user is not Platform Owner (not supported on mobile)

