import 'package:bloc/bloc.dart';
import 'package:apclassstone/bloc/location_ping/location_ping_event.dart';
import 'package:apclassstone/bloc/location_ping/location_ping_state.dart';
import 'package:apclassstone/data/repositories/punch_repository.dart';

class LocationPingBloc extends Bloc<LocationPingEvent, LocationPingState> {
  final PunchRepository _repo;

  LocationPingBloc({required PunchRepository repo}) : _repo = repo, super(LocationPingInitial()) {
    on<PingLocation>(_onPingLocation);
  }

  Future<void> _onPingLocation(PingLocation event, Emitter<LocationPingState> emit) async {
    emit(LocationPingInProgress());
    try {
      final rec = await _repo.saveLocationPing(event.userId, event.body);
      emit(LocationPingSuccess(rec));
    } catch (e) {
      emit(LocationPingFailure(e.toString()));
    }
  }
}

