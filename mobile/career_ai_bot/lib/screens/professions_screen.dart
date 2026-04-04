import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfessionsScreen extends StatefulWidget {
  final ApiService apiService;

  const ProfessionsScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<ProfessionsScreen> createState() => _ProfessionsScreenState();
}

class _ProfessionsScreenState extends State<ProfessionsScreen> {
  String _result = '';
  bool _isLoading = false;

  Future<void> _load() async {
    setState(() => _isLoading = true);
    _result = await widget.apiService.getProfessions();
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
          'Подбор профессий',
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
              child: Text(_result, style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
    );
  }
}
