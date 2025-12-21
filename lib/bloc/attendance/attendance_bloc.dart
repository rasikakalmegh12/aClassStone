import 'package:bloc/bloc.dart';
import 'package:apclassstone/data/repositories/punch_repository.dart';

import 'package:apclassstone/bloc/attendance/attendance_event.dart';
import 'package:apclassstone/bloc/attendance/attendance_state.dart';

import '../../api/integration/api_integration.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final PunchRepository _repo;

  AttendanceBloc({required PunchRepository repo})
      : _repo = repo,
        super(AttendanceInitial()) {
    on<PunchInRequested>(_onPunchIn);
    on<PunchOutRequested>(_onPunchOut);
    on<LoadLocalPunches>(_onLoadLocal);
  }

  Future<void> _onPunchIn(PunchInRequested event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final userId = event.userId;
      final record = await _repo.punchIn(userId, event.body);
      if (record.status == 'success') {
        emit(PunchSuccess(record));
      } else if (record.status == 'failed') {
        emit(PunchFailure(record.errorMessage ?? 'Failed'));
      } else {
        emit(PunchQueued(record));
      }
    } catch (e) {
      emit(PunchFailure(e.toString()));
    }
  }

  Future<void> _onPunchOut(PunchOutRequested event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final userId = event.userId;
      final record = await _repo.punchOut(userId, event.body);
      if (record.status == 'success') {
        emit(PunchSuccess(record));
      } else if (record.status == 'failed') {
        emit(PunchFailure(record.errorMessage ?? 'Failed'));
      } else {
        emit(PunchQueued(record));
      }
    } catch (e) {
      emit(PunchFailure(e.toString()));
    }
  }

  Future<void> _onLoadLocal(LoadLocalPunches event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final list = await _repo.getLocalPunches(userId: event.userId);
      emit(LocalPunchesLoaded(list));
    } catch (e) {
      emit(PunchFailure(e.toString()));
    }
  }
}
