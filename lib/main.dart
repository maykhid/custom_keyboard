import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Keyboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FocusNode _focus = FocusNode();
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
    _focus
      ..removeListener(_onFocusChange)
      ..dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextField(
            controller: textController,
            keyboardType: TextInputType.none,
            focusNode: _focus,
          ),
          const Spacer(),
          _focus.hasFocus
              ? NumericKeypad(
                  controller: textController,
                  focusNode: _focus,
                )
              : Container(),
        ],
      )),
    );
  }
}

class NumericKeypad extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const NumericKeypad(
      {super.key, required this.controller, required this.focusNode});

  @override
  State<NumericKeypad> createState() => _NumericKeypadState();
}

class _NumericKeypadState extends State<NumericKeypad> {
  late TextEditingController _controller;
  late TextSelection _selection;
  late FocusNode _focusNode;
  String temp = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller..addListener(_onSelectionChanged);
    _selection = _controller.selection;
    _focusNode = widget.focusNode;
  }

  @override
  void dispose() {
    _controller.removeListener(_onSelectionChanged);
    super.dispose();
  }

  void _onSelectionChanged() {
    setState(() {
      _selection = _controller.selection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildButton('1'),
            _buildButton('2'),
            _buildButton('3'),
          ],
        ),
        Row(
          children: [
            _buildButton('4'),
            _buildButton('5'),
            _buildButton('6'),
          ],
        ),
        Row(
          children: [
            _buildButton('7'),
            _buildButton('8'),
            _buildButton('9'),
          ],
        ),
        Row(
          children: [
            _buildButton('⇓', onPressed: _hideKeyboard),
            _buildButton('0'),
            _buildButton('⌫', onPressed: _backspace),
          ],
        ),
      ],
    );
  }

  _hideKeyboard() => _focusNode.unfocus();

  Widget _buildButton(String text, {VoidCallback? onPressed}) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed ?? () => _input(text),
        child: Text(text),
      ),
    );
  }

  void _input(String text) {
    int position = _selection.base.offset;

    var value = _controller.text;
    if (value.isNotEmpty) {
      var suffix = value.substring(position, value.length);
      value = value.substring(0, position) + text + suffix;
      _controller.text = value;
      _controller.selection =
          TextSelection.fromPosition(TextPosition(offset: position + 1));
    } else {
      value = _controller.text + text;
      _controller.text = value;
      _controller.selection =
          TextSelection.fromPosition(const TextPosition(offset: 1));
    }
  }

  void _backspace() {
    int position = _selection.base.offset;
    final value = _controller.text;
    if (value.isNotEmpty && position != 0) {
      var suffix = value.substring(position, value.length);
      _controller.text = value.substring(0, position - 1) + suffix;

      _controller.selection =
          TextSelection.fromPosition(TextPosition(offset: position - 1));
    }
  }
}
