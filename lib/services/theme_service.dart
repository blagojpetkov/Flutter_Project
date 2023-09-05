import 'package:flutter/material.dart';
import 'package:postojka/main.dart';

class ThemeService with ChangeNotifier{
  late ThemeData _currentTheme;
  bool _isHighContrast = false;

  ThemeService(){
    _currentTheme = buildAppTheme();
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
}