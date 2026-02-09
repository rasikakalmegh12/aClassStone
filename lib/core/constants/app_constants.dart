/// App Constants for AP Class Stones Marketing App
class AppConstants {
  // App Info
  static const String appName = 'OOTU';
  static const String appVersion = '1.0.0';
  static const String companyTagline = 'Premium Stones, Premium Quality';
  static const String appCode = 'MARKETING';

  // API Configuration
  static const String baseUrl = 'https://api.apclassstones.com/v1/';
  static const String apiTimeout = '30';



  // Storage Keys
  static const String isLoggedInKey = 'is_logged_in';
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String userRoleKey = 'user_role';
  static const String rememberMeKey = 'remember_me';

  // User Roles
  static const String roleExecutive = 'executive';
  static const String roleAdmin = 'admin';
  static const String roleSuperAdmin = 'superadmin';

  // Meeting Status
  static const String meetingStatusActive = 'active';
  static const String meetingStatusCompleted = 'completed';
  static const String meetingStatusCancelled = 'cancelled';

  // Registration Status
  static const String registrationPending = 'pending';
  static const String registrationApproved = 'approved';
  static const String registrationRejected = 'rejected';

  // Punch Status
  static const String punchIn = 'punch_in';
  static const String punchOut = 'punch_out';

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // UI Constants
  static const double defaultPadding = 10.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 56.0;
  static const double inputHeight = 56.0;

  // Image Assets (placeholders for now)
  static const String logoPath = 'assets/images/logo.png';
  static const String splashLogoPath = 'assets/images/splash_logo.png';
  static const String backgroundImagePath = 'assets/images/background.jpg';

  // Lottie Animations
  static const String splashAnimationPath = 'assets/animations/splash.json';
  static const String loadingAnimationPath = 'assets/animations/loading.json';
  static const String successAnimationPath = 'assets/animations/success.json';
  static const String errorAnimationPath = 'assets/animations/error.json';
}

/// Error Messages
class ErrorMessages {
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String timeoutError = 'Request timeout. Please try again.';
  static const String invalidCredentials = 'Invalid username or password.';
  static const String userNotFound = 'User not found.';
  static const String registrationFailed = 'Registration failed. Please try again.';
  static const String unauthorizedAccess = 'Unauthorized access.';
  static const String sessionExpired = 'Session expired. Please login again.';
}

/// Success Messages
class SuccessMessages {
  static const String loginSuccess = 'Login successful!';
  static const String registrationSuccess = 'Registration successful!';
  static const String registrationSubmitted = 'Registration request submitted for approval.';
  static const String punchInSuccess = 'Punched in successfully!';
  static const String punchOutSuccess = 'Punched out successfully!';
  static const String meetingStarted = 'Meeting started successfully!';
  static const String meetingEnded = 'Meeting ended successfully!';
  static const String approvalSuccess = 'Registration approved successfully!';
  static const String rejectionSuccess = 'Registration rejected successfully!';
}

