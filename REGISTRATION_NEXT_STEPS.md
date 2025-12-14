# 🎯 NEXT STEPS FOR REGISTRATION

## 1. VERIFY THE FILES ARE CREATED

```bash
# Check if files exist
ls -la lib/api/integration/registration_api.dart
ls -la lib/bloc/registration/registration.dart
ls -la lib/presentation/screens/auth/registration_screen_example.dart
```

All three should exist. ✅

---

## 2. UPDATE YOUR API ENDPOINT

Open: `lib/api/constants/api_constants.dart`

Make sure this is set to your actual API:
```dart
static const String baseUrl = "http://64.227.134.138:5105/api/v1/";
// or whatever your backend URL is
```

---

## 3. ADD BLoC TO YOUR main.dart

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/registration/registration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegistrationBloc(),
      child: MaterialApp(
        home: const YourRegistrationScreen(), // Use your screen
      ),
    );
  }
}
```

---

## 4. UPDATE YOUR REGISTRATION SCREEN

Copy the code from: `lib/presentation/screens/auth/registration_screen_example.dart`

Or use it as reference to update your existing registration screen.

Key imports to add:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/registration/registration.dart';
```

Key code to use:
```dart
// Dispatch event
context.read<RegistrationBloc>().add(
  RegisterUserEvent(
    fullName: _fullNameController.text,
    email: _emailController.text,
    phone: _phoneController.text,
    password: _passwordController.text,
    appCode: 'YOUR_APP_CODE', // Replace with actual app code
  ),
);

// Listen for success/error
BlocListener<RegistrationBloc, RegistrationState>(
  listener: (context, state) {
    if (state is RegistrationSuccess) {
      // Show success message
      print('Registered: ${state.response.message}');
    } else if (state is RegistrationError) {
      // Show error message
      print('Error: ${state.message}');
    }
  },
);

// Show loading
BlocBuilder<RegistrationBloc, RegistrationState>(
  builder: (context, state) {
    if (state is RegistrationLoading) {
      return const CircularProgressIndicator();
    }
    return ElevatedButton(onPressed: _handleRegistration, child: const Text('Register'));
  },
);
```

---

## 5. TEST THE REGISTRATION

Run your app:
```bash
flutter run
```

Try registration with valid data:
- Full Name: John Doe
- Email: john@example.com
- Phone: 1234567890
- Password: password123
- App Code: (your actual app code)

---

## 6. VERIFY BACKEND RESPONSE

Your backend should return:
```json
{
  "status": true,
  "message": "Registration successful",
  "statusCode": 200,
  "data": {
    "id": "user_123",
    "email": "john@example.com",
    "phone": "1234567890"
  }
}
```

If not, update your backend API to match this format, OR update the `RegistrationResponseBody` model to match your backend.

---

## 7. HANDLE ERRORS

The implementation handles:
- ✅ Network timeouts (30 seconds)
- ✅ HTTP errors (4xx, 5xx)
- ✅ JSON parsing errors
- ✅ Null/empty responses
- ✅ Connection failures

All errors show in `RegistrationError` state with message.

---

## 📋 QUICK CHECKLIST

- [ ] Files created (registration_api.dart, registration.dart, example screen)
- [ ] API endpoint updated in ApiConstants
- [ ] BLoC added to main.dart
- [ ] Registration screen updated with BLoC code
- [ ] App Code value set correctly
- [ ] Tested with backend
- [ ] Success message shows
- [ ] Error messages show
- [ ] Loading indicator works

---

## ❓ COMMON ISSUES

### Issue: "No Podspec for flutter_bloc"
**Solution**: Run `flutter pub get`

### Issue: API returns 404
**Solution**: Check endpoint in ApiConstants matches your backend

### Issue: API returns "Invalid JSON"
**Solution**: Check your backend returns valid JSON matching RegistrationResponseBody

### Issue: "Connection refused"
**Solution**: Check baseUrl is correct and backend is running

### Issue: "Timeout after 30 seconds"
**Solution**: Increase timeout in registration_api.dart or check network

---

## 🎯 FUTURE: ADDING OTHER FEATURES

When ready to add Auth, Dashboard, etc., follow same pattern:

1. Create `lib/api/integration/auth_api.dart` (for auth APIs)
2. Create `lib/bloc/auth/auth.dart` (with events, states, bloc)
3. Use in screens with BLoC

DO NOT touch registration implementation - it's complete!

---

## 📞 SUPPORT

For issues, check:
1. REGISTRATION_GUIDE.md - Detailed guide
2. registration_screen_example.dart - Working example
3. registration_api.dart - API implementation
4. registration.dart - BLoC implementation

---

Status: ✅ READY TO IMPLEMENT
Next: Update API endpoint → Add to main.dart → Update screen → Test!

