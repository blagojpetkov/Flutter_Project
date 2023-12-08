import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:postojka/models/BusStop.dart';
import 'package:vibration/vibration.dart';

class BusLineMapScreen extends StatefulWidget {
  final List<BusStop> busStops;

  BusLineMapScreen({required this.busStops});

  @override
  State<BusLineMapScreen> createState() => _BusLineMapScreenState();
}

class _BusLineMapScreenState extends State<BusLineMapScreen> {
  BusStop? endStop;
  Marker? _userMarker;
  Set<Marker> _markers = {};
  Timer? _timer;
  Location location = Location();
  LocationData? _locationData;
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  MarkerId? _selectedMarkerId;

  @override
  void initState() {
    super.initState();
    enableLocationService();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await getLocationUpdate();
    });
    _setInitialMarkers();
    createUserLocationMarker();
  }

  void createUserLocationMarker() {
    _userMarker = Marker(
      markerId: const MarkerId("user_location"),
      position: LatLng(0, 0), // Initial position
      infoWindow: const InfoWindow(title: "Вашата локација"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
    _markers.add(_userMarker!);
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
      _updateUserLocationMarker(_locationData!);
      if (endStop != null) {
        double distance = _calculateDistance(
          _locationData!.latitude!,
          _locationData!.longitude!,
          endStop!.lat,
          endStop!.lon,
        );
        print(
            "Distance from you to the selected bus stop is ${distance} meters");
        if (distance < 300) {
          if (await Vibration.hasVibrator() != null) {
            Vibration.vibrate();
          }
        }
      }
    }
  }

  void _updateUserLocationMarker(LocationData locationData) {
    LatLng newPosition =
        LatLng(locationData.latitude!, locationData.longitude!);
    setState(() {
      _userMarker = _userMarker!.copyWith(
        positionParam: newPosition,
      );
      _markers.removeWhere((m) => m.markerId == _userMarker!.markerId);
      _markers.add(_userMarker!);
    });
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

  void _setInitialMarkers() {
    _markers = widget.busStops
        .map((stop) => Marker(
            markerId: MarkerId(stop.id.toString()),
            position: LatLng(stop.lat, stop.lon),
            infoWindow: InfoWindow(title: stop.name),
            onTap: () => _onMarkerTapped(stop)))
        .toSet();
  }

  void _onMarkerTapped(BusStop stop) {
    setState(() {
      endStop = stop;
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    _markers = _markers.map((marker) {
      if (endStop != null && marker.markerId == MarkerId(endStop!.id.toString())) {
        return marker.copyWith(
          iconParam:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );
      } else if (_userMarker != null &&
          marker.markerId == _userMarker!.markerId) {
        return marker.copyWith(
          iconParam:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        );
      } else {
        return marker.copyWith(
          iconParam: BitmapDescriptor.defaultMarker,
        );
      }
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мапа на постојки'),
      ),
      body: Stack(children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.busStops[0].lat, widget.busStops[0].lon),
            zoom: 14.0,
          ),
          markers: _markers,
        ),
        if (endStop != null) _buildSelectedBusStopWidget(),
      ]),
    );
  }

  Widget _buildSelectedBusStopWidget() {
    return Positioned(
      top: 10.0,
      right: 10.0,
      left: 10.0,
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text("Одбрана Постојка: ${endStop!.name}"),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => setState(() {
                  endStop = null;
                  _updateMarkers();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
