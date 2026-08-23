import 'package:flutter_test/flutter_test.dart';

import 'package:aite_mobile/data/models/project_summary.dart';
import 'package:aite_mobile/utils/collection_status.dart';

void main() {
  test('project summary parses collection status and amount', () {
    final project = ProjectSummary.fromJson({
      'id': 'project-1',
      'name': 'مشروع مدفوع',
      'status': 'COMPLETED',
      'collectionStatus': 'FULLY_COLLECTED',
      'totalCollectedAmount': '8500.00',
      'client': {'name': 'عميل'},
    });

    expect(project.collectionStatus, 'FULLY_COLLECTED');
    expect(project.totalCollectedAmount, 8500);
    expect(collectionStatusLabel(project.collectionStatus!), 'محصل بالكامل');
  });

  test('missing financial fields stay hidden instead of looking uncollected',
      () {
    final project = ProjectSummary.fromJson({
      'id': 'project-2',
      'name': 'مشروع محدود الصلاحية',
      'status': 'COMPLETED',
    });

    expect(project.collectionStatus, isNull);
    expect(project.totalCollectedAmount, isNull);
  });
}
