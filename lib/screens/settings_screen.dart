import 'package:flutter/material.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/services/http_service.dart';
import 'package:postojka/widgets/toggle_assistant.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final httpService = Provider.of<HttpService>(context);
    httpService.setCurrentScreen(AppScreens.Settings);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Spoken Command: ${httpService.command}'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: httpService.isListening
                ? null
                : () => httpService.startListening(context),
            child: Text('Start Listening'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed:
                httpService.isListening ? httpService.stopListening : null,
            child: Text('Stop Listening'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            child: Text("Press to hear a voice"),
            onPressed: () {
              httpService.speak(
                  "Здраво, јас сум Никола, вашиот личен читач на информации.");
            },
          ),
          ToggleAssistant(
              voiceFunction: httpService.setVoiceAssistantMode,
              toggleValue: httpService.voiceAssistantMode),
          SwitchListTile(
            title: Text("Висок Контраст"),
            value:
                Provider.of<HttpService>(context, listen: false).isHighContrast,
            onChanged: (value) {
              Provider.of<HttpService>(context, listen: false).toggleTheme();
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
          )
        ],
      ),
    );
  }
}
