import 'package:flutter/material.dart';
import 'package:postojka/main.dart';
import 'package:postojka/models/BusLine.dart';
import 'package:postojka/models/BusRoute.dart';
import 'package:postojka/models/BusStop.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/screens/bus_line_detail_screen.dart';
import 'package:postojka/screens/bus_route_detail_screen.dart';
import 'package:postojka/screens/bus_stop_detail_screen.dart';
import 'package:postojka/services/http_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService with ChangeNotifier {
  final HttpService httpService;

  VoiceService(this.httpService){
    setTTSEngine();
    initSpeechRecognition();
  }

  bool voiceAssistantMode = false;
  stt.SpeechToText speech = stt.SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  bool isListening = false;
  bool isInitialized = false;
  String command = '';

  

  void setVoiceAssistantMode(bool voiceAssistantMode) {
    this.voiceAssistantMode = voiceAssistantMode;
    print(this.voiceAssistantMode);
    notifyListeners();
  }

  Future<void> speak(String text) async {
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await flutterTts.stop();
  }

  void setTTSEngine() async {
    await flutterTts.setEngine("com.github.olga_yakovleva.rhvoice.android");
  }

  Future<void> initSpeechRecognition() async {
    bool available = await speech.initialize();
    if (available) {
      isInitialized = true;
    } else {
      // Handle the error
    }
  }

  void handleCommand(String command, BuildContext context, AppScreens currentScreen) {
    // For bus lines when the BusLinesScreen is open
    RegExp regExp = RegExp(r'(\d+)');
    Match? match = regExp.firstMatch(command);
    if (match != null &&
        httpService.currentIndex == 0 &&
        currentScreen == AppScreens.Home) {
      // Check if the BusLinesScreen is currently open
      String number = match.group(1)!;
      openBusLine(int.parse(number), context);
    }

    // For bus stops when the BusStopsScreen is open:
    regExp = RegExp(r'(\d+)');
    match = regExp.firstMatch(command);
    if (match != null && httpService.currentIndex == 1) {
      String stopNumber = match.group(1)!;
      openBusStop(stopNumber, context);
    }

    //For when bus line detail screen is open
    match = regExp.firstMatch(command);
    if (match != null &&
        currentScreen == AppScreens.BusLineDetail) {
      int routeNumber = int.parse(match.group(1)!);
      List<BusRoute> routesForThisLine = httpService.getRoutesForLine();

      if (routeNumber > 0 && routeNumber <= routesForThisLine.length) {
        // Navigate to the detail page of the bus stop
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusRouteDetailScreen(
              route: routesForThisLine[routeNumber - 1],
              allStops: httpService.stops,
              line: httpService.getLineForRoute(routesForThisLine[routeNumber - 1]),
            ),
          ),
        );
      } else {
        speak("Избраниот број не е валидна рута во оваа линија.");
      }
    }


    //For when bus route detail screen is open
    match = regExp.firstMatch(command);
    if (match != null &&
        currentScreen == AppScreens.BusRouteDetail) {
      int stopNumber = int.parse(match.group(1)!);
      List<BusStop> stopsForThisRoute = httpService.getStopsForRoute();

      if (stopNumber > 0 && stopNumber <= stopsForThisRoute.length) {
        // Navigate to the detail page of the bus stop
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusStopDetailScreen(
              busStop: stopsForThisRoute[stopNumber - 1],
            ),
          ),
        );
      } else {
        speak("Избраниот број не е валидна постојка во оваа рута.");
      }
    }

    List<String> go_back_values = ["зад", "назад"];
    if (go_back_values.any((item) => command.toLowerCase().contains(item))) {
      print("Command contains назад.");
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }

    List<String> line_values = [
      "лигња",
      "инија",
      "инии", 
      "limi"];
    if (line_values.any((item) => command.toLowerCase().contains(item))) {
      // print("Command contains Линии.");
      httpService.setCurrentIndex(0);
    }

    List<String> bus_stop_values = [
      "постојка",
      "постојки",
      "острици",
      "остојки",
      "постој",
      "пост"
    ];
    if (bus_stop_values.any((item) => command.toLowerCase().contains(item))) {
      // print("Command contains постојки.");
      httpService.setCurrentIndex(1);
    }

    List<String> favorite_values = [
      "омилен",
      "милен",
      "омилено",
      "омилени",
    ];

    if (favorite_values.any((item) => command.toLowerCase().contains(item))) {
      // print("Command contains постојки.");
      httpService.setCurrentIndex(2);
    }

    List<String> route_values = [
      "рут",
      "руд",
      "rut",
      "rud",
      "tutti",
      "fruthi",
      "fruithy"
    ];
    if (route_values.any((item) => command.toLowerCase().contains(item))) {
      print("Command contains рути.");
    }
  }

  void openBusLine(int lineNumber, BuildContext context) {
    var targetLine = httpService.lines.firstWhere(
        (line) => line.name == 'ЛИНИЈА $lineNumber',
        orElse: () => BusLine.empty());

    if (targetLine.id != 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BusLineDetailScreen(
            line: targetLine,
            httpService: httpService,
          ),
        ),
      );
    } else {
      speak(
          "Не можев да најдам Линија $lineNumber. Ве молам обидете се повторно.");
    }
  }

  void openBusStop(String stopNumber, BuildContext context) {
    var targetStop = httpService.stops.firstWhere((stop) => stop.number == stopNumber,
        orElse: () => BusStop.empty());

    if (targetStop.id != 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BusStopDetailScreen(busStop: targetStop),
        ),
      );
    } else {
      speak(
          "Не можев да ја најдам постојката со број $stopNumber. Ве молам обидете се повторно.");
    }
  }

  void startListening(BuildContext context, AppScreens screen) {
    if (!isListening && isInitialized) {
      speech.listen(
        listenFor: Duration(seconds: 3),
        onResult: (result) {
          print("This is the result: " + result.recognizedWords);
          command = result.recognizedWords;
          // notifyListeners();
          handleCommand(result.recognizedWords, context, screen);
        },
        localeId: 'mk_MK',
      );
      isListening = true;
      // notifyListeners();
      Future.delayed(Duration(seconds: 3), () {
        if (isListening) {
          stopListening();
        }
      });
    }
  }

  void stopListening() {
    if (isListening) {
      speech.stop();
      isListening = false;
      // notifyListeners();
    }
  }

  Widget voiceAssistantButton(BuildContext context, AppScreens screen) {
    return voiceAssistantMode
        ? Container(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                stopSpeaking();
                if (isListening) {
                  stopListening();
                } else {
                  startListening(context, screen);
                }
              },
              style: ElevatedButton.styleFrom(
                primary: AppColors.navBarColor, // Choose your color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              icon: Icon(Icons.mic, size: 30),
              label: Text("Voice Command"),
            ),
          )
        : SizedBox.shrink();
  }
}
