import 'package:flutter/material.dart';
import 'package:postojka/main.dart';
import 'package:postojka/models/BusLine.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/screens/bus_route_detail_screen.dart';
import 'package:postojka/services/http_service.dart';
import 'package:provider/provider.dart';

class BusLineDetailScreen extends StatefulWidget {
  final BusLine line;
  final HttpService httpService;

  BusLineDetailScreen({required this.line, required this.httpService});

  @override
  _BusLineDetailScreenState createState() => _BusLineDetailScreenState();
}

class _BusLineDetailScreenState extends State<BusLineDetailScreen> {
  bool isFavorite = false;

  String getAllRouteNamesWithOrder() {
  List<String> routeDetails = [];
  for (int i = 0; i < widget.line.routeIds.length; i++) {
    final route = widget.httpService.findRouteById(widget.line.routeIds[i]);
      routeDetails.add('Број ${i + 1}, ${route.name}');
  }
  return routeDetails.join(', ');  // This joins all route details into a single string separated by commas.
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    HttpService httpService = Provider.of<HttpService>(context);
    httpService.setCurrentScreen(AppScreens.BusLineDetail);
    if (httpService.voiceAssistantMode) {
      httpService.speak(
          "Успешно го отворивте менито Линија ${widget.line.number}."
          "Оваа линија е од ${widget.line.type == 'URBAN' ? 'Градски' : 'Друг'} тип."
          "Оператор на оваа линија е ${widget.line.carrier}."
          "Рути на оваа линија се: ${getAllRouteNamesWithOrder()}");
    }
  }

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
        title: Text('Детали за Линија ${widget.line.number}'),
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
      body: Stack(
        children: [
          Padding(
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
                      color: widget.httpService.isHighContrast ? Colors.white: AppColors.color4,
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
                      color: widget.httpService.isHighContrast ? Colors.white: AppColors.color4,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.line.routeIds.length,
                    itemBuilder: (context, index) {
                      final route = widget.httpService
                          .findRouteById(widget.line.routeIds[index]);
                      final stops = widget.httpService.stops;
                      return ElevatedButton(
                        onPressed: () {
                          // Navigate to RouteDetails screen when button is pressed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusRouteDetailScreen(
                                route: route,
                                allStops: stops,
                                line: widget.line,
                              ),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: widget.httpService.voiceAssistantButton(context),
          )
        ],
      ),
    );
  }
}
