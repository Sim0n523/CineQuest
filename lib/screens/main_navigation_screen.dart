import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'discover_screen.dart';
import 'quests_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';

/// The 5-tab shell from blueprint section 9: Home, Discover, Quests,
/// Leaderboard, Profile. Everything else opens from these.
///
/// Uses IndexedStack rather than swapping widgets so each tab keeps its
/// scroll position and provider-driven state when you switch away and back.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    DiscoverScreen(),
    QuestsScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.movie_rounded), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.flag_rounded), label: 'Quests'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard_rounded), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
