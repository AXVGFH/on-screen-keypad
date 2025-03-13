

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:onscreen_keypad/on_screen_keypad.dart';

void main() {
  group('OnScreenKeyPad', () {
    testWidgets('renders all keys correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: OnScreenKeyPad(
            onKeyPress: (value) {},
          ),
        ),
      ));

      // Verify all keys are displayed
      for (var row in keyValues) {
        for (var key in row) {
          if (key == 'left' || key == 'right') continue;
          expect(find.text(key), findsOneWidget);
        }
      }
    });

    testWidgets('calls onKeyPress when a key is tapped', (WidgetTester tester) async {
      String? pressedKey;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: OnScreenKeyPad(
            onKeyPress: (value) {
              pressedKey = value;
            },
          ),
        ),
      ));

      // Tap on a number key
      await tester.tap(find.text('5'));
      await tester.pump();

      expect(pressedKey, '5');
    });

    testWidgets('applies key text style if provided', (WidgetTester tester) async {
      const textStyle = TextStyle(fontSize: 24, color: Colors.red);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: OnScreenKeyPad(
            onKeyPress: (_) {},
            style: textStyle,
          ),
        ),
      ));

      final textWidget = tester.widget<Text>(find.text('1'));
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.color, Colors.red);
    });

    testWidgets('applies key background color if provided', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: OnScreenKeyPad(
            onKeyPress: (_) {},
            keyCellBackgroundColor: Colors.blue,
          ),
        ),
      ));

      final keyCells = find.byType(KeyCell);
      expect(keyCells, findsWidgets);

      // For each KeyCell, verify that at least one descendant Container
      // uses a BoxDecoration with the expected background color.
      for (final keyCell in keyCells.evaluate()) {
        final containerFinder = find.descendant(
          of: find.byWidget(keyCell.widget),
          matching: find.byType(Container),
        );
        final containers = containerFinder.evaluate().toList();
        expect(containers.isNotEmpty, isTrue);
        // Check the first container's decoration color.
        final container = containers.first.widget as Container;
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.blue));
      }
    });


    testWidgets('triggers haptic feedback when enabled', (WidgetTester tester) async {
      final binding = tester.binding;
      bool hapticTriggered = false;

      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
            (MethodCall methodCall) async {
          if (methodCall.method == 'HapticFeedback.vibrate') {
            hapticTriggered = true;
          }
          return null;
        },
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: OnScreenKeyPad(
            onKeyPress: (_) {},
            enableHapticFeedback: true,
            hapticFeedbackType: HapticFeedbackType.lightImpact,
          ),
        ),
      ));

      await tester.tap(find.text('1'));
      await tester.pump();

      expect(hapticTriggered, isTrue);
    });
  });
}
