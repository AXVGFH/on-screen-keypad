# Onscreen Keyboard

A customizable on-screen keyboard widget for Flutter applications.

## Installation

### **Using `flutter pub add`**
Run the following command in your terminal:

```sh
flutter pub add onscreen_keypad
```

### **Or manually add it to `pubspec.yaml`**
```yaml
dependencies:
  onscreen_keypad: ^0.0.1+1
```

Then run:

```sh
flutter pub get
```

## Usage

Import the package:

```dart
import 'package:onscreen_keypad/onscreen_keypad.dart';
```

Use the `OnScreenKeyPad` widget:

```dart
import 'package:flutter/material.dart';
import 'package:onscreen_keypad/onscreen_keypad.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KeyPad Demo',
      home: Scaffold(
        appBar: AppBar(title: Text('KeyPad Demo')),
        body: Center(
          child: OnScreenKeyPad(
            onKeyPress: (val) {
              print('Key pressed: $val');
            },
          ),
        ),
      ),
    );
  }
}
```

## Features

✅ Customizable keyboard UI  
✅ Supports haptic feedback  
✅ Left and right action buttons  
✅ Custom styling support  

## Use Cases

- Numeric input fields (e.g., PIN entry, calculator, ATM interface)
- Custom keyboard requirements in apps where the default keyboard is not ideal
- Kiosk applications requiring an on-screen input solution
- Accessibility features for users needing a specialized input method

## Customization

You can customize the keyboard using various properties:

```dart
OnScreenKeyPad(
  enableHapticFeedback: true,
  keyPadding: EdgeInsets.all(8.0),
  keyCellBackgroundColor: Colors.grey[300],
  keyCellHighlightColor: Colors.blueAccent,
  keyCellSplashColor: Colors.blue,
  onKeyPress: (val) {
    print('Key pressed: $val');
  },
);
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on [GitHub](https://github.com/yourusername/flutter_keypad_package).

## License

MIT License - See the [LICENSE](LICENSE) file for details.

