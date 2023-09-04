import 'package:flutter/material.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/screens/bus_stop_detail_screen.dart'; // Ensure this import exists.
import 'package:postojka/services/http_service.dart';
import 'package:provider/provider.dart';

class BusStopsScreen extends StatefulWidget {
  @override
  _BusStopsScreenState createState() => _BusStopsScreenState();
}

class _BusStopsScreenState extends State<BusStopsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    HttpService httpService = Provider.of<HttpService>(context);
    httpService.setCurrentScreen(AppScreens.BusStops);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HttpService>(
      builder: (context, httpService, child) {
        if (httpService.voiceAssistantMode) {
          httpService.speak("Успешно го отворивте менито постојки");
        }
        if (httpService.stops.isEmpty) {
          // If stops list is empty, show a loading indicator
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: httpService.stops.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(httpService.stops[index].name),
                  subtitle: Text(httpService.stops[index].number),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BusStopDetailScreen(
                            busStop: httpService.stops[index]),
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
