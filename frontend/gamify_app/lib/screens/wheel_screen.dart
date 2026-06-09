import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/reward_model.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen>
    with TickerProviderStateMixin {
  late AnimationController _wheelController;
  late AnimationController _pulseController;
  late AnimationController _buttonPressController;
  late AnimationController _glowController;

  late Animation<double> _wheelAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _glowAnimation;

  bool _spinning = false;
  double _currentAngle = 0;
  double _lastHapticAngle = 0;

  final List<WheelPrize> _prizes = const [
    WheelPrize(label: '50 монет',    value: 50,  isCoins: true,  color: AppTheme.gold),
    WheelPrize(label: '100 XP',      value: 100, isCoins: false, color: AppTheme.xpBlue),
    WheelPrize(label: '20 монет',    value: 20,  isCoins: true,  color: AppTheme.questGreen),
    WheelPrize(label: 'ДЖЕКПОТ\n500',value: 500, isCoins: true,  color: AppTheme.primary),
    WheelPrize(label: '30 XP',       value: 30,  isCoins: false, color: AppTheme.legendaryPurple),
    WheelPrize(label: '10 монет',    value: 10,  isCoins: true,  color: AppTheme.bronze),
    WheelPrize(label: '200 XP',      value: 200, isCoins: false, color: AppTheme.xpBlue),
    WheelPrize(label: '75 монет',    value: 75,  isCoins: true,  color: AppTheme.gold),
  ];

  @override
  void initState() {
    super.initState();

    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _buttonPressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _wheelAnimation = const AlwaysStoppedAnimation(0);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.055).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _buttonPressController, curve: Curves.easeOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    _pulseController.dispose();
    _buttonPressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // ─── Spin logic ──────────────────────────────────────────────────────────

  Future<void> _spin() async {
    final state = context.read<AppState>();
    if (_spinning || !state.wheelSpinAvailable) return;

    HapticFeedback.mediumImpact();

    final random = Random();
    final prizeIndex = random.nextInt(_prizes.length);
    final segmentAngle = 2 * pi / _prizes.length;

    final normalised = _currentAngle % (2 * pi);
    final targetOffset = 2 * pi -
        normalised -
        (prizeIndex * segmentAngle) -
        segmentAngle / 2;
    final targetAngle = _currentAngle + (6 * 2 * pi) + targetOffset;

    setState(() => _spinning = true);
    _pulseController.stop();
    _glowController.forward();

    _wheelAnimation = Tween<double>(
      begin: _currentAngle,
      end: targetAngle,
    ).animate(
        CurvedAnimation(parent: _wheelController, curve: _SpinCurve()));

    _lastHapticAngle = _currentAngle;
    _wheelController.addListener(_onWheelTick);

    await _wheelController.forward(from: 0);

    _wheelController.removeListener(_onWheelTick);
    _currentAngle = targetAngle % (2 * pi);
    await _glowController.reverse();

    setState(() => _spinning = false);
    _pulseController.repeat(reverse: true);

    HapticFeedback.heavyImpact();

    if (!mounted) return;
    final prize = _prizes[prizeIndex];
    // applyWheelPrize now takes WheelPrize object
    state.applyWheelPrize(prize);
    _showPrizeDialog(prize);
  }

  void _onWheelTick() {
    final segmentAngle = 2 * pi / _prizes.length;
    final current = _wheelAnimation.value;
    if ((current - _lastHapticAngle) >= segmentAngle * 0.95) {
      _lastHapticAngle = current;
      HapticFeedback.selectionClick();
    }
  }

  // ─── Dialogs ──────────────────────────────────────────────────────────────

  void _showInfoDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: AppTheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppTheme.primary.withValues(alpha: 0.18),
                    AppTheme.primary.withValues(alpha: 0.05),
                  ]),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: AppTheme.primary, size: 26),
              ),
              const SizedBox(height: 14),
              Text(
                'Как работает колесо?',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Колесо Фортуны работает по принципу случайного выбора. '
                'Каждый сектор колеса имеет одинаковую вероятность выпадения, '
                'поэтому все призы участвуют в розыгрыше на равных условиях.',
                style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  color: AppTheme.textSecondary,
                  height: 1.55,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Понятно',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  void _showPrizeDialog(WheelPrize prize) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: AppTheme.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.4, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppTheme.gold.withValues(alpha: 0.25),
                      AppTheme.gold.withValues(alpha: 0.05),
                    ]),
                  ),
                  child: const Center(
                    child: Text('🎉', style: TextStyle(fontSize: 44)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Поздравляем!',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.manrope(
                      fontSize: 15, color: AppTheme.textSecondary),
                  children: [
                    const TextSpan(text: 'Ты выиграл '),
                    TextSpan(
                      text: prize.label.replaceAll('\n', ' '),
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        color: prize.color,
                      ),
                    ),
                    const TextSpan(text: '!'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Забрать награду',
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final available = state.wheelSpinAvailable;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: [
              _buildHeader(available),
              const SizedBox(height: 8),
              _buildSubtitle(available),
              const Spacer(),
              _buildWheel(available),
              const Spacer(),
              _buildSpinButton(available),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool available) {
    return Row(
      children: [
        const SizedBox(width: 40),
        Expanded(
          child: Text(
            'Колесо фортуны',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        GestureDetector(
          onTap: _showInfoDialog,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surface,
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppTheme.primary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle(bool available) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: Container(
        key: ValueKey(available),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: available
              ? AppTheme.questGreen.withValues(alpha: 0.1)
              : AppTheme.textSecondary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          available
              ? '🎁  У тебя есть 1 бесплатное вращение!'
              : '⏰  Возвращайся завтра за новым вращением',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: available ? AppTheme.questGreen : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildWheel(bool available) {
    const double wheelSize = 300;
    const double containerSize = 340;

    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (available)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: child,
              ),
              child: Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.18),
                      blurRadius: 32,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),

          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (_, child) => Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold
                        .withValues(alpha: 0.35 * _glowAnimation.value),
                    blurRadius: 48,
                    spreadRadius: 12,
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: wheelSize + 16,
            height: wheelSize + 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: List.generate(
                  16,
                  (i) => i.isEven
                      ? AppTheme.gold.withValues(alpha: 0.95)
                      : const Color(0xFFFFF3C0),
                ),
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _wheelAnimation,
            builder: (_, child) => Transform.rotate(
              angle: _spinning ? _wheelAnimation.value : _currentAngle,
              child: child,
            ),
            child: CustomPaint(
              size: const Size(wheelSize, wheelSize),
              painter: _WheelPainter(_prizes),
            ),
          ),

          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFEEEEF5)],
                center: Alignment(-0.3, -0.3),
              ),
              border: Border.all(color: AppTheme.gold, width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.star_rounded,
                color: AppTheme.gold, size: 30),
          ),

          Positioned(
            top: (containerSize - wheelSize) / 2 - 18,
            child: CustomPaint(
              size: const Size(30, 36),
              painter: _PointerPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpinButton(bool available) {
    final canSpin = available && !_spinning;

    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (_, child) => Transform.scale(
        scale: _buttonScaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: canSpin
            ? (_) {
                HapticFeedback.lightImpact();
                _buttonPressController.forward();
              }
            : null,
        onTapUp: canSpin
            ? (_) {
                _buttonPressController.reverse();
                _spin();
              }
            : null,
        onTapCancel: () => _buttonPressController.reverse(),
        child: Container(
          width: double.infinity,
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: canSpin
                ? const LinearGradient(
                    colors: [Color(0xFFFF1744), Color(0xFFE8002D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: canSpin ? null : AppTheme.silver.withValues(alpha: 0.5),
            boxShadow: canSpin
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.50),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_spinning) ...[
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Крутится...',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ] else if (available) ...[
                const Text('🎡', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text(
                  'КРУТИТЬ КОЛЕСО',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 10),
                const Text('🎡', style: TextStyle(fontSize: 22)),
              ] else ...[
                const Icon(Icons.lock_clock_rounded,
                    color: Colors.white54, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Использовано сегодня',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white54,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Custom spin curve ────────────────────────────────────────────────────────

class _SpinCurve extends Curve {
  @override
  double transformInternal(double t) {
    if (t < 0.12) {
      return Curves.easeIn.transform(t / 0.12) * 0.12;
    }
    return 0.12 +
        Curves.easeOutCubic.transform((t - 0.12) / 0.88) * 0.88;
  }
}

// ─── Wheel painter ────────────────────────────────────────────────────────────

class _WheelPainter extends CustomPainter {
  final List<WheelPrize> prizes;
  _WheelPainter(this.prizes);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      final startAngle = i * segmentAngle - pi / 2;
      final midAngle = startAngle + segmentAngle / 2;
      final rect = Rect.fromCircle(center: center, radius: radius);

      final base = prizes[i].color;
      final lighter = Color.lerp(base, Colors.white, 0.22)!;
      final darker = Color.lerp(base, Colors.black, 0.10)!;

      final segPaint = Paint()
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + segmentAngle,
          colors: [lighter, base, darker],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, segmentAngle, true, segPaint);

      final shinePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.90),
        startAngle + segmentAngle * 0.08,
        segmentAngle * 0.84,
        false,
        shinePaint,
      );

      final dividerPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        center,
        Offset(center.dx + radius * cos(startAngle),
            center.dy + radius * sin(startAngle)),
        dividerPaint,
      );

      final iconRadius = radius * 0.78;
      final iconOffset = Offset(
        center.dx + iconRadius * cos(midAngle),
        center.dy + iconRadius * sin(midAngle),
      );
      canvas.save();
      canvas.translate(iconOffset.dx, iconOffset.dy);
      canvas.rotate(midAngle + pi / 2);
      final emojiPainter = TextPainter(
        text: TextSpan(
          text: prizes[i].isCoins ? '🪙' : '⭐',
          style: const TextStyle(fontSize: 15),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      emojiPainter.paint(canvas,
          Offset(-emojiPainter.width / 2, -emojiPainter.height / 2));
      canvas.restore();

      final labelRadius = radius * 0.54;
      final labelOffset = Offset(
        center.dx + labelRadius * cos(midAngle),
        center.dy + labelRadius * sin(midAngle),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: prizes[i].label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            height: 1.3,
            shadows: [
              Shadow(
                  color: Colors.black38,
                  blurRadius: 5,
                  offset: Offset(0, 1.5)),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 62);
      canvas.save();
      canvas.translate(labelOffset.dx, labelOffset.dy);
      canvas.rotate(midAngle + pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPainter old) => false;
}

// ─── Pointer painter ──────────────────────────────────────────────────────────

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(size.width / 2, size.height + 4)
        ..lineTo(-2, 2)
        ..lineTo(size.width + 2, 2)
        ..close(),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    final bodyPath = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryLight,
            AppTheme.primary,
          ],
        ).createShader(Rect.fromLTWH(0, 0, 30, 36)),
    );

    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}