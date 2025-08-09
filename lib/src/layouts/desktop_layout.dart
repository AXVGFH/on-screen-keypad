import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_onscreen_keyboard/src/constants/action_key_type.dart';

/// A complete QWERTY desktop keyboard layout excluding the number pad.
///
/// This layout includes rows of alphabetic keys, number keys, symbols,
/// and common action keys like backspace, tab, capslock, enter, and shift.
///
/// Use this layout with [OnscreenKeyboard] for a desktop-style experience.
class DesktopKeyboardLayout extends KeyboardLayout {
  /// Creates a [DesktopKeyboardLayout] instance.
  const DesktopKeyboardLayout();

  @override
  double get aspectRatio => 5 / 2;

  @override
  Map<String, KeyboardMode> get modes => {
    'default': KeyboardMode(rows: _defaultMode),
  };

 List<KeyboardRow> get _defaultMode => [
        // الصف العلوي: 7 8 9
        const KeyboardRow(
          keys: [
            OnscreenKeyboardKey.text(primary: '7'),
            OnscreenKeyboardKey.text(primary: '8'),
            OnscreenKeyboardKey.text(primary: '9'),
          ],
        ),
        // الصف الثاني: 4 5 6
        const KeyboardRow(
          keys: [
            OnscreenKeyboardKey.text(primary: '4'),
            OnscreenKeyboardKey.text(primary: '5'),
            OnscreenKeyboardKey.text(primary: '6'),
          ],
        ),
        // الصف الثالث: 1 2 3
        const KeyboardRow(
          keys: [
            OnscreenKeyboardKey.text(primary: '1'),
            OnscreenKeyboardKey.text(primary: '2'),
            OnscreenKeyboardKey.text(primary: '3'),
          ],
        ),
        // الصف الرابع: 0، نقطة، حذف
        const KeyboardRow(
          keys: [
            OnscreenKeyboardKey.text(primary: '0'),
            OnscreenKeyboardKey.text(primary: '.'),
            OnscreenKeyboardKey.action(
              name: ActionKeyType.backspace,
              child: Icon(Icons.backspace_outlined),
            ),
          ],
        ),
        // صف إضافي اختياري: زر مسافة (لإدخال مسافة إن لزم)
        // أو يمكن حذفه إذا كنت تريد فقط أرقام ونقطة وحذفًا
      ];
}
