import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aite_mobile/utils/formatters.dart';

void main() {
  testWidgets('unavailable and malformed amounts stay distinct from zero',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Column(children: [
      Text(formatSar(null)),
      Text(formatSar('broken')),
      Text(formatSar('0', locale: 'en_US')),
    ])));
    expect(find.text('—'), findsNWidgets(2));
    expect(find.textContaining('0.00'), findsOneWidget);
  });
}
