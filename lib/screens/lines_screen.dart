import 'package:flutter/material.dart';
import 'package:postojka/services/http_service.dart';
import 'package:provider/provider.dart';

class LinesScreen extends StatefulWidget {
  @override
  _LinesScreenState createState() => _LinesScreenState();
}

class _LinesScreenState extends State<LinesScreen> {
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
        if (httpService.lines.isEmpty) {
          // If lines list is empty, show a loading indicator
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: httpService.lines.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(title: Text(httpService.lines[index].name)),
              );
            },
          );
        }
      },
    );
  }
}
