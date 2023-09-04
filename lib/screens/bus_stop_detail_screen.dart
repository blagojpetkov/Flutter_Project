import 'package:flutter/material.dart';
import 'package:postojka/models/Arrival.dart';
import 'package:postojka/models/BusLine.dart';
import 'package:postojka/models/BusStop.dart';
import 'package:postojka/models/BusStopLine.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/services/http_service.dart';
import 'package:provider/provider.dart';

class BusStopDetailScreen extends StatefulWidget {
  final BusStop busStop;

  BusStopDetailScreen({required this.busStop});

  @override
  _BusStopDetailsScreenState createState() => _BusStopDetailsScreenState();
}

class _BusStopDetailsScreenState extends State<BusStopDetailScreen>
    with WidgetsBindingObserver {
  late List<BusStopLine> busStopLines;
  late List<BusLine> busLines;
  late List<Arrival> arrivals;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final httpService = Provider.of<HttpService>(context);
    httpService.setCurrentScreen(AppScreens.BusStopDetail);
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
    if (httpService.voiceAssistantMode) {
      httpService.speak(
          "Успешно ја отворивте постојката со име ${widget.busStop.name} со број ${widget.busStop.number}"
          "Линии кои пристигаат на оваа постојка наскоро се:"
          "${getAllArrivalsAsString()}");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // This code will be executed every time the app is brought back to the foreground
      final httpService = Provider.of<HttpService>(context, listen: false);
      httpService.setCurrentScreen(AppScreens.BusStopDetail);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this); // Unregister the observer
    super.dispose();
  }

  String formatArrival(Arrival arrival) {
    return "${arrival.lineName} - Пристига за ${arrival.timeInMinutes} минути";
  }

  String getAllArrivalsAsString() {
    return arrivals.map(formatArrival).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    HttpService httpService = Provider.of<HttpService>(context);
    return Scaffold(
      appBar: AppBar(title: Text("${widget.busStop.name}")),
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
