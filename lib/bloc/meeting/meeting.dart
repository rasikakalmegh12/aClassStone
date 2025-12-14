// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../api/integration/api_integration.dart';
// import '../../api/models/api_models.dart';
//
// // ==================== MEETING EVENTS ====================
// abstract class MeetingEvent {}
//
// class StartMeetingEvent extends MeetingEvent {
//   final String title;
//   final String? description;
//   final List<String>? attendees;
//   final double? latitude;
//   final double? longitude;
//   final String? location;
//
//   StartMeetingEvent({
//     required this.title,
//     this.description,
//     this.attendees,
//     this.latitude,
//     this.longitude,
//     this.location,
//   });
// }
//
// class EndMeetingEvent extends MeetingEvent {
//   final String meetingId;
//
//   EndMeetingEvent({required this.meetingId});
// }
//
// class LoadMeetingsEvent extends MeetingEvent {}
//
// class LoadMeetingDetailEvent extends MeetingEvent {
//   final String meetingId;
//
//   LoadMeetingDetailEvent({required this.meetingId});
// }
//
// class RefreshMeetingsEvent extends MeetingEvent {}
//
// // ==================== MEETING STATES ====================
// abstract class MeetingState {}
//
// class MeetingInitial extends MeetingState {}
//
// class MeetingLoading extends MeetingState {}
//
// class MeetingStarted extends MeetingState {
//   final String message;
//   final Meeting meeting;
//
//   MeetingStarted({
//     required this.message,
//     required this.meeting,
//   });
// }
//
// class MeetingEnded extends MeetingState {
//   final String message;
//   final Meeting meeting;
//
//   MeetingEnded({
//     required this.message,
//     required this.meeting,
//   });
// }
//
// class MeetingsLoaded extends MeetingState {
//   final List<Meeting> meetings;
//
//   MeetingsLoaded({required this.meetings});
// }
//
// class MeetingDetailLoaded extends MeetingState {
//   final Meeting meeting;
//
//   MeetingDetailLoaded({required this.meeting});
// }
//
// class MeetingError extends MeetingState {
//   final String error;
//
//   MeetingError(this.error);
// }
//
// // ==================== MEETING BLOC ====================
// class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
//   MeetingBloc() : super(MeetingInitial()) {
//     on<StartMeetingEvent>((event, emit) async {
//       emit(MeetingLoading());
//       try {
//         final response = await ApiIntegration.startMeeting(
//           title: event.title,
//           description: event.description,
//           attendees: event.attendees,
//           latitude: event.latitude,
//           longitude: event.longitude,
//           location: event.location,
//         );
//
//         if (response.success && response.meeting != null) {
//           emit(MeetingStarted(
//             message: response.message,
//             meeting: response.meeting!,
//           ));
//         } else {
//           emit(MeetingError(response.message));
//         }
//       } catch (e) {
//         emit(MeetingError('Failed to start meeting: ${e.toString()}'));
//       }
//     });
//
//     on<EndMeetingEvent>((event, emit) async {
//       emit(MeetingLoading());
//       try {
//         final response = await ApiIntegration.endMeeting(event.meetingId);
//
//         if (response.success && response.meeting != null) {
//           emit(MeetingEnded(
//             message: response.message,
//             meeting: response.meeting!,
//           ));
//         } else {
//           emit(MeetingError(response.message));
//         }
//       } catch (e) {
//         emit(MeetingError('Failed to end meeting: ${e.toString()}'));
//       }
//     });
//
//     on<LoadMeetingsEvent>((event, emit) async {
//       emit(MeetingLoading());
//       try {
//         final response = await ApiIntegration.getMeetings();
//
//         if (response.success) {
//           emit(MeetingsLoaded(meetings: response.meetings ?? []));
//         } else {
//           emit(MeetingError(response.message));
//         }
//       } catch (e) {
//         emit(MeetingError('Failed to load meetings: ${e.toString()}'));
//       }
//     });
//
//     on<LoadMeetingDetailEvent>((event, emit) async {
//       emit(MeetingLoading());
//       try {
//         final response = await ApiIntegration.getMeetingDetail(event.meetingId);
//
//         if (response.success && response.meeting != null) {
//           emit(MeetingDetailLoaded(meeting: response.meeting!));
//         } else {
//           emit(MeetingError(response.message));
//         }
//       } catch (e) {
//         emit(MeetingError('Failed to load meeting detail: ${e.toString()}'));
//       }
//     });
//
//     on<RefreshMeetingsEvent>((event, emit) {
//       add(LoadMeetingsEvent());
//     });
//   }
// }
//
