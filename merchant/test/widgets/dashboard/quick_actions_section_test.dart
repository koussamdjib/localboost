import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:localboost_merchant/widgets/dashboard/quick_actions_section.dart';

void main() {
  testWidgets('QuickActionsSection handles zero-width constraints', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 0,
            child: QuickActionsSection(),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
