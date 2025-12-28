// class ExecutiveTrackingByDaysResponse {
//   bool? status;
//   String? message;
//   int? statusCode;
//   Data? data;
//
//   ExecutiveTrackingByDaysResponse(
//       {this.status, this.message, this.statusCode, this.data});
//
//   ExecutiveTrackingByDaysResponse.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     statusCode = json['statusCode'];
//     data = json['data'] != null ? new Data.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['message'] = this.message;
//     data['statusCode'] = this.statusCode;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }
//
// class Data {
//   String? date;
//   String? dateDisplay;
//   List<Sessions>? sessions;
//   List<LocationStays>? locationStays;
//   PunchedInLocation? lastKnownLocation;
//   double? totalPingCount;
//   String? firstPingAt;
//   String? firstPingAtDisplay;
//   String? lastPingAt;
//   String? lastPingAtDisplay;
//
//   Data(
//       {this.date,
//         this.dateDisplay,
//         this.sessions,
//         this.locationStays,
//         this.lastKnownLocation,
//         this.totalPingCount,
//         this.firstPingAt,
//         this.firstPingAtDisplay,
//         this.lastPingAt,
//         this.lastPingAtDisplay});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     date = json['date'];
//     dateDisplay = json['dateDisplay'];
//     if (json['sessions'] != null) {
//       sessions = <Sessions>[];
//       json['sessions'].forEach((v) {
//         sessions!.add(new Sessions.fromJson(v));
//       });
//     }
//     if (json['locationStays'] != null) {
//       locationStays = <LocationStays>[];
//       json['locationStays'].forEach((v) {
//         locationStays!.add(new LocationStays.fromJson(v));
//       });
//     }
//     lastKnownLocation = json['lastKnownLocation'] != null
//         ? new PunchedInLocation.fromJson(json['lastKnownLocation'])
//         : null;
//     totalPingCount = json['totalPingCount'];
//     firstPingAt = json['firstPingAt'];
//     firstPingAtDisplay = json['firstPingAtDisplay'];
//     lastPingAt = json['lastPingAt'];
//     lastPingAtDisplay = json['lastPingAtDisplay'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['date'] = this.date;
//     data['dateDisplay'] = this.dateDisplay;
//     if (this.sessions != null) {
//       data['sessions'] = this.sessions!.map((v) => v.toJson()).toList();
//     }
//     if (this.locationStays != null) {
//       data['locationStays'] =
//           this.locationStays!.map((v) => v.toJson()).toList();
//     }
//     if (this.lastKnownLocation != null) {
//       data['lastKnownLocation'] = this.lastKnownLocation!.toJson();
//     }
//     data['totalPingCount'] = this.totalPingCount;
//     data['firstPingAt'] = this.firstPingAt;
//     data['firstPingAtDisplay'] = this.firstPingAtDisplay;
//     data['lastPingAt'] = this.lastPingAt;
//     data['lastPingAtDisplay'] = this.lastPingAtDisplay;
//     return data;
//   }
// }
//
// class Sessions {
//   String? sessionId;
//   String? status;
//   String? punchedInAt;
//   String? punchedOutAt;
//   String? punchedInAtDisplay;
//   String? punchedOutAtDisplay;
//   PunchedInLocation? punchedInLocation;
//   PunchedInLocation? punchedOutLocation;
//   double? pingCount;
//   double? workMinutes;
//
//   Sessions(
//       {this.sessionId,
//         this.status,
//         this.punchedInAt,
//         this.punchedOutAt,
//         this.punchedInAtDisplay,
//         this.punchedOutAtDisplay,
//         this.punchedInLocation,
//         this.punchedOutLocation,
//         this.pingCount,
//         this.workMinutes});
//
//   Sessions.fromJson(Map<String, dynamic> json) {
//     sessionId = json['sessionId'];
//     status = json['status'];
//     punchedInAt = json['punchedInAt'];
//     punchedOutAt = json['punchedOutAt'];
//     punchedInAtDisplay = json['punchedInAtDisplay'];
//     punchedOutAtDisplay = json['punchedOutAtDisplay'];
//     punchedInLocation = json['punchedInLocation'] != null
//         ? new PunchedInLocation.fromJson(json['punchedInLocation'])
//         : null;
//     punchedOutLocation = json['punchedOutLocation'] != null
//         ? new PunchedInLocation.fromJson(json['punchedOutLocation'])
//         : null;
//     pingCount = json['pingCount'];
//     workMinutes = json['workMinutes'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['sessionId'] = this.sessionId;
//     data['status'] = this.status;
//     data['punchedInAt'] = this.punchedInAt;
//     data['punchedOutAt'] = this.punchedOutAt;
//     data['punchedInAtDisplay'] = this.punchedInAtDisplay;
//     data['punchedOutAtDisplay'] = this.punchedOutAtDisplay;
//     if (this.punchedInLocation != null) {
//       data['punchedInLocation'] = this.punchedInLocation!.toJson();
//     }
//     if (this.punchedOutLocation != null) {
//       data['punchedOutLocation'] = this.punchedOutLocation!.toJson();
//     }
//     data['pingCount'] = this.pingCount;
//     data['workMinutes'] = this.workMinutes;
//     return data;
//   }
// }
//
// class PunchedInLocation {
//   double? lat;
//   double? lng;
//   double? accuracyM;
//   String? capturedAt;
//   String? capturedAtDisplay;
//
//   PunchedInLocation(
//       {this.lat,
//         this.lng,
//         this.accuracyM,
//         this.capturedAt,
//         this.capturedAtDisplay});
//
//   PunchedInLocation.fromJson(Map<String, dynamic> json) {
//     lat = json['lat'];
//     lng = json['lng'];
//     accuracyM = json['accuracyM'];
//     capturedAt = json['capturedAt'];
//     capturedAtDisplay = json['capturedAtDisplay'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['lat'] = this.lat;
//     data['lng'] = this.lng;
//     data['accuracyM'] = this.accuracyM;
//     data['capturedAt'] = this.capturedAt;
//     data['capturedAtDisplay'] = this.capturedAtDisplay;
//     return data;
//   }
// }
//
// class LocationStays {
//   String? sessionId;
//   double? lat;
//   double? lng;
//   String? stayStartedAt;
//   String? stayLastPingAt;
//   int? stayDurationSeconds;
//
//   LocationStays(
//       {this.sessionId,
//         this.lat,
//         this.lng,
//         this.stayStartedAt,
//         this.stayLastPingAt,
//         this.stayDurationSeconds});
//
//   LocationStays.fromJson(Map<String, dynamic> json) {
//     sessionId = json['sessionId'];
//     lat = json['lat'];
//     lng = json['lng'];
//     stayStartedAt = json['stayStartedAt'];
//     stayLastPingAt = json['stayLastPingAt'];
//     stayDurationSeconds = json['stayDurationSeconds'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['sessionId'] = this.sessionId;
//     data['lat'] = this.lat;
//     data['lng'] = this.lng;
//     data['stayStartedAt'] = this.stayStartedAt;
//     data['stayLastPingAt'] = this.stayLastPingAt;
//     data['stayDurationSeconds'] = this.stayDurationSeconds;
//     return data;
//   }
// }


class ExecutiveTrackingByDaysResponse {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  ExecutiveTrackingByDaysResponse(
      {this.status, this.message, this.statusCode, this.data});

  ExecutiveTrackingByDaysResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    statusCode = json['statusCode'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? date;
  String? dateDisplay;
  List<Sessions>? sessions;
  List<LocationStays>? locationStays;
  PunchedInLocation? lastKnownLocation;
  int? totalPingCount;
  String? firstPingAt;
  String? firstPingAtDisplay;
  String? lastPingAt;
  String? lastPingAtDisplay;

  Data(
      {this.date,
        this.dateDisplay,
        this.sessions,
        this.locationStays,
        this.lastKnownLocation,
        this.totalPingCount,
        this.firstPingAt,
        this.firstPingAtDisplay,
        this.lastPingAt,
        this.lastPingAtDisplay});

  Data.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    dateDisplay = json['dateDisplay'];
    if (json['sessions'] != null) {
      sessions = <Sessions>[];
      json['sessions'].forEach((v) {
        sessions!.add(new Sessions.fromJson(v));
      });
    }
    if (json['locationStays'] != null) {
      locationStays = <LocationStays>[];
      json['locationStays'].forEach((v) {
        locationStays!.add(new LocationStays.fromJson(v));
      });
    }
    lastKnownLocation = json['lastKnownLocation'] != null
        ? new PunchedInLocation.fromJson(json['lastKnownLocation'])
        : null;
    totalPingCount = json['totalPingCount'];
    firstPingAt = json['firstPingAt'];
    firstPingAtDisplay = json['firstPingAtDisplay'];
    lastPingAt = json['lastPingAt'];
    lastPingAtDisplay = json['lastPingAtDisplay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['dateDisplay'] = this.dateDisplay;
    if (this.sessions != null) {
      data['sessions'] = this.sessions!.map((v) => v.toJson()).toList();
    }
    if (this.locationStays != null) {
      data['locationStays'] =
          this.locationStays!.map((v) => v.toJson()).toList();
    }
    if (this.lastKnownLocation != null) {
      data['lastKnownLocation'] = this.lastKnownLocation!.toJson();
    }
    data['totalPingCount'] = this.totalPingCount;
    data['firstPingAt'] = this.firstPingAt;
    data['firstPingAtDisplay'] = this.firstPingAtDisplay;
    data['lastPingAt'] = this.lastPingAt;
    data['lastPingAtDisplay'] = this.lastPingAtDisplay;
    return data;
  }
}

class Sessions {
  String? sessionId;
  String? status;
  String? punchedInAt;
  String? punchedOutAt;
  String? punchedInAtDisplay;
  String? punchedOutAtDisplay;
  PunchedInLocation? punchedInLocation;
  PunchedInLocation? punchedOutLocation;
  int? pingCount;
  int? workMinutes;

  Sessions(
      {this.sessionId,
        this.status,
        this.punchedInAt,
        this.punchedOutAt,
        this.punchedInAtDisplay,
        this.punchedOutAtDisplay,
        this.punchedInLocation,
        this.punchedOutLocation,
        this.pingCount,
        this.workMinutes});

  Sessions.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    status = json['status'];
    punchedInAt = json['punchedInAt'];
    punchedOutAt = json['punchedOutAt'];
    punchedInAtDisplay = json['punchedInAtDisplay'];
    punchedOutAtDisplay = json['punchedOutAtDisplay'];
    punchedInLocation = json['punchedInLocation'] != null
        ? new PunchedInLocation.fromJson(json['punchedInLocation'])
        : null;
    punchedOutLocation = json['punchedOutLocation'] != null
        ? new PunchedInLocation.fromJson(json['punchedOutLocation'])
        : null;
    pingCount = json['pingCount'];
    workMinutes = json['workMinutes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    data['status'] = this.status;
    data['punchedInAt'] = this.punchedInAt;
    data['punchedOutAt'] = this.punchedOutAt;
    data['punchedInAtDisplay'] = this.punchedInAtDisplay;
    data['punchedOutAtDisplay'] = this.punchedOutAtDisplay;
    if (this.punchedInLocation != null) {
      data['punchedInLocation'] = this.punchedInLocation!.toJson();
    }
    if (this.punchedOutLocation != null) {
      data['punchedOutLocation'] = this.punchedOutLocation!.toJson();
    }
    data['pingCount'] = this.pingCount;
    data['workMinutes'] = this.workMinutes;
    return data;
  }
}
class PunchedInLocation {
  final double? lat;
  final double? lng;
  final double? accuracyM;
  final String? capturedAt;
  final String? capturedAtDisplay;

  PunchedInLocation({
    this.lat,
    this.lng,
    this.accuracyM,
    this.capturedAt,
    this.capturedAtDisplay,
  });

  factory PunchedInLocation.fromJson(Map<String, dynamic> json) {
    return PunchedInLocation(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      accuracyM: (json['accuracyM'] as num?)?.toDouble(),
      capturedAt: json['capturedAt'],
      capturedAtDisplay: json['capturedAtDisplay'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['accuracyM'] = this.accuracyM;
    data['capturedAt'] = this.capturedAt;
    data['capturedAtDisplay'] = this.capturedAtDisplay;
    return data;
  }
}


class LocationStays {
  String? sessionId;
  double? lat;
  double? lng;
  String? stayStartedAt;
  String? stayLastPingAt;
  int? stayDurationSeconds;

  LocationStays(
      {this.sessionId,
        this.lat,
        this.lng,
        this.stayStartedAt,
        this.stayLastPingAt,
        this.stayDurationSeconds});

  LocationStays.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    lat = json['lat'];
    lng = json['lng'];
    stayStartedAt = json['stayStartedAt'];
    stayLastPingAt = json['stayLastPingAt'];
    stayDurationSeconds = json['stayDurationSeconds'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['stayStartedAt'] = this.stayStartedAt;
    data['stayLastPingAt'] = this.stayLastPingAt;
    data['stayDurationSeconds'] = this.stayDurationSeconds;
    return data;
  }
}
