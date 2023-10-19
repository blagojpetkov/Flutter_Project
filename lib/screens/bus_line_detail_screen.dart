import 'package:flutter/material.dart';
import 'package:postojka/main.dart';
import 'package:postojka/models/BusLine.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/screens/bus_route_detail_screen.dart';
import 'package:postojka/services/http_service.dart';
import 'package:postojka/services/theme_service.dart';
import 'package:postojka/services/voice_service.dart';
import 'package:provider/provider.dart';

class BusLineDetailScreen extends StatefulWidget {
  final BusLine line;
  final HttpService httpService;

  BusLineDetailScreen({required this.line, required this.httpService});

  @override
  _BusLineDetailScreenState createState() => _BusLineDetailScreenState();
}

class _BusLineDetailScreenState extends State<BusLineDetailScreen>
    with RouteAware {
  bool isFavorite = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
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

  void speak() {
    VoiceService voiceService =
        Provider.of<VoiceService>(context, listen: false);

    if (voiceService.voiceAssistantMode) {
      voiceService.speak(
          "Успешно го отворивте менито Линија ${widget.line.number}."
          "Оваа линија е од ${widget.line.type == 'URBAN' ? 'Градски' : 'Друг'} тип."
          "Оператор на оваа линија е ${widget.line.carrier}."
          "Рути на оваа линија се: ${getAllRouteNamesWithOrder()}");
      print("Успешно го отворивте менито Линија ${widget.line.number}");
    }
  }

  String getAllRouteNamesWithOrder() {
    List<String> routeDetails = [];
    for (int i = 0; i < widget.line.routeIds.length; i++) {
      final route = widget.httpService.findRouteById(widget.line.routeIds[i]);
      routeDetails.add('Број ${i + 1}, ${route.name}');
    }
    return routeDetails.join(
        ', '); // This joins all route details into a single string separated by commas.
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
    ThemeService themeService = Provider.of<ThemeService>(context);
    VoiceService voiceService =
        Provider.of<VoiceService>(context, listen: false);
    widget.httpService.setEntityId(widget.line.id);
    speak();
    return Scaffold(
      appBar: AppBar(
        title: Text('Детали за Линија ${widget.line.number}'),
        backgroundColor: AppColors.primaryBackground,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? themeService.isHighContrast
                      ? Colors.white
                      : AppColors.color4
                  : themeService.isHighContrast
                      ? AppColors.color4
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
                Center(
                  child: Text(
                    widget.line.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeService.isHighContrast
                          ? Colors.white
                          : AppColors.color4,
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
                      color: themeService.isHighContrast
                          ? Colors.white
                          : AppColors.color4,
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
            child: voiceService.voiceAssistantButton(
                context, AppScreens.BusLineDetail),
          )
        ],
      ),
    );
  }
}
