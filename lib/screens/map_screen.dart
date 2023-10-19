import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  @override
  void initState() {
    enableLocationService();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) async {
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
    return GoogleMap(
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
        ),
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
}
