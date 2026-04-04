// lib/screens/career_tab_screen.dart
import 'package:flutter/material.dart';
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
  bool _isLoadingProfessions = false;
  bool _isLoadingPlan = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _loadProfessions() async {
    setState(() => _isLoadingProfessions = true);
    _professions = await widget.apiService.getProfessions();
    setState(() => _isLoadingProfessions = false);
  }

  Future<void> _loadCareerPlan() async {
    setState(() => _isLoadingPlan = true);
    _careerPlan = await widget.apiService.getCareerPlan();
    setState(() => _isLoadingPlan = false);
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfessionsTab(primaryColor, scaffoldBg, cardBg),
          _buildCareerPlanTab(secondaryColor, scaffoldBg, cardBg, primaryColor),
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
            label: const Text('Подобрать профессии'),
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
            label: const Text('Карьерный план'),
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
