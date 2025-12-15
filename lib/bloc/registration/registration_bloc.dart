import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api/integration/api_integration.dart';
import 'registration_event.dart';
import 'registration_state.dart';
import '../../api/models/request/RegistrationRequestBody.dart';


class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc() : super(RegistrationInitial()) {
    // Handle user registration
    on<RegisterUserEvent>((event, emit) async {
      emit(RegistrationLoading());

      try {
        // Create request body
        final requestBody = RegistrationRequestBody(
          fullName: event.fullName,
          email: event.email,
          phone: event.phone,
          password: event.password,
          appCode: event.appCode,
        );

        // Call API
        final response = await ApiIntegration.register(requestBody);

        // Check if registration was successful
        if (response.status == true) {
          emit(RegistrationSuccess(response: response));
        } else {
          emit(RegistrationError(
            message: response.message ?? 'Registration failed',
          ));
        }
      } catch (e) {
        emit(RegistrationError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });

    // Handle reset event
    on<ResetRegistrationEvent>((event, emit) {
      emit(RegistrationInitial());
    });
  }
}



class PendingBloc extends Bloc<PendingEvent, PendingState> {
  PendingBloc() : super(PendingInitial()) {
    // Handle user registration
    on<GetPendingEvent>((event, emit) async {
      emit(PendingLoading());

      try {


        // Call API
        final response = await ApiIntegration.getPendingUsers();

        // Check if registration was successful
        if (response.status == true) {
          emit(PendingLoaded(response: response));
        } else {
          emit(PendingError(
            message: response.message ?? 'Registration failed',
          ));
        }
      } catch (e) {
        emit(PendingError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });

  }
}


