import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../api/integration/api_integration.dart';



class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    // Handle user registration
    on<FetchLogin>((event, emit) async {
      emit(LoginLoading());

      try {


        // Call API
        final response = await ApiIntegration.login(event.username, event.password);

        // Check if registration was successful
        if (response.status == true) {
          emit(LoginSuccess(response: response));
        } else {
          emit(LoginError(
            message: response.message ?? 'Login failed',
          ));
        }
      } catch (e) {
        emit(LoginError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });


  }
}