import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpService {
  final String baseUrl;
  final String headerKey = "Eurogps.Eu.Sid";
  String? token;
  HttpService({required this.baseUrl});

  void fetchToken() async {
    try {
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
      }
    } catch (error) {
      print("Network error: $error");
    }
  }

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> post(String endpoint, [dynamic data]) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {"Content-Type": "application/json"},
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
