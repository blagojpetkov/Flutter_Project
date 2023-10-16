import 'package:flutter/material.dart';
import 'package:postojka/models/BusLine.dart';
import 'package:postojka/screens/bus_line_detail_screen.dart';
import 'package:postojka/services/http_service.dart';
import 'package:postojka/services/voice_service.dart';
import 'package:provider/provider.dart';
class BusLinesScreen extends StatefulWidget {
  @override
  _LinesScreenState createState() => _LinesScreenState();
}

class _LinesScreenState extends State<BusLinesScreen> {
  TextEditingController _searchController = TextEditingController();

  // This function will filter the lines based on the search query
  List<BusLine> _filterLines(List<BusLine> lines, String query) {
    if (query.isEmpty) {
      return lines;
    }
    return lines
        .where((line) => line.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    HttpService httpService = Provider.of<HttpService>(context);
    VoiceService voiceService = Provider.of<VoiceService>(context, listen: false);

    if (voiceService.voiceAssistantMode) {
      voiceService.speak("Успешно го отворивте менито линии");
      print("Успешно го отворивте менито линии");
    }
    if (httpService.lines.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else {
      List<BusLine> filteredLines = _filterLines(httpService.lines, _searchController.text);

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Пребарувај линии',
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
              itemCount: filteredLines.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(filteredLines[index].name),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BusLineDetailScreen(
                            line: filteredLines[index],
                            httpService: httpService,
                          ),
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