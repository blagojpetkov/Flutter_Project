import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:postojka/main.dart';
import 'package:postojka/models/BusStopLine.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/screens/bus_line_detail_screen.dart';
import 'package:postojka/screens/bus_stop_detail_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/BusLine.dart';
import '../models/BusRoute.dart';
import '../models/BusStop.dart';

class HttpService with ChangeNotifier {
  final String baseUrl = 'http://info.skopska.mk:8080';
  final String tokenHeaderKey = "Eurogps.Eu.Sid";
  String? token;
  bool isDataLoaded = false;

  int entityId = -1; // The ID of the line / route / stop

  void setEntityId(int entityId) {
    this.entityId = entityId;
  }

  //Used to execute the fetchToken method every X seconds
  Timer? _timer;

  AppScreens currentScreen = AppScreens.BusLines;

  void setCurrentScreen(AppScreens screen) {
    currentScreen = screen;
    print("Current screen is " + currentScreen.toString());
  }

  int currentIndex = 2;
  void setCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  List<BusStop> getStopsForRoute() {
    BusRoute route = routes.firstWhere((route) => route.id == entityId);
    return stops.where((stop) => route.stopIds.contains(stop.id)).toList();
  }

  List<BusRoute> getRoutesForLine() {
    BusLine line = lines.firstWhere((line) => line.id == entityId);
    return line.routeIds.map((routeId) => findRouteById(routeId)).toList();
  }

  BusLine getLineForRoute(BusRoute route) {
    return lines.firstWhere((line) => line.id == route.lineId,
        orElse: () => BusLine.empty());
  }

  HttpService() {
    fetchToken();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      print("EXECUTED TIMER fetchBusStopLines");
      busStopLines = await fetchBusStopLines();
      notifyListeners();
    });
    loadFavorites();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<BusRoute> routes = [];
  List<BusLine> lines = [];
  List<BusStop> stops = [];
  List<BusStopLine> busStopLines = [];

  List<BusRoute> favoriteRoutes = [];
  List<BusLine> favoriteLines = [];
  List<BusStop> favoriteStops = [];

  saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String favoriteRoutesString = jsonEncode(favoriteRoutes);
    String favoriteLinesString = jsonEncode(favoriteLines);
    String favoriteStopsString = jsonEncode(favoriteStops);
    await prefs.setString('favoriteRoutes', favoriteRoutesString);
    await prefs.setString('favoriteLines', favoriteLinesString);
    await prefs.setString('favoriteStops', favoriteStopsString);
  }

  loadFavorites() async {
    print("Loading all favorites");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favoriteRoutesString = prefs.getString('favoriteRoutes');
    String? favoriteLinesString = prefs.getString('favoriteLines');
    String? favoriteStopsString = prefs.getString('favoriteStops');
    if (favoriteRoutesString != null) {
      favoriteRoutes = (jsonDecode(favoriteRoutesString) as List)
          .map((item) => BusRoute.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    if (favoriteLinesString != null) {
      favoriteLines = (jsonDecode(favoriteLinesString) as List)
          .map((item) => BusLine.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    if (favoriteStopsString != null) {
      favoriteStops = (jsonDecode(favoriteStopsString) as List)
          .map((item) => BusStop.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  // Check if a line is a favorite
  bool isLineFavorite(BusLine line) {
    return favoriteLines.any((existingLine) => existingLine.id == line.id);
  }

  // Check if a route is a favorite
  bool isRouteFavorite(BusRoute route) {
    return favoriteRoutes.any((existingRoute) => existingRoute.id == route.id);
  }

  // Check if a stop is a favorite
  bool isStopFavorite(BusStop stop) {
    return favoriteStops.any((existingStop) => existingStop.id == stop.id);
  }

  // Toggle the favorite status of a line
  void toggleFavoriteLine(BusLine line) {
    if (isLineFavorite(line)) {
      removeFavoriteLine(line);
    } else {
      addFavoriteLine(line);
    }
    saveFavorites();
  }

  // Toggle the favorite status of a route
  void toggleFavoriteRoute(BusRoute route) {
    if (isRouteFavorite(route)) {
      removeFavoriteRoute(route);
    } else {
      addFavoriteRoute(route);
    }
    saveFavorites();
  }

  // Toggle the favorite status of a line
  void toggleFavoriteBusStop(BusStop stop) {
    if (isStopFavorite(stop)) {
      removeFavoriteStop(stop);
    } else {
      addFavoriteStop(stop);
    }
    saveFavorites();
  }

  // Add a favorite route
  void addFavoriteRoute(BusRoute route) {
    if (!favoriteRoutes.any((existingRoute) => existingRoute.id == route.id)) {
      favoriteRoutes.add(route);
      notifyListeners();
    }
  }

  // Remove a favorite route
  void removeFavoriteRoute(BusRoute route) {
    favoriteRoutes.remove(route);
    notifyListeners();
  }

  // Add a favorite line
  void addFavoriteLine(BusLine line) {
    if (!favoriteLines.any((existingLine) => existingLine.id == line.id)) {
      favoriteLines.add(line);
      notifyListeners();
    }
  }

  // Remove a favorite line
  void removeFavoriteLine(BusLine line) {
    favoriteLines.remove(line);
    notifyListeners();
  }

  // Add a favorite stop
  void addFavoriteStop(BusStop stop) {
    if (!favoriteStops.any((existingStop) => existingStop.id == stop.id)) {
      favoriteStops.add(stop);
      notifyListeners();
    }
  }

  // Remove a favorite stop
  void removeFavoriteStop(BusStop stop) {
    favoriteStops.remove(stop);
    notifyListeners();
  }

  BusRoute findRouteById(int id) {
    return routes.firstWhere((route) => route.id == id,
        orElse: () => BusRoute.empty());
  }

  BusLine findLineById(int id) {
    return lines.firstWhere((line) => line.id == id,
        orElse: () => BusLine.empty());
  }

  void fetchToken() async {
    final response = await http.post(
      Uri.parse('$baseUrl/rest-auth/guests?aid=3136'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      token = json.decode(response.body);
      if (token is String) {
        print("Token is set in http_service to: " + (this.token ?? " null"));
      } else {
        throw Exception('Failed to fetch token');
      }
    } else {
      print("Request to fetch token failed");
    }

    routes = await fetchRoutes();
    lines = await fetchLines();
    stops = await fetchStops();
    busStopLines = await fetchBusStopLines();
    isDataLoaded = true;
    print("Data Loaded Successfully");
    notifyListeners();
  }

  Future<List<BusRoute>> fetchRoutes() async {
    int retryCount = 0;
    int maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/rest-its/scheme/routes'),
          headers: {
            "Content-Type": "application/json",
            tokenHeaderKey: token ?? ""
          },
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final List<dynamic> parsedList = json.decode(response.body);
          return parsedList
              .map<BusRoute>((json) => BusRoute.fromJson(json))
              .toList();
        } else {
          throw Exception(
              'Failed to fetch BusRoutes with status code: ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          if (e is TimeoutException) {
            throw Exception(
                'Request timed out after multiple attempts. Please try again.');
          } else if (e is SocketException) {
            throw Exception('Network issue. Please check your connection.');
          }
          rethrow;
        }
      }
    }
    throw Exception('Failed to fetch BusRoutes after multiple attempts.');
  }

  Future<List<BusLine>> fetchLines() async {
    int retryCount = 0;
    int maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/rest-its/scheme/lines'),
          headers: {
            "Content-Type": "application/json",
            tokenHeaderKey: token ?? ""
          },
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final List<dynamic> parsedList = json.decode(response.body);
          return parsedList
              .map<BusLine>((json) => BusLine.fromJson(json))
              .toList();
        } else {
          throw Exception(
              'Failed to fetch BusLines with status code: ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          if (e is TimeoutException) {
            throw Exception(
                'Request timed out after multiple attempts. Please try again.');
          } else if (e is SocketException) {
            throw Exception('Network issue. Please check your connection.');
          }
          rethrow; // For any other exceptions
        }
      }
    }

    throw Exception('Failed to fetch BusLines after multiple attempts.');
  }

  Future<List<BusStop>> fetchStops() async {
    int retryCount = 0;
    const int maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/rest-its/scheme/stops?filter=true'),
          headers: {
            "Content-Type": "application/json",
            tokenHeaderKey: token ?? ""
          },
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final List<dynamic> parsedList = json.decode(response.body);
          return parsedList
              .map<BusStop>((json) => BusStop.fromJson(json))
              .toList();
        } else {
          throw Exception(
              'Failed to fetch BusStops with status code: ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          if (e is TimeoutException) {
            throw Exception(
                'Request timed out after multiple attempts. Please try again.');
          } else if (e is SocketException) {
            throw Exception('Network issue. Please check your connection.');
          }
          rethrow; // For any other exceptions
        }
      }
    }

    // If all retries fail, you can handle it accordingly
    throw Exception('Failed to fetch BusStops after multiple attempts.');
  }

  Future<List<BusStopLine>> fetchBusStopLines() async {
    int retryCount = 0;
    const int maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse("$baseUrl/rest-its/scheme/stop-lines"),
          headers: {
            "Content-Type": "application/json",
            tokenHeaderKey: token ?? ""
          },
        ).timeout(const Duration(seconds: 5));

        switch (response.statusCode) {
          case 200:
            final List<dynamic> parsedList = json.decode(response.body);
            return parsedList
                .map<BusStopLine>((json) => BusStopLine.fromJson(json))
                .toList();

          case 400:
            throw Exception('Bad request. Please check the request format.');
          case 401:
            throw Exception('Unauthorized. Please check your token.');
          case 403:
            throw Exception('Forbidden. You do not have permission.');
          case 404:
            throw Exception('Endpoint not found.');
          default:
            throw Exception(
                'Failed to fetch BusStopLines with status code: ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          if (e is TimeoutException) {
            throw Exception(
                'Request timed out after multiple attempts. Please try again.');
          } else if (e is SocketException) {
            throw Exception('Network issue. Please check your connection.');
          }
          rethrow;
        }
      }
    }

    throw Exception('Failed to fetch BusStopLines after multiple attempts.');
  }
}
