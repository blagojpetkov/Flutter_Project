import 'package:flutter/material.dart';
import 'package:postojka/screens/bus_line_detail_screen.dart';
import 'package:postojka/services/http_service.dart';
import 'package:provider/provider.dart';

class FavoriteBusLinesScreen extends StatefulWidget {
  @override
  _FavoriteBusLinesScreenState createState() => _FavoriteBusLinesScreenState();
}

class _FavoriteBusLinesScreenState extends State<FavoriteBusLinesScreen> {
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
        if (httpService.favoriteLines.isEmpty) {
          // If lines list is empty, show a loading indicator
          // return Center(child: CircularProgressIndicator());
          return const Center(child: Text("Немате одбрано омилени линии.", style: TextStyle(fontSize: 20),));
        } else {
          return ListView.builder(
            itemCount: httpService.favoriteLines.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(httpService.favoriteLines[index].name),
                  onTap: () {  // Add onTap callback
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BusLineDetailScreen(line: httpService.favoriteLines[index], httpService: httpService,),
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
