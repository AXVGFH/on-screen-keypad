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
  onscreen_keypad: ^1.0.3
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
void main() {
  runApp(const KeypadExampleApp());
}

class KeypadExampleApp extends StatelessWidget {
  const KeypadExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onscreen Keypad Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const KeypadDemoScreen(),
    );
  }
}

class KeypadDemoScreen extends StatefulWidget {
  const KeypadDemoScreen({super.key});

  @override
  State<KeypadDemoScreen> createState() => _KeypadDemoScreenState();
}

class _KeypadDemoScreenState extends State<KeypadDemoScreen> {
  String _enteredText = '';
  final TextEditingController _controller = TextEditingController();

  void _onKeyPress(String value) {
    setState(() {
      if (value == 'backspace') {
        if (_enteredText.isNotEmpty) {
          _enteredText = _enteredText.substring(0, _enteredText.length - 1);
        }
      } else {
        _enteredText += value;
      }
      _controller.text = _enteredText; // Update controller text
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length), // Move cursor to end
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onscreen Keypad Test')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Input Field',
              ),
              readOnly: true, // Ensures input comes only from the keypad
              controller: _controller,
            ),
            const SizedBox(height: 20),
            OnScreenKeyPad(
              onKeyPress: _onKeyPress,
              enableHapticFeedback: true,
            ),
          ],
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

