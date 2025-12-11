// lib/features/presentation/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pscmate/core/utils/color_config.dart';
import 'package:pscmate/features/presentation/auth/bloc/auth_bloc.dart';
import 'package:pscmate/features/presentation/auth/register_page.dart';
import 'package:pscmate/features/presentation/auth/widgets/glass_container.dart'
    hide AppColors;
import 'package:pscmate/features/presentation/auth/widgets/glowing_textfield.dart';
import 'package:pscmate/features/presentation/auth/widgets/gradient_button.dart';

import 'package:pscmate/features/presentation/home/home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static Route route() =>
      MaterialPageRoute(builder: (_) => const LoginScreen());

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtl = TextEditingController();
  final _pwdCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtl.dispose();
    _pwdCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
  }

  void _showSnack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,

      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) _showSnack(state.message);
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GlassContainer(
                glowColors: [AppColors.primaryTeal, AppColors.primaryBlue],

                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      // Top icon + heading
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.primaryTeal,
                          ], // Teal to Gold
                        ).createShader(bounds),
                        child: Image(
                          height: 300,
                          width: 300,
                          image: AssetImage("assets/png/logo1.png"),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 30),

                            // --- Inputs ---
                            GlowingTextField(
                              icon: Icons.email_outlined,
                              hintText: 'Email Address',
                              controller: _emailCtl,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return "Enter email";
                                if (!v.contains("@"))
                                  return "Enter valid email";
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            GlowingTextField(
                              icon: Icons.lock_outline,
                              hintText: 'Password',
                              isPassword: true,
                              controller: _pwdCtl,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return "Enter password";
                                if (v.length < 6) return "Minimum 6 characters";
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            GradientButton(
                              text: 'LOGIN',
                              colors: const [
                                AppColors.primaryBlue,
                                AppColors.primaryTeal,
                              ],
                              onPressed: () {
                                print("button clicked");
                                isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<AuthBloc>().add(
                                            EmailSignInRequested(
                                              _emailCtl.text.trim(),
                                              _pwdCtl.text,
                                            ),
                                          );
                                        }
                                      };
                              },
                            ),
                            const SizedBox(height: 20),

                            const SizedBox(height: 14),

                            const Row(
                              children: [
                                Expanded(
                                  child: Divider(color: AppColors.textFaded),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: AppColors.textFaded,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: AppColors.textFaded),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.green),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    isLoading ? print("true") : print("false");

                                    isLoading
                                        ? null
                                        : () => context.read<AuthBloc>().add(
                                            const GoogleSignInRequested(),
                                          );
                                  },
                                  borderRadius: BorderRadius.circular(28),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      // Using colored icon to simulate Google logo
                                      Image(
                                        height: 20,
                                        width: 20,
                                        image: AssetImage(
                                          'assets/png/google.png',
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Sign in with Google',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Google button
                            const SizedBox(height: 12),

                            const SizedBox(height: 18),

                            // Register link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(color: AppColors.textFaded),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(
                                          milliseconds: 450,
                                        ),
                                        pageBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) => const RegisterPage(),
                                        transitionsBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                              child,
                                            ) {
                                              final offsetAnimation =
                                                  Tween<Offset>(
                                                    begin: const Offset(
                                                      0.2,
                                                      0,
                                                    ), // slide from right
                                                    end: Offset.zero,
                                                  ).animate(animation);

                                              final fadeAnimation =
                                                  Tween<double>(
                                                    begin: 0.0,
                                                    end: 1.0,
                                                  ).animate(animation);

                                              return SlideTransition(
                                                position: offsetAnimation,
                                                child: FadeTransition(
                                                  opacity: fadeAnimation,
                                                  child: child,
                                                ),
                                              );
                                            },
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: AppColors.primaryTeal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
