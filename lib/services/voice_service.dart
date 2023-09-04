import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  // Initialize TTS
  initTTS() {
    _tts.setLanguage("en-US"); // You can set this to other languages.
    // You can set more properties as needed.
  }

  // Initialize STT
  initSTT() async {
    bool available = await _speech.initialize(onError: errorListener, onStatus: statusListener);
    return available;
  }

  void errorListener(dynamic error) {
    print("Received error status: $error");
  }

  void statusListener(String status) {
    print("Received listener status: $status");
  }

  // Speak a message
  speak(String message) async {
    await _tts.speak(message);
  }

  // Start listening to voice commands
  listen(Function(String text) onResult) {
    _speech.listen(onResult: (result) {
      print("This is the result of listening inside of voiceservice");
      onResult(result.recognizedWords);
    });
  }

  // Stop listening
  stopListening() {
    _speech.stop();
  }
}

final voiceService = VoiceService();