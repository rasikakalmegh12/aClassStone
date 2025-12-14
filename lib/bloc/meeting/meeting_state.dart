// import '../../api/models/api_models.dart';
//
// // Meeting States
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
