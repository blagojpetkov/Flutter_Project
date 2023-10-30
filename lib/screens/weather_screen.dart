import 'package:flutter/material.dart';
import 'package:postojka/services/voice_service.dart';
import 'package:provider/provider.dart';
import 'package:weather/weather.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _weatherFactory = WeatherFactory(
      "8965dc3c86e1cfce0a0693cf82281804",
      language: Language.MACEDONIAN);
  Weather? _weather;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  _loadWeather() async {
    try {
      final weather = await _weatherFactory.currentWeatherByCityName('Skopje');
      setState(() => _weather = weather);
      VoiceService voiceService =
          Provider.of<VoiceService>(context, listen: false);
      if (voiceService.voiceAssistantMode) {
        voiceService.speak(
            "Температурата денес е ${_weather!.temperature!.celsius!.toStringAsFixed(1)} степени целзиусови");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Временска прогноза во Скопје')),
      body: _weather == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                      'Температурата денес е ${_weather!.temperature!.celsius!.toStringAsFixed(1)} °C',
                      style: TextStyle(fontSize: 20),
                      ),
                  SizedBox(height: 20),
                  Text('Состојба на небото: ${_weather!.weatherDescription}',
                  style: TextStyle(fontSize: 20),),
                  SizedBox(height: 20),
                  Text(
                    'Влажност на воздухот: ${_weather!.humidity}%',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Ветар со брзина од ${_weather!.windSpeed} метри во секунда',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
    );
  }
}
