// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'user_profile_event.dart';
// import 'user_profile_state.dart';
// import '../../api/repositories/repositories.dart';
//
// class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
//   final AuthRepository authRepository;
//
//   UserProfileBloc(this.authRepository) : super(UserProfileInitial()) {
//     on<LoadUserProfileEvent>((event, emit) async {
//       emit(UserProfileLoading());
//       try {
//         final response = await authRepository.getUserProfile();
//
//         if (response.success && response.user != null) {
//           emit(UserProfileLoaded(user: response.user!));
//         } else {
//           emit(UserProfileError(response.message));
//         }
//       } catch (e) {
//         emit(UserProfileError('Failed to load profile: ${e.toString()}'));
//       }
//     });
//
//     on<UpdateUserProfileEvent>((event, emit) async {
//       emit(UserProfileLoading());
//       try {
//         final response = await authRepository.updateUserProfile(
//           firstName: event.firstName,
//           lastName: event.lastName,
//           email: event.email,
//         );
//
//         if (response.success && response.user != null) {
//           emit(UserProfileUpdated(
//             message: response.message,
//             user: response.user!,
//           ));
//         } else {
//           emit(UserProfileError(response.message));
//         }
//       } catch (e) {
//         emit(UserProfileError('Failed to update profile: ${e.toString()}'));
//       }
//     });
//
//     on<ChangePasswordEvent>((event, emit) async {
//       emit(UserProfileLoading());
//       try {
//         final response = await authRepository.changePassword(
//           currentPassword: event.currentPassword,
//           newPassword: event.newPassword,
//         );
//
//         if (response.success) {
//           emit(PasswordChanged(message: response.message));
//         } else {
//           emit(UserProfileError(response.message));
//         }
//       } catch (e) {
//         emit(UserProfileError('Failed to change password: ${e.toString()}'));
//       }
//     });
//   }
// }
