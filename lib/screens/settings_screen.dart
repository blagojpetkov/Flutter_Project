import 'package:flutter/material.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/screens/camera_screen.dart';
import 'package:postojka/screens/ocr_result_screen.dart';
import 'package:postojka/services/http_service.dart';
import 'package:postojka/services/theme_service.dart';
import 'package:postojka/services/voice_service.dart';
import 'package:postojka/widgets/toggle_assistant.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final voiceService = Provider.of<VoiceService>(context);
    if (voiceService.voiceAssistantMode) {
          voiceService.speak("Успешно го отворивте менито поставки");
          print("Успешно го отворивте менито поставки");
        }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Spoken Command: ${voiceService.command}'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: voiceService.isListening
                ? null
                : () =>
                    voiceService.startListening(context, AppScreens.Settings),
            child: Text('Start Listening'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed:
                voiceService.isListening ? voiceService.stopListening : null,
            child: Text('Stop Listening'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            child: Text("Press to hear a voice"),
            onPressed: () {
              voiceService.speak(
                  "Здраво, јас сум Никола, вашиот личен читач на информации.");
            },
          ),
          ToggleAssistant(
              voiceFunction: voiceService.setVoiceAssistantMode,
              toggleValue: voiceService.voiceAssistantMode),
          SwitchListTile(
            title: Text("Висок Контраст"),
            value: Provider.of<ThemeService>(context, listen: false)
                .isHighContrast,
            onChanged: (value) {
              Provider.of<ThemeService>(context, listen: false).toggleTheme();
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(),
                      ),
                    );
                  },
            child: Text('Camera Text Recognition'),
          ),
        ],
      ),
    );
  }
}
