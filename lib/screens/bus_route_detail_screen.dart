import 'package:flutter/material.dart';
import 'package:postojka/main.dart';
import 'package:postojka/models/BusLine.dart';
import 'package:postojka/models/BusRoute.dart';
import 'package:postojka/models/BusStop.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/screens/bus_stop_detail_screen.dart';
import 'package:postojka/services/http_service.dart';
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
class _BusRouteDetailScreenState extends State<BusRouteDetailScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    HttpService httpService = Provider.of<HttpService>(context);
    httpService.setCurrentScreen(AppScreens.BusRouteDetail);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final httpService = Provider.of<HttpService>(context, listen: false);
      httpService.setCurrentScreen(AppScreens.BusRouteDetail);
      print("Setting current screen in bus route detail");
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  List<BusStop> getStopsForRoute() {
    return widget.allStops.where((stop) => widget.route.stopIds.contains(stop.id)).toList();
  }

  String getStopNamesForRouteWithOrder() {
  return getStopsForRoute().asMap().entries.map((entry) {
    int idx = entry.key + 1;  // +1 since you want to start from 1, not 0
    BusStop stop = entry.value;
    return 'Број $idx, ${stop.name}';
  }).join(', ');
}

  @override
  Widget build(BuildContext context) {
    HttpService httpService = Provider.of<HttpService>(context);
    httpService.setEntityId(widget.route.id);
    var stopsForThisRoute = getStopsForRoute();
    if (httpService.voiceAssistantMode) {
    httpService.speak("Успешно го отворивте менито Рута ${widget.route.name}."
        "Оваа рута се состои од ${stopsForThisRoute.length} постојки."
        "Должината на оваа рута е ${(widget.route.length / 1000).toStringAsFixed(2)} километри."
        "Постојки на оваа рута се: ${getStopNamesForRouteWithOrder()}");
    }

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
            child: httpService.voiceAssistantButton(context),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to be performed when FAB is clicked
          httpService.stopSpeaking();
        },
        child: Icon(Icons.stop),
      ),
    );
  }
}
