import 'package:flutter/material.dart';
import 'package:postojka/main.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/screens/bus_lines_screen.dart';
import 'package:postojka/screens/bus_stops_nearby_screen.dart';
import 'package:postojka/screens/bus_stops_screen.dart';
import 'package:postojka/screens/map_screen.dart';
import 'package:postojka/screens/settings_screen.dart';
import 'package:postojka/services/http_service.dart';
import 'package:postojka/widgets/favorites_tab_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  

  List<Widget> get _pages => [
        BusLinesScreen(),
        BusStopsScreen(),
        FavoritesTabScreen(),
        MapScreen(),
        SettingsScreen(),
      ];

  List<String> titles = ["Линии", "Постојки", "Омилени", "Circle", "Square"];


  @override
  Widget build(BuildContext context) {
    HttpService httpService = Provider.of<HttpService>(context);
    httpService.setCurrentScreen(AppScreens.Home);
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
          titles[httpService.currentIndex],
          style: TextStyle(fontSize: 20),
        ),
        actions: httpService.currentIndex == 1
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
          _pages[httpService.currentIndex],
          Align(
            alignment: Alignment.bottomCenter,
            child: httpService.voiceAssistantButton(context),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.color4,
        unselectedItemColor: AppColors.primaryBackground,
        currentIndex: httpService.currentIndex,
        onTap: (index) {
          setState(() {
            httpService.setCurrentIndex(index);
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
