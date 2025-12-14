// Simple User and response models for the application

/// User model representing a registered user
class User {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  String toString() => 'User(id: $id, email: $email, name: $firstName $lastName)';
}

/// Base response model for API responses
class BaseResponse {
  final bool success;
  final String message;
  final int? statusCode;

  const BaseResponse({
    required this.success,
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'BaseResponse(success: $success, message: $message)';
}

/// Login response containing user and token
class LoginResponse extends BaseResponse {
  final User? user;
  final String? token;

  const LoginResponse({
    required bool success,
    required String message,
    int? statusCode,
    this.user,
    this.token,
  }) : super(success: success, message: message, statusCode: statusCode);

  @override
  String toString() => 'LoginResponse(success: $success, user: $user, token: $token)';
}

/// Dashboard statistics model
class DashboardStats {
  final int totalUsers;
  final int activeUsers;
  final int totalMeetings;
  final int attendanceRate;

  const DashboardStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalMeetings,
    required this.attendanceRate,
  });

  @override
  String toString() => 'DashboardStats(totalUsers: $totalUsers, activeUsers: $activeUsers)';
}

/// Pending registration model (for admin)
class PendingRegistration {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime createdAt;
  final String status;

  const PendingRegistration({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    required this.status,
  });

  @override
  String toString() => 'PendingRegistration(id: $id, email: $email, status: $status)';
}

/// Attendance record model
class AttendanceRecord {
  final String id;
  final String userId;
  final DateTime punchIn;
  final DateTime? punchOut;
  final String? location;

  const AttendanceRecord({
    required this.id,
    required this.userId,
    required this.punchIn,
    this.punchOut,
    this.location,
  });

  @override
  String toString() => 'AttendanceRecord(id: $id, userId: $userId, punchIn: $punchIn)';
}

/// Meeting model
class Meeting {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final String createdBy;
  final List<String>? attendees;
  final String? location;

  const Meeting({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    required this.createdBy,
    this.attendees,
    this.location,
  });

  @override
  String toString() => 'Meeting(id: $id, title: $title, startTime: $startTime)';
}

