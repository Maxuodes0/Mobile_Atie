import 'package:flutter_test/flutter_test.dart';

import 'package:aite_mobile/data/models/dashboard_summary.dart';

void main() {
  test('dashboard summary parses client and operating-company counts', () {
    final summary = DashboardSummary.fromJson({
      'clientCount': 30,
      'operatingCompanyCount': '23',
    });

    expect(summary.clientCount, 30);
    expect(summary.operatingCompanyCount, 23);
  });
}
