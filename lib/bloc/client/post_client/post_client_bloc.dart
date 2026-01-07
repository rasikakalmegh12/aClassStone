

import 'package:apclassstone/bloc/client/post_client/post_client_event.dart';
import 'package:apclassstone/bloc/client/post_client/post_client_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../api/integration/api_integration.dart';

class PostClientAddBloc extends Bloc<PostClientAddEvent, PostClientAddState> {
  PostClientAddBloc() : super(PostClientAddInitial()) {
    on<FetchPostClientAdd>((event, emit) async {
      emit(PostClientAddLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.postClientAdd(requestBody: event.requestBody);

        if (response.status == true) {
          emit(PostClientAddLoaded(response: response));
        } else {
          emit(PostClientAddLoaded(response: response));
        }
      } catch (e) {
        emit(PostClientAddError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}


class PostClientAddLocationBloc extends Bloc<PostClientAddLocationEvent, PostClientAddLocationState> {
  PostClientAddLocationBloc() : super(PostClientAddLocationInitial()) {
    on<FetchPostClientAddLocation>((event, emit) async {
      emit(PostClientAddLocationLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.postClientAddLocation(requestBody: event.requestBody,clientId: event.clientId);

        if (response.status == true) {
          emit(PostClientAddLocationLoaded(response: response));
        } else {
          emit(PostClientAddLocationLoaded(response: response));
        }
      } catch (e) {
        emit(PostClientAddLocationError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}


class PostClientAddContactBloc extends Bloc<PostClientAddContactEvent, PostClientAddContactState> {
  PostClientAddContactBloc() : super(PostClientAddContactInitial()) {
    on<FetchPostClientAddContact>((event, emit) async {
      emit(PostClientAddContactLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.postClientAddContact(requestBody: event.requestBody, clientId: event.clientId, locationId: event.locationId);

        if (response.status == true) {
          emit(PostClientAddContactLoaded(response: response));
        } else {
          emit(PostClientAddContactLoaded(response: response));
        }
      } catch (e) {
        emit(PostClientAddContactError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}

