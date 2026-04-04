import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class VacanciesScreen extends StatefulWidget {
  final ApiService apiService;

  const VacanciesScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<VacanciesScreen> createState() => _VacanciesScreenState();
}

class _VacanciesScreenState extends State<VacanciesScreen> {
  final TextEditingController _queryController = TextEditingController();
  String _experience = 'noExperience';
  List<dynamic> _vacancies = [];
  List<String> _suggestions = [];
  bool _isLoading = false;
  bool _isLoadingSuggestions = true;
  bool _isFirstLoad = true;
  bool _isSuggestionsExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadCachedVacancies();
    _loadSuggestions();
  }

  Future<void> _loadCachedVacancies() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('cached_vacancies');
    final cachedQuery = prefs.getString('cached_vacancy_query');
    if (cachedJson != null && mounted) {
      try {
        final List<dynamic> cached = jsonDecode(cachedJson);
        setState(() {
          _vacancies = cached;
          _isFirstLoad = false;
          if (cachedQuery != null) _queryController.text = cachedQuery;
        });
        return;
      } catch (_) {}
    }
    _loadRecommendedVacancies();
  }

  Future<void> _cacheVacancies(List<dynamic> items, String query) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_vacancies', jsonEncode(items));
    await prefs.setString('cached_vacancy_query', query);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    setState(() => _isLoadingSuggestions = true);
    try {
      final suggestions = await widget.apiService.getVacancySuggestions();
      if (mounted) {
        setState(() => _suggestions = suggestions);
      }
    } catch (e) {
      print('Ошибка загрузки подсказок: $e');
      if (mounted) {
        setState(() {
          _suggestions = [
            'flutter developer',
            'python стажёр',
            'junior frontend',
            'аналитик данных',
            'java developer',
          ];
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingSuggestions = false);
    }
  }

  Future<void> _loadRecommendedVacancies() async {
    setState(() {
      _isLoading = true;
      _isFirstLoad = false;
    });

    String defaultQuery = _suggestions.isNotEmpty ? _suggestions.first : 'flutter developer';
    try {
      final items = await widget.apiService.getVacanciesScored(defaultQuery, _experience, 0);
      setState(() => _vacancies = items);
      if (items.isNotEmpty) _cacheVacancies(items, defaultQuery);
      if (items.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет вакансий по умолчанию, попробуйте другой запрос')),
        );
      }
    } catch (e) {
      print('Scored endpoint failed, falling back: $e');
      try {
        final items = await widget.apiService.getVacancies(defaultQuery, _experience, 0);
        if (mounted) {
          setState(() => _vacancies = items);
          if (items.isNotEmpty) _cacheVacancies(items, defaultQuery);
        }
      } catch (e2) {
        print('Ошибка загрузки: $e2');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка загрузки: $e2')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите профессию или навык')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _vacancies = [];
    });

    try {
      final items = await widget.apiService.getVacanciesScored(query, _experience, 0);
      setState(() => _vacancies = items);
      if (items.isNotEmpty) _cacheVacancies(items, query);
      if (items.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ничего не найдено. Попробуйте другой запрос или опыт')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Найдено ${items.length} вакансий')),
        );
      }
    } catch (e) {
      print('Scored endpoint failed, falling back: $e');
      try {
        final items = await widget.apiService.getVacancies(query, _experience, 0);
        if (mounted) {
          setState(() => _vacancies = items);
          if (items.isNotEmpty) _cacheVacancies(items, query);
          if (items.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ничего не найдено. Попробуйте другой запрос или опыт')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Найдено ${items.length} вакансий')),
            );
          }
        }
      } catch (e2) {
        print('Ошибка поиска: $e2');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: $e2')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchWithSuggestion(String query) async {
    _queryController.text = query;
    await _search();
  }

  void _toggleSuggestions() {
    setState(() {
      _isSuggestionsExpanded = !_isSuggestionsExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final cardBg = theme.cardColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Поиск вакансий',
          style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
        ),
        backgroundColor: cardBg,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadSuggestions();
              _loadRecommendedVacancies();
            },
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: Column(
        children: [
          // Панель поиска
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _queryController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Например: python стажёр',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[700]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: scaffoldBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _search,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Найти', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _experience,
                  dropdownColor: cardBg,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Опыт работы',
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: scaffoldBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'noExperience', child: Text('Нет опыта')),
                    DropdownMenuItem(value: 'between1And3', child: Text('1-3 года')),
                    DropdownMenuItem(value: 'between3And6', child: Text('3-6 лет')),
                    DropdownMenuItem(value: 'moreThan6', child: Text('Более 6 лет')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _experience = v);
                      if (_queryController.text.isNotEmpty) {
                        _search();
                      } else {
                        _loadRecommendedVacancies();
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Персональные подсказки от API с возможностью сворачивания
                if (!_isLoadingSuggestions && _suggestions.isNotEmpty) ...[
                  InkWell(
                    onTap: _toggleSuggestions,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            _isSuggestionsExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 18,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Подобрано под ваш профиль:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_suggestions.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isSuggestionsExpanded) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestions.map((query) {
                        return ActionChip(
                          label: Text(query, style: const TextStyle(fontSize: 12, color: Colors.white)),
                          onPressed: () => _searchWithSuggestion(query),
                          backgroundColor: scaffoldBg,
                          side: BorderSide(color: primaryColor.withOpacity(0.5)),
                          avatar: Icon(Icons.trending_up, size: 16, color: primaryColor),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 4),
                ] else if (_isLoadingSuggestions)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      height: 20,
                      child: LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        backgroundColor: scaffoldBg,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Список вакансий
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  )
                : _vacancies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business_center, size: 64, color: Colors.grey[700]),
                            const SizedBox(height: 16),
                            Text(
                              _isFirstLoad ? 'Загрузка вакансий...' : 'Ничего не найдено',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Попробуйте изменить запрос или выбрать опыт',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (!_isFirstLoad && _vacancies.isEmpty)
                              TextButton.icon(
                                onPressed: _loadRecommendedVacancies,
                                icon: Icon(Icons.refresh, color: primaryColor),
                                label: Text('Показать рекомендуемые', style: TextStyle(color: primaryColor)),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _vacancies.length,
                        itemBuilder: (ctx, i) {
                          final v = _vacancies[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: cardBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: InkWell(
                              onTap: () {
                                final url = v['url'] ?? '';
                                if (url.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Открыть в браузере: $url'),
                                      duration: const Duration(seconds: 3),
                                      action: SnackBarAction(
                                        label: 'OK',
                                        onPressed: () {},
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Ссылка не доступна')),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border(
                                    left: BorderSide(color: primaryColor, width: 3),
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.work,
                                            color: primaryColor,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                v['title'] ?? 'Без названия',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                v['company'] ?? 'Компания не указана',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: primaryColor,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (v['match_score'] != null && (v['match_score'] as num) > 0)
                                          Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: ((v['match_score'] as num) >= 70
                                                      ? theme.colorScheme.primary
                                                      : (v['match_score'] as num) >= 40
                                                          ? theme.colorScheme.secondary
                                                          : Colors.red)
                                                  .withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: (v['match_score'] as num) >= 70
                                                    ? theme.colorScheme.primary
                                                    : (v['match_score'] as num) >= 40
                                                        ? theme.colorScheme.secondary
                                                        : Colors.red,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              '${v['match_score']}%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: (v['match_score'] as num) >= 70
                                                    ? theme.colorScheme.primary
                                                    : (v['match_score'] as num) >= 40
                                                        ? theme.colorScheme.secondary
                                                        : Colors.red,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            v['city'] ?? 'Город не указан',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (v['salary'] != null && v['salary'].toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Row(
                                          children: [
                                            Icon(Icons.currency_ruble_rounded, size: 14, color: secondaryColor),
                                            const SizedBox(width: 4),
                                            Text(
                                              v['salary'],
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: secondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (v['schedule'] != null && v['schedule'].toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          children: [
                                            Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                                            const SizedBox(width: 4),
                                            Text(
                                              v['schedule'],
                                              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (v['match_reason'] != null && v['match_reason'].toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          v['match_reason'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey[400],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
