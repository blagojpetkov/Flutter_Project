import 'package:flutter/material.dart';
import 'package:postojka/main.dart';
import 'package:postojka/models/BusLine.dart';
import 'package:postojka/screens/bus_line_detail_screen.dart';
import 'package:postojka/services/http_service.dart';
import 'package:postojka/services/voice_service.dart';
import 'package:provider/provider.dart';
import 'dart:math';
class BusLinesScreen extends StatefulWidget {
  @override
  _LinesScreenState createState() => _LinesScreenState();
}

class _LinesScreenState extends State<BusLinesScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // This will be called when the user comes back to this screen from another screen

    if (!mounted) return;
    speak();
  }

  void speak() {
    VoiceService voiceService =
        Provider.of<VoiceService>(context, listen: false);

    if (voiceService.voiceAssistantMode) {
      voiceService.speak("Успешно го отворивте менито линии");
      print("Успешно го отворивте менито линии");
    }
  }

  TextEditingController _searchController = TextEditingController();

  // This function will filter the lines based on the search query
  List<BusLine> _filterLines(List<BusLine> lines, String query) {
    if (query.isEmpty) {
      lines.sort(_naturalCompare);
      return lines;
    }

    final filteredLines = lines
        .where((line) => line.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    filteredLines.sort(_naturalCompare);

    return filteredLines;
  }

  int _naturalCompare(BusLine a, BusLine b) {
    final RegExp regExp = RegExp(r'(\d+|\D+)');
    final List<String> partsA =
        regExp.allMatches(a.name).map((m) => m.group(0)!).toList();
    final List<String> partsB =
        regExp.allMatches(b.name).map((m) => m.group(0)!).toList();

    for (int i = 0; i < min(partsA.length, partsB.length); i++) {
      final partA = partsA[i];
      final partB = partsB[i];

      final isPartANumeric = int.tryParse(partA) != null;
      final isPartBNumeric = int.tryParse(partB) != null;

      if (isPartANumeric && isPartBNumeric) {
        final num numA = int.parse(partA);
        final num numB = int.parse(partB);
        if (numA != numB) {
          return numA.compareTo(numB);
        }
      } else if (partA != partB) {
        return partA.compareTo(partB);
      }
    }

    return partsA.length.compareTo(partsB.length);
  }

  @override
  Widget build(BuildContext context) {
    HttpService httpService = Provider.of<HttpService>(context);
    speak();
    if (httpService.lines.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else {
      List<BusLine> filteredLines =
          _filterLines(httpService.lines, _searchController.text);

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
    routeObserver.unsubscribe(this);
    super.dispose();
  }
}
