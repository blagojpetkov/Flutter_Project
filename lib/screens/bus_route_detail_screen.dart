import 'package:flutter/material.dart';
import 'package:postojka/main.dart';
import 'package:postojka/models/BusLine.dart';
import 'package:postojka/models/BusRoute.dart';
import 'package:postojka/models/BusStop.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/screens/bus_line_map_screen.dart';
import 'package:postojka/screens/bus_stop_detail_screen.dart';
import 'package:postojka/services/http_service.dart';
import 'package:postojka/services/theme_service.dart';
import 'package:postojka/services/voice_service.dart';
import 'package:provider/provider.dart';

class BusRouteDetailScreen extends StatefulWidget {
  final BusRoute route;
  final BusLine line;
  final List<BusStop> allStops;

  BusRouteDetailScreen({
    required this.route,
    required this.allStops,
    required this.line,
  });

  @override
  _BusRouteDetailScreenState createState() => _BusRouteDetailScreenState();
}

class _BusRouteDetailScreenState extends State<BusRouteDetailScreen>
    with RouteAware {
  bool isFavorite = false;

  void speak() {
    VoiceService voiceService =
        Provider.of<VoiceService>(context, listen: false);

    if (voiceService.voiceAssistantMode) {
      voiceService.speak(
          "Успешно го отворивте менито Рута ${widget.route.name}."
          "Оваа рута се состои од ${getStopsForRoute().length} постојки."
          "Должината на оваа рута е ${(widget.route.length / 1000).toStringAsFixed(2)} километри."
          "Постојки на оваа рута се: ${getStopNamesForRouteWithOrder()}");
      print("Успешно го отворивте менито Рута ${widget.route.name}.");
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // This will be called when the user comes back to this screen from another screen
    if (!mounted) return;
    speak();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  _toggleFavoriteStatus() {
    HttpService httpService = Provider.of<HttpService>(context, listen: false);
    httpService.toggleFavoriteRoute(widget.route);
    setState(() {
      isFavorite = httpService.isRouteFavorite(widget.route);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    HttpService httpService = Provider.of<HttpService>(context);
    setState(() {
      isFavorite = httpService.isRouteFavorite(widget.route);
    });
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  List<BusStop> getStopsForRoute() {
    return widget.allStops
        .where((stop) => widget.route.stopIds.contains(stop.id))
        .toList();
  }

  String getStopNamesForRouteWithOrder() {
    return getStopsForRoute().asMap().entries.map((entry) {
      int idx = entry.key + 1; // +1 since you want to start from 1, not 0
      BusStop stop = entry.value;
      return 'Број $idx, ${stop.name}';
    }).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    HttpService httpService = Provider.of<HttpService>(context);
    ThemeService themeService = Provider.of<ThemeService>(context);
    VoiceService voiceService =
        Provider.of<VoiceService>(context, listen: false);

    httpService.setEntityId(widget.route.id);
    var stopsForThisRoute = getStopsForRoute();
    speak();

    final buttonWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.route.name}',
                style: TextStyle(
                    fontSize: 20.0)), // Adjusted font size for the route name
            Text('Линија ${widget.line.number}',
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors
                        .white70)), // Adjusted font size and color for the line name
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? themeService.isHighContrast
                      ? Colors.white
                      : AppColors.primaryBackground
                  : themeService.isHighContrast
                      ? AppColors.primaryBackground
                      : Colors.white,
            ),
            onPressed: _toggleFavoriteStatus,
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Број на постојки: ${stopsForThisRoute.length}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Должина на рута: ${(widget.route.length / 1000).toStringAsFixed(2)} km',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),

                Center(
                  child: Container(
                    width: buttonWidth,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                BusLineMapScreen(busStops: stopsForThisRoute),
                          ),
                        );
                      },
                      child: Text('Мапа на рута'),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Постојки:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 10,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: stopsForThisRoute.length,
                    itemBuilder: (context, index) {
                      var stop = stopsForThisRoute[index];
                      return ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BusStopDetailScreen(busStop: stop),
                            ),
                          );
                        },
                        child: Text(stop.name),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryBackground),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: voiceService.voiceAssistantButton(
                context, AppScreens.BusRouteDetail),
          )
        ],
      ),
      floatingActionButton: voiceService.voiceAssistantMode
          ? FloatingActionButton(
              onPressed: () {
                // Action to be performed when FAB is clicked
                voiceService.stopSpeaking();
              },
              child: Icon(Icons.stop),
              backgroundColor: AppColors.accentColor1,
            )
          : null,
    );
  }
}
