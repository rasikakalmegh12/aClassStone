# 📝 Registration Implementation Guide

## ✅ What's Been Created

### 1. **API Integration** (`lib/api/integration/registration_api.dart`)
- Simple HTTP-based API integration (no retrofit, no code generation)
- Single method: `ApiIntegration.register()`
- Real API calls to your backend
- Proper error handling and timeouts

### 2. **Registration BLoC** (`lib/bloc/registration/registration.dart`)
- **All in ONE file**: Events + States + BLoC
- **RegistrationEvent**: `RegisterUserEvent` - fired when user submits form
- **RegistrationStates**: 
  - `RegistrationInitial` - Initial state
  - `RegistrationLoading` - When API call is in progress
  - `RegistrationSuccess` - When registration succeeds (returns full response)
  - `RegistrationError` - When registration fails

### 3. **Example Registration Screen** (`lib/presentation/screens/auth/registration_screen_example.dart`)
- Complete working example
- Form validation
- BLoC integration
- Success/error handling
- Loading state UI

---

## 🚀 How to Use

### Step 1: Add BLoC Provider in main.dart

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
        home: const YourRegistrationScreen(),
      ),
    );
  }
}
```

### Step 2: Use in Your Screen

```dart
// Import
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/registration/registration.dart';

// In your button/submit handler
void _handleRegistration() {
  context.read<RegistrationBloc>().add(
    RegisterUserEvent(
      fullName: 'John Doe',
      email: 'john@example.com',
      phone: '1234567890',
      password: 'password123',
      appCode: 'YOUR_APP_CODE',
    ),
  );
}

// Listen to states
BlocListener<RegistrationBloc, RegistrationState>(
  listener: (context, state) {
    if (state is RegistrationSuccess) {
      // Show success message
      // Navigate to next screen
    } else if (state is RegistrationError) {
      // Show error message
    }
  },
  child: YourWidget(),
);

// Show loading indicator
BlocBuilder<RegistrationBloc, RegistrationState>(
  builder: (context, state) {
    if (state is RegistrationLoading) {
      return const CircularProgressIndicator();
    }
    return const Text('Register');
  },
);
```

---

## 📊 API Request/Response

### Request Body
```dart
RegistrationRequestBody(
  fullName: 'John Doe',
  email: 'john@example.com',
  phone: '1234567890',
  password: 'password123',
  appCode: 'YOUR_APP_CODE',
)
```

### Response Body
```dart
RegistrationResponseBody(
  status: true,
  message: 'Registration successful',
  statusCode: 200,
  data: Data(
    id: 'user_123',
    email: 'john@example.com',
    phone: '1234567890',
  ),
)
```

---

## 🔧 Configuration

### Update API Base URL
In `lib/api/constants/api_constants.dart`:
```dart
static const String baseUrl = "http://your-backend.com/api/v1/";
```

### Update App Code
In your registration form, replace `'YOUR_APP_CODE'` with:
```dart
appCode: 'your_actual_app_code',
```

---

## 📱 Integration Steps

1. **Copy the files** to your project:
   - `lib/api/integration/registration_api.dart`
   - `lib/bloc/registration/registration.dart`
   - Update/use `lib/presentation/screens/auth/registration_screen_example.dart` as reference

2. **Add BLoC provider** in your main.dart

3. **Use in your registration screen**:
   - Copy code from `registration_screen_example.dart`
   - Adapt to your UI design

4. **Test**:
   - Run the app
   - Try registration with valid data
   - Check your backend logs

---

## ✨ Key Features

✅ **No Dummy Data** - Real API calls only
✅ **Simple Structure** - No unnecessary files
✅ **One File BLoCs** - All events, states, and logic together
✅ **Clean API Integration** - Using http package, no retrofit
✅ **Proper Error Handling** - Network errors and response errors
✅ **Form Validation** - Built-in validation in example
✅ **Loading State** - Shows loading while registering
✅ **Type Safe** - Uses proper request/response models

---

## 🐛 Troubleshooting

### "ApiIntegration not found"
- Import: `import '../../api/integration/registration_api.dart';`

### "RegistrationBloc not found"
- Import: `import '../../bloc/registration/registration.dart';`

### API returns 404
- Check `ApiConstants.register` endpoint
- Verify backend is running

### "Connection timeout"
- Check your `baseUrl` in `ApiConstants`
- Check network connectivity

### "Invalid response format"
- Verify backend returns correct JSON structure
- Check `RegistrationResponseBody` model matches your API

---

## 📋 File Structure

```
lib/
├── api/
│   ├── constants/
│   │   └── api_constants.dart        (has endpoints)
│   ├── integration/
│   │   └── registration_api.dart     ✨ NEW (real API calls)
│   ├── models/
│   │   ├── request/
│   │   │   └── RegistrationRequestBody.dart
│   │   └── response/
│   │       └── RegistrationResponseBody.dart
│   └── network/
│       └── (not needed anymore)
│
├── bloc/
│   └── registration/
│       └── registration.dart         ✨ NEW (events + states + bloc)
│
└── presentation/
    └── screens/
        └── auth/
            ├── registration_screen_example.dart  ✨ NEW (example)
            └── your_registration_screen.dart     (your actual screen)
```

---

## 🎯 What NOT to do

❌ Don't use api_client.dart or api_client.g.dart for registration
❌ Don't create separate files for events, states, bloc
❌ Don't add dummy data
❌ Don't create repositories layer
❌ Don't use retrofit/retrofit annotations

---

## ✅ Next Steps

1. Update API base URL in `ApiConstants`
2. Create your registration form screen
3. Use `registration_screen_example.dart` as reference
4. Test with your backend
5. When dashboard is needed, follow same pattern in separate folder

---

Created: December 14, 2025
Status: Ready to Use ✅

