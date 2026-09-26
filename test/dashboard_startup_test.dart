import 'dart:async';

import 'package:aite_mobile/data/api/api_client.dart';
import 'package:aite_mobile/data/api/cookie_store.dart';
import 'package:aite_mobile/data/api/dashboard_api.dart';
import 'package:aite_mobile/data/models/dashboard_mobile_summary.dart';
import 'package:aite_mobile/screens/dashboard/dashboard_screen_controller.dart';
import 'package:aite_mobile/state/period_filter_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _ControlledDashboardApi extends DashboardApi {
  _ControlledDashboardApi()
      : super(ApiClient(
          baseUrl: 'https://api.example.test',
          cookieStore: CookieStore(restoreFromStorage: false),
        ));

  final List<String> requests = <String>[];
  final Map<String, Completer<DashboardMobileSummary>> pending = {};

  @override
  Future<DashboardMobileSummary> mobileSummary({
    int? year,
    String? from,
    String? to,
    List<String>? sections,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) {
    final key = sections?.join(',') ?? '';
    requests.add(key);
    final completer = Completer<DashboardMobileSummary>();
    pending[key] = completer;
    return completer.future;
  }
}

DashboardMobileSummary _payload(
  Set<String> sections, {
  List<int>? years,
}) =>
    DashboardMobileSummary(
      sections: sections,
      errors: const {},
      availableYears: years,
      finance: null,
      collections: sections.contains('collections') ? const [] : null,
      statusCounts: sections.contains('statusCounts') ? const [] : null,
      summary: null,
      latestProjects: sections.contains('latestProjects') ? const [] : null,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('first dashboard sections resolve independently before heavy queries',
      () async {
    final api = _ControlledDashboardApi();
    final filters = PeriodFilterController();
    final controller = DashboardScreenController(
      dashboardApi: api,
      periodFilters: filters,
    );
    addTearDown(() {
      controller.dispose();
      filters.selection.dispose();
    });

    final load = controller.setActive(true);
    expect(api.requests, ['years', 'finance', 'collections']);
    expect(controller.loading, isTrue);

    api.pending['years']!.complete(_payload({'years'}, years: [2026]));
    await Future<void>.delayed(Duration.zero);
    expect(controller.loading, isFalse);
    expect(controller.availableYears, contains(2026));
    expect(
        api.requests, isNot(contains('statusCounts,summary,latestProjects')));

    api.pending['finance']!.complete(_payload({'finance'}));
    api.pending['collections']!.complete(_payload({'collections'}));
    await Future<void>.delayed(Duration.zero);
    expect(api.requests.last, 'statusCounts,summary,latestProjects');

    api.pending['statusCounts,summary,latestProjects']!.complete(
      _payload({'statusCounts', 'summary', 'latestProjects'}),
    );
    await load;
    expect(controller.updatingSections, isEmpty);
  });
}
