import 'dart:async'; // Import for Timer
import 'dart:math';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:postojka/main.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/screens/bus_stop_detail_screen.dart';
import 'package:postojka/services/http_service.dart';
import 'package:provider/provider.dart';
import 'package:postojka/models/BusStop.dart';

class BusStopsNearbyScreen extends StatefulWidget {
  @override
  _BusStopsNearbyScreenState createState() => _BusStopsNearbyScreenState();
}

class _BusStopsNearbyScreenState extends State<BusStopsNearbyScreen> {
  List<double> userLocation = [0.0, 0.0];
  Location location = Location();
  Timer? _timer;
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  @override
  void initState() {
    super.initState();
    enableLocationService();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) async {
      await getLocationUpdate();
    });
  }

  Future<void> enableLocationService() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    await getLocationUpdate();
  }

  Future<void> getLocationUpdate() async {
    _locationData = await location.getLocation();
    if (_locationData != null) {
      if (_locationData!.latitude != null && _locationData!.longitude != null) {
        setState(() {
          userLocation = [_locationData!.latitude!, _locationData!.longitude!];
          // userLocation = const [41.9991, 21.3900];
        });
        print(_locationData!.latitude);
        print(_locationData!.longitude);
      } else {
        print("Latitude or Longitude is null");
      }
    } else {
      print("Location data is null");
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Dispose of the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HttpService httpService = Provider.of<HttpService>(context);
    final allBusStops = httpService.stops;
    httpService.setCurrentScreen(AppScreens.BusStopNearby);
    final nearbyBusStops =
        getNearbyBusStops(allBusStops, userLocation[0], userLocation[1]);

    return Scaffold(
      appBar: AppBar(title: Text('Nearby Bus Stops')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: nearbyBusStops.length,
          itemBuilder: (ctx, index) {
            var stop = nearbyBusStops[index];
            var distance = haversineDistance(
                userLocation[0], userLocation[1], stop.lat, stop.lon);
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusStopDetailScreen(busStop: stop),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryBackground),
              child: Column(children: [
                Text(stop.name),
                Text("${distance.toStringAsFixed(0)} метри"),
              ]),
            );
          },
        ),
      ),
    );
  }

  double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000; // Earth radius in meters
    var radLat1 = lat1 * pi / 180;
    var radLon1 = lon1 * pi / 180;
    var radLat2 = lat2 * pi / 180;
    var radLon2 = lon2 * pi / 180;
    var dLat = radLat2 - radLat1;
    var dLon = radLon2 - radLon1;
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(radLat1) * cos(radLat2) * sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in meters
  }

  List<BusStop> getNearbyBusStops(
      List<BusStop> allStops, double userLat, double userLon) {
    return allStops.where((stop) {
      var distance = haversineDistance(userLat, userLon, stop.lat, stop.lon);
      return distance <= 200;
    }).toList();
  }
}
