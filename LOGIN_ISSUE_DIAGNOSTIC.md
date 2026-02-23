# Login Malfunction Diagnostic Guide

## Issue Description
Unable to log in to the Flutter application running on a physical Android device connecting to the production backend (`https://attend-mark.onrender.com/api`).

## Potential Causes & Verification Steps

### 1. Backend Connectivity
- [ ] **Verify Production URL**: Ensure `ApiService.baseUrl` is strictly `https://attend-mark.onrender.com/api` and does not contain any local IP (e.g., `192.168.x.x`).
- [ ] **Check Server Status**: Open `https://attend-mark.onrender.com/api/health` (or similar) in a browser to confirm the server is running.
- [ ] **SSL Handshake**: Ensure the device trusts the SSL certificate of the production domain.

### 2. Data Model Mismatches (Highly Likely)
- [ ] **Organization ID vs Prefix**: The backend response for login might not include a `prefix` field, leading to an empty organization selection in the app.
    - **Fix**: Update `OrganizationModel.fromJson` to fallback to `organizationId` if `prefix` is missing.
- [ ] **JSON Keys**: Verify if the backend sends `orgName` instead of `name`.
    - **Fix**: Update `OrganizationModel` to check `json['orgName']`.

### 3. Application State & Context Safety
- [ ] **"Widget Unmounted" Error**: If the app crashes after login but before dashboard, the `LoginScreen` logic might be trying to update the UI after it closes.
    - **Fix**: Ensure `if (!mounted) return;` is called immediately after EVERY `await` call.
- [ ] **Race Conditions**: If auto-selection logic runs too fast, verify `_selectOrganization` doesn't race with `setState`.

### 4. Network Permissions (Android)
- [ ] **AndroidManifest.xml**: Confirm `<uses-permission android:name="android.permission.INTERNET"/>` is present.
- [ ] **Network Logic**: Ensure the device has active internet (toggle Wifi/Data).

## Resolved Issues (Reference)
- **Local IP**: We previously removed a hardcoded assertion for local IPs in `app.dart`.
- **Parsing**: We recently patched `user_model.dart` to accept `organizationId` as a valid ID source.

## How to Verify Fixes
1. Stop the app completely (`q` in terminal).
2. Run `flutter clean`.
3. Run `flutter run --release` (or debug) to ensure a fresh build is deployed to the phone.
