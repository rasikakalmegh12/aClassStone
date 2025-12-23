import 'package:bloc/bloc.dart';
import 'package:apclassstone/data/repositories/punch_repository.dart';

import 'package:apclassstone/bloc/attendance/attendance_event.dart';
import 'package:apclassstone/bloc/attendance/attendance_state.dart';

import '../../api/integration/api_integration.dart';

class PunchInBloc extends Bloc<PunchInEvent, PunchInState> {
  PunchInBloc() : super(PunchInInitial()) {
    // Handle user registration
    on<FetchPunchIn>((event, emit) async {
      emit(PunchInLoading());

      try {


        // Call API
        final response = await ApiIntegration.punchIn(event.body);

        // Check if registration was successful
        if (response.status == true) {
          emit(PunchInLoaded(response: response));
        } else {
          emit(PunchInError(
            message: response.message ?? 'Approval failed',
          ));
        }
      } catch (e) {
        emit(PunchInError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });

  }
}


class PunchOutBloc extends Bloc<PunchOutEvent, PunchOutState> {
  PunchOutBloc() : super(PunchOutInitial()) {
    // Handle user registration
    on<FetchPunchOut>((event, emit) async {
      emit(PunchOutLoading());

      try {


        // Call API
        final response = await ApiIntegration.punchOut(event.body);

        // Check if registration was successful
        if (response.status == true) {
          emit(PunchOutLoaded(response: response));
        } else {
          emit(PunchOutError(
            message: response.message ?? 'Approval failed',
          ));
        }
      } catch (e) {
        emit(PunchOutError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });

  }
}


class LocationPingBloc extends Bloc<LocationPingEvent, LocationPingState> {
  LocationPingBloc() : super(LocationPingInitial()) {
    // Handle user registration
    on<FetchLocationPing>((event, emit) async {
      emit(LocationPingLoading());

      try {


        // Call API
        final response = await ApiIntegration.locationPing(event.body);

        // Check if registration was successful
        if (response.status == true) {
          emit(LocationPingLoaded(response: response));
        } else {
          emit(LocationPingError(
            message: response.message ?? 'Approval failed',
          ));
        }
      } catch (e) {
        emit(LocationPingError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });

  }
}