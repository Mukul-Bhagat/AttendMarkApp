# AttendMark Mobile App - Flutter Implementation Details

## Overview
AttendMark is a comprehensive attendance management system with a mobile app built using Flutter. The app provides secure, location-based attendance tracking with QR code scanning, real-time monitoring, and multi-role support.

## Core Features

### 1. Authentication & User Management
- **Login/Logout**: Secure authentication with JWT tokens
- **Password Reset**: Forgot password flow with email verification
- **Profile Management**: View and edit user profile (name, phone, bio, profile picture)
- **Device Registration**: Device locking feature to prevent unauthorized access
- **Role-Based Access**: Different UI/UX based on user role:
  - Super Admin
  - Company Admin
  - Manager
  - Session Admin
  - End User (Employee)

### 2. QR Code Attendance Scanning
- **Dynamic QR Code Scanner**: Scan session QR codes to mark attendance
- **Location Verification**: GPS-based location verification (required for physical sessions)
- **Real-time Validation**: 
  - Session date/time validation
  - Location proximity check (configurable radius, default 100m)
  - Device ID verification
  - Late attendance detection (configurable late limit, default 30 minutes)
- **Attendance Status**: 
  - Present (marked via QR scan)
  - Absent (auto-marked if not scanned)
  - On Leave (approved leave requests)
- **Session Types Support**:
  - Physical sessions (location required)
  - Remote sessions (location not required)
  - Hybrid sessions (mixed physical/remote)

### 3. Session Management
- **View Sessions**: 
  - My Sessions (sessions assigned to user)
  - All Sessions (for admins/managers)
  - Upcoming sessions
  - Past sessions
- **Session Details**: 
  - Session name, description, time, location
  - Assigned users list
  - Attendance status for each user
  - Session type (Physical/Remote/Hybrid)
- **Session Creation** (Admin/Manager roles):
  - Create one-time, daily, weekly, or monthly sessions
  - Set start/end dates and times
  - Configure location (Google Maps link or coordinates)
  - Assign users with specific modes (Physical/Remote)
  - Set geofence radius
- **Session Editing**: Modify existing sessions
- **Session Cancellation**: Cancel sessions with reason

### 4. Attendance Tracking & Reports
- **My Attendance**: 
  - Personal attendance history
  - Filter by date range
  - View check-in times, location status, late status
- **Session Attendance**: 
  - View attendance for specific sessions
  - See who's present, absent, or on leave
  - Real-time updates during session
- **Attendance Reports** (Admin/Manager):
  - Organization-wide attendance reports
  - User-specific reports
  - Date range filtering
  - Export capabilities
- **Dashboard**: 
  - Real-time attendance statistics
  - Charts and visualizations
  - Today's attendance summary
  - Late arrivals tracking

### 5. Leave Management
- **Leave Requests**: 
  - Apply for leaves (Personal Leave, Casual Leave, Sick Leave)
  - View leave balance/quota
  - Track leave request status (Pending/Approved/Rejected)
- **Leave Approval** (Manager/Session Admin):
  - Approve/reject leave requests
  - View all pending requests
- **Leave Quota**: 
  - View available leave balance
  - Custom quotas per user (if set by admin)
  - Organization default quotas

### 6. User Management (Admin Roles)
- **Manage Users**: 
  - Add new users
  - Edit user details
  - Delete users
  - Bulk import via CSV
  - Reset device registration
- **Manage Staff**: 
  - Manage Manager and SessionAdmin roles
  - Assign permissions
- **Class/Batch Management**: 
  - Create and manage classes/batches
  - Assign users to classes
  - Link sessions to classes

### 7. Organization Management (Super Admin/Company Admin)
- **Organization Settings**: 
  - Configure late attendance limit
  - Set strict attendance mode
  - Manage organization details
- **Multi-Organization Support**: 
  - Switch between organizations (Super Admin)
  - Manage multiple branches/departments

### 8. Additional Features
- **Data Backup**: Export organization data
- **Audit Logs**: Track system activities (Platform Owner)
- **Notifications**: Push notifications for:
  - Upcoming sessions
  - Attendance reminders
  - Leave request updates
  - Session cancellations
- **Offline Support**: Cache data for offline viewing
- **Dark Mode**: Theme support

## Technical Architecture

### Flutter Dependencies (Recommended)
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  # or riverpod: ^2.4.9
  
  # HTTP & API
  http: ^1.1.0
  dio: ^5.4.0
  
  # Local Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # QR Code
  qr_code_scanner: ^1.0.1
  # or mobile_scanner: ^3.5.0
  
  # Location Services
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  permission_handler: ^11.1.0
  
  # Maps
  google_maps_flutter: ^2.5.0
  
  # UI Components
  cupertino_icons: ^1.0.8
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  
  # Forms & Validation
  flutter_form_builder: ^9.1.1
  form_builder_validators: ^9.1.0
  
  # Date/Time
  intl: ^0.19.0
  table_calendar: ^3.0.9
  
  # Charts
  fl_chart: ^0.65.0
  
  # File Handling
  file_picker: ^6.1.1
  csv: ^5.0.2
  
  # Notifications
  flutter_local_notifications: ^16.3.0
  firebase_messaging: ^14.7.9
  
  # Image Handling
  image_picker: ^1.0.7
  
  # Device Info
  device_info_plus: ^9.1.1
  package_info_plus: ^5.0.1
  
  # Biometric Auth (Future)
  local_auth: ^2.1.7
```

### Project Structure
```
lib/
├── main.dart
├── config/
│   ├── api_config.dart
│   ├── app_config.dart
│   └── theme_config.dart
├── models/
│   ├── user.dart
│   ├── session.dart
│   ├── attendance.dart
│   ├── leave_request.dart
│   └── organization.dart
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── storage_service.dart
│   ├── location_service.dart
│   ├── qr_service.dart
│   └── notification_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── session_provider.dart
│   ├── attendance_provider.dart
│   └── leave_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   └── reset_password_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── attendance/
│   │   ├── scan_qr_screen.dart
│   │   ├── my_attendance_screen.dart
│   │   └── attendance_report_screen.dart
│   ├── sessions/
│   │   ├── sessions_list_screen.dart
│   │   ├── session_details_screen.dart
│   │   └── create_session_screen.dart
│   ├── leaves/
│   │   ├── leaves_screen.dart
│   │   └── apply_leave_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── admin/
│       ├── manage_users_screen.dart
│       ├── dashboard_screen.dart
│       └── settings_screen.dart
├── widgets/
│   ├── common/
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   └── loading_indicator.dart
│   ├── attendance/
│   │   └── attendance_card.dart
│   └── session/
│       └── session_card.dart
├── utils/
│   ├── validators.dart
│   ├── date_formatter.dart
│   ├── constants.dart
│   └── helpers.dart
└── routes/
    └── app_router.dart
```

## Key Screens & Functionality

### 1. Login Screen
- Email/password authentication
- Remember me option
- Forgot password link
- Device registration on first login
- Role-based navigation after login

### 2. Home/Dashboard Screen
- Role-based dashboard:
  - **End User**: Today's sessions, quick scan button, attendance summary
  - **Manager/Session Admin**: Team attendance overview, pending leave requests
  - **Admin**: Organization statistics, recent activities
- Quick actions (Scan QR, Apply Leave, View Sessions)
- Notifications panel
- Upcoming sessions widget

### 3. QR Scanner Screen
- Camera-based QR code scanner
- Real-time location capture
- GPS accuracy display
- Session validation feedback
- Success/error animations
- Attendance confirmation dialog

### 4. My Attendance Screen
- Calendar view with attendance markers
- List view with filters:
  - Date range
  - Session type
  - Status (Present/Absent/On Leave)
- Attendance details:
  - Check-in time
  - Location status
  - Late status (if applicable)
  - Distance from session location

### 5. Sessions Screen
- List of sessions (upcoming/past)
- Search and filter functionality
- Session cards showing:
  - Name, time, location
  - Attendance status
  - Number of attendees
- Pull to refresh
- Swipe actions (for admins: edit/delete)

### 6. Session Details Screen
- Full session information
- Assigned users list with attendance status
- Real-time attendance updates
- Map view showing session location
- QR code generation (for admins)
- Action buttons based on role

### 7. Leave Management Screen
- Leave balance display
- Leave history
- Apply leave form:
  - Leave type selection
  - Date range picker
  - Reason input
  - Balance check
- Leave request status tracking

### 8. Profile Screen
- User information display
- Edit profile functionality
- Profile picture upload
- Change password
- Device information
- Logout option

### 9. Admin Screens
- **Manage Users**: CRUD operations, bulk import
- **Dashboard**: Analytics, charts, statistics
- **Settings**: Organization settings, preferences
- **Reports**: Generate and export reports

## Security Features

### 1. Device Locking
- Device ID registration on first login
- Device verification on each attendance scan
- Device reset capability (admin only)

### 2. Location Verification
- GPS-based location check
- Configurable geofence radius
- Accuracy threshold validation
- Required for physical sessions only

### 3. Authentication
- JWT token-based authentication
- Token refresh mechanism
- Secure token storage
- Auto-logout on token expiry

### 4. Data Security
- Encrypted local storage
- Secure API communication (HTTPS)
- Input validation
- SQL injection prevention (handled by backend)

## API Integration

### Base API Endpoints
- Authentication: `/api/auth/*`
- Attendance: `/api/attendance/*`
- Sessions: `/api/sessions/*`
- Users: `/api/users/*`
- Leaves: `/api/leaves/*`
- Reports: `/api/reports/*`
- Dashboard: `/api/dashboard/*`

### Key API Calls
1. `POST /api/auth/login` - User login
2. `POST /api/attendance/scan` - Mark attendance via QR scan
3. `GET /api/attendance/me` - Get user's attendance history
4. `GET /api/sessions` - Get sessions list
5. `GET /api/sessions/:id` - Get session details
6. `POST /api/leaves` - Apply for leave
7. `GET /api/dashboard` - Get dashboard data

## Permissions Required

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

### iOS (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan QR codes for attendance</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location access to verify your attendance location</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need location access to verify your attendance location</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to upload profile pictures</string>
```

## UI/UX Design Guidelines

### Color Scheme
- Primary: Red (#D61C22) - Based on web app branding
- Background: Dark theme (#050505)
- Accent colors: 
  - Emerald (success)
  - Purple (info)
  - Orange (warning)
  - Rose (admin)

### Design Principles
- Material Design 3 guidelines
- Dark mode first (with light mode option)
- Responsive layout
- Smooth animations
- Intuitive navigation
- Clear visual feedback
- Accessibility support

### Navigation
- Bottom navigation bar for main sections
- Drawer menu for additional options
- Stack navigation for detail screens
- Tab navigation for sub-sections

## Performance Considerations

1. **Image Optimization**: Use cached network images
2. **API Caching**: Cache frequently accessed data
3. **Lazy Loading**: Load data on demand
4. **Background Processing**: Handle location updates efficiently
5. **Battery Optimization**: Optimize GPS usage
6. **Offline Support**: Cache essential data for offline access

## Testing Strategy

1. **Unit Tests**: Business logic, utilities, validators
2. **Widget Tests**: UI components
3. **Integration Tests**: API integration, navigation flows
4. **E2E Tests**: Critical user journeys
5. **Device Testing**: Multiple Android/iOS devices
6. **Location Testing**: Various GPS scenarios

## Future Enhancements

1. **Biometric Authentication**: Face recognition, fingerprint
2. **Offline Mode**: Full offline attendance marking
3. **Push Notifications**: Real-time updates
4. **Widget Support**: Home screen widgets
5. **Wearable Support**: Smartwatch integration
6. **Multi-language**: Internationalization
7. **Accessibility**: Enhanced screen reader support
8. **Analytics**: User behavior tracking

## Development Phases

### Phase 1: Core Features (MVP)
- Authentication
- QR Code scanning
- Basic attendance tracking
- Profile management

### Phase 2: Enhanced Features
- Session management
- Leave management
- Reports and analytics
- Admin features

### Phase 3: Advanced Features
- Offline support
- Push notifications
- Advanced analytics
- Performance optimizations

### Phase 4: Polish & Launch
- UI/UX refinements
- Comprehensive testing
- App store optimization
- Documentation

## Deployment

### Android
- Google Play Store
- Minimum SDK: 21 (Android 5.0)
- Target SDK: Latest

### iOS
- App Store
- Minimum iOS: 13.0
- Target iOS: Latest

## Support & Maintenance

- Regular updates for bug fixes
- Feature enhancements based on feedback
- Security patches
- Performance improvements
- Compatibility updates for new OS versions

---

**Note**: This document should be updated as the app development progresses and new features are added or requirements change.

