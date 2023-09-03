// import 'package:flutter/material.dart';

// class MyBottomNavigationBar extends StatefulWidget {
//   const MyBottomNavigationBar({super.key});

//   @override
//   State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
// }

// class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {

//   int currentIndex = 0;
//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         selectedIconTheme: const IconThemeData(color: Colors.black),
//         unselectedIconTheme: const IconThemeData(color: Colors.blueGrey),
//         currentIndex: currentIndex,
//         onTap: (index) {
//           setState(() {
//             currentIndex = index;
//           });

//           if (index == 0) {
//             Navigator.of(context).pushReplacementNamed('/lines');
//           }
//           else if (index == 1) {
//             Navigator.of(context).pushReplacementNamed('/stops');
//           }
//           else if (index == 2) {
//             Navigator.of(context).pushReplacementNamed('/lines');
//           }
//           else if (index == 3) {
//             Navigator.of(context).pushReplacementNamed('/lines');
//           }
//           else if (index == 4) {
//             Navigator.of(context).pushReplacementNamed('/home');
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.directions_bus),
//             label: 'Линии',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.pin_drop),
//             label: 'Постојки',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.favorite),
//             label: 'Омилени',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.circle),
//             label: 'Circle',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.crop_square),
//             label: 'Square',
//           ),
//         ],
      
//     );
//   }
// }
