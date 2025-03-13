import 'package:flutter/services.dart';
import 'package:flutter/material.dart';


class OnScreenKeyPad extends StatelessWidget {
  final bool enableHapticFeedback;
  final HapticFeedbackType? hapticFeedbackType;
  final EdgeInsets? keyPadding;
  final BoxShape keyShape;
  final Color? keyCellSplashColor;
  final Color? keyCellHighlightColor;
  final Color? keyCellBackgroundColor;
  final void Function(String) onKeyPress;
  final Widget? leftButtonAction;
  final Widget? rightButtonAction;
  final TextStyle? style;

  const OnScreenKeyPad({super.key,
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

  void _handleKeyPress(String value) {
    if (onKeyPress != null) {
      if (value == "⌫") {
        onKeyPress("backspace"); 
      } else {
        onKeyPress!(value);import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// A customizable on-screen keypad widget for Flutter.
class OnScreenKeyPad extends StatelessWidget {
  /// Enables haptic feedback on keypress.
  final bool enableHapticFeedback;

  /// Defines the type of haptic feedback to use.
  final HapticFeedbackType? hapticFeedbackType;

  /// Padding for each key.
  final EdgeInsets? keyPadding;

  /// Shape of each key (default is rectangle).
  final BoxShape keyShape;

  /// Splash color when a key is pressed.
  final Color? keyCellSplashColor;

  /// Highlight color when a key is pressed.
  final Color? keyCellHighlightColor;

  /// Background color for each key.
  final Color? keyCellBackgroundColor;

  /// Callback function triggered when a key is pressed.
  final void Function(String) onKeyPress;

  /// Widget displayed on the left action button (e.g., backspace icon).
  final Widget? leftButtonAction;

  /// Widget displayed on the right action button.
  final Widget? rightButtonAction;

  /// Text style for the key labels.
  final TextStyle? style;

  /// Constructor for the on-screen keypad.
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

  /// Handles keypress events, including backspace functionality.
  void _handleKeyPress(String value) {
    if (value == "backspace") { // Unicode for backspace symbol
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
              children: keyRow.map((keyCell) {
                if (keyCell == 'right') {
                  return rightButtonAction ?? SizedBox.shrink();
                }
                if (keyCell == 'left') {
                  return leftButtonAction ??
                      KeyCell.withChild(
                        enableHapticFeedback: enableHapticFeedback,
                        keyPadding: keyPadding,
                        keyShape: keyShape,
                        splashColor: keyCellSplashColor,
                        highlightColor: keyCellHighlightColor,
                        backgroundColor: keyCellBackgroundColor,
                        value: "backspace", // Unicode for backspace symbol
                        onTap: _handleKeyPress,
                        child: Icon(Icons.backspace, color: Colors.black),
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
                  onTap: _handleKeyPress,
                  style: style,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

/// A single key widget used inside the keypad.
class KeyCell extends StatelessWidget {
  final HapticFeedbackType? hapticFeedbackType;
  final bool enableHapticFeedback;
  final EdgeInsets? keyPadding;
  final BoxShape keyShape;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? backgroundColor;
  final void Function(String)? onTap;
  final Widget? child;
  final String value;
  final bool _hasChild;
  final TextStyle? style;

  /// Default constructor for a key without a child widget.
  KeyCell({
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
  })  : child = null,
        _hasChild = false;

  /// Constructor for a key with a custom child widget (e.g., backspace icon).
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
        padding: keyPadding ?? EdgeInsets.all(16),
        child: Center(
          child: _hasChild
              ? child
              : Text(
                  value,
                  textAlign: TextAlign.center,
                  style: style ?? TextStyle(fontSize: 40, color: Colors.black),
                ),
        ),
      ),
    );
  }
}

/// Defines the key layout for the on-screen keypad.
List<List<String>> get keyValues {
  return [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['left', '0', 'right'], // 'left' and 'right' represent special action buttons.
  ];
}

/// Enum representing different types of haptic feedback.
enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  notificationSuccess,
  notificationWarning,
  notificationError
}

      }
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
                    return rightButtonAction ?? SizedBox.shrink();
                  }
                  if (keyCell == 'left') {
                    return leftButtonAction ??
                        KeyCell.withChild(
                          enableHapticFeedback: enableHapticFeedback,
                          keyPadding: keyPadding,
                          keyShape: keyShape,
                          splashColor: keyCellSplashColor ?? Colors.transparent,
                          highlightColor: keyCellHighlightColor ?? Colors.transparent,
                          backgroundColor: keyCellBackgroundColor,
                          value: "⌫",  // Correct backspace value
                          onTap: (val) {
                            _handleKeyPress(val);
                          },
                          child: Icon(
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

class KeyCell extends StatelessWidget {
  final HapticFeedbackType? hapticFeedbackType;
  final bool enableHapticFeedback;
  final EdgeInsets? keyPadding;
  final BoxShape keyShape;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? backgroundColor;
  final void Function(String)? onTap;
  final Widget? child;
  final String value;
  final bool _hasChild;
  final TextStyle? style;

  KeyCell({super.key,
    this.enableHapticFeedback = false,
    this.keyPadding,
    required this.keyShape,
    this.splashColor,
    this.highlightColor,
    this.backgroundColor,
    this.onTap,
    required this.value,
    this.style, this.hapticFeedbackType,
  })  : child = Offstage(),
        _hasChild = false;

  const KeyCell.withChild({super.key,
    this.enableHapticFeedback = false,
    this.keyPadding,
    required this.keyShape,
    this.splashColor,
    this.highlightColor,
    this.backgroundColor,
    this.onTap,
    this.child,
    required this.value,
    this.style, this.hapticFeedbackType,
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
          HapticFeedback.lightImpact();
        }
        if (onTap != null) {
          onTap!(value);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          shape: keyShape,
          color: backgroundColor ?? Colors.white,
        ),
        padding: keyPadding ?? EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        child:Center(
          child: _hasChild
              ? child
              : Text(
            value,
            textAlign: TextAlign.center,
            style: style ?? TextStyle(fontSize: 40,color: Colors.black),
          ),
        ),
      ),
    );
  }
}

List<List<String>> get keyValues {
  return [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['left', '0', 'right'],
  ];
}

enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  notificationSuccess,
  notificationWarning,
  notificationError
}
