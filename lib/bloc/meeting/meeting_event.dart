// Meeting Events
abstract class MeetingEvent {}

class StartMeetingEvent extends MeetingEvent {
  final String title;
  final String? description;
  final List<String>? attendees;
  final double? latitude;
  final double? longitude;
  final String? location;

  StartMeetingEvent({
    required this.title,
    this.description,
    this.attendees,
    this.latitude,
    this.longitude,
    this.location,
  });
}

class EndMeetingEvent extends MeetingEvent {
  final String meetingId;

  EndMeetingEvent({required this.meetingId});
}

class LoadMeetingsEvent extends MeetingEvent {}

class LoadMeetingDetailEvent extends MeetingEvent {
  final String meetingId;

  LoadMeetingDetailEvent({required this.meetingId});
}

class RefreshMeetingsEvent extends MeetingEvent {}
