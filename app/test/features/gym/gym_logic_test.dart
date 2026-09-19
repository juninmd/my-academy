import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_academy/features/gym/data/models/gym_json.dart';
import 'package:my_academy/features/gym/presentation/widgets/plan_form_dialog.dart';
import 'package:my_academy/features/gym/presentation/widgets/status_chip.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR', null));

  group('parsePrice accepts how owners type prices in Brazil', () {
    test('comma decimals and thousand separators', () {
      expect(parsePrice('119,90'), 119.9);
      expect(parsePrice('1.299,50'), 1299.5);
      expect(parsePrice(' 89.9 '), 89.9);
    });

    test('rejects text that is not a price', () {
      expect(parsePrice(''), isNull);
      expect(parsePrice('grátis'), isNull);
    });
  });

  group('API mapping', () {
    test('dashboard revenue comes back as a double even when integral', () {
      final d = dashboardFromJson({
        'activeMembers': 3,
        'pendingPayments': 1,
        'overduePayments': 0,
        'revenueThisMonth': 120,
      });
      expect(d.revenueThisMonth, 120.0);
      expect(brl.format(d.revenueThisMonth), contains('120,00'));
    });

    test('membership counts only unpaid payments as pending', () {
      final m = membershipFromJson({
        'status': 'ACTIVE',
        'gym': {'name': 'Academia Centro'},
        'plan': {'name': 'Mensal'},
        'endDate': '2026-10-18T00:00:00.000Z',
        'payments': [
          {'status': 'PAID'},
          {'status': 'PENDING'},
          {'status': 'OVERDUE'},
        ],
      });
      expect(m.gymName, 'Academia Centro');
      expect(m.pendingPayments, 2);
    });

    test('member without a loaded user still renders', () {
      final m = memberFromJson({
        'id': 7,
        'status': 'ACTIVE',
        'startDate': '2026-09-18T00:00:00.000Z',
      });
      expect(m.name, '—');
      expect(m.endDate, isNull);
    });
  });

  testWidgets('status chip announces a pt-BR status, not a checkbox', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StatusChip('OVERDUE'))),
    );
    expect(find.bySemanticsLabel('Status: Atrasado'), findsOneWidget);
    handle.dispose();
  });
}
