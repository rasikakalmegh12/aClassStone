// Dashboard Events
abstract class DashboardEvent {}

class LoadExecutiveDashboardEvent extends DashboardEvent {}

class LoadAdminDashboardEvent extends DashboardEvent {}

class LoadSuperAdminDashboardEvent extends DashboardEvent {}

class RefreshDashboardEvent extends DashboardEvent {}


abstract class AllUsersEvent {}
class  GetAllUsers extends AllUsersEvent {
  // FetchIndustryDetails();
}


abstract class ActiveSessionEvent {}
class FetchActiveSession extends ActiveSessionEvent {
  // new: whether the UI should show a full-page loader

  FetchActiveSession();
}