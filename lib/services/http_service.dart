import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:postojka/models/BusStopLine.dart';
import 'dart:convert';

import '../models/BusLine.dart';
import '../models/BusRoute.dart';
import '../models/BusStop.dart';

class HttpService with ChangeNotifier {
  final String baseUrl = 'http://info.skopska.mk:8080';
  final String tokenHeaderKey = "Eurogps.Eu.Sid";
  String? token;

  List<BusRoute> routes = [];
  List<BusLine> lines = [];
  List<BusStop> stops = [];
  List<BusStopLine> busStopLines = [];

  HttpService() {
    fetchToken();
  }

  BusRoute findRouteById(int id) {
    return routes.firstWhere((route) => route.id == id,
        orElse: () => BusRoute.empty());
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
    print("Data Loaded Successfully");
    notifyListeners();
  }

  Future<List<BusRoute>> fetchRoutes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rest-its/scheme/routes'),
      headers: {
        "Content-Type": "application/json",
        tokenHeaderKey: token ?? ""
      },
    );
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<BusRoute>((json) => BusRoute.fromJson(json)).toList();
  }

  Future<List<BusLine>> fetchLines() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rest-its/scheme/lines'),
      headers: {
        "Content-Type": "application/json",
        tokenHeaderKey: token ?? ""
      },
    );

    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<BusLine>((json) => BusLine.fromJson(json)).toList();
  }

  Future<List<BusStop>> fetchStops() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rest-its/scheme/stops?filter=true'),
      headers: {
        "Content-Type": "application/json",
        tokenHeaderKey: token ?? ""
      },
    );

    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<BusStop>((json) => BusStop.fromJson(json)).toList();
  }

  Future<List<BusStopLine>> fetchBusStopLines() async {
    final response = await http.get(
      Uri.parse("$baseUrl/rest-its/scheme/stop-lines"),
      headers: {
        "Content-Type": "application/json",
        tokenHeaderKey: token ?? ""
      },
    );

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);
      return parsed
          .map<BusStopLine>((json) => BusStopLine.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch BusStopLines');
    }
  }

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'), headers: {
      "Content-Type": "application/json",
      tokenHeaderKey: token ?? ""
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> post(String endpoint, [dynamic data]) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        "Content-Type": "application/json",
        tokenHeaderKey: token ?? ""
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to post data');
    }
  }

  // You can also add methods for PUT, DELETE, etc.
}
