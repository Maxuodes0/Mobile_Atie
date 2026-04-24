import '../data/api/api_client.dart';
import '../data/api/auth_api.dart';
import '../data/api/dashboard_api.dart';
import '../data/api/finance_api.dart';
import '../data/api/projects_api.dart';
import '../data/api/reports_api.dart';
import '../data/api/tasks_api.dart';
import '../data/api/users_api.dart';
import '../state/period_filter_controller.dart';
import '../state/session_controller.dart';

class AppServices {
  static late final ApiClient api;
  static late final AuthApi auth;
  static late final DashboardApi dashboard;
  static late final FinanceApi finance;
  static late final ProjectsApi projects;
  static late final ReportsApi reports;
  static late final TasksApi tasks;
  static late final UsersApi users;
  static late final SessionController session;
  static late final PeriodFilterController periodFilters;

  static void init() {
    api = ApiClient();
    auth = AuthApi(api);
    dashboard = DashboardApi(api);
    finance = FinanceApi(api);
    projects = ProjectsApi(api);
    reports = ReportsApi(api);
    tasks = TasksApi(api);
    users = UsersApi(api);
    session = SessionController(auth, api);
    periodFilters = PeriodFilterController();
  }
}
