import 'package:flutter/material.dart';
import 'package:postojka/screens/bus_alarm_screen.dart';
import 'package:postojka/screens/camera_screen.dart';
import 'package:postojka/screens/weather_screen.dart';
import 'package:postojka/services/theme_service.dart';
import 'package:postojka/services/voice_service.dart';
import 'package:postojka/widgets/toggle_assistant.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.8;
    final voiceService = Provider.of<VoiceService>(context);
    if (voiceService.voiceAssistantMode) {
      voiceService.speak("Успешно го отворивте менито поставки");
      print("Успешно го отворивте менито поставки");
    }
    return Center(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 30),
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
          SizedBox(height: 50),
          Container(
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(),
                  ),
                );
              },
              child: Text('Camera Text Recognition'),
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WeatherScreen(),
                  ),
                );
              },
              child: Text('Weather'),
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: () async {
                print("Pressing haptic button");
                if (await Vibration.hasVibrator() != null) {
                  Vibration.vibrate();
                }
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => BusAlarmScreen(),
                //   ),
                // );
              },
              child: Text('Alarm'),
            ),
          ),
        ],
      ),
    );
  }
}
