import 'package:flutter/material.dart';
import 'package:postojka/models/BusLine.dart';
import 'package:postojka/screens/bus_route_detail_screen.dart';
import 'package:postojka/services/http_service.dart';

class BusLineDetailScreen extends StatelessWidget {
  final BusLine line;
  final HttpService httpService;

  BusLineDetailScreen({required this.line, required this.httpService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Детали за линија ${line.number}'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                line.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Вид: ${line.type == 'URBAN' ? 'Градски' : 'Друг'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Оператор: ${line.carrier}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Ноќен: ${line.nightly ? 'Да' : 'Не'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // The added label
            Center(
              child: Text(
                'Рути',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: line.routeIds.length,
                itemBuilder: (context, index) {
                  final route = httpService.findRouteById(line.routeIds[index]);
                  final stops = httpService.stops;
                  return ElevatedButton(
                    onPressed: () {
                      // Navigate to RouteDetails screen when button is pressed
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RouteDetailScreen(route: route, allStops: stops, line: line,),
                        ),
                      );
                    },
                    child: Text('${route?.name ?? 'Неизвестна рута'}'),
                    style: ElevatedButton.styleFrom(primary: Colors.purple),
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