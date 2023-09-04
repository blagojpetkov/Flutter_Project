import 'package:flutter/material.dart';
import 'package:postojka/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'services/http_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HttpService(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: buildAppTheme(),
        home: HomeScreen(),
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
