import 'package:apclassstone/api/integration/api_integration.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_profile_event.dart';
import 'user_profile_state.dart';


class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {


  UserProfileBloc() : super(UserProfileInitial()) {
    on<LoadUserProfileEvent>((event, emit) async {
      emit(UserProfileLoading());
      try {
        final response = await ApiIntegration.getProfile();

        if (response.status== true) {
          emit(UserProfileLoaded(user: response));
        } else {
          emit(UserProfileError(response.message!));
        }
      } catch (e) {
        emit(UserProfileError('Failed to load profile: ${e.toString()}'));
      }
    });

    on<UpdateUserProfileEvent>((event, emit) async {
      emit(UserProfileLoading());
      try {
        final response = await ApiIntegration.updateProfile(event.requestBody,);

        if (response.status==true ) {
          emit(UserProfileUpdated(

            user: response,
          ));
        } else {
          emit(UserProfileError(response.message!));
        }
      } catch (e) {
        emit(UserProfileError('Failed to update profile: ${e.toString()}'));
      }
    });

    // on<ChangePasswordEvent>((event, emit) async {
    //   emit(UserProfileLoading());
    //   try {
    //     final response = await authRepository.changePassword(
    //       currentPassword: event.currentPassword,
    //       newPassword: event.newPassword,
    //     );
    //
    //     if (response.success) {
    //       emit(PasswordChanged(message: response.message));
    //     } else {
    //       emit(UserProfileError(response.message));
    //     }
    //   } catch (e) {
    //     emit(UserProfileError('Failed to change password: ${e.toString()}'));
    //   }
    // });
  }
}
