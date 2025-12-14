// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../api/integration/api_integration.dart';
// import '../../api/models/api_models.dart';
//
// // ==================== USER PROFILE EVENTS ====================
// abstract class UserProfileEvent {}
//
// class FetchUserProfileEvent extends UserProfileEvent {}
//
// class UpdateUserProfileEvent extends UserProfileEvent {
//   final String firstName;
//   final String lastName;
//   final String email;
//
//   UpdateUserProfileEvent({
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//   });
// }
//
// class ChangePasswordEvent extends UserProfileEvent {
//   final String currentPassword;
//   final String newPassword;
//
//   ChangePasswordEvent({
//     required this.currentPassword,
//     required this.newPassword,
//   });
// }
//
// // ==================== USER PROFILE STATES ====================
// abstract class UserProfileState {}
//
// class UserProfileInitState extends UserProfileState {}
//
// class UserProfileLoadingState extends UserProfileState {}
//
// class UserProfileLoadedState extends UserProfileState {
//   final User user;
//
//   UserProfileLoadedState({required this.user});
// }
//
// class UserProfileUpdateState extends UserProfileState {
//   final String message;
//   final User user;
//
//   UserProfileUpdateState({
//     required this.message,
//     required this.user,
//   });
// }
//
// class PasswordChangedState extends UserProfileState {
//   final String message;
//
//   PasswordChangedState({required this.message});
// }
//
// class UserProfileErrorState extends UserProfileState {
//   final String error;
//
//   UserProfileErrorState(this.error);
// }
//
// // ==================== USER PROFILE BLOC ====================
// class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
//   UserProfileBloc() : super(UserProfileInitState()) {
//     on<FetchUserProfileEvent>((event, emit) async {
//       emit(UserProfileLoadingState());
//       try {
//         final response = await ApiIntegration.getUserProfile();
//
//         if (response.success && response.user != null) {
//           emit(UserProfileLoadedState(user: response.user!));
//         } else {
//           emit(UserProfileErrorState(response.message));
//         }
//       } catch (e) {
//         emit(UserProfileErrorState('Failed to load profile: ${e.toString()}'));
//       }
//     });
//
//     on<UpdateUserProfileEvent>((event, emit) async {
//       emit(UserProfileLoadingState());
//       try {
//         // For now, just return success
//         // In a real app, you'd call ApiIntegration.updateUserProfile()
//         await Future.delayed(const Duration(seconds: 1));
//
//         final user = User(
//           id: 'user_1',
//           username: event.email,
//           email: event.email,
//           firstName: event.firstName,
//           lastName: event.lastName,
//           role: 'executive',
//           status: 'active',
//           createdAt: DateTime.now(),
//         );
//
//         emit(UserProfileUpdateState(
//           message: 'Profile updated successfully',
//           user: user,
//         ));
//       } catch (e) {
//         emit(UserProfileErrorState('Failed to update profile: ${e.toString()}'));
//       }
//     });
//
//     on<ChangePasswordEvent>((event, emit) async {
//       emit(UserProfileLoadingState());
//       try {
//         // For now, just return success
//         // In a real app, you'd call ApiIntegration.changePassword()
//         await Future.delayed(const Duration(seconds: 1));
//
//         emit(PasswordChangedState(message: 'Password changed successfully'));
//       } catch (e) {
//         emit(UserProfileErrorState('Failed to change password: ${e.toString()}'));
//       }
//     });
//   }
// }
//
