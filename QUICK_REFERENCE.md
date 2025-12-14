# Quick Reference Guide

## 🚀 Quick Start

### In main.dart:
```dart
void main() {
  AppBlocProvider.initialize();
  runApp(const MyApp());
}
```

### Provide BLoCs:
```dart
BlocProvider(
  create: (context) => AppBlocProvider.authBloc
    ..add(CheckAuthStatusEvent()),
),
```

---

## 📂 File Locations

| Feature | BLoC File | Events | States |
|---------|-----------|--------|--------|
| Auth | `bloc/auth/auth.dart` | LoginEvent, RegisterEvent, ... | AuthLoading, AuthAuthenticated, ... |
| Registration | `bloc/registration/registration.dart` | LoadPendingRegistrationsEvent, ... | RegistrationLoading, PendingRegistrationsLoaded, ... |
| Attendance | `bloc/attendance/attendance.dart` | PunchInEvent, PunchOutEvent, ... | AttendanceLoading, PunchInSuccess, ... |
| Meeting | `bloc/meeting/meeting.dart` | StartMeetingEvent, EndMeetingEvent, ... | MeetingLoading, MeetingStarted, ... |
| Dashboard | `bloc/dashboard/dashboard.dart` | LoadExecutiveDashboardEvent, ... | DashboardLoading, ExecutiveDashboardLoaded, ... |
| User Profile | `bloc/user_profile/user_profile.dart` | FetchUserProfileEvent, ... | UserProfileLoadingState, UserProfileLoadedState, ... |

**API Integration:** `api/integration/api_integration.dart`

---

## 💡 Usage Examples

### Example 1: Login

**Dispatch Event:**
```dart
context.read<AuthBloc>().add(
  LoginEvent(
    username: 'super@admin.com',
    password: 'admin@123',
  ),
);
```

**Listen to State:**
```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome ${state.user?.firstName}')),
      );
      context.go('/dashboard');
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: // your widget
);
```

---

### Example 2: Punch In

**Dispatch Event:**
```dart
context.read<AttendanceBloc>().add(
  PunchInEvent(
    location: 'Office',
    latitude: 12.9716,
    longitude: 77.5946,
  ),
);
```

**Listen to State:**
```dart
BlocListener<AttendanceBloc, AttendanceState>(
  listener: (context, state) {
    if (state is PunchInSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Punched in at ${state.timestamp}')),
      );
    }
  },
);
```

---

### Example 3: Start Meeting

**Dispatch Event:**
```dart
context.read<MeetingBloc>().add(
  StartMeetingEvent(
    title: 'Team Standup',
    description: 'Daily standup meeting',
    location: 'Conference Room A',
    attendees: ['user1@company.com', 'user2@company.com'],
  ),
);
```

**Build UI:**
```dart
BlocBuilder<MeetingBloc, MeetingState>(
  builder: (context, state) {
    if (state is MeetingLoading) {
      return const CircularProgressIndicator();
    } else if (state is MeetingStarted) {
      return Text('Meeting started: ${state.meeting.title}');
    } else if (state is MeetingError) {
      return Text('Error: ${state.error}');
    }
    return const SizedBox.shrink();
  },
);
```

---

### Example 4: Load Dashboard

**Dispatch Event:**
```dart
context.read<DashboardBloc>().add(
  LoadExecutiveDashboardEvent(),
);
```

**Build UI:**
```dart
BlocBuilder<DashboardBloc, DashboardState>(
  builder: (context, state) {
    if (state is DashboardLoading) {
      return const LoadingWidget();
    } else if (state is ExecutiveDashboardLoaded) {
      return ExecutiveDashboardScreen(
        stats: state.stats,
        meetings: state.recentMeetings,
        attendance: state.todayAttendance,
      );
    }
    return const SizedBox.shrink();
  },
);
```

---

### Example 5: Approve Registration

**Dispatch Event:**
```dart
context.read<RegistrationBloc>().add(
  ApproveRegistrationEvent(
    registrationId: 'pending_1',
  ),
);
```

**Listen to State:**
```dart
BlocListener<RegistrationBloc, RegistrationState>(
  listener: (context, state) {
    if (state is RegistrationApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
      // Refresh list
      context.read<RegistrationBloc>().add(
        LoadPendingRegistrationsEvent(),
      );
    }
  },
);
```

---

## 🔧 Common Patterns

### Pattern 1: Load Data on Screen Init

```dart
@override
void initState() {
  super.initState();
  context.read<DashboardBloc>().add(
    LoadExecutiveDashboardEvent(),
  );
}
```

### Pattern 2: Refresh Data

```dart
RefreshIndicator(
  onRefresh: () async {
    context.read<AttendanceBloc>().add(
      RefreshAttendanceEvent(),
    );
  },
  child: // your list widget
)
```

### Pattern 3: Show Loading Overlay

```dart
if (state is AttendanceLoading) {
  return Stack(
    children: [
      // your content
      const LoadingOverlay(),
    ],
  );
}
```

### Pattern 4: Error Handling

```dart
if (state is AuthError) {
  return ErrorWidget(
    message: state.message,
    onRetry: () {
      context.read<AuthBloc>().add(
        LoginEvent(username: 'user', password: 'pass'),
      );
    },
  );
}
```

---

## 🎯 API Integration Direct Calls

If you need to call API without going through BLoC:

```dart
// Login
final response = await ApiIntegration.login('user@example.com', 'password');

// Punch In
final response = await ApiIntegration.punchIn(
  latitude: 12.9716,
  longitude: 77.5946,
  location: 'Office',
);

// Start Meeting
final response = await ApiIntegration.startMeeting(
  title: 'Team Meeting',
  attendees: ['user1', 'user2'],
);

// Get Dashboard
final response = await ApiIntegration.getExecutiveDashboard();
```

---

## 🔌 Credentials for Testing

```dart
// Super Admin
username: 'super@admin.com'
password: 'admin@123'

// Admin
username: 'admin@demo.com'
password: 'admin@123'

// Executive
username: 'executive@demo.com'
password: 'admin@123'
```

---

## ✅ Verification Checklist

- [ ] All imports updated to use `bloc/bloc.dart` or specific `bloc/*/feature.dart`
- [ ] No imports from `bloc/*_bloc.dart`, `bloc/*_event.dart`, `bloc/*_state.dart`
- [ ] No imports from `api/repositories/`
- [ ] `AppBlocProvider.initialize()` called in main()
- [ ] All BLoCs provided via `AppBlocProvider.authBloc`, etc.
- [ ] API calls use `ApiIntegration.methodName()`
- [ ] No repository instantiation anywhere
- [ ] All screens import from `bloc/bloc.dart`

---

## 🐛 Troubleshooting

### Issue: "Unknown import path"
**Solution:** Make sure you're importing from `bloc/bloc.dart` or the specific feature file like `bloc/auth/auth.dart`

### Issue: "BLoC not initialized"
**Solution:** Make sure `AppBlocProvider.initialize()` is called in main() before runApp()

### Issue: "Event not defined"
**Solution:** Check that the event is exported from the consolidated BLoC file

### Issue: "State not matching"
**Solution:** Ensure you're checking for the correct state class (especially user_profile states which have unique names)

---

## 📚 Additional Resources

- See `REFACTORING_COMPLETE.md` for detailed changes
- See `REFACTORING_SUMMARY.md` for overview

---

Created: December 2024
Last Updated: December 2024

