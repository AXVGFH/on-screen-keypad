# Flutter Keypad Package

A customizable on-screen keypad widget for Flutter applications.

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_keypad_package: ^0.0.1
```

Then run:

```sh
flutter pub get
```

## Usage

Import the package:

```dart
import 'package:flutter_keypad_package/flutter_keypad_package.dart';
```

Use the `OnScreenKeyPad` widget:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_keypad_package/flutter_keypad_package.dart';

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

✅ Customizable keypad UI  
✅ Supports haptic feedback  
✅ Left and right action buttons  
✅ Custom styling support  

## Customization

You can customize the keypad using various properties:

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

