import 'package:flutter/material.dart';
import 'package:mapmoa/widgets/custom_bottom_nav_bar.dart';
import 'package:mapmoa/map/map_main.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const MapMainPage(),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
