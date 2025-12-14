// Dashboard Events
abstract class DashboardEvent {}

class LoadExecutiveDashboardEvent extends DashboardEvent {}

class LoadAdminDashboardEvent extends DashboardEvent {}

class LoadSuperAdminDashboardEvent extends DashboardEvent {}

class RefreshDashboardEvent extends DashboardEvent {}
