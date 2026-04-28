import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _userType = 0; // 0=customer 1=admin

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(children: [
          const SizedBox(height: 32),

          // Logo
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _userType == 0 ? AppTheme.primary : AppTheme.accent,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(
                  color: (_userType == 0 ? AppTheme.primary : AppTheme.accent)
                      .withOpacity(0.3),
                  blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Icon(
              _userType == 0 ? Icons.directions_car : Icons.admin_panel_settings,
              size: 40, color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(_userType == 0 ? 'AutoHub' : 'Admin Portal',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Text(_userType == 0 ? 'Your Vehicle Marketplace' : 'AutoHub Management',
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),

          // Customer / Admin toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: AppTheme.border.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                _TypeBtn(label: '👤  Customer', selected: _userType == 0,
                    color: AppTheme.primary,
                    onTap: () => setState(() => _userType = 0)),
                _TypeBtn(label: '🔐  Admin', selected: _userType == 1,
                    color: AppTheme.accent,
                    onTap: () => setState(() => _userType = 1)),
              ]),
            ),
          ),
          const SizedBox(height: 8),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _userType == 0
                  ? const _CustomerForm()
                  : const _AdminForm(),
            ),
          ),
        ]),
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TypeBtn({required this.label, required this.selected,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.card : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected ? [BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14,
                color: selected ? color : AppTheme.textSecondary)),
      ),
    ),
  );
}

// ── Customer Form ─────────────────────────────────────────────────────────────
class _CustomerForm extends StatefulWidget {
  const _CustomerForm();
  @override
  State<_CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<_CustomerForm> {
  bool _isLogin = true;
  final _nameCtrl        = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passCtrl        = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _showPass = false, _showConfirmPass = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (!auth.privacyAccepted) {
      showError(context, 'Please accept Terms & Privacy Policy first');
      PrivacySheet.show(context, onAccept: auth.acceptPrivacy);
      return;
    }
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      showError(context, 'Please fill all required fields'); return;
    }
    if (!_isLogin && _nameCtrl.text.trim().isEmpty) {
      showError(context, 'Please enter your name'); return;
    }
    if (!_isLogin && pass != _confirmPassCtrl.text) {
      showError(context, 'Passwords do not match'); return;
    }
    if (pass.length < 6) {
      showError(context, 'Password must be at least 6 characters'); return;
    }

    if (_isLogin) {
      final error = await auth.loginWithEmail(email, pass);
      if (error != null && mounted) showError(context, error);
    } else {
      final error = await auth.registerWithEmail(_nameCtrl.text.trim(), email, pass);
      if (error != null && mounted) {
        showError(context, error);
      } else if (mounted) {
        showSuccess(context, 'Account created! Welcome to AutoHub 🎉');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Privacy banner
      GestureDetector(
        onTap: () => PrivacySheet.show(context,
            onAccept: context.read<AuthProvider>().acceptPrivacy),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: auth.privacyAccepted
                ? AppTheme.success.withOpacity(0.07)
                : AppTheme.warning.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: auth.privacyAccepted
                  ? AppTheme.success.withOpacity(0.3)
                  : AppTheme.warning.withOpacity(0.3),
            ),
          ),
          child: Row(children: [
            Icon(auth.privacyAccepted ? Icons.check_circle : Icons.warning_amber,
                size: 18,
                color: auth.privacyAccepted ? AppTheme.success : AppTheme.warning),
            const SizedBox(width: 8),
            Expanded(child: Text(
              auth.privacyAccepted
                  ? 'Terms & Privacy Policy Accepted ✓'
                  : '⚠️ Tap here to accept Terms & Privacy Policy before login',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: auth.privacyAccepted ? AppTheme.success : AppTheme.warning),
            )),
          ]),
        ),
      ),
      const SizedBox(height: 16),

      // Google Sign-In
      _GoogleBtn(loading: auth.loading, onTap: () async {
        final a = context.read<AuthProvider>();
        if (!a.privacyAccepted) {
          showError(context, 'Please accept Terms & Privacy Policy first');
          PrivacySheet.show(context, onAccept: a.acceptPrivacy); return;
        }
        final ok = await a.loginWithGoogle();
        if (!ok && mounted) showError(context, 'Google sign-in failed. Try again.');
      }),
      const SizedBox(height: 16),

      Row(children: [
        const Expanded(child: Divider()),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('or', style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.6)))),
        const Expanded(child: Divider()),
      ]),
      const SizedBox(height: 16),

      // Login / Register tabs
      Container(
        decoration: BoxDecoration(
            color: AppTheme.border.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(4),
        child: Row(children: [
          _TabBtn(label: '🔑  Login', selected: _isLogin,
              onTap: () => setState(() => _isLogin = true)),
          _TabBtn(label: '📝  Register', selected: !_isLogin,
              onTap: () => setState(() => _isLogin = false)),
        ]),
      ),
      const SizedBox(height: 20),

      // Name (register only)
      if (!_isLogin)
        AppField(label: 'Full Name *', hint: 'Enter your full name',
            controller: _nameCtrl),

      // Email
      AppField(label: 'Email Address *', hint: 'your@email.com',
          controller: _emailCtrl, keyboard: TextInputType.emailAddress),

      // Password
      AppField(
        label: 'Password *',
        hint: _isLogin ? 'Enter your password' : 'Min 6 characters',
        controller: _passCtrl,
        obscure: !_showPass,
        suffix: IconButton(
          icon: Icon(_showPass ? Icons.visibility : Icons.visibility_off,
              color: AppTheme.textSecondary),
          onPressed: () => setState(() => _showPass = !_showPass),
        ),
      ),

      // Confirm Password (register only)
      if (!_isLogin)
        AppField(
          label: 'Confirm Password *',
          hint: 'Re-enter your password',
          controller: _confirmPassCtrl,
          obscure: !_showConfirmPass,
          suffix: IconButton(
            icon: Icon(_showConfirmPass ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.textSecondary),
            onPressed: () => setState(() => _showConfirmPass = !_showConfirmPass),
          ),
        ),

      const SizedBox(height: 4),
      PrimaryBtn(
        label: _isLogin ? 'Login' : 'Create Account',
        onTap: _submit,
        loading: auth.loading,
        icon: _isLogin ? Icons.login : Icons.person_add,
      ),
      const SizedBox(height: 12),

      // Switch link
      Center(
        child: GestureDetector(
          onTap: () => setState(() => _isLogin = !_isLogin),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              children: [
                TextSpan(text: _isLogin
                    ? "Don't have an account? "
                    : 'Already have an account? '),
                TextSpan(
                  text: _isLogin ? 'Register here' : 'Login here',
                  style: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}

class _TabBtn extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _TabBtn({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.card : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                color: selected ? AppTheme.primary : AppTheme.textSecondary)),
      ),
    ),
  );
}

class _GoogleBtn extends StatelessWidget {
  final VoidCallback onTap; final bool loading;
  const _GoogleBtn({required this.onTap, required this.loading});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1.5),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        loading
            ? const SizedBox(width: 22, height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Color(0xFF4285F4)))
            : const Text('🔵', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Text(loading ? 'Signing in...' : 'Continue with Google',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

// ── Admin Form ────────────────────────────────────────────────────────────────
class _AdminForm extends StatefulWidget {
  const _AdminForm();
  @override State<_AdminForm> createState() => _AdminFormState();
}

class _AdminFormState extends State<_AdminForm> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      showError(context, 'Enter email and password'); return;
    }
    final ok = await context.read<AuthProvider>()
        .adminLogin(_emailCtrl.text.trim(), _passCtrl.text);
    if (!ok && mounted) showError(context, 'Invalid admin credentials');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Column(children: [
      AppField(label: 'Admin Email', hint: 'admin@autohub.com',
          controller: _emailCtrl, keyboard: TextInputType.emailAddress),
      AppField(
        label: 'Password', hint: 'Enter password',
        controller: _passCtrl, obscure: !_showPass,
        suffix: IconButton(
          icon: Icon(_showPass ? Icons.visibility : Icons.visibility_off,
              color: AppTheme.textSecondary),
          onPressed: () => setState(() => _showPass = !_showPass),
        ),
      ),
      PrimaryBtn(label: 'Login as Admin', onTap: _login,
          loading: auth.loading, color: AppTheme.accent,
          icon: Icons.lock),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppTheme.border.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8)),
        child: const Text('Demo: admin@autohub.com / admin123',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ),
    ]);
  }
}