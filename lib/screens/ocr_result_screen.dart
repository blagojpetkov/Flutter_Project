import 'package:flutter/material.dart';
import 'package:postojka/services/theme_service.dart';
import 'package:postojka/services/voice_service.dart';
import 'package:provider/provider.dart';

class OCRResultScreen extends StatelessWidget {
  final String text;
  const OCRResultScreen({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    ThemeService themeService = Provider.of<ThemeService>(context);
    VoiceService voiceService = Provider.of<VoiceService>(context, listen: false);
    if (voiceService.voiceAssistantMode) {
      voiceService.speak(text);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Text Recognition', style: TextStyle(fontSize: 20.0)),
      ),
      body: Center(
        child: Text(text),
      ),
    );
  }
}
