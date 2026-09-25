import 'package:aite_mobile/data/models/finance_dashboard.dart';
import 'package:aite_mobile/data/models/finance_module.dart';
import 'package:aite_mobile/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('query carries period and filters, and can clear optional filters', () {
    const query = FinanceQuery(
      year: 2026,
      quarter: 'Q2',
      clientId: 'client-1',
      search: 'example',
      page: 3,
    );
    expect(query.toQuery(), containsPair('year', 2026));
    expect(query.toQuery(), containsPair('quarter', 'Q2'));
    expect(query.toQuery(), containsPair('page', 3));
    final cleared = query.copyWith(
      quarter: 'ALL',
      clearClient: true,
      clearSearch: true,
      page: 1,
    );
    expect(cleared.toQuery(), isNot(contains('quarter')));
    expect(cleared.toQuery(), isNot(contains('clientId')));
    expect(cleared.toQuery(), isNot(contains('search')));
    expect(cleared.toQuery(), containsPair('page', 1));
  });

  test('drilldown preserves authoritative decimal strings and basis', () {
    final page = FinanceDataPage.fromJson({
      'rows': [
        {'projectId': 'p1', 'value': '999999999999999.99'},
      ],
      'cardTotal': '999999999999999.99',
      'filteredTotal': '999999999999999.99',
      'matchesCard': true,
      'basis': {
        'collectedAmount': '600.20',
        'contractValueWithVat': '1000.00',
      },
      'meta': {'total': 100, 'page': 2, 'pageSize': 25, 'totalPages': 4},
    });
    expect(page.rows.single['value'], '999999999999999.99');
    expect(page.cardTotal, '999999999999999.99');
    expect(page.basis['collectedAmount'], '600.20');
    expect(page.meta.totalPages, 4);
  });

  test('unavailable report is distinguishable from a genuine zero', () {
    final unavailable = FinanceDataPage.fromJson({
      'rows': [],
      'meta': {
        'unavailable': true,
        'unavailableReason': 'No authoritative due date',
      },
    });
    final empty = FinanceDataPage.fromJson({'rows': [], 'totalCount': 0});
    expect(unavailable.unavailable, isTrue);
    expect(unavailable.unavailableReason, 'No authoritative due date');
    expect(empty.unavailable, isFalse);
  });

  test('report pagination reads top-level values beside metadata', () {
    final page = FinanceDataPage.fromJson({
      'rows': [],
      'totalCount': 58,
      'page': 2,
      'pageSize': 20,
      'meta': {'totalPages': 3},
    });
    expect(page.meta.total, 58);
    expect(page.meta.page, 2);
    expect(page.meta.pageSize, 20);
    expect(page.meta.totalPages, 3);
  });

  test('fallback dashboard is rejected instead of displaying false zeros', () {
    expect(
      () => FinanceDashboard.fromJson({
        'kpis': {'totalCosts': '0.00'},
        'meta': {'fallback': true},
      }),
      throwsFormatException,
    );
  });

  test('all-time outstanding is kept separate from the selected year amount',
      () {
    final kpis = FinanceKpis.fromJson({
      'outstandingAmount': '115.00',
      'allTimeOutstandingAmount': '325.00',
    });
    expect(kpis.outstandingAmount, '115.00');
    expect(kpis.allTimeOutstandingAmount, '325.00');
  });

  test('large and fractional money stays exact during presentation', () {
    expect(
        formatSar('9007199254740993.01'), contains('9,007,199,254,740,993.01'));
    expect(formatSar('0.005'), contains('0.01'));
    expect(formatSar('-1234.5'), contains('-1,234.50'));
    expect(formatSar('0'), contains('0.00'));
    expect(formatSar(null), '—');
    expect(formatPercent('72.345'), contains('72.35%'));
  });
}
