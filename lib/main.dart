import 'package:flutter/material.dart';
import 'package:postojka/screens/home_screen.dart';
import 'package:postojka/screens/bus_lines_screen.dart';
import 'package:postojka/screens/map_screen.dart';
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
        theme: ThemeData(
          primarySwatch: Colors.purple,
          primaryColor: Colors.purple,
        ),
        home: HomeScreen(),
        // routes: {
        //   '/home': (context) {
        //     return HomeScreen();
        //   },
        //   '/map': (context) {
        //     return MapScreen();
        //   },
        //   '/lines': (context) {
        //     return LinesScreen();
        //   },
        //   '/stops': (context) {
        //     return LinesScreen();
        //     // TODO
        //   },
          

        // },
      ),
    );
  }
}
