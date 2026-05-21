import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/authservice.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();

  bool _isLogin = true; // true = login, false = registro
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      if (_isLogin) {
        await _authService.signIn(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
      } else {
        await _authService.register(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(_authService.getErrorMessage(e));
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: AppTheme.accent),
          const SizedBox(width: 12),
          Expanded(child: Text(msg)),
        ]),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            colors: [AppTheme.primary, Color(0xFF0D0D1A), AppTheme.surface],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Column(
                children: [
                  // ── Logo / Header ───────────────────────────────────────
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accent.withOpacity(0.4), width: 1.5),
                    ),
                    child: const Icon(Icons.local_offer_rounded, color: AppTheme.accent, size: 36),
                  ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 24),
                  Text(
                    'PromoManager',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textLight,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'Bienvenido de vuelta' : 'Crea tu cuenta',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 40),

                  // ── Formulario ──────────────────────────────────────────
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AppTheme.textLight),
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Campo requerido';
                            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v)) {
                              return 'Correo no válido';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                        const SizedBox(height: 16),

                        // Contraseña
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          style: const TextStyle(color: AppTheme.textLight),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Campo requerido';
                            if (v.length < 6) return 'Mínimo 6 caracteres';
                            return null;
                          },
                        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                        const SizedBox(height: 28),

                        // Botón principal
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _loading
                              ? const SizedBox(
                                  height: 52,
                                  child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
                                )
                              : ElevatedButton(
                                  onPressed: _submit,
                                  child: Text(_isLogin ? 'Iniciar sesión' : 'Registrarse'),
                                ),
                        ).animate().fadeIn(delay: 600.ms),
                        const SizedBox(height: 20),

                        // Toggle login / registro
                        TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: _isLogin ? '¿No tienes cuenta? ' : '¿Ya tienes cuenta? ',
                                ),
                                TextSpan(
                                  text: _isLogin ? 'Regístrate' : 'Inicia sesión',
                                  style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 700.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}