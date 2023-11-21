import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:postojka/main.dart';
import 'package:postojka/models/BusRoute.dart';
import 'package:postojka/screens/bus_line_detail_screen.dart';
import 'package:postojka/services/voice_service.dart';
import 'package:provider/provider.dart';
import '../services/http_service.dart';
import '../models/BusStop.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<BusStop> stops = [];
  Set<Marker> _markers = {};
  Marker? startMarker;
  Marker? endMarker;
  Marker? userMarker;

  LatLng? startLocation;
  LatLng? endLocation;

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
      body: Stack(children: [
        GoogleMap(
          markers: _markers,
          onMapCreated: (controller) {
            VoiceService voiceService =
                Provider.of<VoiceService>(context, listen: false);
            if (voiceService.voiceAssistantMode) {
              voiceService.speak("Успешно го отворивте менито мапа");
              print("Успешно го отворивте менито мапа");
            }
            print("Map is created");
            // _displayMarkers();
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
        Positioned(
          top: 10.0,
          right: 10.0,
          left: 10.0,
          child: _buildSelectedStopsWidget(),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: _checkRouteAvailability,
        child: const Icon(Icons.directions_bus),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSelectedStopsWidget() {
    return Column(
      children: <Widget>[
        if (startLocation == null && endLocation == null)
          Container(
              margin: EdgeInsets.only(bottom: 8),
              color: AppColors.primaryBackground,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.09,
              child: const Card(
                child: Center(
                    child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Одберете почетна и крајна локација за вашето патување",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )),
              )),
        if (startLocation != null)
          _buildLocationRow(
              startLocation!,
              "Почетна Локација",
              () => setState(() {
                    startLocation = null;
                    _markers.remove(startMarker);
                    startMarker = null;
                  })),
        if (endLocation != null)
          _buildLocationRow(
              endLocation!,
              "Крајна Локација",
              () => setState(() {
                    endLocation = null;
                    _markers.remove(endMarker);
                    endMarker = null;
                  })),
      ],
    );
  }

  Widget _buildLocationRow(
      LatLng location, String label, VoidCallback onRemove) {
    return FutureBuilder(
      future: geocoding.placemarkFromCoordinates(
          location.latitude, location.longitude,
          localeIdentifier: "mk_MK"),
      builder: (BuildContext context,
          AsyncSnapshot<List<geocoding.Placemark>> snapshot) {
        if (snapshot.hasData) {
          geocoding.Placemark place = snapshot.data!.first;
          String address =
              "${place.street}, ${place.locality}, ${place.country}";
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text("$label: $address"),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: onRemove,
                  ),
                ],
              ),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  void _checkRouteAvailability() {
    if (startLocation == null || endLocation == null) {
      // Show an error or prompt the user to select both stops
      return;
    }

    List<BusRoute> routes = _routesForLocations(startLocation!, endLocation!);
    _showRouteAvailabilityMessage(routes);
  }

  List<BusRoute> _routesForLocations(LatLng startLocation, LatLng endLocation) {
    final httpService = Provider.of<HttpService>(context, listen: false);
    List<BusRoute> allRoutes = httpService.routes;

    List<BusRoute> routesForLocations = [];
    List<BusStop> startingBusStops = _findNearestBusStops(startLocation);
    List<BusStop> endingBusStops = _findNearestBusStops(endLocation);

    for (var route in allRoutes) {
      int startIndex = -1;

      for (int i = 0; i < route.stopIds.length; i++) {
        var stopId = route.stopIds[i];

        // Check for starting bus stop
        if (startIndex == -1 && startingBusStops.any((s) => s.id == stopId)) {
          startIndex = i;
        }

        // Check for ending bus stop
        if (startIndex != -1 &&
            endingBusStops.any((e) => e.id == stopId) &&
            i > startIndex) {
          routesForLocations.add(route);
          break;
        }
      }
    }

    return routesForLocations;
  }

  void _showRouteAvailabilityMessage(List<BusRoute> routes) {
    final httpService = Provider.of<HttpService>(context, listen: false);
    final routeIds = routes.map((route) => route.id).toSet();
    final lines = httpService.lines
        .where((line) => line.routeIds.any(routeIds.contains))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Линии кои се движат низ бараните локации'),
        content: lines.isNotEmpty
            ? Container(
                width: double
                    .maxFinite, // Ensures the container takes full width of the dialog
                child: ListView.builder(
                  shrinkWrap:
                      true, // Makes the ListView only occupy needed space
                  itemCount: lines.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: AppColors.secondaryBackground,
                      child: ListTile(
                        title: Text(
                          lines[index].name,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pop(); // Close the dialog before navigating
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BusLineDetailScreen(
                                line: lines[index],
                                httpService: httpService,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              )
            : Text(
                "За жал нема автобуски линии кои се движат низ бараните локации."),
        actions: <Widget>[
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ElevatedButton(
                child: Text('Во ред'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _displayUserMarker() {
    if (_locationData != null) {
      print("Adding the users location");
      userMarker = Marker(
        markerId: const MarkerId("user_location"),
        position: LatLng(_locationData!.latitude!, _locationData!.longitude!),
        infoWindow: const InfoWindow(title: "Вашата локација"),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue), // You can customize the marker icon
      );
      _markers.add(userMarker!);
    } else {
      print("Location data is null");
    }
    setState(() {});
  }

  void _onMapTapped(LatLng position) {
    // Find the nearest bus stop to the tapped position
    print("Tapped on the map");
    // First select the start stop, then the end stop
    setState(() {
      if (startLocation == null) {
        startLocation = position;
        startMarker = Marker(
          markerId: const MarkerId("start_location"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: "Почетна локација"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueMagenta), // You can customize the marker icon
        );
        _markers.add(startMarker!);
      } else if (endLocation == null) {
        endLocation = position;
        endMarker = Marker(
          markerId: const MarkerId("end_location"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: "Крајна локација"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow), // You can customize the marker icon
        );
        _markers.add(endMarker!);
      }
    });
  }

  List<BusStop> _findNearestBusStops(LatLng position) {
    const double maxDistance = 300;
    // The distance in meters to the bus stop
    List<Map<String, dynamic>> nearbyStops = [];

    for (var stop in stops) {
      var distance = _calculateDistance(
          position.latitude, position.longitude, stop.lat, stop.lon);
      if (distance < maxDistance) {
        nearbyStops.add({'busStop': stop, 'distance': distance});
      }
    }

    nearbyStops.sort((a, b) => a['distance'].compareTo(b['distance']));

    return nearbyStops.map((item) => item['busStop'] as BusStop).toList();
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
