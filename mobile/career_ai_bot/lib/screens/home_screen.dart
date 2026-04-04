import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // PROTRACK logo
              Center(
                child: Column(
                  children: [
                    Text('PROTRACK',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00C853),
                        letterSpacing: 8,
                        shadows: [Shadow(color: Color(0xFF00C853).withOpacity(0.3), blurRadius: 20)],
                      ),
                    ),
                    Text('CAREER AI',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 12,
                        color: Colors.grey[600],
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Dashboard cards
              _DashCard(
                icon: Icons.work_outline,
                title: 'Вакансии',
                desc: 'Подобранные предложения по твоему профилю',
                badge: 'НОВОЕ',
                onTap: () => DefaultTabController.of(context)?.animateTo(2),
              ),
              const SizedBox(height: 10),
              _DashCard(
                icon: Icons.science_outlined,
                title: 'AI Анализ',
                desc: 'Подбор профессий и карьерный план',
                badge: 'AI',
                onTap: () => DefaultTabController.of(context)?.animateTo(1),
              ),
              const SizedBox(height: 10),
              _DashCard(
                icon: Icons.chat_bubble_outline,
                title: 'Консультант',
                desc: 'AI-чат по вопросам карьеры',
                badge: 'ОНЛАЙН',
                onTap: () {
                  Navigator.pushNamed(context, '/chat');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final String badge;
  final VoidCallback? onTap;

  const _DashCard({required this.icon, required this.title, required this.desc, required this.badge, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          border: Border(left: BorderSide(color: Color(0xFF00C853), width: 3)),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [BoxShadow(color: Color(0xFF00C853).withOpacity(0.1), blurRadius: 15)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(icon, color: Color(0xFF00C853), size: 20),
                  const SizedBox(width: 8),
                  Text(title, style: TextStyle(fontFamily: 'Courier', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF00C853)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(badge, style: TextStyle(fontFamily: 'Courier', fontSize: 9, color: Color(0xFF00C853), letterSpacing: 1)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(desc, style: TextStyle(fontFamily: 'Courier', fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}
