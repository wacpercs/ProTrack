// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'career_tab_screen.dart';
import 'vacancies_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final ApiService apiService;
  const MainScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      CareerTabScreen(apiService: widget.apiService),
      VacanciesScreen(apiService: widget.apiService),
      ProfileScreen(apiService: widget.apiService),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: const Color(0xFF00C853),
        unselectedItemColor: const Color(0xFF757575),
        selectedLabelStyle: const TextStyle(fontFamily: 'Courier', fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Courier', fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.science_outlined), label: 'Карьера'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Вакансии'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Профиль'),
        ],
      ),
    );
  }
}
