import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/visit_timer.dart';
import '../services/storage_service.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<VisitTimer> _timers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimers();
  }

  Future<void> _loadTimers() async {
    final timers = await StorageService.loadTimers();
    setState(() {
      _timers = timers;
      _isLoading = false;
    });
  }

  void _openCategoryScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CategoryScreen()),
    );

    if (result == true) {
      _loadTimers();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Título
              Text(
                'Visit Timer',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFE94560).withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Botão circular principal
              GestureDetector(
                onTap: _openCategoryScreen,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE94560), Color(0xFFFF6B6B)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE94560).withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.timer_outlined,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Iniciar nova visita',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 40),
              // Linha divisória
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFFE94560).withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Título da lista
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Icon(
                      Icons.history,
                      color: Color(0xFFE94560),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Histórico de Visitas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Lista de timers
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFE94560),
                          ),
                        )
                        : _timers.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.hourglass_empty,
                                size: 60,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma visita registrada',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _timers.length,
                          itemBuilder: (context, index) {
                            final timer = _timers[index];
                            return _buildTimerCard(timer);
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCard(VisitTimer timer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getCategoryColor(timer.category).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(timer.category),
              color: _getCategoryColor(timer.category),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timer.displayTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(timer.dateTime),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE94560).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              timer.formattedDuration,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF6B6B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(VisitCategory category) {
    switch (category) {
      case VisitCategory.medico:
        return const Color(0xFF4ECDC4);
      case VisitCategory.conhecido:
        return const Color(0xFFFFE66D);
      case VisitCategory.amigo:
        return const Color(0xFF95E1D3);
      case VisitCategory.fofoqueiro:
        return const Color(0xFFFF6B6B);
    }
  }

  IconData _getCategoryIcon(VisitCategory category) {
    switch (category) {
      case VisitCategory.medico:
        return Icons.medical_services_outlined;
      case VisitCategory.conhecido:
        return Icons.person_outline;
      case VisitCategory.amigo:
        return Icons.favorite_outline;
      case VisitCategory.fofoqueiro:
        return Icons.chat_bubble_outline;
    }
  }
}
