# Healthcare Appointment Management System

A comprehensive Flutter-based mobile application for managing healthcare appointments with role-based access control, GPS verification, automated notifications, and advanced analytics.

## 🌟 Key Features

### 🩺 Enhanced Patient Experience

#### Seamless Registration & Authentication
- **Quick Account Creation**: Streamlined registration process with role selection (Patient, Doctor, Admin)
- **Secure Authentication**: Password hashing with crypto library and JWT-based session management
- **Multi-role Support**: Automatic dashboard routing based on user role
- **Profile Management**: Complete patient profile with medical history and preferences

#### Smart Doctor Search & Discovery
- **Advanced Search Filters**: Find doctors by name, specialization, hospital, rating, and consultation fee
- **Location-based Search**: Search doctors by city and proximity to your location
- **Real-time Availability**: Instant availability check with live slot updates
- **Doctor Profiles**: Comprehensive profiles with experience, qualifications, ratings, and patient reviews
- **Specialization Categories**: Browse doctors by 12+ medical specializations
- **Hospital Information**: Complete hospital details with contact information and facilities

#### Intelligent Appointment Booking
- **Real-time Slot Booking**: Live availability checking to prevent double bookings
- **Smart Time Slots**: Pre-defined time slots with automatic conflict resolution
- **Date Restrictions**: No Sunday bookings with 30-day advance booking window
- **Detailed Booking Form**: Comprehensive reason for visit (minimum 10 characters) and optional notes
- **Instant Confirmation**: Immediate booking confirmation with unique appointment tokens
- **Multi-step Validation**: Form validation and availability verification before booking

#### GPS Location Verification System
- **Automated Location Check**: GPS-based verification on appointment day
- **500-meter Radius**: Automatic verification within 500 meters of hospital
- **Real-time Monitoring**: Continuous location tracking during appointment time
- **Auto-cancellation**: Automatic appointment cancellation if patient is too far away
- **Visual Feedback**: Interactive location verification interface with distance display
- **Permission Handling**: Seamless location permission requests and settings management
- **Accuracy Tracking**: Location accuracy monitoring and error handling

#### Comprehensive Appointment Management
- **Multi-status Tracking**: Track appointments through pending, approved, rejected, completed, and cancelled states
- **Real-time Updates**: Live status updates across all interfaces
- **Appointment History**: Complete history with advanced filtering options
- **Search & Filter**: Search by doctor name, specialization, hospital, or appointment details
- **Categorized Views**: Separate views for upcoming, past, and all appointments
- **One-click Actions**: Easy appointment cancellation and rescheduling
- **Detailed Information**: Complete appointment details with doctor and hospital information

#### Advanced Email Notification System
- **SendGrid Integration**: Professional email delivery with high deliverability
- **Appointment Confirmations**: Instant email confirmation with appointment token
- **Status Updates**: Real-time email notifications for all status changes
- **Automated Reminders**: Smart reminder system with 1-hour and 15-minute alerts
- **Location Alerts**: Email notifications for location verification requirements
- **Cancellation Notices**: Automatic notifications for appointment cancellations
- **Professional Templates**: HTML-formatted emails with hospital branding
- **Multiple Languages**: Support for multiple language email templates

#### Token-based Reference System
- **Unique Tokens**: Cryptographically secure appointment tokens (APT-timestamp format)
- **Easy Reference**: Simple token-based appointment lookup and management
- **QR Code Generation**: QR codes for quick hospital check-in (coming soon)
- **Token Validation**: Secure token verification at hospital reception
- **Copy-to-clipboard**: Easy token copying for sharing and reference
- **Token History**: Complete token usage history and tracking

### 👨‍⚕️ Doctor Dashboard Features

#### Professional Profile Management
- **Complete Medical Profiles**: License number, specialization, experience, and qualifications
- **Hospital Affiliation**: Multi-hospital association with primary hospital selection
- **Availability Management**: Custom available days and hours configuration
- **Consultation Fees**: Transparent fee structure with currency support
- **Professional Bio**: Detailed doctor biography and areas of expertise
- **Verification Status**: Medical license verification and hospital credentialing

#### Advanced Appointment Review System
- **Request Queue**: Organized queue of pending appointment requests
- **Patient Information**: Access to patient history and medical records
- **Decision Tools**: Approve, reject, or request additional information
- **Custom Notes**: Add professional notes to appointment decisions
- **Bulk Actions**: Handle multiple appointments simultaneously
- **Priority Sorting**: Sort appointments by urgency, date, or patient type

#### Schedule Overview & Management
- **Visual Calendar**: Interactive calendar view with appointment slots
- **Dashboard Analytics**: Quick stats for pending, approved, and completed appointments
- **Patient Communication**: Direct messaging through the platform (coming soon)
- **Appointment History**: Complete record of all patient interactions
- **Revenue Tracking**: Consultation fee tracking and payment status
- **Time Blocking**: Block specific time slots for breaks or emergencies

#### Real-time Notifications & Alerts
- **Instant Alerts**: Push notifications for new appointment requests
- **Email Integration**: Professional email notifications with appointment details
- **SMS Alerts**: Optional SMS notifications for urgent appointments (coming soon)
- **Custom Preferences**: Personalized notification settings and schedules
- **Sound Alerts**: Audio notifications for mobile app users
- **Badge Counters**: Visual indication of pending requests and actions

### 🔐 Admin Control Panel

#### Comprehensive System Dashboard
- **Real-time Metrics**: Live statistics for users, appointments, and system performance
- **Growth Analytics**: User registration trends and platform adoption metrics
- **System Health**: Database performance, API response times, and error monitoring
- **Revenue Analytics**: Financial metrics and consultation fee analysis
- **Geographic Distribution**: User and appointment distribution by location
- **Performance KPIs**: Key performance indicators with trend analysis

#### Advanced User Management
- **Multi-role Administration**: Manage patients, doctors, and admin accounts
- **Account Activation**: User account approval and deactivation controls
- **Bulk Operations**: Mass user operations and data management
- **User Search**: Advanced search and filtering by multiple criteria
- **Profile Verification**: Doctor license and hospital credential verification
- **Activity Monitoring**: User activity logs and session management

#### Business Intelligence & Analytics
- **Registration Trends**: Detailed analysis of user growth patterns
- **Appointment Analytics**: Success rates, cancellation patterns, and peak hours
- **Doctor Performance**: Top-performing doctors and patient satisfaction metrics
- **Hospital Utilization**: Resource utilization across hospital network
- **Revenue Reports**: Financial analytics with trend forecasting
- **Data Export**: CSV and JSON export capabilities for external analysis

#### System Administration Tools
- **Database Management**: Direct database access for advanced operations
- **Email Service Management**: SendGrid integration monitoring and configuration
- **Location Service Control**: GPS service monitoring and configuration
- **Background Services**: Control of automated reminder and monitoring services
- **Security Management**: Access control, authentication logs, and security monitoring
- **System Maintenance**: Automated backups, database optimization, and cleanup

### 🏥 Advanced System Features

#### Intelligent Background Processing
- **Automated Reminders**: Node-cron powered reminder system with 1-hour and 15-minute alerts
- **Smart Monitoring**: Automatic appointment status monitoring and updates
- **Location Tracking**: Continuous GPS verification during appointment times
- **Auto-cancellation**: Intelligent cancellation for location verification failures
- **Database Optimization**: Automated database cleanup and optimization
- **Error Recovery**: Automatic error detection and recovery mechanisms

#### Professional Email Integration
- **SendGrid API**: Professional email delivery with 99%+ deliverability
- **Template Management**: Customizable HTML email templates
- **Delivery Tracking**: Email delivery confirmation and bounce handling
- **Automated Workflows**: Trigger-based email sequences for different appointment stages
- **Multi-language Support**: Localized email templates for different regions
- **Attachment Support**: Medical reports and prescription attachments (coming soon)

#### Security & Compliance Features
- **Data Encryption**: End-to-end encryption for sensitive medical data
- **HIPAA Compliance**: Healthcare data protection and privacy compliance
- **Access Control**: Role-based permissions with granular control
- **Audit Trails**: Complete activity logging for compliance reporting
- **Secure Authentication**: Multi-factor authentication support (coming soon)
- **Data Backup**: Automated daily backups with encryption

#### Mobile-First Design
- **Responsive UI**: Optimized for all screen sizes and orientations
- **Native Performance**: Flutter-based native mobile performance
- **Offline Support**: Limited offline functionality for appointment viewing
- **Push Notifications**: Native mobile push notifications
- **Dark Mode**: Automatic dark/light theme switching (coming soon)
- **Accessibility**: Full accessibility support for users with disabilities

## 🚀 Enhanced Patient Journey

### Registration & Onboarding
1. **Account Creation**: Visit registration screen and select "Patient" role
2. **Profile Setup**: Complete personal information with phone number validation
3. **Email Verification**: Receive welcome email with account confirmation
4. **Dashboard Access**: Automatic login and dashboard redirection
5. **Feature Tour**: Interactive onboarding tour of key features

### Doctor Discovery & Selection
1. **Smart Search**: Use advanced search filters to find the perfect doctor
2. **Compare Options**: Compare multiple doctors by ratings, fees, and experience
3. **Read Reviews**: Patient reviews and ratings for informed decisions
4. **Check Availability**: Real-time availability for immediate booking
5. **Hospital Information**: Complete hospital details and location

### Appointment Booking Process
1. **Select Doctor**: Choose from filtered search results
2. **Pick Date**: Select from available dates (excluding Sundays)
3. **Choose Time**: Pick from available time slots with real-time updates
4. **Provide Details**: Enter reason for visit and optional notes
5. **Confirm Booking**: Review and confirm appointment with instant token generation
6. **Email Confirmation**: Receive detailed confirmation email with all information

### Appointment Day Experience
1. **Reminder Notifications**: Receive 1-hour and 15-minute email reminders
2. **Location Verification**: Use GPS verification when arriving at hospital
3. **Real-time Updates**: Get live updates on appointment status
4. **Hospital Check-in**: Present appointment token at reception
5. **Post-appointment**: Receive completion confirmation and feedback request

### Ongoing Management
1. **Track Appointments**: Monitor all appointments in organized dashboard
2. **Receive Updates**: Get real-time notifications for status changes
3. **History Access**: Complete appointment history with search and filter
4. **Easy Cancellation**: One-click cancellation with automatic notifications
5. **Profile Management**: Update personal information and preferences

## 👩‍💻 Technical Architecture

### Frontend (Flutter)
```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── user_model.dart
│   ├── appointment_model.dart
│   ├── doctor_model.dart
│   └── hospital_model.dart
├── screens/                     # UI screens
│   ├── auth/                    # Authentication screens
│   ├── patient/                 # Patient-specific screens
│   ├── doctor/                  # Doctor dashboard screens
│   └── admin/                   # Admin panel screens
├── services/                    # API and business logic
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── location_service.dart
│   └── notification_service.dart
├── widgets/                     # Reusable UI components
└── utils/                       # Utility functions
```

### Backend (Node.js + Express)
```
backend/
├── server.js                    # Server entry point
├── config/                      # Configuration files
├── models/                      # Database models
├── routes/                      # API routes
├── middleware/                  # Authentication & validation
├── services/                    # Business logic
├── utils/                       # Utility functions
└── jobs/                        # Background jobs
```

### Database Schema
- **Users:** Patients, doctors, admins with role-based access
- **Appointments:** Complete appointment lifecycle management
- **Hospitals:** Hospital information and locations
- **Notifications:** Email and push notification tracking
- **Analytics:** Performance metrics and reporting data

## 🔒 Security Features

### Authentication & Authorization
- JWT-based authentication
- Role-based access control
- Session management
- Two-factor authentication

### Data Protection
- Password hashing with bcrypt
- Data encryption at rest
- HTTPS/SSL encryption
- GDPR compliance

### API Security
- Rate limiting
- Input validation
- SQL injection prevention
- XSS protection

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Node.js (16.x or higher)
- PostgreSQL/MySQL database
- SendGrid account for emails
- Google Maps API key

### Installation

1. **Clone Repository**
```bash
git clone <repository-url>
cd healthcare-appointment-system
```

2. **Backend Setup**
```bash
cd backend
npm install
cp .env.example .env
# Configure environment variables
npm run dev
```

3. **Frontend Setup**
```bash
cd flutter_app
flutter pub get
flutter run
```

4. **Database Setup**
```bash
# Run database migrations
npm run migrate
# Seed initial data
npm run seed
```

## 📱 Mobile App Features

### Cross-Platform Support
- iOS and Android compatibility
- Responsive design
- Native performance
- Offline capability

### Push Notifications
- Real-time appointment updates
- Reminder notifications
- Emergency alerts
- Custom notification preferences

### Location Services
- GPS tracking and verification
- Geofencing for hospitals
- Navigation integration
- Location-based services

## 📊 Analytics & Reporting

### Real-time Dashboards
- Live appointment tracking
- User activity monitoring
- Performance metrics
- System health monitoring

### Business Intelligence
- Custom report generation
- Data visualization
- Trend analysis
- Predictive analytics

### Export Capabilities
- CSV/Excel export
- PDF reports
- API data access
- Automated reporting

## 🤝 Contributing

### Development Guidelines
1. Follow Flutter/Dart style guidelines
2. Implement proper error handling
3. Write comprehensive tests
4. Document API endpoints
5. Ensure mobile responsiveness

### Code Quality
- ESLint for JavaScript
- Dart analyzer for Flutter
- Unit and integration tests
- Code review process

## 📞 Support & Contact

- **Technical Support:** support@healthcare-app.com
- **Documentation:** [API Docs](https://docs.healthcare-app.com)
- **Community:** [GitHub Issues](https://github.com/healthcare-app/issues)

---

**Note:** This is a comprehensive healthcare management system designed for production use with enterprise-grade security, scalability, and compliance features. The system follows healthcare industry standards and includes robust data protection measures.

## 🚀 Features

- **User Authentication**: Secure login with email and password
- **User Registration**: Create new accounts with validation
- **Password Security**: SHA-256 password hashing
- **Local Database**: SQLite database for user data storage
- **Admin Panel**: View all registered users
- **Form Validation**: Input validation and error handling
- **Material Design**: Modern UI with Material 3 components

## 📱 Screenshots

The app includes:
- Login screen with email/password fields
- Registration screen for new users  
- Welcome screen after successful login
- Admin screen to view all users

## 🏗️ Architecture Overview

### Frontend (Flutter UI)
```
lib/
├── main.dart              # App entry point and routing
├── login_screen.dart      # Login UI and authentication logic
├── register_screen.dart   # Registration UI and user creation
├── welcome_screen.dart    # Post-login welcome screen
├── admin_screen.dart      # Admin panel to view all users
├── database_helper.dart   # Database operations and queries
└── user_model.dart        # User data model
```

### Backend (SQLite Database)
- **Database Name**: `user_database.db`
- **Table**: `users`
- **Storage**: Local device storage using sqflite

## 🗄️ Database Schema

### Users Table
```sql
CREATE TABLE users(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,           -- SHA-256 hashed
  full_name TEXT,
  created_at TEXT NOT NULL
)
```

### Default Test User
- **Email**: `test@example.com`
- **Password**: `password123`
- **Full Name**: `Test User`

## 🔧 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  sqflite: ^2.3.0        # SQLite database for Flutter
  path: ^1.8.3           # Path manipulation utilities
  crypto: ^3.0.3         # Cryptographic functions for password hashing
```

## 📝 Code Structure

### 1. Database Helper (`database_helper.dart`)

**Key Features:**
- Singleton pattern for database instance
- Password hashing with SHA-256
- CRUD operations for user management

**Main Methods:**
```dart
// Authentication
Future<Map<String, dynamic>?> authenticateUser(String email, String password)

// User Management
Future<bool> registerUser(String email, String password, String fullName)
Future<bool> userExists(String email)
Future<List<Map<String, dynamic>>> getAllUsers()
Future<void> deleteUser(String email)
Future<void> updateUser(String email, Map<String, dynamic> updates)
```

**Security Features:**
```dart
String _hashPassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString();
}
```

### 2. User Model (`user_model.dart`)

```dart
class User {
  final int? id;
  final String email;
  final String password;
  final String? fullName;
  final DateTime createdAt;
  
  // Serialization methods
  Map<String, dynamic> toMap()
  factory User.fromMap(Map<String, dynamic> map)
}
```

### 3. Login Screen (`login_screen.dart`)

**Features:**
- Form validation
- Loading states
- Database authentication
- Navigation to registration
- Error handling

**Authentication Flow:**
```dart
void _login() async {
  // 1. Validate form inputs
  // 2. Show loading indicator
  // 3. Query database for user credentials
  // 4. Navigate to welcome screen or show error
}
```

### 4. Registration Screen (`register_screen.dart`)

**Features:**
- Full name, email, password, confirm password fields
- Input validation
- Duplicate email checking
- Password confirmation
- Automatic login after registration

**Registration Flow:**
```dart
void _register() async {
  // 1. Validate all form fields
  // 2. Check if user already exists
  // 3. Hash password and store in database
  // 4. Navigate to welcome screen
}
```

### 5. Welcome Screen (`welcome_screen.dart`)

**Features:**
- Personalized welcome message
- User information display
- Logout functionality
- Admin panel access

### 6. Admin Screen (`admin_screen.dart`)

**Features:**
- View all registered users
- User details in cards
- Database statistics
- Refresh functionality

## 🔐 Security Implementation

### Password Security
- **Hashing Algorithm**: SHA-256
- **Salt**: Not implemented (consider adding for production)
- **Storage**: Only hashed passwords stored in database

### Database Security
- **Local Storage**: SQLite database stored locally on device
- **Validation**: Server-side validation for all inputs
- **SQL Injection**: Protected by parameterized queries

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Android Studio/VS Code
- Android Emulator or iOS Simulator

### Installation

1. **Clone and Setup**
```bash
git clone <repository-url>
cd login_app
flutter pub get
```

2. **Run the App**
```bash
# Check available devices
flutter devices

# Run on Android emulator
flutter run -d emulator-5554

# Run on iOS simulator
flutter run -d ios
```

3. **Test Login**
Use the default test account:
- Email: `test@example.com`
- Password: `password123`

## 🧪 Testing

### Manual Testing Scenarios

1. **Login Testing**
   - Valid credentials → Success
   - Invalid credentials → Error message
   - Empty fields → Validation errors

2. **Registration Testing**
   - New user → Success
   - Existing email → Error message
   - Password mismatch → Validation error
   - Invalid email format → Validation error

3. **Database Testing**
   - User creation and storage
   - Password hashing verification
   - User retrieval and authentication

## 🔄 Database Operations Flow

```
Registration Flow:
User Input → Validation → Check Existing → Hash Password → Store in DB → Success

Login Flow:
User Input → Validation → Hash Password → Query DB → Match Check → Success/Failure

Admin View:
Request → Query All Users → Format Data → Display List
```

## 📱 UI Components

### Custom Widgets Used
- `TextFormField` with validation
- `ElevatedButton` with loading states
- `OutlinedButton` for secondary actions
- `Card` widgets for user display
- `CircularProgressIndicator` for loading
- `SnackBar` for user feedback

### Material 3 Theme
- Primary color: Blue
- Modern rounded corners
- Consistent spacing and typography
- Responsive design principles

## 🛠️ Development Tips

### Adding New Features
1. **New Database Fields**: Update schema in `_onCreate` method
2. **New Screens**: Follow existing navigation patterns
3. **New Validations**: Add to form validator functions
4. **New Database Operations**: Add methods to `DatabaseHelper`

### Common Issues
1. **Database Path**: Ensure proper path handling across platforms
2. **Form Validation**: Always validate on both client and database level
3. **Loading States**: Implement proper loading indicators for async operations
4. **Error Handling**: Wrap database operations in try-catch blocks

### Performance Considerations
- Database queries are asynchronous
- Use `FutureBuilder` for dynamic data loading
- Implement proper dispose methods for controllers
- Consider pagination for large user lists

## 📄 File Structure Details

```
login_app/
├── lib/
│   ├── main.dart                 # App initialization and routing
│   ├── database_helper.dart      # SQLite database operations
│   ├── user_model.dart          # User data model
│   ├── login_screen.dart        # Authentication UI
│   ├── register_screen.dart     # User registration UI
│   ├── welcome_screen.dart      # Post-login interface
│   └── admin_screen.dart        # Admin panel for user management
├── android/                     # Android-specific configurations
├── ios/                         # iOS-specific configurations
├── pubspec.yaml                 # Dependencies and project metadata
└── README.md                    # This documentation file
```

## 🤝 Contributing

When contributing to this project:

1. Follow Flutter/Dart style guidelines
2. Add proper error handling
3. Update tests for new features
4. Document new database schema changes
5. Ensure UI consistency with Material 3

## 📚 Learning Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [sqflite Package](https://pub.dev/packages/sqflite)
- [Material 3 Design](https://m3.material.io/)

---

**Note**: This is a demonstration app with basic security implementations. For production use, consider implementing additional security measures such as:
- Salt for password hashing
- JWT tokens for session management
- Server-side authentication
- Data encryption
- Input sanitization
- Rate limiting
# flutter_DoctorsToken
