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
                          value: 'backspace',
                          onTap: (val) {
                            onKeyPress(val);
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
                      onKeyPress(val);
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
