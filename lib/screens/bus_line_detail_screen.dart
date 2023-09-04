import 'package:flutter/material.dart';
import 'package:postojka/main.dart';
import 'package:postojka/models/BusLine.dart';
import 'package:postojka/screens/bus_route_detail_screen.dart';
import 'package:postojka/services/http_service.dart';
class BusLineDetailScreen extends StatefulWidget {
  final BusLine line;
  final HttpService httpService;

  BusLineDetailScreen({required this.line, required this.httpService});

  @override
  _BusLineDetailScreenState createState() => _BusLineDetailScreenState();
}

class _BusLineDetailScreenState extends State<BusLineDetailScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  _checkFavoriteStatus() {
    setState(() {
      isFavorite = widget.httpService.isLineFavorite(widget.line);
    });
  }

  _toggleFavoriteStatus() {
    widget.httpService.toggleFavoriteLine(widget.line);
    _checkFavoriteStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Детали за линија ${widget.line.number}'),
        backgroundColor: AppColors.primaryBackground,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.color4 : Colors.white,
            ),
            onPressed: _toggleFavoriteStatus,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.line.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.color4,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Вид: ${widget.line.type == 'URBAN' ? 'Градски' : 'Друг'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Оператор: ${widget.line.carrier}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Ноќен: ${widget.line.nightly ? 'Да' : 'Не'}',
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
                  color: AppColors.color4,
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.line.routeIds.length,
                itemBuilder: (context, index) {
                  final route = widget.httpService.findRouteById(widget.line.routeIds[index]);
                  final stops = widget.httpService.stops;
                  return ElevatedButton(
                    onPressed: () {
                      // Navigate to RouteDetails screen when button is pressed
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BusRouteDetailScreen(route: route, allStops: stops, line: widget.line,),
                        ),
                      );
                    },
                    child: Text('${route?.name ?? 'Неизвестна рута'}'),
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