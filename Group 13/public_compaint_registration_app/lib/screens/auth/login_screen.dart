import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _obscure = true;

  // Login
  final _loginEmail = TextEditingController();
  final _loginPass  = TextEditingController();

  // Register
  final _regName  = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPhone = TextEditingController();
  final _regPass  = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    // FIX: clear any stale errors when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ap.AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _loginEmail.dispose();
    _loginPass.dispose();
    _regName.dispose();
    _regEmail.dispose();
    _regPhone.dispose();
    _regPass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<ap.AuthProvider>();
    await auth.signIn(_loginEmail.text.trim(), _loginPass.text.trim());
  }

  // FIX: now calls signUp with named parameters that actually exist
  Future<void> _register() async {
    final auth = context.read<ap.AuthProvider>();
    await auth.signUp(
      email:    _regEmail.text.trim(),
      password: _regPass.text.trim(),
      name:     _regName.text.trim(),
      phone:    _regPhone.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgGray,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A3C6E), Color(0xFF0F2548)],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFE8A020), Color(0xFFF0C040)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                          child: Text('🏛️',
                              style: TextStyle(fontSize: 32))),
                    ),
                    const SizedBox(height: 12),
                    const Text('CivicVoice',
                        style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text('MUNICIPAL COMPLAINT PORTAL',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0x99FFFFFF),
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),

              // ── Form card ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20)),
                        ),
                        child: TabBar(
                          controller: _tabs,
                          indicatorColor: AppTheme.navyPrimary,
                          indicatorWeight: 3,
                          labelColor: AppTheme.navyPrimary,
                          unselectedLabelColor: const Color(0xFF9CA3AF),
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                          // FIX: clear errors when switching tabs
                          onTap: (_) =>
                              context.read<ap.AuthProvider>().clearError(),
                          tabs: const [
                            Tab(text: 'Sign In'),
                            Tab(text: 'Register'),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          controller: _tabs,
                          children: [
                            _LoginForm(
                              emailCtrl:       _loginEmail,
                              passCtrl:        _loginPass,
                              obscure:         _obscure,
                              onToggleObscure: () =>
                                  setState(() => _obscure = !_obscure),
                              onSubmit: _login,
                            ),
                            _RegisterForm(
                              nameCtrl:        _regName,
                              emailCtrl:       _regEmail,
                              phoneCtrl:       _regPhone,
                              passCtrl:        _regPass,
                              obscure:         _obscure,
                              onToggleObscure: () =>
                                  setState(() => _obscure = !_obscure),
                              onSubmit: _register,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Error banner ───────────────────────────────────────────
              Consumer<ap.AuthProvider>(builder: (_, auth, __) {
                if (auth.error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8D7DA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                          const Color(0xFFDC3545).withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Text('⚠️'),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(auth.error!,
                              style: const TextStyle(
                                  color: Color(0xFF721C24),
                                  fontSize: 13))),
                    ]),
                  ),
                );
              }),

              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '🔑 Admin? Use your admin credentials to access the admin panel.',
                  textAlign: TextAlign.center,
                  style:
                  TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Login form ───────────────────────────────────────────────────────────────
class _LoginForm extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const _LoginForm({
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _AuthField(
              label:    'Email',
              ctrl:     emailCtrl,
              hint:     'you@example.com',
              keyboard: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _AuthField(
            label:   'Password',
            ctrl:    passCtrl,
            hint:    '••••••••',
            obscure: obscure,
            suffix: IconButton(
              icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: const Color(0xFF9CA3AF)),
              onPressed: onToggleObscure,
            ),
          ),
          const SizedBox(height: 24),
          Consumer<ap.AuthProvider>(builder: (_, auth, __) {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.loading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navyPrimary,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: auth.loading
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : const Text('Sign In',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Register form ────────────────────────────────────────────────────────────
class _RegisterForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const _RegisterForm({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _AuthField(
              label: 'Full Name', ctrl: nameCtrl, hint: 'Your name'),
          const SizedBox(height: 12),
          _AuthField(
              label:    'Email',
              ctrl:     emailCtrl,
              hint:     'you@example.com',
              keyboard: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _AuthField(
              label:    'Phone',
              ctrl:     phoneCtrl,
              hint:     '+91 XXXXX XXXXX',
              keyboard: TextInputType.phone),
          const SizedBox(height: 12),
          _AuthField(
            label:   'Password',
            ctrl:    passCtrl,
            hint:    'Min 6 characters',
            obscure: obscure,
            suffix: IconButton(
              icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: const Color(0xFF9CA3AF)),
              onPressed: onToggleObscure,
            ),
          ),
          const SizedBox(height: 20),
          Consumer<ap.AuthProvider>(builder: (_, auth, __) {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.loading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navyPrimary,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: auth.loading
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : const Text('Create Account',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Shared auth text field ───────────────────────────────────────────────────
class _AuthField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboard;

  const _AuthField({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.obscure = false,
    this.suffix,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4A5568),
                letterSpacing: 0.6)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboard,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFFAFBFD),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFFDDE1EA), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFFDDE1EA), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: AppTheme.navyPrimary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}