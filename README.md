# AP Class Stones - Marketing App

A comprehensive Flutter marketing app for AP Class Stones with role-based dashboards, authentication, and meeting management.

## 🎯 Features

### Authentication & Authorization
- **Login System**: Username/password authentication
- **Registration**: Role-based registration with Super Admin approval
- **Role Management**: Three user types with different permissions:
  - **Executive**: Punch in/out, start/end meetings
  - **Admin**: Manage employees, view reports, meeting schedules
  - **Super Admin**: Approve registrations, system management

### Executive Features
- ⏰ Punch In/Out functionality with location tracking
- 📅 Start and end meetings
- 📊 Personal dashboard with today's status
- 📈 Activity history tracking

### Admin Features
- 👥 Employee management overview
- 📊 Dashboard with key metrics
- 📅 Meeting schedule management
- 📈 Performance reports

### Super Admin Features
- ✅ Approve/reject registration requests
- 👤 User management
- 🔧 System configuration
- 📊 Complete system overview

### UI/UX Features
- 🎨 Eye-catching color scheme with gold and blue gradients
- ✨ Beautiful animated splash screen
- 📱 Responsive design with Flutter ScreenUtil
- 🎭 Smooth animations with Flutter Animate
- 🎨 Google Fonts integration (Lato & Playfair Display)

## 🏗️ Project Structure

```
lib/
├── api/                          # API Integration Layer
│   ├── models/                   # Data models with JSON serialization
│   │   └── api_models.dart      # All API response/request models
│   ├── network/                 # Network configuration
│   │   ├── api_client.dart      # Retrofit API client
│   │   └── network_service.dart # Dio configuration & interceptors
│   └── repositories/            # Data repositories
│       └── repositories.dart    # Auth, Registration, Meeting repos
├── bloc/                        # State Management (BLoC Pattern)
│   ├── auth/                    # Authentication BLoC
│   │   ├── bloc/auth_bloc.dart
│   │   ├── event/auth_event.dart
│   │   └── state/auth_state.dart
│   ├── registration/            # Registration Management BLoC
│   │   ├── bloc/registration_bloc.dart
│   │   ├── event/registration_event.dart
│   │   └── state/registration_state.dart
│   ├── dashboard/               # Dashboard BLoCs (future expansion)
│   └── meeting/                 # Meeting Management BLoCs (future expansion)
├── core/                        # Core utilities and constants
│   ├── constants/
│   │   ├── app_colors.dart     # Complete color palette
│   │   └── app_constants.dart  # App-wide constants
│   ├── utils/                  # Utility functions
│   └── services/              # Core services
├── presentation/               # UI Layer
│   ├── screens/
│   │   ├── splash/
│   │   │   └── splash_screen.dart      # Animated splash screen
│   │   ├── auth/
│   │   │   ├── login_screen.dart       # Login interface
│   │   │   └── register_screen.dart    # Registration form
│   │   └── dashboard/
│   │       ├── dashboard_router.dart    # Role-based routing
│   │       ├── executive_dashboard.dart # Executive dashboard
│   │       ├── admin_dashboard.dart     # Admin dashboard
│   │       └── super_admin_dashboard.dart # Super admin dashboard
│   └── widgets/                # Reusable UI components
│       ├── custom_text_field.dart      # Styled text input
│       ├── custom_button.dart          # Styled buttons
│       └── loading_overlay.dart        # Loading indicator
└── main.dart                   # App entry point with theme setup
```

## 🎨 Design System

### Colors
- **Primary**: Gold (#DAA520) - Premium, luxury feel
- **Secondary**: Blue (#1E3A8A) - Trust, professionalism
- **Accent**: Orange (#FF6B35) - Energy, warmth
- **Success**: Green (#10B981) - Growth, success
- **Warning**: Amber (#F59E0B) - Attention
- **Error**: Red (#EF4444) - Alerts

### Typography
- **Headers**: Playfair Display (elegant, serif)
- **Body**: Lato (clean, readable sans-serif)

### Components
- **Rounded corners**: 12px border radius
- **Shadows**: Subtle elevation with transparency
- **Gradients**: Multi-color gradients for premium feel
- **Animations**: Smooth, purposeful motion

## 🛠️ Tech Stack

### Framework & Language
- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language

### State Management
- **flutter_bloc**: Predictable state management
- **equatable**: Value equality for models

### Networking
- **dio**: HTTP client
- **retrofit**: Type-safe REST client
- **json_annotation**: JSON serialization

### UI/UX
- **google_fonts**: Typography
- **flutter_animate**: Smooth animations
- **flutter_screenutil**: Responsive design
- **lottie**: Complex animations (ready for integration)

### Storage
- **shared_preferences**: Local data persistence

### Development Tools
- **build_runner**: Code generation
- **json_serializable**: Automatic JSON conversion
- **retrofit_generator**: API client generation

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- iOS/Android development setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd apclassstone
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Development Workflow

1. **Code Generation**: After modifying API models or adding new ones:
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

2. **Clean Build**: If encountering issues:
   ```bash
   flutter clean
   flutter pub get
   flutter packages pub run build_runner build
   ```

3. **Analysis**: Check code quality:
   ```bash
   flutter analyze
   ```

## 📱 User Flows

### Registration Flow
1. User fills registration form with role selection
2. Super Admin receives notification of pending registration
3. Super Admin approves/rejects from dashboard
4. User receives access upon approval

### Executive Daily Flow
1. Login to app
2. Punch in to start day
3. Create meetings as needed
4. Punch out at end of day
5. View activity summary

### Admin Management Flow
1. Access admin dashboard
2. View employee metrics and reports
3. Manage meeting schedules
4. Monitor team performance

### Super Admin Oversight Flow
1. Review system metrics
2. Manage pending registrations
3. Configure system settings
4. Monitor overall platform health

## 🔒 Security Features

- **Token-based authentication** with automatic refresh
- **Role-based access control** (RBAC)
- **Secure local storage** for user data
- **API request/response encryption** ready
- **Session management** with automatic logout

## 📈 Future Enhancements

- [ ] Push notifications for meetings and approvals
- [ ] Offline capability with data sync
- [ ] Advanced analytics and reporting
- [ ] Chat/messaging between users
- [ ] Calendar integration
- [ ] File sharing and documents
- [ ] Performance metrics and KPIs
- [ ] Multi-language support

## 🏢 Company Branding

**AP Class Stones** - Premium Stones, Premium Quality

The app reflects the premium nature of the stone business with:
- Elegant gold and blue color scheme
- Sophisticated typography
- Smooth animations and transitions
- Professional, trustworthy design language

---

Built with ❤️ for AP Class Stones marketing team.
