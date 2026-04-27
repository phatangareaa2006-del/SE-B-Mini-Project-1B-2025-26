import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import 'main_shell.dart';
import 'admin_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // User login controllers
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl  = TextEditingController();

  // Register controllers
  final _regNameCtrl    = TextEditingController();
  final _regEmailCtrl   = TextEditingController();
  final _regPassCtrl    = TextEditingController();

  // Admin controller
  final _adminCodeCtrl  = TextEditingController();

  final _loginFormKey  = GlobalKey<FormState>();
  final _regFormKey    = GlobalKey<FormState>();
  final _adminFormKey  = GlobalKey<FormState>();

  bool _loginPassVisible = false;
  bool _regPassVisible   = false;
  bool _adminPassVisible = false;
  bool _isLoading        = false;
  String? _error;

  // 0=Sign In, 1=Register, 2=Admin
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      setState(() { _selectedTab = _tabCtrl.index; _error = null; });
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _loginEmailCtrl.dispose(); _loginPassCtrl.dispose();
    _regNameCtrl.dispose(); _regEmailCtrl.dispose(); _regPassCtrl.dispose();
    _adminCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _error = null; });

    final err = await AuthService.instance.signIn(
      email: _loginEmailCtrl.text.trim(),
      password: _loginPassCtrl.text,
    );

    setState(() => _isLoading = false);
    if (err != null) { setState(() => _error = err); return; }
    if (mounted) Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()));
  }

  Future<void> _handleRegister() async {
    if (!_regFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _error = null; });

    final err = await AuthService.instance.signUp(
      email: _regEmailCtrl.text.trim(),
      password: _regPassCtrl.text,
      name: _regNameCtrl.text.trim(),
    );

    setState(() => _isLoading = false);
    if (err != null) { setState(() => _error = err); return; }
    if (mounted) Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()));
  }

  Future<void> _handleAdminLogin() async {
    if (!_adminFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _error = null; });

    final err = await AuthService.instance.adminLogin(
        code: _adminCodeCtrl.text.trim());

    setState(() => _isLoading = false);
    if (err != null) { setState(() => _error = err); return; }
    if (mounted) Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 48),

              // Logo
              Row(children: [
                Container(width: 52, height: 52,
                    decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.ev_station,
                        color: AppColors.primary, size: 30)),
                const SizedBox(width: 14),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('EV Charge Finder',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                  Text('Your EV charging companion',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ]),
              ]),
              const SizedBox(height: 32),

              // Error banner
              if (_error != null) ...[
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withOpacity(0.3))),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13))),
                  ]),
                ),
                const SizedBox(height: 16),
              ],

              // Tab card
              Container(
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
                        blurRadius: 20, offset: const Offset(0, 4))]),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.background,
                          borderRadius: BorderRadius.circular(14)),
                      child: TabBar(
                        controller: _tabCtrl,
                        indicator: BoxDecoration(color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12)),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.textSecondary,
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Sign In'),
                          Tab(text: 'Register'),
                          Tab(text: '🔐 Admin'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _selectedTab == 1 ? 420 : 340,
                    child: TabBarView(
                      controller: _tabCtrl,
                      children: [
                        _buildLoginTab(),
                        _buildRegisterTab(),
                        _buildAdminTab(),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _loginFormKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Welcome back! 👋',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Sign in to your account',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),

          TextFormField(
            controller: _loginEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Email is required' : null,
            decoration: const InputDecoration(
                hintText: 'Email address',
                prefixIcon: Icon(Icons.mail_outline, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _loginPassCtrl,
            obscureText: !_loginPassVisible,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline,
                  color: AppColors.textSecondary),
              suffixIcon: IconButton(
                icon: Icon(_loginPassVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                    color: AppColors.textSecondary, size: 20),
                onPressed: () => setState(
                        () => _loginPassVisible = !_loginPassVisible),
              ),
            ),
          ),
          const Spacer(),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
                : const Text('Sign In'),
          ),
        ]),
      ),
    );
  }

  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _regFormKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Create account ✨',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Join EV Charge Finder today',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 20),

          TextFormField(
            controller: _regNameCtrl,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Full name is required' : null,
            decoration: const InputDecoration(
                hintText: 'Full name',
                prefixIcon: Icon(Icons.person_outline,
                    color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _regEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter valid email';
              return null;
            },
            decoration: const InputDecoration(
                hintText: 'Email address',
                prefixIcon: Icon(Icons.mail_outline,
                    color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _regPassCtrl,
            obscureText: !_regPassVisible,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleRegister(),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Minimum 6 characters';
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Password (min 6 chars)',
              prefixIcon: const Icon(Icons.lock_outline,
                  color: AppColors.textSecondary),
              suffixIcon: IconButton(
                icon: Icon(_regPassVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                    color: AppColors.textSecondary, size: 20),
                onPressed: () => setState(
                        () => _regPassVisible = !_regPassVisible),
              ),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
                : const Text('Create Account'),
          ),
        ]),
      ),
    );
  }

  Widget _buildAdminTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _adminFormKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Admin badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warning.withOpacity(0.3))),
            child: const Row(children: [
              Icon(Icons.admin_panel_settings,
                  color: AppColors.warning, size: 18),
              SizedBox(width: 8),
              Text('Station Owner / Admin Access',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.warning)),
            ]),
          ),
          const SizedBox(height: 20),

          const Text('Admin Login 🔐',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Enter your admin access code',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),

          TextFormField(
            controller: _adminCodeCtrl,
            obscureText: !_adminPassVisible,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleAdminLogin(),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Admin code is required' : null,
            decoration: InputDecoration(
              hintText: 'Enter admin code',
              prefixIcon: const Icon(Icons.key,
                  color: AppColors.textSecondary),
              suffixIcon: IconButton(
                icon: Icon(_adminPassVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                    color: AppColors.textSecondary, size: 20),
                onPressed: () => setState(
                        () => _adminPassVisible = !_adminPassVisible),
              ),
            ),
          ),
          const Spacer(),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleAdminLogin,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
                : const Text('Login as Admin'),
          ),

          const SizedBox(height: 12),
          Center(child: Text('Admin code: ADMIN@EV2024',
              style: TextStyle(fontSize: 11,
                  color: AppColors.textSecondary.withOpacity(0.5)))),
        ]),
      ),
    );
  }
}