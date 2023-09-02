import 'package:flutter/material.dart';
import 'package:postojka/screens/lines_screen.dart';
import 'package:postojka/screens/map_screen.dart';
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
  String _command = '';
  int _currentIndex = 0;

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
              _speak(
                  "Здраво, јас сум Никола, вашиот личен читач на информации.");
            },
          ),
          ElevatedButton(
            child: Text("Press to open the map"),
            onPressed: () {
              Navigator.of(context).pushNamed("/map");
            },
          )
        ],
      ),
    );
  }

  List<Widget> get _pages => [
        LinesScreen(),
        LinesScreen(),
        LinesScreen(),
        MapScreen(),
        homeScreenCenter(),
      ];

  Future<void> _speak(String text) async {
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
    // Make this method asynchronous
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
    List<String> menu_values = [
      "мен",
      "мели",
      "мени",
      "meli",
      "meni",
      "мени",
      "ени"
    ];

    if (menu_values.any((item) => command.toLowerCase().contains(item))) {
      print("Command contains Мени. Hooray!");
      // Open the menu or navigate to the menu screen
      // You can use Navigator to navigate to another screen
      _scaffoldKey.currentState?.openDrawer();
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
      // Open the menu or navigate to the menu screen
      // You can use Navigator to navigate to another screen
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
      // Open the menu or navigate to the menu screen
      // You can use Navigator to navigate to another screen
    }

    List<String> helper_values = ["советник", "совет", "оветни"];
    if (helper_values.any((item) => command.toLowerCase().contains(item))) {
      print("Command contains советник. Hooray!");
      // Open the menu or navigate to the menu screen
      // You can use Navigator to navigate to another screen
    }
    // Add more command handling logic as needed
  }

  void startListening() {
    setState(() {
      _command = '';
    });
    if (!_isListening && _isInitialized) {
      _speech.listen(
        listenFor: Duration(seconds: 2),
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

      Future.delayed(Duration(seconds: 2), () {
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
        leading: Padding(
          padding: EdgeInsets.only(left: 8.0), // Adjust the value as needed
          child: Image.asset('assets/bus.png'),
        ),
        elevation: 4.0,
        title: Text(
          'Постојка - Секогаш на време!',
          style: TextStyle(fontSize: 20),
        ),
        actions: <Widget>[],
      ),
      // drawer: Padding(
      //   padding: const EdgeInsets.fromLTRB(0, 90, 0, 0),
      //   child: _buildDrawer(),
      // ),
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.pink,
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

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                _buildButton(title: 'Линии'),
                _buildButton(title: 'Рути'),
                _buildButton(title: 'Постојки'),
                _buildVoiceControlButton('АКТИВИРАЈ ГЛАСОВНА КОНТРОЛА'),
              ],
            ),
          ),
          _buildAdvisorButton('Отвори советник'),
        ],
      ),
    );
  }

  Widget _buildButton(
      {required title,
      Color bgColor = Colors.white,
      Color textColor = Colors.black,
      Color borderColor = Colors.purple}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // This line adds padding to left and right
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          side: BorderSide(color: borderColor),
          primary: bgColor,
          onSurface: Colors.purple,
          minimumSize: Size(
              double.infinity, 50), // Ensure consistent size for all buttons
        ),
        onPressed: () {},
        child: Text(title, style: TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _buildVoiceControlButton(String title) {
    return ElevatedButton(
      child: Text(title),
      style: ElevatedButton.styleFrom(
        primary: Colors.deepPurpleAccent,
        onPrimary: Colors.white,
      ),
      onPressed: () {
        // Handle button press here
      },
    );
  }

  Widget _buildAdvisorButton(String title) {
    return ElevatedButton(
      child: Text(title),
      style: ElevatedButton.styleFrom(
        primary: Colors.purple.shade100,
        onPrimary: Colors.black,
      ),
      onPressed: () {
        // Handle button press here
      },
    );
  }
}
