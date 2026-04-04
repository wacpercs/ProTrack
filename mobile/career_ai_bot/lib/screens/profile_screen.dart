// lib/screens/profile_screen.dart (Breaking Bad theme)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  final ApiService apiService;

  const ProfileScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();
  final _educationController = TextEditingController();
  final _interestsController = TextEditingController();
  final _skillsController = TextEditingController();

  String _gender = 'male';
  bool _isLoading = true;
  bool _isSaving = false;
  bool _profileExists = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _educationController.dispose();
    _interestsController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profileData = await widget.apiService.getProfile();
      if (profileData['exists'] == true && profileData['profile'] != null) {
        _profileExists = true;
        final profile = profileData['profile'];
        _nameController.text = profile['name'] ?? '';
        _ageController.text = profile['age']?.toString() ?? '';
        _cityController.text = profile['city'] ?? '';
        _educationController.text = profile['education'] ?? '';
        _interestsController.text = profile['interests'] ?? '';
        _skillsController.text = profile['skills'] ?? '';
        _gender = profile['gender'] ?? 'male';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final profileData = {
        'name': _nameController.text.trim(),
        'gender': _gender,
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'city': _cityController.text.trim(),
        'education': _educationController.text.trim(),
        'interests': _interestsController.text.trim(),
        'skills': _skillsController.text.trim(),
      };
      final success = await widget.apiService.updateProfile(profileData);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Профиль сохранён!')));
          _profileExists = true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка сохранения')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[500]),
      prefixIcon: Icon(icon, color: Colors.grey[500]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Мой профиль',
          style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF252525),
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadProfile,
              tooltip: 'Обновить',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: const Color(0xFF252525),
            onSelected: (value) async {
              if (value == 'about') {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF252525),
                    title: const Text('О разработчиках', style: TextStyle(color: Colors.white, fontFamily: 'Courier')),
                    content: const Text(
                      'Сазонов Захар\nПаршин Даниил\nКонтакт для связи: Gmail\nZaharsazonov5@gmail.com',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Закрыть', style: TextStyle(color: Color(0xFF00C853))),
                      ),
                    ],
                  ),
                );
              } else if (value == 'logout') {
                await widget.apiService.logout();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem<String>(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white70),
                    SizedBox(width: 12),
                    Text('О разработчиках', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent),
                    SizedBox(width: 12),
                    Text('Выйти', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(Icons.person, size: 80, color: Color(0xFF00C853)),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Имя', Icons.person_outline),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите имя' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      dropdownColor: const Color(0xFF252525),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Пол', Icons.people_outline),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Мужской')),
                        DropdownMenuItem(value: 'female', child: Text('Женский')),
                        DropdownMenuItem(value: 'scp', child: Text('Другой')),
                      ],
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Возраст', Icons.cake_outlined),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v != null && v.isNotEmpty) {
                          final age = int.tryParse(v);
                          if (age == null || age < 14 || age > 120) return '14-120 лет';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Город', Icons.location_city_outlined),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _educationController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: _inputDecoration('Образование', Icons.school_outlined),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _interestsController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: _inputDecoration('Интересы', Icons.favorite_outline),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _skillsController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: _inputDecoration('Навыки', Icons.code_outlined),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: const Color(0xFF1A1A1A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A1A1A)),
                              ),
                            )
                          : const Text(
                              'Сохранить профиль',
                              style: TextStyle(fontSize: 16, fontFamily: 'Courier', fontWeight: FontWeight.bold),
                            ),
                    ),
                    if (_profileExists)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Профиль создан',
                          style: TextStyle(color: const Color(0xFF00C853), fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
