import 'package:flutter/material.dart';
import 'package:postojka/main.dart';
import 'package:postojka/models/Arrival.dart';
import 'package:postojka/models/BusLine.dart';
import 'package:postojka/models/BusStop.dart';
import 'package:postojka/models/BusStopLine.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/services/http_service.dart';
import 'package:postojka/services/theme_service.dart';
import 'package:postojka/services/voice_service.dart';
import 'package:provider/provider.dart';

class BusStopDetailScreen extends StatefulWidget {
  final BusStop busStop;

  BusStopDetailScreen({required this.busStop});

  @override
  _BusStopDetailsScreenState createState() => _BusStopDetailsScreenState();
}

class _BusStopDetailsScreenState extends State<BusStopDetailScreen> {
  bool isFavorite = false;

  _toggleFavoriteStatus() {
    HttpService httpService = Provider.of<HttpService>(context, listen: false);
    httpService.toggleFavoriteBusStop(widget.busStop);
    setState(() {
      isFavorite = httpService.isStopFavorite(widget.busStop);
    });
  }

  late List<BusStopLine> busStopLines;
  late List<BusLine> busLines;
  late List<Arrival> arrivals;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final httpService = Provider.of<HttpService>(context);
    final voiceService = Provider.of<VoiceService>(context, listen: false);

    busStopLines = httpService.busStopLines
        .where((line) => line.stopId == widget.busStop.id)
        .toList();
    busLines = httpService.lines;

    // Transform data to individual bus arrivals and sort
    arrivals = busStopLines.expand((line) {
      return line.remainingTime.map((time) => Arrival(
          lineId: line.lineId,
          timeInMinutes: (time / 60).round(),
          lineName: busLines
              .firstWhere((busLine) => busLine.id == line.lineId)
              .name // assuming you have a name attribute in BusLine
          ));
    }).toList();

    arrivals.sort((a, b) => a.timeInMinutes.compareTo(b.timeInMinutes));
    if (voiceService.voiceAssistantMode) {
      voiceService.speak(
          "Успешно ја отворивте постојката со име ${widget.busStop.name} со број ${widget.busStop.number}"
          "Линии кои пристигаат на оваа постојка наскоро се:"
          "${getAllArrivalsAsString()}");
      print(
          "Успешно ја отворивте постојката со име ${widget.busStop.name} со број ${widget.busStop.number}");
    }
  }

  String formatArrival(Arrival arrival) {
    return "${arrival.lineName} - Пристига за ${arrival.timeInMinutes} минути";
  }

  String getAllArrivalsAsString() {
    return arrivals.take(10).map(formatArrival).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    VoiceService voiceService = Provider.of<VoiceService>(context);
    ThemeService themeService = Provider.of<ThemeService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.busStop.name}"),
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
          ListView.builder(
            itemCount: arrivals.length,
            itemBuilder: (context, index) {
              final arrival = arrivals[index];

              return ListTile(
                title: Text(arrival.lineName),
                subtitle: Text("Пристига за ${arrival.timeInMinutes} минути"),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: voiceService.voiceAssistantButton(
                context, AppScreens.BusStopDetail),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to be performed when FAB is clicked
          voiceService.stopSpeaking();
        },
        child: Icon(Icons.stop),
      ),
    );
  }
}
