import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api/integration/api_integration.dart';

import '../../api/models/request/RegistrationRequestBody.dart';
import '../../api/models/response/RegistrationResponseBody.dart';

// ==================== REGISTRATION EVENTS ====================
abstract class RegistrationEvent {}

class RegisterUserEvent extends RegistrationEvent {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String appCode;

  RegisterUserEvent({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.appCode,
  });
}

// ==================== REGISTRATION STATES ====================
abstract class RegistrationState {}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoading extends RegistrationState {}

class RegistrationSuccess extends RegistrationState {
  final RegistrationResponseBody response;

  RegistrationSuccess(this.response);
}

class RegistrationError extends RegistrationState {
  final String message;

  RegistrationError(this.message);
}

// ==================== REGISTRATION BLOC ====================
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc() : super(RegistrationInitial()) {
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

        if (response.status == true) {
          emit(RegistrationSuccess(response));
        } else {
          emit(RegistrationError(
            response.message ?? 'Registration failed',
          ));
        }
      } catch (e) {
        emit(RegistrationError('Error: ${e.toString()}'));
      }
    });
  }
}


