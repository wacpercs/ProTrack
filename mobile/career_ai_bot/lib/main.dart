import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'providers/theme_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';  // Добавлен импорт MainScreen
import 'screens/profile_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/vacancies_screen.dart';
import 'screens/professions_screen.dart';
import 'screens/career_plan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('api_token');
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(apiService: apiService, isAuthenticated: token != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  final bool isAuthenticated;
  
  const MyApp({Key? key, required this.apiService, required this.isAuthenticated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Career AI Bot',
          theme: themeProvider.themeData,
          debugShowCheckedModeBanner: false,
          initialRoute: isAuthenticated ? '/' : '/auth',
          routes: {
            '/auth': (context) => AuthScreen(apiService: apiService),
            '/': (context) => MainScreen(apiService: apiService),  // Изменено с HomeScreen на MainScreen
            '/profile': (context) => ProfileScreen(apiService: apiService),
            '/chat': (context) => ChatScreen(apiService: apiService),
            '/vacancies': (context) => VacanciesScreen(apiService: apiService),
            '/professions': (context) => ProfessionsScreen(apiService: apiService),
            '/career-plan': (context) => CareerPlanScreen(apiService: apiService),
          },
        );
      },
    );
  }
}