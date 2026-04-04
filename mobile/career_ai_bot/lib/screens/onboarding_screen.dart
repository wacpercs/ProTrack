// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OnboardingScreen extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback? onProfileSaved;

  const OnboardingScreen({Key? key, required this.apiService, this.onProfileSaved}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1
  final _nameController = TextEditingController();
  String? _gender;

  // Step 2
  int? _age;

  // Step 3
  final _cityController = TextEditingController();

  // Step 4
  String? _education;

  // Step 5
  final _interestsController = TextEditingController();

  // Step 6
  final _skillsController = TextEditingController();

  bool _isSaving = false;

  final List<String> _educationOptions = [
    'Школьник 9-11 класс',
    'Студент колледжа/СПО',
    'Студент вуза',
    'Выпускник',
  ];

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
          'Создание профиля',
          style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
        ),
        backgroundColor: cardBg,
        foregroundColor: Colors.white,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentStep--),
              )
            : null,
      ),
      body: Theme(
        data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: primaryColor,
            onSurface: Colors.white,
          ),
          canvasColor: scaffoldBg,
        ),
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: _nextStep,
            onStepCancel: _currentStep > 0 ? () => setState(() => _currentStep--) : null,
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        minimumSize: const Size(120, 45),
                      ),
                      child: Text(
                        _currentStep == 6 ? 'Готово' : 'Далее',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Назад', style: TextStyle(color: Colors.grey)),
                      ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Шаг 1 из 7', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Как тебя зовут?', style: TextStyle(color: Colors.grey)),
                content: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Твое имя',
                        labelStyle: TextStyle(color: Colors.grey[500]),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: cardBg,
                      ),
                      validator: (v) => v!.isEmpty ? 'Введите имя' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Кто ты?', style: TextStyle(color: Colors.white)),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Мальчик'),
                            selected: _gender == 'male',
                            selectedColor: primaryColor,
                            labelStyle: TextStyle(
                              color: _gender == 'male' ? theme.colorScheme.onPrimary : Colors.white,
                            ),
                            backgroundColor: cardBg,
                            onSelected: (s) => setState(() => _gender = s ? 'male' : null),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Девочка'),
                            selected: _gender == 'female',
                            selectedColor: primaryColor,
                            labelStyle: TextStyle(
                              color: _gender == 'female' ? theme.colorScheme.onPrimary : Colors.white,
                            ),
                            backgroundColor: cardBg,
                            onSelected: (s) => setState(() => _gender = s ? 'female' : null),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Шаг 2 из 7', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Сколько тебе лет?', style: TextStyle(color: Colors.grey)),
                content: TextFormField(
                  controller: TextEditingController(text: _age?.toString() ?? ''),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Возраст',
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: cardBg,
                  ),
                  onChanged: (v) => _age = int.tryParse(v),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Введите возраст';
                    final age = int.tryParse(v);
                    if (age == null || age < 14 || age > 100) return 'Введите корректный возраст';
                    return null;
                  },
                ),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Шаг 3 из 7', style: TextStyle(color: Colors.white)),
                subtitle: const Text('В каком ты городе живешь?', style: TextStyle(color: Colors.grey)),
                content: TextFormField(
                  controller: _cityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Город',
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: cardBg,
                  ),
                  validator: (v) => v!.isEmpty ? 'Введите город' : null,
                ),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Шаг 4 из 7', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Твое образование', style: TextStyle(color: Colors.grey)),
                content: DropdownButtonFormField<String>(
                  value: _education,
                  dropdownColor: cardBg,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Образование',
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: cardBg,
                  ),
                  items: _educationOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _education = v),
                  validator: (v) => v == null ? 'Выберите образование' : null,
                ),
                isActive: _currentStep >= 3,
                state: _currentStep > 3 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Шаг 5 из 7', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Твои интересы и хобби', style: TextStyle(color: Colors.grey)),
                content: TextFormField(
                  controller: _interestsController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Интересы и хобби',
                    hintText: 'Например: программирование, дизайн, спорт, музыка...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: cardBg,
                  ),
                ),
                isActive: _currentStep >= 4,
                state: _currentStep > 4 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Шаг 6 из 7', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Какие навыки у тебя уже есть?', style: TextStyle(color: Colors.grey)),
                content: TextFormField(
                  controller: _skillsController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Навыки',
                    hintText: 'Например: Python, Figma, работа в команде...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: cardBg,
                  ),
                ),
                isActive: _currentStep >= 5,
                state: _currentStep > 5 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Шаг 7 из 7', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Готово!', style: TextStyle(color: Colors.grey)),
                content: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: primaryColor),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Нажми "Готово", чтобы сохранить профиль',
                              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isSaving)
                      Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save),
                        label: const Text('Сохраняю'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: theme.colorScheme.onSecondary,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                  ],
                ),
                isActive: _currentStep >= 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep < 6) {
        setState(() => _currentStep++);
      } else {
        _saveProfile();
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final success = await widget.apiService.updateProfile({
      'name': _nameController.text,
      'gender': _gender,
      'age': _age,
      'city': _cityController.text,
      'education': _education,
      'interests': _interestsController.text,
      'skills': _skillsController.text,
    });

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль сохранен!')),
      );
      if (widget.onProfileSaved != null) {
        widget.onProfileSaved!();
      } else {
        Navigator.pushReplacementNamed(context, '/');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка сохранения'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _interestsController.dispose();
    _skillsController.dispose();
    super.dispose();
  }
}
