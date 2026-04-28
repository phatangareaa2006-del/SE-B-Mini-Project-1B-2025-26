import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart' as ap;
import '../theme/app_theme.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey     = GlobalKey<FormState>();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  bool  _obscurePass = true;

  late final AnimationController _animCtrl;
  late final Animation<double>    _fadeAnim;
  late final Animation<Offset>    _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<ap.AuthProvider>();
    await auth.signIn(_emailCtrl.text, _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navyDark,
      body: Stack(
        children: [
          // Background decorative circles
          Positioned(
            top:   -80,
            right: -60,
            child: _DecorCircle(size: 250, color: Colors.white.withValues(alpha: 0.04)),
          ),
          Positioned(
            bottom: -100,
            left:   -80,
            child: _DecorCircle(size: 300, color: Colors.white.withValues(alpha: 0.03)),
          ),
          Positioned(
            top:  160,
            left: -50,
            child: _DecorCircle(size: 160, color: AppTheme.gold.withValues(alpha: 0.08)),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          width:  80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE8A020), Color(0xFFF0C040)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:      AppTheme.gold.withValues(alpha: 0.4),
                                blurRadius: 24,
                                offset:     const Offset(0, 8),
                              )
                            ],
                          ),
                          child: const Center(
                            child: Text('🏛️', style: TextStyle(fontSize: 40)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'CivicVoice',
                          style: TextStyle(
                            fontFamily:    'Georgia',
                            fontSize:      32,
                            fontWeight:    FontWeight.w800,
                            color:         Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'ADMIN MANAGEMENT PANEL',
                          style: TextStyle(
                            fontSize:      10,
                            color:         Color(0x99FFFFFF),
                            letterSpacing: 2.5,
                            fontWeight:    FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Card
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color:        Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color:      Colors.black.withValues(alpha: 0.25),
                                blurRadius: 40,
                                offset:     const Offset(0, 12),
                              )
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontFamily:  'Georgia',
                                    fontSize:    24,
                                    fontWeight:  FontWeight.w700,
                                    color:       Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Enter your admin credentials to continue',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:    Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Email
                                _FieldLabel('Email Address'),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller:      _emailCtrl,
                                  keyboardType:    TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText:   'admin@civicvoice.gov',
                                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!v.contains('@')) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password
                                _FieldLabel('Password'),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller:       _passCtrl,
                                  obscureText:      _obscurePass,
                                  textInputAction:  TextInputAction.done,
                                  onFieldSubmitted: (_) => _submit(),
                                  decoration: InputDecoration(
                                    hintText:   '••••••••',
                                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(
                                              () => _obscurePass = !_obscurePass),
                                      icon: Icon(
                                        _obscurePass
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (v.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Error banner
                                Consumer<ap.AuthProvider>(
                                  builder: (_, auth, __) {
                                    if (auth.error == null) {
                                      return const SizedBox.shrink();
                                    }
                                    return Container(
                                      margin:  const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color:        const Color(0xFFFFEBEE),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFFFCDD2)),
                                      ),
                                      child: Row(children: [
                                        const Icon(Icons.error_outline,
                                            color: Color(0xFFE74C3C), size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            auth.error!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color:    Color(0xFFB71C1C),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: auth.clearError,
                                          child: const Icon(Icons.close,
                                              size: 16, color: Color(0xFFE74C3C)),
                                        ),
                                      ]),
                                    );
                                  },
                                ),

                                // Submit button
                                Consumer<ap.AuthProvider>(
                                  builder: (_, auth, __) {
                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: auth.loading ? null : _submit,
                                        child: auth.loading
                                            ? const SizedBox(
                                          width:  20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                            : const Text('Sign In'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Footer
                        const SizedBox(height: 28),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield_outlined,
                                color: Color(0x66FFFFFF), size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Authorised administrators only',
                              style: TextStyle(
                                fontSize: 12,
                                color:    Color(0x66FFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize:   13,
      fontWeight: FontWeight.w600,
      color:      Color(0xFF374151),
    ),
  );
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final Color  color;
  const _DecorCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width:  size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
    ),
  );
}