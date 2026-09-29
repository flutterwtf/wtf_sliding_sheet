import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_sliding_sheet/wtf_sliding_sheet.dart';

void main() {
  Widget sheet(SheetController controller, {required bool visible}) {
    return MaterialApp(
      home: visible
          ? SlidingSheet(
              controller: controller,
              builder: (_, __) => const SizedBox(height: 400),
            )
          : const SizedBox(),
    );
  }

  testWidgets(
    'collapse after the sheet is disposed does nothing',
    (tester) async {
      final controller = SheetController();
      await tester.pumpWidget(sheet(controller, visible: true));
      expect(controller.isAttached, isTrue);

      await tester.pumpWidget(sheet(controller, visible: false));
      expect(controller.isAttached, isFalse);

      expect(controller.collapse(), isNull);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a disposed sheet does not detach the sheet that replaced it',
    (tester) async {
      final controller = SheetController();
      Widget app(Key key) => MaterialApp(
            home: SlidingSheet(
              key: key,
              controller: controller,
              builder: (_, __) => const SizedBox(height: 400),
            ),
          );
      await tester.pumpWidget(app(const ValueKey(1)));
      await tester.pumpWidget(app(const ValueKey(2)));

      expect(controller.isAttached, isTrue);
      unawaited(controller.expand());
      await tester.pumpAndSettle();
      expect(controller.state?.isExpanded, isTrue);
    },
  );
}
