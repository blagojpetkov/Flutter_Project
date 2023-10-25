import 'dart:async';

import 'package:flutter/material.dart';
import 'package:postojka/models/Alarm.dart';
import 'package:postojka/models/Arrival.dart';
import 'package:postojka/models/BusStopLine.dart';
import 'package:postojka/services/http_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dropdown_search/dropdown_search.dart';

class BusAlarmScreen extends StatefulWidget {
  @override
  _BusAlarmScreenState createState() => _BusAlarmScreenState();
}

class _BusAlarmScreenState extends State<BusAlarmScreen> {
  Timer? _timer;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TextEditingController timeController = TextEditingController();
  int? selectedBusStopId;
  int? selectedLineId;
  List<Arrival> arrivals = [];
  List<BusStopLine> busStopLines = [];
  List<Alarm> alarms = [];

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    double dropdownWidth =
        MediaQuery.of(context).size.width * 0.8; // 80% of screen width

    return Scaffold(
      appBar: AppBar(title: Text('Bus Alarm')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: dropdownWidth,
              child: DropdownButton<int>(
                hint: const Text('Select Bus Stop'),
                value: selectedBusStopId,
                items: busStopsDropdownItems(),
                onChanged: (int? value) {
                  setState(() {
                    selectedBusStopId = value;
                    selectedLineId = null; // Clear previously selected line
                    fetchBusStopLinesAndArrivalsForBusStop(selectedBusStopId!);
                    // updateLinesDropdown(selectedBusStopId);
                  });
                },
                isExpanded: true,
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: dropdownWidth,
              child: DropdownButton<int>(
                hint: const Text('Select Bus Line'),
                value: selectedLineId,
                items: linesDropdownItems(),
                onChanged: (int? value) {
                  setState(() {
                    selectedLineId = value;
                  });
                },
                isExpanded: true,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Time in minutes'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setAlarm(int.parse(timeController.text));
              },
              child: Text('Set Alarm'),
            ),
            const SizedBox(height: 20),
            _buildAlarmInfo(),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>> busStopsDropdownItems() {
    final httpService = Provider.of<HttpService>(context, listen: false);
    return httpService.stops.map((busStop) {
      return DropdownMenuItem(
        child: Text(busStop.name),
        value: busStop.id,
      );
    }).toList();
  }

  List<Arrival> fetchBusStopLinesAndArrivalsForBusStop(int busStopId) {
  print("Fetching arrivals in bus alarm screen");
  final httpService = Provider.of<HttpService>(context, listen: false);

  var currentBusStopLines = httpService.busStopLines
      .where((line) => line.stopId == busStopId)
      .toList();

  busStopLines = currentBusStopLines; // Needed to populate the bus line dropdown

  var currentArrivals = currentBusStopLines.expand((line) {
    return line.remainingTime.map((time) => Arrival(
        lineId: line.lineId,
        timeInMinutes: (time / 60).round(),
        lineName: httpService.lines
            .firstWhere((busLine) => busLine.id == line.lineId)
            .name));
  }).toList();

  return currentArrivals;
}

  List<DropdownMenuItem<int>> linesDropdownItems() {
    final httpService = Provider.of<HttpService>(context, listen: false);

    // Extract unique line IDs first
    final uniqueLineIds =
        busStopLines.map((line) => line.lineId).toSet().toList();

    return uniqueLineIds.map((lineId) {
      final busLine = httpService.lines.firstWhere((l) => l.id == lineId);
      final lineName = busLine.name;

      return DropdownMenuItem(
        child: Text(lineName),
        value: lineId,
      );
    }).toList();
  }

  Widget _buildAlarmInfo() {
    if (alarms.isEmpty) return Container();

    return Expanded(
      child: ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          final busStopName = Provider.of<HttpService>(context, listen: false)
              .stops
              .firstWhere((stop) => stop.id == alarm.busStopId)
              .name;
          final lineName = Provider.of<HttpService>(context, listen: false)
              .lines
              .firstWhere((line) => line.id == alarm.lineId)
              .name;

          return Card(
            child: ListTile(
              title: Text(
                  'Alarm for bus line: $lineName at stop: $busStopName in ${alarm.timeInMinutes} minutes'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    alarms.removeAt(index);
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void setAlarm(int minutes) {
    if (_timer != null) {
      _timer!.cancel();
    }

    checkIfShouldSendNotification(minutes);
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      checkIfShouldSendNotification(minutes);
    });

    alarms.add(Alarm(
        busStopId: selectedBusStopId!,
        lineId: selectedLineId!,
        timeInMinutes: minutes));

    setState(() {});
  }

  void checkIfShouldSendNotification(int minutes) {
  for (var alarm in alarms) {
    var currentArrivals = fetchBusStopLinesAndArrivalsForBusStop(alarm.busStopId);
    
    var alarmArrivals = currentArrivals.where((arrival) =>
        arrival.lineId == alarm.lineId &&
        (arrival.timeInMinutes <= alarm.timeInMinutes &&
            arrival.timeInMinutes >= alarm.timeInMinutes - 5));

    if (alarmArrivals.isNotEmpty) {
      var lineName = Provider.of<HttpService>(context, listen: false)
          .lines
          .firstWhere((line) => line.id == alarm.lineId)
          .name;

      var stopName = Provider.of<HttpService>(context, listen: false)
          .stops
          .firstWhere((stop) => stop.id == alarm.busStopId)
          .name;
      print(
          "Calling send notification for alarm with lineId: ${alarm.lineId}");
      _sendNotification(lineName, stopName);
      alarms.remove(alarm);
      break; // If found an alarm that satisfies the condition, break out of the loop.
    } else {
      print("Not sending notification for alarm with lineId: ${alarm.lineId}");
    }
  }
}

  void _sendNotification(String lineName, String stopName) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'bus_alarm_channel_id',
      'Bus Alarm',
      channelDescription: 'Notification for bus arrival',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Bus Arrival Alert for $lineName',
      'The bus will arrive at $stopName soon!',
      platformChannelSpecifics,
    );
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }
}
