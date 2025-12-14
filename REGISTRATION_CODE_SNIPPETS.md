# 📋 READY-TO-COPY CODE SNIPPETS

## 1. ADD TO main.dart

```dart
import 'package:flutter/material.dart';
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
        title: 'App Name',
        home: const RegistrationScreen(),  // Your registration screen
      ),
    );
  }
}
```

---

## 2. IN YOUR REGISTRATION SCREEN

### Import
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/registration/registration.dart';
```

### Dispatch Event (in button press handler)
```dart
void _handleRegistration() {
  if (_formKey.currentState!.validate()) {
    context.read<RegistrationBloc>().add(
      RegisterUserEvent(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        appCode: 'YOUR_APP_CODE',  // Get from config
      ),
    );
  }
}
```

### Listen to Success/Error
```dart
@override
Widget build(BuildContext context) {
  return BlocListener<RegistrationBloc, RegistrationState>(
    listener: (context, state) {
      if (state is RegistrationSuccess) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.response.message ?? 'Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to next screen
        // context.go('/login');
      } else if (state is RegistrationError) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
    child: _buildForm(),
  );
}
```

### Form Fields with Validation
```dart
Column(
  children: [
    // Full Name
    TextFormField(
      controller: _fullNameController,
      decoration: InputDecoration(
        labelText: 'Full Name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Full name is required';
        }
        return null;
      },
    ),
    const SizedBox(height: 16),

    // Email
    TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        if (!value.contains('@')) {
          return 'Enter a valid email';
        }
        return null;
      },
    ),
    const SizedBox(height: 16),

    // Phone
    TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Phone',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Phone is required';
        }
        if (value.length < 10) {
          return 'Enter a valid phone number';
        }
        return null;
      },
    ),
    const SizedBox(height: 16),

    // Password
    TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    ),
  ],
)
```

### Register Button with Loading
```dart
BlocBuilder<RegistrationBloc, RegistrationState>(
  builder: (context, state) {
    final isLoading = state is RegistrationLoading;

    return ElevatedButton(
      onPressed: isLoading ? null : _handleRegistration,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.blue,
        disabledBackgroundColor: Colors.grey,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            )
          : const Text(
              'Register',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  },
);
```

---

## 3. DISPOSE CONTROLLERS
```dart
@override
void dispose() {
  _fullNameController.dispose();
  _emailController.dispose();
  _phoneController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```

---

## 4. COMPLETE SCREEN EXAMPLE

See: `lib/presentation/screens/auth/registration_screen_example.dart`

---

## 5. TESTING SNIPPETS

### Test with Valid Data
```
Full Name: John Doe
Email: john@example.com
Phone: 1234567890
Password: password123
```

### Log State Changes
```dart
BlocListener<RegistrationBloc, RegistrationState>(
  listener: (context, state) {
    print('State changed to: ${state.runtimeType}');
    if (state is RegistrationSuccess) {
      print('Success: ${state.response.message}');
      print('Data: ${state.response.data?.toJson()}');
    } else if (state is RegistrationError) {
      print('Error: ${state.message}');
    }
  },
)
```

### Log API Request
In `registration_api.dart`, add after creating request:
```dart
print('Sending request to: $url');
print('Request body: ${requestBody.toJson()}');
```

### Log API Response
In `registration_api.dart`, add after receiving response:
```dart
print('Response status: ${response.statusCode}');
print('Response body: ${response.body}');
```

---

## 6. ERROR HANDLING

### Network Error
Automatically handled. Shows: "Error: SocketException: Connection refused"

### Timeout Error
Automatically handled. Shows: "Error: TimeoutException after 30 seconds"

### Invalid JSON
Automatically handled. Shows: "Error: FormatException: Invalid JSON"

### API Error
Automatically handled. Shows: "Registration failed. Status: 400" (or whatever status)

---

## 7. CONFIGURATION UPDATES

### Update API Endpoint
In `lib/api/constants/api_constants.dart`:
```dart
static const String baseUrl = "http://your-api.com/api/v1/";
```

### Update App Code
When dispatching RegisterUserEvent:
```dart
appCode: 'YOUR_ACTUAL_APP_CODE',  // Replace with real value
```

---

## 8. USEFUL DEBUGGING CODE

### Print current state in BlocBuilder
```dart
BlocBuilder<RegistrationBloc, RegistrationState>(
  builder: (context, state) {
    debugPrint('Current state: ${state.runtimeType}');
    // ... rest of builder
  },
);
```

### Print state transitions
```dart
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc() : super(RegistrationInitial()) {
    // ... existing code ...
    
    // Add this to track transitions
    on<RegisterUserEvent>((event, emit) async {
      debugPrint('=== Registration Started ===');
      debugPrint('Full Name: ${event.fullName}');
      debugPrint('Email: ${event.email}');
      debugPrint('Phone: ${event.phone}');
      
      emit(RegistrationLoading());
      debugPrint('Emitted: RegistrationLoading');
      
      // ... rest of handler ...
    });
  }
}
```

### Check response format
```dart
if (state is RegistrationSuccess) {
  print('Status: ${state.response.status}');
  print('Message: ${state.response.message}');
  print('StatusCode: ${state.response.statusCode}');
  print('Data ID: ${state.response.data?.id}');
  print('Data Email: ${state.response.data?.email}');
  print('Data Phone: ${state.response.data?.phone}');
}
```

---

## QUICK COPY-PASTE CHECKLIST

- [ ] Copy main.dart BlocProvider code
- [ ] Copy imports for your screen
- [ ] Copy _handleRegistration() method
- [ ] Copy BlocListener code
- [ ] Copy form fields code
- [ ] Copy register button code
- [ ] Copy dispose() method
- [ ] Update appCode value
- [ ] Test with backend

---

Created: December 14, 2025
Ready to copy & use!

