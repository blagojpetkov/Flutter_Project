import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'http_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: Colors.purple,
      ),
      home: CommandScreen(),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class CommandScreen extends StatefulWidget {
  @override
  _CommandScreenState createState() => _CommandScreenState();
}

class _CommandScreenState extends State<CommandScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  bool _isListening = false;
  bool _isInitialized = false;
  String _command = '';

  final HttpService httpService =
      HttpService(baseUrl: 'http://info.skopska.mk:8080');

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    _initSpeechRecognition();
    httpService.fetchToken();
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
        elevation: 4.0,
        title: Text('Voice Command App'),
        actions: <Widget>[],
      ),
      drawer: Padding(
        padding: const EdgeInsets.fromLTRB(0, 90, 0, 0),
        child: _buildDrawer(),
      ),
      body: Center(
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
                _speak("Hello, how are you?");
              },
            )
          ],
        ),
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
