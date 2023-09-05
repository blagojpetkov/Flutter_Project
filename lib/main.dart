import 'package:flutter/material.dart';
import 'package:postojka/screens/home_screen.dart';
import 'package:postojka/services/theme_service.dart';
import 'package:postojka/services/voice_service.dart';
import 'package:provider/provider.dart';
import 'services/http_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.@override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HttpService>(
          create: (context) => HttpService(),
        ),
        ChangeNotifierProvider<ThemeService>(
          create: (context) => ThemeService(),
        ),
        ChangeNotifierProvider<VoiceService>(
          create: (context) {
            HttpService httpService =
                Provider.of<HttpService>(context, listen: false);
            return VoiceService(httpService);
          },
        )
      ],
      child: Builder(
        builder: (context) {
          ThemeService themeService = Provider.of<ThemeService>(context);

          return MaterialApp(
            title: 'Flutter Demo',
            theme: themeService.getTheme(),
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}

class AppColors {
  static const color1 = Color(0xFFFFB997);
  static const color2 = Color(0xFFF67E7D);
  static const color3 = Color(0xFF843B62);
  static const color4 = Color(0xFF0B032D);
  static const color5 = Color(0xFF74546A);

  static const navBarColor = Color.fromARGB(255, 74, 62, 110);

  static const primaryBackground = Color.fromARGB(255, 153, 136, 211);
  static const secondaryBackground = Color.fromARGB(255, 96, 82, 136);

  static const primaryText = Color(0xFF2F4F4F);
  static const secondaryText = Color(0xFF696969);
  static const accentColor1 = Color(0xFFD8BFD8);
  static const accentColor2 = Color(0xFFDDA0DD);
}
