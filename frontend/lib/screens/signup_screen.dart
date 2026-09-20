import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../config/liquid_glass_theme.dart';
import '../widgets/animated_orb_background.dart';
import '../widgets/glass_container.dart';
import '../utils/page_transitions.dart';
import 'dashboard_screen.dart';

/// Signup screen — mirrors login's Liquid Glass design.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signup(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        AppRoutes.fadeSlide(const DashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedOrbBackground()),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            gradient: LiquidGlass.primaryGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: LiquidGlass.glowShadow(LiquidGlass.accentPrimary, intensity: 0.5, blur: 28),
                          ),
                          child: const Icon(Icons.person_add_outlined, color: Colors.white, size: 38),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Create Account',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Start tracking your applications',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Glass form card
                        GlassContainer(
                          borderRadius: 24,
                          padding: const EdgeInsets.all(28),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Get started',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 22),

                                _buildTextField(
                                  controller: _emailController,
                                  hint: 'Email address',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Enter your email';
                                    if (!v.contains('@')) return 'Enter a valid email';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),

                                _buildTextField(
                                  controller: _passwordController,
                                  hint: 'Password',
                                  icon: Icons.lock_outline,
                                  obscure: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.white.withValues(alpha: 0.4), size: 20,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Enter a password';
                                    if (v.length < 6) return 'Password must be 6+ characters';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),

                                _buildTextField(
                                  controller: _confirmPasswordController,
                                  hint: 'Confirm password',
                                  icon: Icons.lock_outline,
                                  obscure: _obscureConfirm,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.white.withValues(alpha: 0.4), size: 20,
                                    ),
                                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Confirm your password';
                                    if (v != _passwordController.text) return 'Passwords do not match';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 26),

                                // Error
                                Consumer<AuthProvider>(
                                  builder: (ctx, auth, _) {
                                    if (auth.error != null) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 14),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: LiquidGlass.accentRed.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: LiquidGlass.accentRed.withValues(alpha: 0.3)),
                                          ),
                                          child: Text(
                                            auth.error!,
                                            style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),

                                // Signup button
                                Consumer<AuthProvider>(
                                  builder: (ctx, auth, _) {
                                    return GestureDetector(
                                      onTap: auth.isLoading ? null : _handleSignup,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        height: 52,
                                        decoration: auth.isLoading
                                            ? BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.06),
                                                borderRadius: BorderRadius.circular(14),
                                              )
                                            : LiquidGlass.glowButtonDecoration(),
                                        child: Center(
                                          child: auth.isLoading
                                              ? const SizedBox(
                                                  width: 22, height: 22,
                                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                                )
                                              : Text(
                                                  'Create Account',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<AuthProvider>().clearError();
                                Navigator.pop(context);
                              },
                              child: ShaderMask(
                                shaderCallback: (bounds) =>
                                    LiquidGlass.primaryGradient.createShader(bounds),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: LiquidGlass.glassInputDecoration(
        hint: hint,
        prefix: Icon(icon, color: Colors.white.withValues(alpha: 0.4), size: 20),
        suffix: suffixIcon,
      ),
    );
  }
}
