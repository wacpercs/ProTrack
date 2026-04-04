// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'career_tab_screen.dart';
import 'vacancies_screen.dart';
import 'profile_screen.dart';
import 'onboarding_screen.dart';

class MainScreen extends StatefulWidget {
  final ApiService apiService;
  const MainScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _profileLoaded = false;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      final data = await widget.apiService.getProfile();
      if (mounted) {
        setState(() {
          _profileLoaded = true;
          _hasProfile = data['exists'] == true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _profileLoaded = true;
          _hasProfile = false;
        });
      }
    }
  }

  void _onOnboardingComplete() {
    setState(() {
      _hasProfile = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_profileLoaded) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
      );
    }

    if (!_hasProfile) {
      return OnboardingScreen(
        apiService: widget.apiService,
        onProfileSaved: _onOnboardingComplete,
      );
    }

    final screens = <Widget>[
      DashboardScreen(
        onNavigate: (idx) => setState(() => _selectedIndex = idx),
      ),
      CareerTabScreen(apiService: widget.apiService),
      VacanciesScreen(apiService: widget.apiService),
      ProfileScreen(apiService: widget.apiService),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: theme.scaffoldBackgroundColor,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: const Color(0xFF757575),
        selectedLabelStyle: const TextStyle(fontFamily: 'Courier', fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Courier', fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.science_outlined), label: 'Карьера'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Вакансии'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Профиль'),
        ],
      ),
    );
  }
}
