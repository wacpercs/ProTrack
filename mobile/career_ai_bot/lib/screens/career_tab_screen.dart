// lib/screens/career_tab_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class CareerTabScreen extends StatefulWidget {
  final ApiService apiService;

  const CareerTabScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<CareerTabScreen> createState() => _CareerTabScreenState();
}

class _CareerTabScreenState extends State<CareerTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _professions = '';
  String _careerPlan = '';
  String _skillGap = '';
  bool _isLoadingProfessions = false;
  bool _isLoadingPlan = false;
  bool _isLoadingSkillGap = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCachedResults();
  }

  Future<void> _loadCachedResults() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedProfessions = prefs.getString('cached_professions');
    final cachedCareerPlan = prefs.getString('cached_career_plan');
    final cachedSkillGap = prefs.getString('cached_skill_gap');
    if (mounted) {
      setState(() {
        if (cachedProfessions != null) _professions = cachedProfessions;
        if (cachedCareerPlan != null) _careerPlan = cachedCareerPlan;
        if (cachedSkillGap != null) _skillGap = cachedSkillGap;
      });
    }
  }

  Future<void> _saveCachedResult(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _loadProfessions() async {
    setState(() => _isLoadingProfessions = true);
    final result = await widget.apiService.getProfessions();
    if (mounted) {
      setState(() {
        _professions = result;
        _isLoadingProfessions = false;
      });
      _saveCachedResult('cached_professions', result);
    }
  }

  Future<void> _loadCareerPlan() async {
    setState(() => _isLoadingPlan = true);
    final result = await widget.apiService.getCareerPlan();
    if (mounted) {
      setState(() {
        _careerPlan = result;
        _isLoadingPlan = false;
      });
      _saveCachedResult('cached_career_plan', result);
    }
  }

  Future<void> _loadSkillGap() async {
    setState(() => _isLoadingSkillGap = true);
    final result = await widget.apiService.getSkillGap();
    if (mounted) {
      setState(() {
        _skillGap = result;
        _isLoadingSkillGap = false;
      });
      _saveCachedResult('cached_skill_gap', result);
    }
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
          'Карьера',
          style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
        ),
        backgroundColor: cardBg,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey[500],
          tabs: const [
            Tab(text: 'Профессии'),
            Tab(text: 'Карьерный план'),
            Tab(text: 'Skill Gap'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfessionsTab(primaryColor, scaffoldBg, cardBg),
          _buildCareerPlanTab(secondaryColor, scaffoldBg, cardBg, primaryColor),
          _buildSkillGapTab(primaryColor, scaffoldBg, cardBg),
        ],
      ),
    );
  }

  Widget _buildProfessionsTab(Color primaryColor, Color scaffoldBg, Color cardBg) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _loadProfessions,
            icon: const Icon(Icons.auto_awesome),
            label: Text(_professions.isEmpty ? 'Подобрать профессии' : 'Перегенерировать'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI проанализирует твои интересы и навыки и подберет подходящие профессии',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoadingProfessions
                ? _buildLoadingAnimation('Анализирую профиль...', primaryColor)
                : _buildResultCard(_professions, cardBg),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerPlanTab(Color secondaryColor, Color scaffoldBg, Color cardBg, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _loadCareerPlan,
            icon: const Icon(Icons.timeline),
            label: Text(_careerPlan.isEmpty ? 'Карьерный план' : 'Перегенерировать'),
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI составит план развития карьеры с конкретными ресурсами и сроками',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoadingPlan
                ? _buildLoadingAnimation('Составляю план...', primaryColor)
                : _buildResultCard(_careerPlan, cardBg),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillGapTab(Color primaryColor, Color scaffoldBg, Color cardBg) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _loadSkillGap,
            icon: const Text('\u{1F4CA}', style: TextStyle(fontSize: 18)),
            label: Text(_skillGap.isEmpty ? 'Анализ навыков' : 'Перегенерировать'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI определит разрыв между текущими навыками и требованиями рынка',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoadingSkillGap
                ? _buildLoadingAnimation('Анализирую навыки...', primaryColor)
                : _buildResultCard(_skillGap, cardBg),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingAnimation(String text, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          const SizedBox(height: 8),
          _buildDotsAnimation(primaryColor),
        ],
      ),
    );
  }

  Widget _buildDotsAnimation(Color primaryColor) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildResultCard(String content, Color cardBg) {
    if (content.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Нажмите кнопку, чтобы получить рекомендации',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Text(content, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.white)),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
