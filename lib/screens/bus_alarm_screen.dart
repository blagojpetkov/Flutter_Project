import 'package:flutter/material.dart';
import 'package:postojka/models/Arrival.dart';
import 'package:postojka/models/BusStopLine.dart';
import 'package:postojka/services/http_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BusAlarmScreen extends StatefulWidget {
  @override
  _BusAlarmScreenState createState() => _BusAlarmScreenState();
}

class _BusAlarmScreenState extends State<BusAlarmScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final TextEditingController timeController = TextEditingController();
  int? selectedBusStopId;
  int? selectedLineId;
  List<Arrival> arrivals = [];
  List<BusStopLine> busStopLines = [];

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }


  @override
  Widget build(BuildContext context) {
    final httpService = Provider.of<HttpService>(context);
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
                hint: Text('Select Bus Stop'),
                value: selectedBusStopId,
                items: busStopsDropdownItems(),
                onChanged: (int? value) {
                  setState(() {
                    selectedBusStopId = value;
                    selectedLineId = null; // Clear previously selected line
                    updateLinesDropdown(selectedBusStopId);
                  });
                },
                isExpanded: true,
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: dropdownWidth,
              child: DropdownButton<int>(
                hint: Text('Select Bus Line'),
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

   void updateLinesDropdown(int? busStopId) {
    if (busStopId == null) return;
    final httpService = Provider.of<HttpService>(context, listen: false);
    busStopLines = httpService.busStopLines
        .where((line) => line.stopId == busStopId)
        .toList();

  }

  void fetchArrivals(){
    final httpService = Provider.of<HttpService>(context, listen: false);
    arrivals = busStopLines.expand((line) {
      return line.remainingTime.map((time) => Arrival(
          lineId: line.lineId,
          timeInMinutes: (time / 60).round(),
          lineName: httpService.lines
              .firstWhere((busLine) => busLine.id == line.lineId)
              .name
          ));
    }).toList();
  }

  List<DropdownMenuItem<int>> linesDropdownItems() {
    final httpService = Provider.of<HttpService>(context, listen: false);

    // Extract unique line IDs first
    final uniqueLineIds = busStopLines.map((line) => line.lineId).toSet().toList();

    return uniqueLineIds.map((lineId) {
      final busLine = httpService.lines.firstWhere((l) => l.id == lineId);
      final lineName =
          busLine.name;

      return DropdownMenuItem(
        child: Text(lineName),
        value: lineId,
      );
    }).toList();
  }

  void setAlarm(int minutes) {
    var alarmArrivals = arrivals.where((arrival) =>
        arrival.lineId == selectedLineId &&
        (arrival.timeInMinutes <= minutes &&
            arrival.timeInMinutes >=
                minutes - 5));

    if (alarmArrivals.isNotEmpty) {
      // Sending a local notification
      print("Calling send notification");
      _sendNotification();
    }
    else{
      print("Not sending notification");
    }
  }

  void _sendNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'bus_alarm_channel_id',
      'Bus Alarm',
      channelDescription: 'Notification for bus arrival',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Bus Arrival Alert',
      'The bus is about to arrive!',
      platformChannelSpecifics,
    );
  }
}
