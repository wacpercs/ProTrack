import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://89.125.118.57:8000/api';

  String? _authToken;
  int? _userId;

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('api_token');
    _userId = prefs.getInt('user_id');
  }

  Future<void> saveCredentials(String token, int userId) async {
    _authToken = token;
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_token', token);
    await prefs.setInt('user_id', userId);
  }

  Future<void> clearCredentials() async {
    _authToken = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
    await prefs.remove('user_id');
  }

  Future<void> logout() async => clearCredentials();

  Future<Map<String, String>> _getHeaders() async {
    if (_authToken == null) await _loadCredentials();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<http.Response> _makeRequest(
    String method,
    String endpoint,
    {Map<String, String>? headers,
    Object? body}
  ) async {
    final requestUrl = '$baseUrl$endpoint';

    debugPrint('Request: $method $requestUrl');

    try {
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(
            Uri.parse(requestUrl),
            headers: headers ?? await _getHeaders(),
          ).timeout(const Duration(seconds: 30));
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(requestUrl),
            headers: headers ?? await _getHeaders(),
            body: body,
          ).timeout(const Duration(seconds: 30));
          break;
        default:
          throw Exception('Unsupported method');
      }

      debugPrint('Status: ${response.statusCode}');
      return response;

    } catch (e) {
      debugPrint('Request error: $e');
      rethrow;
    }
  }

  // Регистрация
  Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      debugPrint('Register: $username');

      final response = await _makeRequest(
        'POST',
        '/auth/register',
        body: jsonEncode({
          'username': username.trim(),
          'password': password,
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['token'] != null && data['user_id'] != null) {
          await saveCredentials(data['token'], data['user_id']);
          return {'success': true};
        } else {
          return {'success': false, 'error': 'Неверный ответ сервера'};
        }
      } else {
        return {
          'success': false,
          'error': data['error'] ?? data['message'] ?? 'Ошибка регистрации. Попробуйте другой логин.'
        };
      }
    } on FormatException {
      return {'success': false, 'error': 'Ошибка формата данных'};
    } catch (e) {
      debugPrint('Registration error: $e');
      return {'success': false, 'error': 'Ошибка: $e'};
    }
  }

  // Логин
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      debugPrint('Login: $username');

      final response = await _makeRequest(
        'POST',
        '/auth/login',
        body: jsonEncode({
          'username': username.trim(),
          'password': password,
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['token'] != null && data['user_id'] != null) {
          await saveCredentials(data['token'], data['user_id']);
          return {'success': true};
        } else {
          return {'success': false, 'error': 'Неверный ответ сервера'};
        }
      } else {
        return {
          'success': false,
          'error': data['error'] ?? data['message'] ?? 'Неверный логин или пароль'
        };
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return {'success': false, 'error': 'Ошибка: $e'};
    }
  }

  bool get isAuthenticated => _authToken != null && _userId != null;

  // Профиль
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _makeRequest('GET', '/profile');
      return jsonDecode(response.body);
    } catch (e) {
      return {'exists': false, 'error': e.toString()};
    }
  }

  // Обновление профиля
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/profile',
        body: jsonEncode(profileData),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Профессии
  Future<String> getProfessions() async {
    try {
      final response = await _makeRequest('GET', '/professions');
      final data = jsonDecode(response.body);
      return data['result'] ?? 'Не удалось получить рекомендации';
    } catch (e) {
      return 'Ошибка загрузки: $e';
    }
  }

  // Карьерный план
  Future<String> getCareerPlan() async {
    try {
      final response = await _makeRequest('GET', '/career-plan');
      final data = jsonDecode(response.body);
      return data['result'] ?? 'Не удалось получить план';
    } catch (e) {
      return 'Ошибка загрузки: $e';
    }
  }

  // Чат
  Future<String> sendMessage(String message) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/chat',
        body: jsonEncode({'message': message}),
      );
      final data = jsonDecode(response.body);
      return data['reply'] ?? 'Не удалось получить ответ';
    } catch (e) {
      return 'Ошибка: $e';
    }
  }

  // Вакансии
  Future<List<dynamic>> getVacancies(String query, String experience, int page) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/vacancies',
        body: jsonEncode({
          'query': query,
          'experience': experience,
          'page': page
        }),
      );
      final data = jsonDecode(response.body);
      return data['items'] ?? [];
    } catch (e) {
      debugPrint('Error loading vacancies: $e');
      return [];
    }
  }

  // Skill Gap Analysis
  Future<String> getSkillGap() async {
    try {
      final response = await _makeRequest('GET', '/skill-gap');
      final data = jsonDecode(response.body);
      return data['result'] ?? 'Не удалось провести анализ';
    } catch (e) {
      return 'Ошибка загрузки: $e';
    }
  }

  // Вакансии со скорингом
  Future<List<dynamic>> getVacanciesScored(String query, String experience, int page) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/vacancies/scored',
        body: jsonEncode({
          'query': query,
          'experience': experience,
          'page': page
        }),
      );
      final data = jsonDecode(response.body);
      return data['items'] ?? [];
    } catch (e) {
      debugPrint('Error loading scored vacancies: $e');
      return getVacancies(query, experience, page);
    }
  }

  // Подсказки для поиска
  Future<List<String>> getVacancySuggestions() async {
    try {
      final response = await _makeRequest('GET', '/vacancy-suggestions');
      final data = jsonDecode(response.body);
      return List<String>.from(data['queries'] ?? []);
    } catch (e) {
      debugPrint('Error loading suggestions: $e');
      return ['python разработчик', 'frontend стажер', 'аналитик данных'];
    }
  }
}
