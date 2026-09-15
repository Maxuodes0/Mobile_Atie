import 'package:aite_mobile/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatSar uses the official Saudi riyal symbol', () {
    final formatted = formatSar('1234.50');

    expect(formatted, contains('\u20C1'));
    expect(formatted, isNot(contains('SAR')));
    expect(formatted, isNot(contains('ر.س')));
    expect(formatted, contains('1,234.5'));
  });
}
