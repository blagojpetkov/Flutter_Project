import 'package:flutter/material.dart';
import 'package:postojka/models/Arrival.dart';
import 'package:postojka/models/BusLine.dart';
import 'package:postojka/models/BusStop.dart';
import 'package:postojka/models/BusStopLine.dart';
import 'package:postojka/services/http_service.dart';
import 'package:provider/provider.dart';
class BusStopDetailScreen extends StatefulWidget {
  final BusStop busStop;

  BusStopDetailScreen({required this.busStop});

  @override
  _BusStopDetailsScreenState createState() => _BusStopDetailsScreenState();
}

class _BusStopDetailsScreenState extends State<BusStopDetailScreen> {
  late List<BusStopLine> busStopLines;
  late List<BusLine> busLines;
  late List<Arrival> arrivals;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final httpService = Provider.of<HttpService>(context);
    busStopLines = httpService.busStopLines.where((line) => line.stopId == widget.busStop.id).toList();
    busLines = httpService.lines;

    // Transform data to individual bus arrivals and sort
    arrivals = busStopLines.expand((line) {
      return line.remainingTime.map((time) => Arrival(
          lineId: line.lineId,
          timeInMinutes: (time / 60).round(),
          lineName: busLines.firstWhere((busLine) => busLine.id == line.lineId).name // assuming you have a name attribute in BusLine
          ));
    }).toList();

    arrivals.sort((a, b) => a.timeInMinutes.compareTo(b.timeInMinutes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.busStop.name}")),
      body: ListView.builder(
        itemCount: arrivals.length,
        itemBuilder: (context, index) {
          final arrival = arrivals[index];

          return ListTile(
            title: Text(arrival.lineName),
            subtitle: Text("Пристига за ${arrival.timeInMinutes} минути"),
          );
        },
      ),
    );
  }
}