import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:provider/provider.dart';
import '../services/http_service.dart';
import '../models/BusStop.dart';

class MapScreen extends StatefulWidget {

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<BusStop> stops = [];
  Set<Marker> _markers = {};


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final httpService = Provider.of<HttpService>(context);
    stops = httpService.stops;
    httpService.setCurrentScreen(AppScreens.MapScreen);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        markers: _markers,
        onMapCreated: (controller) {
          print("Map is created");
          _displayMarkers();
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(41.99646, 21.43141),
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
}