import 'package:flutter/material.dart';
import 'package:onscreen_keypad/on_screen_keypad.dart';  

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keypad Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const KeypadExampleScreen(),
    );
  }
}

class KeypadExampleScreen extends StatefulWidget {
  const KeypadExampleScreen({super.key});

  @override
  State<KeypadExampleScreen> createState() => _KeypadExampleScreenState();
}

class _KeypadExampleScreenState extends State<KeypadExampleScreen> {
  String _enteredText = '';
  final TextEditingController _controller = TextEditingController();

  void _onKeyPress(String value) {
    setState(() {
      if (value == 'backspace' && _enteredText.isNotEmpty) {
        _enteredText = _enteredText.substring(0, _enteredText.length - 1);
      } else if (value != 'backspace') {
        _enteredText += value;
      }
      _controller.text = _enteredText;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onscreen Keypad Example')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Input Field',
              ),
            ),
          ),
          OnScreenKeyPad(
            onKeyPress: _onKeyPress,
            keyCellBackgroundColor: Colors.amber,
            enableHapticFeedback: true,
          ),
        ],
      ),
    );
  }
}
