import 'package:flutter/material.dart';

class ToggleAssistant extends StatefulWidget {
  Function voiceFunction;

  ToggleAssistant({required this.voiceFunction, required this.toggleValue});

  bool toggleValue;

  @override
  _ToggleAssistantState createState() => _ToggleAssistantState();
}

class _ToggleAssistantState extends State<ToggleAssistant> {
  bool _isAssistantOn = false; // Track the state of the toggle button

  @override
  Widget build(BuildContext context) {
    _isAssistantOn = widget.toggleValue;
    return SwitchListTile(
      title: Text("Гласовен Помошник"),
      value: _isAssistantOn,
      onChanged: (newValue) {
        setState(() {
          _isAssistantOn = newValue;
        });
        widget.voiceFunction(newValue);
        // Handle the logic here when the toggle state changes
      },
      activeColor: Colors.green,
      inactiveThumbColor: Colors.red,
    );
  }
}