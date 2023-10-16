import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:postojka/models/BusStop.dart';

class BusLineMapScreen extends StatelessWidget {
  final List<BusStop> busStops;

  BusLineMapScreen({required this.busStops});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Line Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(busStops[0].lat, busStops[0].lon),
          zoom: 14.0,
        ),
        markers: busStops.map((stop) => Marker(
          markerId: MarkerId(stop.id.toString()),
          position: LatLng(stop.lat, stop.lon),
          infoWindow: InfoWindow(title: stop.name),
        )).toSet(),
      ),
    );
  }
}