import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api/integration/api_integration.dart';
import '../../core/session/session_manager.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {

    on<FetchLogin>((event, emit) async {
      emit(LoginLoading());
      try {
        final response =
        await ApiIntegration.login(event.username, event.password);

        if (response.status == true) {
          emit(LoginSuccess(response: response));
        } else {
          emit(LoginError(message: response.message ?? 'Login failed'));
        }
      } catch (e) {
        emit(LoginError(message: e.toString()));
      }
    });

    /// ✅ ADD THIS
    on<ForceLogoutRequested>((event, emit) async {
      await SessionManager.logout();
      emit(LoginLoggedOut());
    });
  }
}



class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  LogoutBloc() : super(LogoutInitial()) {
    // Handle user registration
    on<FetchLogout>((event, emit) async {
      emit(LogoutLoading());

      try {


        // Call API
        final response = await ApiIntegration.logout(event.refreshToken);

        // Check if registration was successful
        if (response.status == true) {
          emit(LogoutLoaded(response: response));
        } else {
          emit(LogoutError(
            message: response.message ?? 'Failed to load executive executive_history',
          ));
        }
      } catch (e) {
        emit(LogoutError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });

  }
}