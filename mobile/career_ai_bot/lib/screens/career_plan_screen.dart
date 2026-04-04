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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Карьерный план',
          style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF252525),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(_plan, style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
    );
  }
}
