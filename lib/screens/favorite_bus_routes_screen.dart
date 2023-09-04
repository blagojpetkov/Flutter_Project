import 'package:flutter/material.dart';
import 'package:postojka/models/enumerations/app_screens.dart';
import 'package:postojka/screens/bus_line_detail_screen.dart';
import 'package:postojka/screens/bus_route_detail_screen.dart';
import 'package:postojka/services/http_service.dart';
import 'package:provider/provider.dart';

class FavoriteBusRoutesScreen extends StatefulWidget {
  @override
  _FavoriteBusRoutesScreenState createState() => _FavoriteBusRoutesScreenState();
}

class _FavoriteBusRoutesScreenState extends State<FavoriteBusRoutesScreen> {
  @override
  void initState() {
    super.initState();
    // The fetchToken method is already called inside HttpService's constructor,
    // so there's no need to call it here.
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HttpService>(
      builder: (context, httpService, child) {
        httpService.setCurrentScreen(AppScreens.FavoriteBusRoutes);
        if (httpService.favoriteRoutes.isEmpty) {
          // If lines list is empty, show a loading indicator
          // return Center(child: CircularProgressIndicator());
          return const Center(child: Text("Немате одбрано омилени рути.", style: TextStyle(fontSize: 20),));
        } else {
          return ListView.builder(
            itemCount: httpService.favoriteRoutes.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(httpService.favoriteRoutes[index].name),
                  onTap: () {  // Add onTap callback
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BusRouteDetailScreen(route: httpService.favoriteRoutes[index], allStops: httpService.stops, line: httpService.findLineById(httpService.favoriteRoutes[index].lineId)),
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
