import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/firebase_auth_service.dart';
import '../../widgets/animated_bubble_bg.dart';
import '../../widgets/glass_card.dart';
import '../../services/notification_service.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoginMode = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitAuth() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }
    
    if (!_isLoginMode && _nameController.text.trim().isEmpty) {
      _showError("Please provide your full name.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLoginMode) {
        await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await _authService.createUserWithEmailAndPassword(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
         NotificationService().syncAlarmsToDevice(user.uid);
      }

      _navigateToDashboard();
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Authentication failed.");
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
           NotificationService().syncAlarmsToDevice(user.uid);
        }
        _navigateToDashboard();
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Google Sign-In failed.");
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showError("Please enter your email first to reset your password.");
      return;
    }
    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset link sent to your email."),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Failed to send reset email.");
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(prefixIcon, color: Colors.blueAccent),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedBubbleBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    const Icon(
                      Icons.monitor_heart,
                      size: 80,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.blueAccent, blurRadius: 20),
                      ],
                    ).animate()
                     .scale(duration: 600.ms, curve: Curves.elasticOut)
                     .fadeIn(),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      _isLoginMode ? "Welcome Back" : "Create Account",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate(target: _isLoginMode ? 1 : 0.9)
                     .slideX(begin: -0.5, end: 0, duration: 400.ms, curve: Curves.easeOut)
                     .fadeIn(),

                    const SizedBox(height: 32),

                    // Name Field (Slide down dynamically)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _isLoginMode ? 0 : 80,
                      curve: Curves.easeInOut,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _nameController,
                              hintText: "Full Name",
                              prefixIcon: Icons.person,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // Email Field
                    _buildTextField(
                      controller: _emailController,
                      hintText: "Email Address",
                      prefixIcon: Icons.email,
                    ).animate(delay: 500.ms).slideY(begin: 0.5, end: 0, duration: 500.ms).fadeIn(),

                    const SizedBox(height: 16),

                    // Password Field
                    _buildTextField(
                      controller: _passwordController,
                      hintText: "Password",
                      prefixIcon: Icons.lock,
                      isPassword: true,
                    ).animate(delay: 650.ms).slideY(begin: 0.5, end: 0, duration: 500.ms).fadeIn(),

                    // Forgot Password
                    if (_isLoginMode)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: const Text("Forgot Password?", style: TextStyle(color: Colors.blueAccent)),
                        ),
                      ),

                    if (!_isLoginMode) const SizedBox(height: 24),

                    // Login / Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 10,
                          shadowColor: Colors.blueAccent.withOpacity(0.5),
                        ),
                        child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isLoginMode ? "Login" : "Register",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ).animate(delay: 800.ms).scale(begin: const Offset(0.8, 0.8)).fadeIn(),

                    const SizedBox(height: 16),

                    // Google Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 30),
                        label: const Text(
                          "Continue with Google",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ).animate(delay: 950.ms).fadeIn(duration: 500.ms),

                    const SizedBox(height: 24),

                    // Toggle Register/Login
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLoginMode = !_isLoginMode;
                          // Clear errors locally, clear fields optionally
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          text: _isLoginMode ? "Don't have an account? " : "Already have an account? ",
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                          children: [
                            TextSpan(
                              text: _isLoginMode ? "Register" : "Login",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
