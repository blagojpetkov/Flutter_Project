import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:postojka/models/BusLine.dart';
import 'package:postojka/models/BusRoute.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/services/voice_service.dart';
import 'package:provider/provider.dart';
import '../services/http_service.dart';
import '../models/BusStop.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<BusStop> stops = [];
  Set<Marker> _markers = {};

  BusStop? startStop;
  BusStop? endStop;

  @override
  void initState() {
    enableLocationService();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) async {
      print("Updating user location with timer");
      await getLocationUpdate();
    });
    super.initState();
  }

  Timer? _timer;
  Location location = Location();
  LocationData? _locationData;
  List<double> userLocation = [0.0, 0.0];
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;

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
        if (mounted) {
          setState(() {
            userLocation = [
              _locationData!.latitude!,
              _locationData!.longitude!
            ];
            _displayUserMarker();
          });
        }
      } else {
        print("Latitude or Longitude is null");
      }
    } else {
      print("Location data is null");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final httpService = Provider.of<HttpService>(context);
    stops = httpService.stops;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        markers: _markers,
        onMapCreated: (controller) {
          VoiceService voiceService =
              Provider.of<VoiceService>(context, listen: false);
          if (voiceService.voiceAssistantMode) {
            voiceService.speak("Успешно го отворивте менито мапа");
            print("Успешно го отворивте менито мапа");
          }
          print("Map is created");
          _displayMarkers();
        },
        initialCameraPosition: CameraPosition(
          target: _locationData != null
              ? LatLng(_locationData!.latitude!, _locationData!.longitude!)
              : const LatLng(41.99646,
                  21.43141), // Use default location if user location is not available
          zoom: 12.0,
        ),
        onTap: _onMapTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _checkRouteAvailability,
        child: Icon(Icons.directions_bus),
      ),
    );
  }

  void _checkRouteAvailability() {
    if (startStop == null || endStop == null) {
      // Show an error or prompt the user to select both stops
      return;
    }

    // Implement logic to check if there's a route containing both stops
    // This is a placeholder logic
    List<BusRoute> routes = _routesContainingStops(startStop!, endStop!);

    // Show the result to the user
    _showRouteAvailabilityMessage(routes);
  }

  List<BusRoute> _routesContainingStops(BusStop start, BusStop end) {
    // Retrieve all routes from HttpService
    final httpService = Provider.of<HttpService>(context, listen: false);
    List<BusRoute> allRoutes = httpService.routes;

    List<BusRoute> routesContainingStops = [];

    for (var route in allRoutes) {
      bool startStopFound = false;
      bool endStopFound = false;

      for (var stopId in route.stopIds) {
        if (stopId == start.id) startStopFound = true;
        if (stopId == end.id) endStopFound = true;
    
        if (startStopFound && endStopFound) routesContainingStops.add(route);
      }
    }

    return routesContainingStops;
  }

  void _showRouteAvailabilityMessage(List<BusRoute> routes) {
    final httpService = Provider.of<HttpService>(context, listen: false);
    final routeIds = routes.map((route) => route.id).toSet();
    final lines = httpService.lines
      .where((line) => line.routeIds.any(routeIds.contains))
      .toList();
    String message = "";

    if (lines.isNotEmpty) {
      final lineNames = lines.map((line) => line.name).join(", ");
      message = "Bus lines connecting those bus stops: $lineNames";
    } else {
      message = "No bus lines connect these stops.";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Route Availability'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _displayMarkers() {
    Set<Marker> newMarkers = {};
    for (BusStop stop in stops) {
      newMarkers.add(
        Marker(
            markerId: MarkerId(stop.id.toString()),
            position: LatLng(stop.lat, stop.lon),
            infoWindow: InfoWindow(title: stop.name),
            onTap: () => _onMarkerTapped(stop)),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  void _displayUserMarker() {
    if (_locationData != null) {
      print("Adding the users location");
      _markers.add(
        Marker(
          markerId: const MarkerId("user_location"),
          position: LatLng(_locationData!.latitude!, _locationData!.longitude!),
          infoWindow: const InfoWindow(title: "Вашата локација"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue), // You can customize the marker icon
        ),
      );
    } else {
      print("Location data is null");
    }
    setState(() {});
  }

  void _onMapTapped(LatLng position) {
    // Find the nearest bus stop to the tapped position
    print("Tapped on the map");
    final nearestStop = _findNearestBusStop(position);
    if (nearestStop == null) return;

    // First select the start stop, then the end stop
    setState(() {
      if (startStop == null) {
        startStop = nearestStop;
        print("selected start stop as ${nearestStop.name}");
      } else if (endStop == null) {
        endStop = nearestStop;
        print("selected end stop as ${nearestStop.name}");
        // Optionally, display a dialog or a snackbar to confirm the selection
      } else {
        startStop = endStop = null;
        print("removed selection");
      }
    });
  }

  void _onMarkerTapped(BusStop stop) {
    print("Marker tapped: ${stop.name}");
    setState(() {
      if (startStop == null) {
        startStop = stop;
        print("selected start stop as ${stop.name}");
      } else if (endStop == null) {
        endStop = stop;
        print("selected end stop as ${stop.name}");
      } else {
        startStop = endStop = null;
        print("removed selection");
      }
    });
  }

  BusStop? _findNearestBusStop(LatLng position) {
    double minDistance = double.infinity;
    BusStop? nearestStop;
    for (var stop in stops) {
      var distance = _calculateDistance(
          position.latitude, position.longitude, stop.lat, stop.lon);
      if (distance < minDistance) {
        minDistance = distance;
        nearestStop = stop;
      }
    }
    return nearestStop;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
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
}
