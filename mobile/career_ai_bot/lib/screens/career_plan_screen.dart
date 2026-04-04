import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CareerPlanScreen extends StatefulWidget {
  final ApiService apiService;

  const CareerPlanScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<CareerPlanScreen> createState() => _CareerPlanScreenState();
}

class _CareerPlanScreenState extends State<CareerPlanScreen> {
  String _plan = '';
  bool _isLoading = false;

  Future<void> _load() async {
    setState(() => _isLoading = true);
    _plan = await widget.apiService.getCareerPlan();
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Карьерный план',
          style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.cardColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(_plan, style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
    );
  }
}
