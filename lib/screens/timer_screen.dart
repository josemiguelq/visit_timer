import 'dart:async';
import 'package:flutter/material.dart';
import '../models/visit_timer.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';

class TimerScreen extends StatefulWidget {
  final VisitCategory category;
  final String name;
  final int durationSeconds;

  const TimerScreen({
    super.key,
    required this.category,
    required this.name,
    required this.durationSeconds,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  late int _elapsedSeconds;
  Timer? _timer;
  bool _isFinished = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    _elapsedSeconds = 0;
    _startTimer();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _elapsedSeconds++;
        });
      } else {
        _finishTimer();
      }
    });
  }

  Future<void> _finishTimer({bool playAudio = true}) async {
    _timer?.cancel();

    setState(() {
      _isFinished = true;
    });

    // Salvar o timer
    final visitTimer = VisitTimer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: widget.category,
      name: widget.name,
      dateTime: DateTime.now(),
      durationSeconds: _elapsedSeconds,
    );

    await StorageService.addTimer(visitTimer);

    // Tocar áudio apenas se não foi encerrado manualmente
    if (playAudio) {
      await AudioService.playAlarm();
    }
  }

  Future<void> _endEarly() async {
    await _finishTimer(playAudio: false);
    _goHome();
  }

  void _goHome() {
    AudioService.stop();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        widget.durationSeconds > 0
            ? _elapsedSeconds / widget.durationSeconds
            : 0.0;

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                const SizedBox(height: 60),
                // Info da visita
                Text(
                  'Visita de ${widget.category.displayName}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: _getCategoryColor(widget.category),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const Spacer(),
                // Timer circular
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isFinished ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  _isFinished
                                      ? const Color(
                                        0xFFE94560,
                                      ).withValues(alpha: 0.5)
                                      : _getCategoryColor(
                                        widget.category,
                                      ).withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Progress ring background
                            SizedBox(
                              width: 260,
                              height: 260,
                              child: CircularProgressIndicator(
                                value: 1,
                                strokeWidth: 12,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.1,
                                ),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                            ),
                            // Progress ring
                            SizedBox(
                              width: 260,
                              height: 260,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 12,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _isFinished
                                      ? const Color(0xFFE94560)
                                      : _getCategoryColor(widget.category),
                                ),
                              ),
                            ),
                            // Timer display
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isFinished) ...[
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Color(0xFFE94560),
                                    size: 60,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Tempo esgotado!',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE94560),
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    _formatTime(_remainingSeconds),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'restantes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                // Tempo decorrido
                if (!_isFinished)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timelapse,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Decorrido: ${_formatTime(_elapsedSeconds)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                // Botões de ação
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Botão principal
                      GestureDetector(
                        onTap: _isFinished ? _goHome : null,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient:
                                _isFinished
                                    ? const LinearGradient(
                                      colors: [
                                        Color(0xFFE94560),
                                        Color(0xFFFF6B6B),
                                      ],
                                    )
                                    : null,
                            color:
                                _isFinished
                                    ? null
                                    : Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow:
                                _isFinished
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
                          child: Center(
                            child: Text(
                              _isFinished
                                  ? 'Voltar ao Início'
                                  : 'Timer em andamento...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    _isFinished
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.5),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Botão para encerrar antes
                      if (!_isFinished) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _endEarly,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(
                                  0xFFFFE66D,
                                ).withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.directions_run,
                                    color: const Color(0xFFFFE66D),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ufa, foi embora antes!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFFFE66D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
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
}
