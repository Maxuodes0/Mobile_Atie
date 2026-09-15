import 'package:aite_mobile/data/models/finance_dashboard.dart';
import 'package:aite_mobile/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('real zero is not unavailable', () {
    expect(formatSar('0', locale: 'en_US'), contains('0.00'));
    expect(formatPercent('0'), contains('0.00%'));
  });
  test('missing and malformed numbers never become zero', () {
    for (final raw in [null, '', 'oops', 'NaN', 'Infinity', ' ']) {
      expect(formatSar(raw), '—');
      expect(formatPercent(raw), '—');
    }
    expect(FinanceKpis.fromJson({}).totalCosts, isNull);
    expect(() => FinanceDashboard.fromJson({}), throwsFormatException);
    expect(() => FinanceKpis.fromJson({'totalCosts': 'broken'}),
        throwsFormatException);
  });
  test('valid decimals and locales retain two places', () {
    expect(formatSar('1234.50', locale: 'en_US'), contains('1,234.50'));
    expect(formatSar('1234.50', locale: 'ar'),
        isNot(formatSar('1234.50', locale: 'en_US')));
    expect(FinanceKpis.fromJson({'totalCosts': '0.00'}).totalCosts, '0.00');
    expect(formatPercent('12.345', locale: 'en_US'), contains('12.35%'));
  });
}
