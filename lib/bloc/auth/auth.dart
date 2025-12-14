// import 'package:apclassstone/api/models/request/RegistrationRequestBody.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../api/integration/api_integration.dart';
// import '../../api/models/api_models.dart';
// import '../../core/session/session_manager.dart';
//
// // ==================== AUTH EVENTS ====================
// abstract class AuthEvent {}
//
// class LoginEvent extends AuthEvent {
//   final String username;
//   final String password;
//
//   LoginEvent({required this.username, required this.password});
// }
//
// class RegisterEvent extends AuthEvent {
//   final RegistrationRequestBody request;
//
//
//   RegisterEvent({
//     required this.request,
//
//   });
// }
//
// class LogoutEvent extends AuthEvent {}
//
// class LoadUserProfileEvent extends AuthEvent {}
//
// class CheckAuthStatusEvent extends AuthEvent {}
//
// class ResetAuthEvent extends AuthEvent {}
//
// // ==================== AUTH STATES ====================
// abstract class AuthState {}
//
// class AuthInitial extends AuthState {}
//
// class AuthLoading extends AuthState {}
//
// class AuthAuthenticated extends AuthState {
//   final String message;
//   final User? user;
//   final String? token;
//
//   AuthAuthenticated({
//     this.message = 'Login successful',
//     this.user,
//     this.token,
//   });
// }
//
// class AuthUnauthenticated extends AuthState {
//   final String message;
//
//   AuthUnauthenticated({this.message = 'Please login to continue'});
// }
//
// class AuthError extends AuthState {
//   final String message;
//
//   AuthError(this.message);
// }
//
// class RegisterLoading extends AuthState {}
//
// class RegisterSuccess extends AuthState {
//   final String message;
//
//
//   RegisterSuccess({
//     required this.message,
//
//   });
// }
//
// class UserProfileLoaded extends AuthState {
//   final User user;
//
//   UserProfileLoaded({required this.user});
// }
//
// class LogoutLoading extends AuthState {}
//
// class LogoutSuccess extends AuthState {
//   final String message;
//
//   LogoutSuccess({this.message = 'Logout successful'});
// }
//
// // ==================== AUTH BLOC ====================
// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   AuthBloc() : super(AuthInitial()) {
//     on<LoginEvent>((event, emit) async {
//       emit(AuthLoading());
//       try {
//         final response = await ApiIntegration.login(event.username, event.password);
//
//         if (response.success && response.user != null) {
//           await SessionManager.saveUserSession(
//             headerKey: response.token ?? '',
//             userId: response.user!.id,
//             userName: '${response.user!.firstName} ${response.user!.lastName}',
//             userEmail: response.user!.email,
//           );
//
//           emit(AuthAuthenticated(
//             message: response.message,
//             user: response.user,
//             token: response.token,
//           ));
//         } else {
//           emit(AuthError(response.message));
//         }
//       } catch (e) {
//         emit(AuthError('Login failed: ${e.toString()}'));
//       }
//     });
//
//     on<RegisterEvent>((event, emit) async {
//       emit(RegisterLoading());
//       try {
//         final response = await ApiIntegration.register(
//          event.request
//         );
//
//         if (response.statusCode==200) {
//           emit(RegisterSuccess(
//             message: response.message!,
//
//           ));
//         } else {
//           emit(AuthError(response.message!));
//         }
//       } catch (e) {
//         emit(AuthError('Registration failed: ${e.toString()}'));
//       }
//     });
//
//     on<LoadUserProfileEvent>((event, emit) async {
//       emit(AuthLoading());
//       try {
//         final response = await ApiIntegration.getUserProfile();
//
//         if (response.success && response.user != null) {
//           emit(UserProfileLoaded(user: response.user!));
//         } else {
//           emit(AuthError(response.message));
//         }
//       } catch (e) {
//         emit(AuthError('Failed to load profile: ${e.toString()}'));
//       }
//     });
//
//     on<LogoutEvent>((event, emit) async {
//       emit(LogoutLoading());
//       try {
//         final response = await ApiIntegration.logout();
//
//         if (response.success) {
//           await SessionManager.clearSession();
//           emit(LogoutSuccess(message: response.message));
//         } else {
//           emit(AuthError(response.message));
//         }
//       } catch (e) {
//         await SessionManager.clearSession();
//         emit(LogoutSuccess(message: 'Logged out locally'));
//       }
//     });
//
//     on<CheckAuthStatusEvent>((event, emit) async {
//       emit(AuthLoading());
//       try {
//         final isLoggedIn = await SessionManager.isLoggedIn();
//         if (isLoggedIn) {
//           final userEmail = await SessionManager.getUserEmail();
//           final userName = await SessionManager.getUserName();
//           final userId = await SessionManager.getUserId();
//
//           if (userEmail != null && userName != null && userId != null) {
//             final user = User(
//               id: userId,
//               username: userEmail,
//               email: userEmail,
//               firstName: userName.split(' ').first,
//               lastName: userName.split(' ').length > 1 ? userName.split(' ').last : '',
//               role: userEmail.contains('super') ? 'super_admin' :
//                     userEmail.contains('admin') ? 'admin' : 'executive',
//               status: 'active',
//               createdAt: DateTime.now(),
//             );
//
//             emit(AuthAuthenticated(
//               message: 'Already logged in',
//               user: user,
//               token: await SessionManager.getLoginHeaderkey(),
//             ));
//           } else {
//             emit(AuthUnauthenticated());
//           }
//         } else {
//           emit(AuthUnauthenticated());
//         }
//       } catch (e) {
//         emit(AuthError('Failed to check authentication status: ${e.toString()}'));
//       }
//     });
//
//     on<ResetAuthEvent>((event, emit) {
//       emit(AuthInitial());
//     });
//   }
// }
//
