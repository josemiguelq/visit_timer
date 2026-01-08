import 'dart:math';
import 'package:flutter/material.dart';
import '../models/visit_timer.dart';
import 'timer_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  VisitCategory? _selectedCategory;
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int _generateRandomDuration(VisitCategory category) {
    final random = Random();
    final minSeconds = category.minMinutes * 60;
    final maxSeconds = category.maxMinutes * 60;
    return minSeconds + random.nextInt(maxSeconds - minSeconds + 1);
  }

  void _startTimer() {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione uma categoria'),
          backgroundColor: const Color(0xFFE94560),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final name =
        _nameController.text.trim().isEmpty
            ? 'Visitante'
            : _nameController.text.trim();

    final durationSeconds = _generateRandomDuration(_selectedCategory!);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => TimerScreen(
              category: _selectedCategory!,
              name: name,
              durationSeconds: durationSeconds,
            ),
      ),
    );
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
              // Header com botão voltar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Título
                      const Text(
                        'Esta vai ser uma visita de...',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Campo de nome
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nome do visitante (opcional)',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            icon: Icon(
                              Icons.person_outline,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Grid de categorias
                      ...VisitCategory.values.map(
                        (category) => _buildCategoryCard(category),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              // Botão Iniciar
              Padding(
                padding: const EdgeInsets.all(24),
                child: GestureDetector(
                  onTap: _startTimer,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            _selectedCategory != null
                                ? [
                                  const Color(0xFFE94560),
                                  const Color(0xFFFF6B6B),
                                ]
                                : [Colors.grey.shade700, Colors.grey.shade600],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow:
                          _selectedCategory != null
                              ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE94560,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                              : null,
                    ),
                    child: const Center(
                      child: Text(
                        'Iniciar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(VisitCategory category) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? _getCategoryColor(category).withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? _getCategoryColor(category)
                    : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getCategoryColor(category).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(category),
                color: _getCategoryColor(category),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.displayName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? _getCategoryColor(category)
                              : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getCategoryTimeRange(category),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: _getCategoryColor(category),
                size: 28,
              ),
          ],
        ),
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

  String _getCategoryTimeRange(VisitCategory category) {
    if (category.maxMinutes >= 60) {
      final maxHours = category.maxMinutes ~/ 60;
      final minMinutes = category.minMinutes;
      if (minMinutes >= 60) {
        return '${minMinutes ~/ 60}h - ${maxHours}h';
      }
      return '$minMinutes min - ${maxHours}h';
    }
    return '${category.minMinutes} - ${category.maxMinutes} min';
  }
}
