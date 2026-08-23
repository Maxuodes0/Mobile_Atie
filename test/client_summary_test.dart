import 'package:flutter_test/flutter_test.dart';

import 'package:aite_mobile/data/models/client_list_result.dart';

void main() {
  test('client list parses project and revenue statistics', () {
    final result = ClientListResult.fromJson({
      'clients': [
        {
          'id': 'client-1',
          'name': 'The Moment Client',
          'status': 'ACTIVE',
          '_count': {'projects': 7},
          'totalRevenueWithoutVat': '125000.50',
        },
      ],
      'meta': {'total': 1, 'limit': 200, 'offset': 0},
    });

    expect(result.meta.total, 1);
    expect(result.clients, hasLength(1));
    expect(result.clients.single.projectCount, 7);
    expect(result.clients.single.totalRevenueWithoutVat, 125000.50);
  });
}
