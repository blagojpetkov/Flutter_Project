import 'package:flutter/material.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/screens/bus_stop_detail_screen.dart';  // Ensure this import exists.
import 'package:postojka/services/http_service.dart';
import 'package:provider/provider.dart';

class FavoriteBusStopsScreen extends StatefulWidget {
  @override
  _FavoriteBusStopsScreenState createState() => _FavoriteBusStopsScreenState();
}

class _FavoriteBusStopsScreenState extends State<FavoriteBusStopsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HttpService>(
      builder: (context, httpService, child) {
        httpService.setCurrentScreen(AppScreens.FavoriteBusStops);
        if (httpService.favoriteStops.isEmpty) {
          // If stops list is empty, show a loading indicator
          // return Center(child: CircularProgressIndicator());
          return const Center(child: Text("Немате одбрано омилени постојки.", style: TextStyle(fontSize: 20),));
        } else {
          return ListView.builder(
            itemCount: httpService.favoriteStops.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(httpService.favoriteStops[index].name),
                  subtitle: Text(httpService.favoriteStops[index].number),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BusStopDetailScreen(busStop: httpService.favoriteStops[index]),
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