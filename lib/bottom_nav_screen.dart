import 'package:flutter/material.dart';
import 'package:pristine_andaman/BookRide/search_location_page.dart';

import 'DrawerPages/Profile/profile_page.dart';
import 'DrawerPages/Rides/my_rides_page.dart';

class BottomNavScreen extends StatefulWidget {
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    SearchLocationPage(),
     MyRidesPage("3",fromWhere: true,),
    ProfilePage(
      fromWhere: true,
    )
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/home.png', width: 24, height: 24),
            activeIcon: Image.asset('assets/home1.png', width: 24, height: 24),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/car.png', width: 24, height: 24),
            activeIcon: Image.asset('assets/car1.png', width: 24, height: 24),
            label: "My Rides",
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/profile.png', width: 24, height: 24),
            activeIcon:
                Image.asset('assets/profile1.png', width: 24, height: 24),
            label: "Profile",
          ),

        ],
      ),
    );
  }
}
