import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              // ── Logo + tagline ──
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height:
                    MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : null,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(),
                padding: const EdgeInsets.only(top: 32, bottom: 16),
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.primary.withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.bolt_rounded,
                              color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 20),
                        const _GamificationTeaser(),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Card with Login / Register tabs ──
              SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 32,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Tab bar
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: TabBar(
                            controller: _tabController,
                            labelStyle: GoogleFonts.manrope(
                                fontWeight: FontWeight.w700, fontSize: 14),
                            unselectedLabelStyle: GoogleFonts.manrope(
                                fontWeight: FontWeight.w500, fontSize: 14),
                            labelColor: AppTheme.primary,
                            unselectedLabelColor: AppTheme.textSecondary,
                            indicator: UnderlineTabIndicator(
                              borderSide: BorderSide(
                                  color: AppTheme.primary, width: 2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            tabs: const [
                              Tab(text: 'Вход'),
                              Tab(text: 'Регистрация'),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 360,
                          child: TabBarView(
                            controller: _tabController,
                            children: const [
                              _LoginForm(),
                              _RegisterForm(),
                            ],
                          ),
                        ),
                      ],
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
}

// ── Login form ────────────────────────────────────────────────────────────────

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final state = context.read<AppState>();
    final ok = await state.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (!ok && state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    // Navigation is handled by _AuthGate — no pushReplacement needed
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AppState, bool>((s) => s.isLoading);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Войди и продолжи путь к наградам',
            style: GoogleFonts.manrope(
                fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary),
            decoration: const InputDecoration(hintText: 'Email'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Пароль',
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textHint,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    'Войти',
                    style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Register form ─────────────────────────────────────────────────────────────

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final state = context.read<AppState>();
    final ok = await state.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (!ok && state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AppState, bool>((s) => s.isLoading);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          TextField(
            controller: _usernameController,
            style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary),
            decoration: const InputDecoration(hintText: 'Имя пользователя'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary),
            decoration: const InputDecoration(hintText: 'Email'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Пароль',
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textHint,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    'Создать аккаунт',
                    style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Teaser ────────────────────────────────────────────────────────────────────

class _GamificationTeaser extends StatelessWidget {
  const _GamificationTeaser();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'GamifyApp',
          style: GoogleFonts.manrope(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Зарабатывай бонусы, выполняй квесты',
          style:
              GoogleFonts.manrope(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _perk(Icons.emoji_events_rounded, AppTheme.gold, 'Квесты'),
            const SizedBox(width: 16),
            _perk(Icons.casino_rounded, AppTheme.primary, 'Колесо'),
            const SizedBox(width: 16),
            _perk(
                Icons.military_tech_rounded, AppTheme.legendaryPurple, 'Лиги'),
          ],
        ),
      ],
    );
  }

  Widget _perk(IconData icon, Color color, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
