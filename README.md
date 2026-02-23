# AttendMark Mobile App

Production-ready Flutter mobile application for AttendMark attendance management system.

## Features

- ✅ Login with email/password and organization selection
- ✅ Role-based dashboard
- ✅ QR code scanning for attendance
- ✅ GPS location verification
- ✅ View sessions (Today, Upcoming, Past)
- ✅ View personal attendance history
- ✅ Apply for leaves
- ✅ View leave balance and requests
- ✅ User profile management
- ✅ Dark theme UI matching web app

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (stable channel)
- Android Studio / VS Code with Flutter extensions
- Android SDK (minimum SDK 21)
- Backend server running (see main project README)

### 2. Configure Backend URL

**IMPORTANT**: Update the backend API URL in `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'http://YOUR_BACKEND_URL/api';
```

- **Android Emulator**: Use `http://10.0.2.2:5000/api` (localhost proxy)
- **Physical Device**: Use your computer's IP address, e.g., `http://192.168.1.100:5000/api`
- **Production**: Use your deployed backend URL

### 3. Install Dependencies

```bash
cd attend_mark
flutter pub get
```

### 4. Run the App

```bash
# For Android
flutter run

# For specific device
flutter devices
flutter run -d <device-id>
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app widget with providers
├── config/                   # Configuration files
│   ├── api_config.dart      # API endpoints
│   ├── theme.dart           # App theme
│   └── constants.dart       # App constants
├── core/                     # Core functionality
│   ├── network/            # HTTP client (Dio)
│   ├── storage/             # Local storage
│   └── utils/               # Utilities (logger)
├── models/                   # Data models
├── services/                 # API services
├── providers/               # State management (Provider)
├── screens/                  # UI screens
├── widgets/                  # Reusable widgets
└── routes/                   # Navigation routes
```

## Key Features Implementation

### Authentication
- Two-step login: email/password → organization selection
- JWT token storage
- Auto-logout on 401 errors
- Device registration

### QR Code Scanning
- Real-time QR code scanning
- GPS location capture
- Location verification before marking attendance
- Error handling and user feedback

### State Management
- Provider for state management
- Separate providers for Auth, Sessions, Attendance, Leaves
- Automatic UI updates on state changes

### Error Handling
- Comprehensive error handling
- User-friendly error messages
- Retry mechanisms
- Network error detection

## Permissions

The app requires the following permissions (already configured in AndroidManifest.xml):

- Internet (for API calls)
- Camera (for QR scanning)
- Location (for GPS verification)

## Development Notes

- **State Management**: Uses Provider package (no Riverpod)
- **HTTP Client**: Uses Dio with interceptors
- **Storage**: Uses SharedPreferences for tokens
- **Theme**: Dark theme matching web app branding
- **Logging**: Comprehensive logging for debugging

## Troubleshooting

### App won't connect to backend
- Check if backend server is running
- Verify API URL in `api_config.dart`
- For physical device, ensure phone and computer are on same network
- Check firewall settings

### QR Scanner not working
- Grant camera permission when prompted
- Ensure camera is not being used by another app
- Check device camera functionality

### Location not working
- Grant location permission when prompted
- Enable GPS/location services on device
- Ensure location services are enabled in device settings

### Build errors
- Run `flutter clean`
- Run `flutter pub get`
- Ensure Flutter SDK is up to date
- Check Android SDK version (minimum 21)

## Next Steps

- [ ] Add forgot password flow
- [ ] Add edit profile functionality
- [ ] Add change password
- [ ] Add apply leave form
- [ ] Add session details screen
- [ ] Add attendance reports
- [ ] Add push notifications
- [ ] Add offline support

## Support

For issues or questions, refer to the main project documentation or contact the development team.
