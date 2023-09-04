import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:postojka/main.dart';
import 'package:postojka/models/BusStopLine.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/screens/bus_line_detail_screen.dart';
import 'package:postojka/screens/bus_stop_detail_screen.dart';
import 'dart:convert';

import '../models/BusLine.dart';
import '../models/BusRoute.dart';
import '../models/BusStop.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class HttpService with ChangeNotifier {
  late ThemeData _currentTheme;
  bool _isHighContrast = false;

  final String baseUrl = 'http://info.skopska.mk:8080';
  final String tokenHeaderKey = "Eurogps.Eu.Sid";
  String? token;

  int entityId = -1; // The ID of the line / route / stop

  void setEntityId(int entityId) {
    this.entityId = entityId;
  }

  //Used to execute the fetchToken method every X seconds
  Timer? _timer;
  bool voiceAssistantMode = false;
  stt.SpeechToText speech = stt.SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  bool isListening = false;
  bool isInitialized = false;
  String command = '';

  int currentIndex = 0;
  AppScreens currentScreen = AppScreens.BusLines;

  void setCurrentScreen(AppScreens screen) {
    currentScreen = screen;
    print("Current screen is " + currentScreen.toString());
  }

  void setCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

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

  List<BusStop> getStopsForRoute() {
    BusRoute route = routes.firstWhere((route) => route.id == entityId);
    return stops.where((stop) => route.stopIds.contains(stop.id)).toList();
  }

  void handleCommand(String command, BuildContext context) {
    // For bus lines when the BusLinesScreen is open
    RegExp regExp = RegExp(r'(\d+)');
    Match? match = regExp.firstMatch(command);
    if (match != null &&
        currentIndex == 0 &&
        currentScreen == AppScreens.BusLines) {
      // Check if the BusLinesScreen is currently open
      String number = match.group(1)!;
      openBusLine(int.parse(number), context);
    }

    // For bus stops when the BusStopsScreen is open:
    regExp = RegExp(r'(\d+)');
    match = regExp.firstMatch(command);
    if (match != null && currentIndex == 1) {
      String stopNumber = match.group(1)!;
      openBusStop(stopNumber, context);
    }
    //For when bus route detail screen is open
    match = regExp.firstMatch(command);
    if (match != null && currentScreen == AppScreens.BusRouteDetail) {
      int stopNumber = int.parse(match.group(1)!);
      List<BusStop> stopsForThisRoute = getStopsForRoute();

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

    List<String> line_values = ["лигња", "инија", "инии", "limi"];
    if (line_values.any((item) => command.toLowerCase().contains(item))) {
      // print("Command contains Линии.");
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
      // print("Command contains постојки.");
      setCurrentIndex(1);
    }

    List<String> favorite_values = [
      "омилен",
      "милен",
      "омилено",
      "омилени",
    ];

    if (favorite_values.any((item) => command.toLowerCase().contains(item))) {
      // print("Command contains постојки.");
      setCurrentIndex(2);
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

    List<String> helper_values = ["советник", "совет", "оветни"];
    if (helper_values.any((item) => command.toLowerCase().contains(item))) {
      print("Command contains советник.");
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
          notifyListeners();
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
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                stopSpeaking();
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

  getTheme() => _currentTheme;
  bool get isHighContrast => _isHighContrast;

  toggleTheme() {
    if (_isHighContrast) {
      _currentTheme = buildAppTheme();
      _isHighContrast = false;
    } else {
      _currentTheme = buildHighContrastTheme();
      _isHighContrast = true;
    }
    notifyListeners();
  }

   ThemeData buildHighContrastTheme() {
    return ThemeData(
      primaryColor: Colors.black,
      colorScheme: ColorScheme.dark(
        primary: Colors.white,
        secondary: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.black,
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.white,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  ThemeData buildAppTheme() {
  return ThemeData(
    primaryColor: AppColors.primaryBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.color4,
      secondary: AppColors.accentColor1, 
    ),
    scaffoldBackgroundColor: AppColors.primaryBackground,
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.color4,
      textTheme: ButtonTextTheme.primary, // This will ensure button text is readable against the button color
    ),
    // ... Add other ThemeData properties as needed
  );
}

  HttpService() {
    _currentTheme = buildAppTheme();
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
