import 'package:flutter/material.dart';
import 'package:postojka/main.dart';
import 'package:postojka/models/BusLine.dart';
import 'package:postojka/models/BusStop.dart';
import 'package:postojka/screens/bus_line_detail_screen.dart';
import 'package:postojka/screens/bus_lines_screen.dart';
import 'package:postojka/screens/bus_stop_detail_screen.dart';
import 'package:postojka/screens/bus_stops_nearby_screen.dart';
import 'package:postojka/screens/bus_stops_screen.dart';
import 'package:postojka/screens/map_screen.dart';
import 'package:postojka/services/http_service.dart';
import 'package:postojka/widgets/favorites_tab_screen.dart';
import 'package:postojka/widgets/toggle_assistant.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  bool _isListening = false;
  bool _isInitialized = false;
  bool voiceAssistantMode = false;
  String _command = '';
  int _currentIndex = 0;

  void setVoiceAssistantMode(bool voiceAssistantMode) {
    setState(() {
      this.voiceAssistantMode = voiceAssistantMode;
    });
    print(this.voiceAssistantMode);
  }

  Widget homeScreenCenter() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Spoken Command: $_command'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isListening ? null : startListening,
            child: Text('Start Listening'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _isListening ? stopListening : null,
            child: Text('Stop Listening'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            child: Text("Press to hear a voice"),
            onPressed: () {
              speak(
                  "Здраво, јас сум Никола, вашиот личен читач на информации.");
            },
          ),
          ToggleAssistant(
              voiceFunction: setVoiceAssistantMode,
              toggleValue: voiceAssistantMode),
        ],
      ),
    );
  }

  List<Widget> get _pages => [
        BusLinesScreen(),
        BusStopsScreen(),
        FavoritesTabScreen(),
        MapScreen(),
        homeScreenCenter(),
      ];

  List<String> titles = ["Линии", "Постојки", "Омилени", "Circle", "Square"];


  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    _initSpeechRecognition();
    setTTSEngine();
  }

  void setTTSEngine() async {
    await flutterTts.setEngine("com.github.olga_yakovleva.rhvoice.android");
  }

  Future<void> _initSpeechRecognition() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isInitialized =
            true; // Set this to true if initialization is successful
      });
    } else {
      // Handle the error as needed, maybe show a dialog or toast message
    }
  }

  void handleCommand(String command) {
    // For bus lines when the BusLinesScreen is open
    RegExp regExp = RegExp(r'(\d+)');
    Match? match = regExp.firstMatch(command);
    if (match != null && _currentIndex == 0) {
      // Check if the recognized command is a number AND the BusLinesScreen is currently open
      String number = match.group(1)!;
      openBusLine(int.parse(number));
    }

    // For bus stops when the BusStopsScreen is open:
    RegExp regExpStop = RegExp(r'(\d+)');  
    Match? matchStop = regExpStop.firstMatch(command);
    if (matchStop != null && _currentIndex == 1) {
        String stopNumber = matchStop.group(1)!;
        openBusStop(stopNumber);
    }

    List<String> line_values = ["лигња", "инија", "инии", "limi"];
    if (line_values.any((item) => command.toLowerCase().contains(item))) {
      print("Command contains Линии. Hooray!");
      setState(() {
        _currentIndex = 0;
      });
      speak("Успешно го отворивте менито Линии");
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
      setState(() {
        _currentIndex = 1; // Set index for Постојки
      });
      speak("Успешно го отворивте менито Постојки");
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

  void openBusLine(int lineNumber) {
    var httpService = Provider.of<HttpService>(context, listen: false); 
    var targetLine = httpService.lines.firstWhere(
        (line) => line.name == 'ЛИНИЈА $lineNumber', 
        orElse: () => BusLine.empty()
    );

    if (targetLine.id != 0) {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => BusLineDetailScreen(line: targetLine, httpService: httpService,),
            ),
        );
        speak("Успешно го отворивте менито Линија $lineNumber. Оваа линија е од ${targetLine.type == 'URBAN' ? 'Градски' : 'Друг'} тип. Оператор на оваа линија е ${targetLine.carrier}.");
        


    } else {
        speak("Не можев да најдам Линија $lineNumber. Ве молам обидете се повторно.");
    }
}

void openBusStop(String stopNumber) {
    var httpService = Provider.of<HttpService>(context, listen: false); 
    var targetStop = httpService.stops.firstWhere(
        (stop) => stop.number == stopNumber, 
        orElse: () => BusStop.empty()
    );

    if (targetStop.id != 0) {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => BusStopDetailScreen(busStop: targetStop),
            ),
        );
        speak("Успешно ја отворивте постојката со број $stopNumber");
    } else {
        speak("Не можев да ја најдам постојката со број $stopNumber. Ве молам обидете се повторно.");
    }
}



  void startListening() {
    setState(() {
      _command = '';
    });
    if (!_isListening && _isInitialized) {
      _speech.listen(
        listenFor: Duration(seconds: 3),
        onResult: (result) {
          print("This is the result: " + result.recognizedWords);
          setState(() {
            _command = result.recognizedWords;
          });
          handleCommand(result.recognizedWords);
        },
        localeId: 'mk_MK',
      );
      setState(() {
        _isListening = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        if (_isListening) {
          stopListening();
        }
      });
    }
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.navBarColor,
        leading: Padding(
          padding: EdgeInsets.only(left: 8.0), // Adjust the value as needed
          child: Image.asset('assets/bus.png'),
        ),
        elevation: 4.0,
        title: Text(
          titles[_currentIndex],
          style: TextStyle(fontSize: 20),
        ),
        actions: _currentIndex == 1
            ? [
                IconButton(
                  icon: Icon(Icons.map),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusStopsNearbyScreen(),
                      ),
                    );
                  },
                ),
              ]
            : [],
      ),
      body: Stack(
        children: [
          _pages[_currentIndex],
          Align(
            alignment: Alignment.bottomCenter,
            child: _voiceAssistantButton(),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.color4,
        unselectedItemColor: AppColors.primaryBackground,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'Линии',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pin_drop),
            label: 'Постојки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Омилени',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: 'Circle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.square),
            label: 'Square',
          ),
        ],
      ),
    );
  }
}
