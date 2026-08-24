import 'package:flutter_test/flutter_test.dart';
import 'package:aite_mobile/data/models/project_details.dart';

void main() {
  test('project details parse values before and after VAT', () {
    final project = ProjectDetails.fromJson({
      'id': 'project-1',
      'name': 'مشروع تجريبي',
      'status': 'COMPLETED',
      'projectValueWithoutVat': '8500.00',
      'vatPercentage': '15.00',
      'dueAmount': '9775.00',
    });

    expect(project.projectValueWithoutVat, 8500);
    expect(project.projectValueWithVat, 9775);
  });

  test('project details calculate VAT value when the API omits it', () {
    final project = ProjectDetails.fromJson({
      'id': 'project-2',
      'name': 'مشروع تجريبي',
      'status': 'COMPLETED',
      'projectValueWithoutVat': 1000,
      'vatPercentage': 15,
    });

    expect(project.projectValueWithoutVat, 1000);
    expect(project.projectValueWithVat, 1150);
  });
}
