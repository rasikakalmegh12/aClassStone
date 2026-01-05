// // GENERATED CODE - DO NOT MODIFY BY HAND
//
// part of 'api_client.dart';
//
// // **************************************************************************
// // RetrofitGenerator
// // **************************************************************************
//
// // ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers
//
// class _ApiClient implements ApiClient {
//   _ApiClient(
//     this._dio, {
//     this.baseUrl,
//   });
//
//   final Dio _dio;
//
//   String? baseUrl;
//
//   @override
//   Future<LoginResponse> login(LoginRequest request) async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final _data = <String, dynamic>{};
//     _data.addAll(request.toJson());
//     final _result = await _dio
//         .fetch<Map<String, dynamic>>(_setStreamType<LoginResponse>(Options(
//       method: 'POST',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/auth/login',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = LoginResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<RegisterResponse> register(RegisterRequest request) async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final _data = <String, dynamic>{};
//     _data.addAll(request.toJson());
//     final _result = await _dio
//         .fetch<Map<String, dynamic>>(_setStreamType<RegisterResponse>(Options(
//       method: 'POST',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/auth/register',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = RegisterResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<BaseResponse> logout() async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final Map<String, dynamic>? _data = null;
//     final _result = await _dio
//         .fetch<Map<String, dynamic>>(_setStreamType<BaseResponse>(Options(
//       method: 'POST',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/auth/logout',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = BaseResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<UserProfileResponse> getUserProfile() async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final Map<String, dynamic>? _data = null;
//     final _result = await _dio.fetch<Map<String, dynamic>>(
//         _setStreamType<UserProfileResponse>(Options(
//       method: 'GET',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/auth/profile',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = UserProfileResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<PendingRegistrationsResponse> getPendingRegistrations() async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final Map<String, dynamic>? _data = null;
//     final _result = await _dio.fetch<Map<String, dynamic>>(
//         _setStreamType<PendingRegistrationsResponse>(Options(
//       method: 'GET',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/admin/registrations/pending',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = PendingRegistrationsResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<BaseResponse> approveRegistration(String registrationId) async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final Map<String, dynamic>? _data = null;
//     final _result = await _dio
//         .fetch<Map<String, dynamic>>(_setStreamType<BaseResponse>(Options(
//       method: 'PUT',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/admin/registrations/${registrationId}/approve',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = BaseResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<BaseResponse> rejectRegistration(String registrationId) async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final Map<String, dynamic>? _data = null;
//     final _result = await _dio
//         .fetch<Map<String, dynamic>>(_setStreamType<BaseResponse>(Options(
//       method: 'PUT',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/admin/registrations/${registrationId}/reject',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = BaseResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<PunchResponse> punchIn(PunchRequest request) async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final _data = <String, dynamic>{};
//     _data.addAll(request.toJson());
//     final _result = await _dio
//         .fetch<Map<String, dynamic>>(_setStreamType<PunchResponse>(Options(
//       method: 'POST',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/executive/punch-in',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = PunchResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<PunchResponse> punchOut(PunchRequest request) async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final _data = <String, dynamic>{};
//     _data.addAll(request.toJson());
//     final _result = await _dio
//         .fetch<Map<String, dynamic>>(_setStreamType<PunchResponse>(Options(
//       method: 'POST',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/executive/punch-out',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = PunchResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<AttendanceHistoryResponse> getAttendanceHistory() async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final Map<String, dynamic>? _data = null;
//     final _result = await _dio.fetch<Map<String, dynamic>>(
//         _setStreamType<AttendanceHistoryResponse>(Options(
//       method: 'GET',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/executive/executive_history-history',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = AttendanceHistoryResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<MeetingResponse> startMeeting(StartMeetingRequest request) async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final _data = <String, dynamic>{};
//     _data.addAll(request.toJson());
//     final _result = await _dio
//         .fetch<Map<String, dynamic>>(_setStreamType<MeetingResponse>(Options(
//       method: 'POST',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/meetings/start',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = MeetingResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<MeetingResponse> endMeeting(String meetingId) async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final Map<String, dynamic>? _data = null;
//     final _result = await _dio
//         .fetch<Map<String, dynamic>>(_setStreamType<MeetingResponse>(Options(
//       method: 'PUT',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/meetings/${meetingId}/end',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = MeetingResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<MeetingsListResponse> getMeetings() async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final Map<String, dynamic>? _data = null;
//     final _result = await _dio.fetch<Map<String, dynamic>>(
//         _setStreamType<MeetingsListResponse>(Options(
//       method: 'GET',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/meetings',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = MeetingsListResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<MeetingDetailResponse> getMeetingDetail(String meetingId) async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final Map<String, dynamic>? _data = null;
//     final _result = await _dio.fetch<Map<String, dynamic>>(
//         _setStreamType<MeetingDetailResponse>(Options(
//       method: 'GET',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/meetings/${meetingId}',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = MeetingDetailResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<ExecutiveDashboardResponse> getExecutiveDashboard() async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final Map<String, dynamic>? _data = null;
//     final _result = await _dio.fetch<Map<String, dynamic>>(
//         _setStreamType<ExecutiveDashboardResponse>(Options(
//       method: 'GET',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/dashboard/executive',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = ExecutiveDashboardResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<AdminDashboardResponse> getAdminDashboard() async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final Map<String, dynamic>? _data = null;
//     final _result = await _dio.fetch<Map<String, dynamic>>(
//         _setStreamType<AdminDashboardResponse>(Options(
//       method: 'GET',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/dashboard/admin',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = AdminDashboardResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   @override
//   Future<SuperAdminDashboardResponse> getSuperAdminDashboard() async {
//     const _extra = <String, dynamic>{};
//     final queryParameters = <String, dynamic>{};
//     final _headers = <String, dynamic>{};
//     final Map<String, dynamic>? _data = null;
//     final _result = await _dio.fetch<Map<String, dynamic>>(
//         _setStreamType<SuperAdminDashboardResponse>(Options(
//       method: 'GET',
//       headers: _headers,
//       extra: _extra,
//     )
//             .compose(
//               _dio.options,
//               '/dashboard/super-admin',
//               queryParameters: queryParameters,
//               data: _data,
//             )
//             .copyWith(
//                 baseUrl: _combineBaseUrls(
//               _dio.options.baseUrl,
//               baseUrl,
//             ))));
//     final value = SuperAdminDashboardResponse.fromJson(_result.data!);
//     return value;
//   }
//
//   RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
//     if (T != dynamic &&
//         !(requestOptions.responseType == ResponseType.bytes ||
//             requestOptions.responseType == ResponseType.stream)) {
//       if (T == String) {
//         requestOptions.responseType = ResponseType.plain;
//       } else {
//         requestOptions.responseType = ResponseType.json;
//       }
//     }
//     return requestOptions;
//   }
//
//   String _combineBaseUrls(
//     String dioBaseUrl,
//     String? baseUrl,
//   ) {
//     if (baseUrl == null || baseUrl.trim().isEmpty) {
//       return dioBaseUrl;
//     }
//
//     final url = Uri.parse(baseUrl);
//
//     if (url.isAbsolute) {
//       return url.toString();
//     }
//
//     return Uri.parse(dioBaseUrl).resolveUri(url).toString();
//   }
// }
