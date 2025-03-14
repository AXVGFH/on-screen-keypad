import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// A customizable on-screen numeric keypad for Flutter applications.
///
/// This widget is useful for PIN entry, authentication screens, and custom
/// input fields with haptic feedback support.
class OnScreenKeyPad extends StatelessWidget {
  /// Enables or disables haptic feedback for key presses.
  final bool enableHapticFeedback;

  /// Type of haptic feedback to trigger on key press.
  final HapticFeedbackType? hapticFeedbackType;

  /// Padding for each key cell.
  final EdgeInsets? keyPadding;

  /// The shape of the keypad keys (rectangle or circle).
  final BoxShape keyShape;

  /// Splash color effect when a key is tapped.
  final Color? keyCellSplashColor;

  /// Highlight color effect when a key is tapped.
  final Color? keyCellHighlightColor;

  /// Background color of the keypad keys.
  final Color? keyCellBackgroundColor;

  /// Callback function that gets triggered when a key is pressed.
  final void Function(String) onKeyPress;

  /// Custom widget for the left button (e.g., backspace).
  final Widget? leftButtonAction;

  /// Custom widget for the right button (e.g., submit).
  final Widget? rightButtonAction;

  /// Text style applied to keypad keys.
  final TextStyle? style;

  /// Constructs an [OnScreenKeyPad] widget.
  const OnScreenKeyPad({
    super.key,
    this.enableHapticFeedback = false,
    this.hapticFeedbackType,
    this.keyPadding,
    this.keyShape = BoxShape.rectangle,
    this.keyCellSplashColor,
    this.keyCellHighlightColor,
    this.keyCellBackgroundColor,
    required this.onKeyPress,
    this.leftButtonAction,
    this.rightButtonAction,
    this.style,
  });

  /// Handles key presses and triggers the [onKeyPress] callback.
  void _handleKeyPress(String value) {
    if (value == "⌫") {
      onKeyPress("backspace");
    } else {
      onKeyPress(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          for (final keyRow in keyValues)
            TableRow(
              children: List.generate(
                keyRow.length,
                (index) {
                  final keyCell = keyRow[index];
                  if (keyCell == 'right') {
                    return rightButtonAction ?? const SizedBox.shrink();
                  }
                  if (keyCell == 'left') {
                    return leftButtonAction ??
                        KeyCell.withChild(
                          enableHapticFeedback: enableHapticFeedback,
                          keyPadding: keyPadding,
                          keyShape: keyShape,
                          splashColor: keyCellSplashColor ?? Colors.transparent,
                          highlightColor:
                              keyCellHighlightColor ?? Colors.transparent,
                          backgroundColor: keyCellBackgroundColor,
                          value: "⌫",
                          onTap: (val) {
                            _handleKeyPress(val);
                          },
                          child: const Icon(
                            Icons.backspace,
                            color: Colors.black,
                          ),
                        );
                  }
                  return KeyCell(
                    enableHapticFeedback: enableHapticFeedback,
                    keyPadding: keyPadding,
                    keyShape: keyShape,
                    splashColor: keyCellSplashColor,
                    highlightColor: keyCellHighlightColor,
                    backgroundColor: keyCellBackgroundColor,
                    value: keyCell,
                    onTap: (val) {
                      _handleKeyPress(val);
                    },
                    style: style,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// A single key cell used in the [OnScreenKeyPad].
///
/// This widget represents a numeric key or special function key (e.g., backspace).
class KeyCell extends StatelessWidget {
  /// Type of haptic feedback to apply when the key is pressed.
  final HapticFeedbackType? hapticFeedbackType;

  /// Enables or disables haptic feedback.
  final bool enableHapticFeedback;

  /// Padding around the key.
  final EdgeInsets? keyPadding;

  /// The shape of the key (rectangle or circle).
  final BoxShape keyShape;

  /// Splash color effect on tap.
  final Color? splashColor;

  /// Highlight color effect on tap.
  final Color? highlightColor;

  /// Background color of the key.
  final Color? backgroundColor;

  /// Callback triggered when the key is tapped.
  final void Function(String)? onTap;

  /// Optional child widget inside the key (e.g., an icon).
  final Widget? child;

  /// The text value of the key.
  final String value;

  /// Indicates if the key has a child widget.
  final bool _hasChild;

  /// Text style for the key value.
  final TextStyle? style;

  /// Creates a standard numeric key.
  const KeyCell({
    super.key,
    this.enableHapticFeedback = false,
    this.keyPadding,
    required this.keyShape,
    this.splashColor,
    this.highlightColor,
    this.backgroundColor,
    this.onTap,
    required this.value,
    this.style,
    this.hapticFeedbackType,
  })  : child = const Offstage(),
        _hasChild = false;

  /// Creates a key with a custom child widget (e.g., an icon).
  const KeyCell.withChild({
    super.key,
    this.enableHapticFeedback = false,
    this.keyPadding,
    required this.keyShape,
    this.splashColor,
    this.highlightColor,
    this.backgroundColor,
    this.onTap,
    this.child,
    required this.value,
    this.style,
    this.hapticFeedbackType,
  }) : _hasChild = true;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: splashColor ?? Colors.transparent,
      highlightColor: highlightColor ?? Colors.transparent,
      key: Key(value),
      onTap: () {
        if (enableHapticFeedback) {
          switch (hapticFeedbackType) {
            case HapticFeedbackType.lightImpact:
              HapticFeedback.lightImpact();
              break;
            case HapticFeedbackType.mediumImpact:
              HapticFeedback.mediumImpact();
              break;
            case HapticFeedbackType.heavyImpact:
              HapticFeedback.heavyImpact();
              break;
            case HapticFeedbackType.selectionClick:
              HapticFeedback.selectionClick();
              break;
            default:
              HapticFeedback.lightImpact();
          }
        }
        onTap?.call(value);
      },
      child: Container(
        decoration: BoxDecoration(
          shape: keyShape,
          color: backgroundColor ?? Colors.white,
        ),
        padding: keyPadding ?? const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        child: Center(
          child: _hasChild
              ? child
              : Text(
                  value,
                  textAlign: TextAlign.center,
                  style: style ?? const TextStyle(fontSize: 40, color: Colors.black),
                ),
        ),
      ),
    );
  }
}

/// Defines different types of haptic feedback for key presses.
enum HapticFeedbackType {
  /// Light vibration effect.
  lightImpact,

  /// Medium vibration effect.
  mediumImpact,

  /// Strong vibration effect.
  heavyImpact,

  /// Short click effect.
  selectionClick,

  /// Success notification haptic feedback.
  notificationSuccess,

  /// Warning notification haptic feedback.
  notificationWarning,

  /// Error notification haptic feedback.
  notificationError
}

/// Defines the layout of the keypad with numbers and special keys.
List<List<String>> get keyValues {
  return [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['left', '0', 'right'],
  ];
}
