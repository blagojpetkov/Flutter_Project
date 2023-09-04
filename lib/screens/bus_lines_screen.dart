import 'package:flutter/material.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/screens/bus_line_detail_screen.dart';
import 'package:postojka/services/http_service.dart';
import 'package:provider/provider.dart';

class BusLinesScreen extends StatefulWidget {
  @override
  _LinesScreenState createState() => _LinesScreenState();
}

class _LinesScreenState extends State<BusLinesScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    HttpService httpService = Provider.of<HttpService>(context);
    httpService.setCurrentScreen(AppScreens.BusLines);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HttpService>(
      builder: (context, httpService, child) {
        if (httpService.voiceAssistantMode) {
          httpService.speak("Успешно го отворивте менито линии");
        }
        if (httpService.lines.isEmpty) {
          // If lines list is empty, show a loading indicator
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: httpService.lines.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(httpService.lines[index].name),
                  onTap: () {
                    // Add onTap callback
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BusLineDetailScreen(
                          line: httpService.lines[index],
                          httpService: httpService,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
