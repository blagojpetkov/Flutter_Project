import 'package:flutter/material.dart';
import 'package:postojka/main.dart';
import 'package:postojka/models/BusLine.dart';
import 'package:postojka/models/BusRoute.dart';
import 'package:postojka/models/BusStop.dart';
import 'package:postojka/screens/bus_stop_detail_screen.dart';

class BusRouteDetailScreen extends StatelessWidget {
  final BusRoute route;
  final BusLine line;
  final List<BusStop> allStops; // assuming you'll pass all stops

  BusRouteDetailScreen(
      {required this.route, required this.allStops, required this.line});

  List<BusStop> getStopsForRoute() {
    return allStops.where((stop) => route.stopIds.contains(stop.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    var stopsForThisRoute = getStopsForRoute();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${route.name}',
                style: TextStyle(
                    fontSize: 20.0)), // Adjusted font size for the route name
            Text('Линија ${line.number}',
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors
                        .white70)), // Adjusted font size and color for the line name
          ],
        ),
      ),
      body: Padding(
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
              'Должина на рута: ${(route.length / 1000).toStringAsFixed(2)} km',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Постојки:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(height: 10,),
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
                          builder: (context) => BusStopDetailScreen(busStop: stop),
                        ),
                      );
                    },
                    child: Text(stop.name),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryBackground),
                  );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
