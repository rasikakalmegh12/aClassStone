import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apclassstone/api/integration/api_integration.dart';
import 'user_management_event.dart';
import 'user_management_state.dart';

class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  UserManagementBloc() : super(UserManagementInitial()) {
    on<FetchUserProfileDetails>(_onFetchUserProfileDetails);
    on<ChangeUserRole>(_onChangeUserRole);
    on<ChangeUserStatus>(_onChangeUserStatus);
  }

  Future<void> _onFetchUserProfileDetails(
    FetchUserProfileDetails event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(UserProfileDetailsLoading(showLoader: event.showLoader));

    final response = await ApiIntegration.getUserProfileDetails(event.userId);

    if (response.status == true) {
      emit(UserProfileDetailsLoaded(response));
    } else {
      emit(UserProfileDetailsError(response.message ?? 'Failed to load user profile'));
    }
  }

  Future<void> _onChangeUserRole(
    ChangeUserRole event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(ChangeRoleLoading(showLoader: event.showLoader));

    final response = await ApiIntegration.changeUserRole(
      userId: event.userId,
      role: event.role,
    );

    if (response.status == true) {
      emit(ChangeRoleSuccess(response));
    } else {
      emit(ChangeRoleError(response.message ?? 'Failed to change user role'));
    }
  }

  Future<void> _onChangeUserStatus(
    ChangeUserStatus event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(ChangeStatusLoading(showLoader: event.showLoader));

    final response = await ApiIntegration.changeUserStatus(
      userId: event.userId,
      isActive: event.isActive,
    );

    if (response.status == true) {
      emit(ChangeStatusSuccess(response));
    } else {
      emit(ChangeStatusError(response.message ?? 'Failed to change user status'));
    }
  }
}

