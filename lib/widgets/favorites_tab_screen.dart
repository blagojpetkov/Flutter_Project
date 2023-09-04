import 'package:flutter/material.dart';
import 'package:postojka/main.dart';
import 'package:postojka/screens/favorite_bus_lines_screen.dart';
import 'package:postojka/screens/favorite_bus_routes_screen.dart';
import 'package:postojka/screens/favorite_bus_stops_screen.dart';
import 'package:postojka/services/http_service.dart';
import 'package:provider/provider.dart';

class FavoritesTabScreen extends StatefulWidget {
  @override
  _FavoritesTabScreenState createState() => _FavoritesTabScreenState();
}

class _FavoritesTabScreenState extends State<FavoritesTabScreen>
    with SingleTickerProviderStateMixin {
  int _favoriteTabIndex = 0;
  TabController? _tabController;

  final _favoritePages = [
    FavoriteBusLinesScreen(),
    FavoriteBusStopsScreen(),
    FavoriteBusRoutesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _favoritePages.length);
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        setState(() {
          _favoriteTabIndex = _tabController!.index;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final httpService = Provider.of<HttpService>(context);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: AppColors.secondaryBackground,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context)
                .colorScheme
                .secondary, // Use your theme's secondary color
            tabs: [
              Tab(text: 'Линии'),
              Tab(text: 'Постојки'),
              Tab(text: 'Рути'),
            ],
          ),
        ),
        Expanded(child: _favoritePages[_favoriteTabIndex]),
      ],
    );
  }
}
