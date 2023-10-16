import 'package:flutter/material.dart';
import 'package:postojka/models/BusStop.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/screens/bus_stop_detail_screen.dart'; // Ensure this import exists.
import 'package:postojka/services/http_service.dart';
import 'package:postojka/services/voice_service.dart';
import 'package:provider/provider.dart';

class BusStopsScreen extends StatefulWidget {
  @override
  _BusStopsScreenState createState() => _BusStopsScreenState();
}

class _BusStopsScreenState extends State<BusStopsScreen> {
  TextEditingController _searchController = TextEditingController();

  // This function will filter the stops based on the search query
  List<BusStop> _filterStops(List<BusStop> stops, String query) {
    if (query.isEmpty) {
      return stops;
    }
    return stops
        .where((stop) => stop.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    HttpService httpService = Provider.of<HttpService>(context, listen: false);
    VoiceService voiceService = Provider.of<VoiceService>(context, listen: false);

    if (voiceService.voiceAssistantMode) {
      voiceService.speak("Успешно го отворивте менито постојки");
      print("Успешно го отворивте менито постојки");
    }
    if (httpService.stops.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else {
      List<BusStop> filteredStops = _filterStops(httpService.stops, _searchController.text);

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Пребарувај постојки',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStops.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(filteredStops[index].name),
                    subtitle: Text(filteredStops[index].number),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BusStopDetailScreen(
                              busStop: filteredStops[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}