import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:postojka/main.dart';
import 'package:postojka/models/BusStopLine.dart';
import 'package:postojka/screens/bus_line_detail_screen.dart';
import 'package:postojka/screens/bus_stop_detail_screen.dart';
import 'dart:convert';

import '../models/BusLine.dart';
import '../models/BusRoute.dart';
import '../models/BusStop.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class HttpService with ChangeNotifier {
  final String baseUrl = 'http://info.skopska.mk:8080';
  final String tokenHeaderKey = "Eurogps.Eu.Sid";
  String? token;

  //Used to execute the fetchToken method every X seconds
  Timer? _timer;
  bool voiceAssistantMode = false;
  stt.SpeechToText speech = stt.SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  bool isListening = false;
  bool isInitialized = false;
  String command = '';

  int currentIndex = 0;

  void setCurrentIndex(int index) {
  currentIndex = index;
  notifyListeners(); 
}

  void setVoiceAssistantMode(bool voiceAssistantMode) {
    this.voiceAssistantMode = voiceAssistantMode;
    print(this.voiceAssistantMode);
    notifyListeners();
  }

  bool isVoiceNavigationEnabled = false;

  void toggleVoiceNavigation() {
    isVoiceNavigationEnabled = !isVoiceNavigationEnabled;
    notifyListeners(); // Notify listeners about the change.
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  void setTTSEngine() async {
    await flutterTts.setEngine("com.github.olga_yakovleva.rhvoice.android");
  }

  Future<void> initSpeechRecognition() async {
    bool available = await speech.initialize();
    if (available) {
      isInitialized = true; // Set this to true if initialization is successful
    } else {
      // Handle the error as needed, maybe show a dialog or toast message
    }
  }

  void handleCommand(String command, BuildContext context) {
    // For bus lines when the BusLinesScreen is open
    RegExp regExp = RegExp(r'(\d+)');
    Match? match = regExp.firstMatch(command);
    if (match != null && currentIndex == 0) {
      // Check if the recognized command is a number AND the BusLinesScreen is currently open
      String number = match.group(1)!;
      openBusLine(int.parse(number), context);
    }

    // For bus stops when the BusStopsScreen is open:
    RegExp regExpStop = RegExp(r'(\d+)');
    Match? matchStop = regExpStop.firstMatch(command);
    if (matchStop != null && currentIndex == 1) {
      String stopNumber = matchStop.group(1)!;
      openBusStop(stopNumber, context);
    }

    List<String> line_values = ["лигња", "инија", "инии", "limi"];
    if (line_values.any((item) => command.toLowerCase().contains(item))) {
      print("Command contains Линии. Hooray!");
      speak("Успешно го отворивте менито Линии");
      setCurrentIndex(0);
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
      print("Command contains постојки. Hooray!");
      speak("Успешно го отворивте менито Постојки");
      setCurrentIndex(1);
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
      print("Command contains рути. Hooray!");
    }

    List<String> helper_values = ["советник", "совет", "оветни"];
    if (helper_values.any((item) => command.toLowerCase().contains(item))) {
      print("Command contains советник. Hooray!");
    }
  }

  void openBusLine(int lineNumber, BuildContext context) {
    var targetLine = lines.firstWhere(
        (line) => line.name == 'ЛИНИЈА $lineNumber',
        orElse: () => BusLine.empty());

    if (targetLine.id != 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BusLineDetailScreen(
            line: targetLine,
            httpService: this,
          ),
        ),
      );
      speak(
          "Успешно го отворивте менито Линија $lineNumber. Оваа линија е од ${targetLine.type == 'URBAN' ? 'Градски' : 'Друг'} тип. Оператор на оваа линија е ${targetLine.carrier}.");
    } else {
      speak(
          "Не можев да најдам Линија $lineNumber. Ве молам обидете се повторно.");
    }
  }

  void openBusStop(String stopNumber, BuildContext context) {
    var targetStop = stops.firstWhere((stop) => stop.number == stopNumber,
        orElse: () => BusStop.empty());

    if (targetStop.id != 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BusStopDetailScreen(busStop: targetStop),
        ),
      );
      speak("Успешно ја отворивте постојката со број $stopNumber");
    } else {
      speak(
          "Не можев да ја најдам постојката со број $stopNumber. Ве молам обидете се повторно.");
    }
  }

  void startListening(BuildContext context) {
    if (!isListening && isInitialized) {
      speech.listen(
        listenFor: Duration(seconds: 3),
        onResult: (result) {
          print("This is the result: " + result.recognizedWords);
            command = result.recognizedWords;
          handleCommand(result.recognizedWords, context);
        },
        localeId: 'mk_MK',
      );
      isListening = true;

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
    }
  }

  Widget voiceAssistantButton(BuildContext context) {
    return voiceAssistantMode
        ? Container(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                if (isListening) {
                  stopListening();
                } else {
                  startListening(context);
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

  HttpService() {
    fetchToken();
    setTTSEngine();
    initSpeechRecognition();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      print("EXECUTED TIMER");
      fetchBusStopLines();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<BusRoute> routes = [];
  List<BusLine> lines = [];
  List<BusStop> stops = [];
  List<BusStopLine> busStopLines = [];

  List<BusRoute> favoriteRoutes = [];
  List<BusLine> favoriteLines = [];
  List<BusStop> favoriteStops = [];

  // Check if a line is a favorite
  bool isLineFavorite(BusLine line) {
    return favoriteLines.any((existingLine) => existingLine.id == line.id);
  }

  // Toggle the favorite status of a line
  void toggleFavoriteLine(BusLine line) {
    if (isLineFavorite(line)) {
      removeFavoriteLine(line);
    } else {
      addFavoriteLine(line);
    }
  }

  // Add a favorite route
  void addFavoriteRoute(BusRoute route) {
    if (!favoriteRoutes.any((existingRoute) => existingRoute.id == route.id)) {
      favoriteRoutes.add(route);
      notifyListeners();
    }
  }

  // Remove a favorite route
  void removeFavoriteRoute(BusRoute route) {
    favoriteRoutes.remove(route);
    notifyListeners();
  }

  // Add a favorite line
  void addFavoriteLine(BusLine line) {
    if (!favoriteLines.any((existingLine) => existingLine.id == line.id)) {
      favoriteLines.add(line);
      notifyListeners();
    }
  }

  // Remove a favorite line
  void removeFavoriteLine(BusLine line) {
    favoriteLines.remove(line);
    notifyListeners();
  }

  // Add a favorite stop
  void addFavoriteStop(BusStop stop) {
    if (!favoriteStops.any((existingStop) => existingStop.id == stop.id)) {
      favoriteStops.add(stop);
      notifyListeners();
    }
  }

  // Remove a favorite stop
  void removeFavoriteStop(BusStop stop) {
    favoriteStops.remove(stop);
    notifyListeners();
  }

  BusRoute findRouteById(int id) {
    return routes.firstWhere((route) => route.id == id,
        orElse: () => BusRoute.empty());
  }

  BusLine findLineById(int id) {
    return lines.firstWhere((line) => line.id == id,
        orElse: () => BusLine.empty());
  }

  void fetchToken() async {
    final response = await http.post(
      Uri.parse('$baseUrl/rest-auth/guests?aid=3136'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      token = json.decode(response.body);
      if (token is String) {
        print("Token is set in http_service to: " + (this.token ?? " null"));
      } else {
        throw Exception('Failed to fetch token');
      }
    } else {
      print("Request to fetch token failed");
    }

    routes = await fetchRoutes();
    lines = await fetchLines();
    stops = await fetchStops();
    busStopLines = await fetchBusStopLines();
    print("Data Loaded Successfully");
    notifyListeners();
  }

  Future<List<BusRoute>> fetchRoutes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rest-its/scheme/routes'),
      headers: {
        "Content-Type": "application/json",
        tokenHeaderKey: token ?? ""
      },
    );
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<BusRoute>((json) => BusRoute.fromJson(json)).toList();
  }

  Future<List<BusLine>> fetchLines() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rest-its/scheme/lines'),
      headers: {
        "Content-Type": "application/json",
        tokenHeaderKey: token ?? ""
      },
    );

    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<BusLine>((json) => BusLine.fromJson(json)).toList();
  }

  Future<List<BusStop>> fetchStops() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rest-its/scheme/stops?filter=true'),
      headers: {
        "Content-Type": "application/json",
        tokenHeaderKey: token ?? ""
      },
    );

    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<BusStop>((json) => BusStop.fromJson(json)).toList();
  }

  Future<List<BusStopLine>> fetchBusStopLines() async {
    final response = await http.get(
      Uri.parse("$baseUrl/rest-its/scheme/stop-lines"),
      headers: {
        "Content-Type": "application/json",
        tokenHeaderKey: token ?? ""
      },
    );

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);
      return parsed
          .map<BusStopLine>((json) => BusStopLine.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch BusStopLines');
    }
  }
}
