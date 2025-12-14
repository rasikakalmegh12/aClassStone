// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'meeting_event.dart';
// import 'meeting_state.dart';
// import '../../api/integration/api_integration.dart';
//
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
