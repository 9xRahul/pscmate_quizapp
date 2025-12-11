// lib/features/auth/presentation/pages/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pscmate/core/utils/color_config.dart';

import 'package:pscmate/features/data/datasources/firebase_auth_datasource.dart';
import 'package:pscmate/features/data/repositories/auth_repository_impl.dart';
import 'package:pscmate/features/presentation/auth/bloc/auth_bloc.dart';
import 'package:pscmate/features/presentation/auth/login_page.dart';
import 'package:pscmate/features/presentation/auth/widgets/glass_container.dart';
import 'package:pscmate/features/presentation/auth/widgets/glowing_textfield.dart';
import 'package:pscmate/features/presentation/auth/widgets/gradient_button.dart';
import 'package:pscmate/features/presentation/auth/widgets/shreaded_mask.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap with BlocProvider so registration uses same bloc pattern
    return BlocProvider(
      create: (_) => AuthBloc(AuthRepositoryImpl(FirebaseAuthDataSource())),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _pwdCtl = TextEditingController();
  final _pwd2Ctl = TextEditingController();

  @override
  void dispose() {
    _emailCtl.dispose();
    _pwdCtl.dispose();
    _pwd2Ctl.dispose();
    super.dispose();
  }

  void _showSnack(String txt) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(txt)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) _showSnack(state.message);
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GlassContainer(
              glowColors: [AppColors.primaryTeal, AppColors.primaryBlue],
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(
                      height: 200,
                      width: 200,
                      image: AssetImage("assets/png/signup.png"),
                    ),

                    //     AppColors.primaryBlue, AppColors.primaryTeal
                    shreadMaskWidget(
                      size: 55,
                      textContent: "Create Account",
                      color1: AppColors.primaryBlue,
                      color2: AppColors.primaryTeal,
                    ),
                    shreadMaskWidget(
                      color1: Colors.grey,
                      color2: Colors.white,
                      size: 20,
                      textContent: "Start Your Journey Here",
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          GlowingTextField(
                            icon: Icons.email_outlined,
                            hintText: 'Full Name',
                            controller: _emailCtl,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return "Enter your name";
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          GlowingTextField(
                            icon: Icons.email_outlined,
                            hintText: 'Email Address',
                            controller: _emailCtl,
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Enter email";
                              if (!v.contains("@")) return "Enter valid email";
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

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
                          const SizedBox(height: 10),

                          GlowingTextField(
                            icon: Icons.lock_outline,
                            hintText: 'Confirm password',
                            isPassword: true,
                            controller: _pwd2Ctl,
                            validator: (v) {
                              if (v != _pwdCtl.text) {
                                return "Please Same password here";
                              }
                              if (v == null || v.isEmpty) {
                                return "Please confirm password";
                              }
                              if (v.length < 6) return "Minimum 6 characters";
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          const SizedBox(height: 20),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;
                              return GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<AuthBloc>().add(
                                            EmailRegisterRequested(
                                              _emailCtl.text.trim(),
                                              _pwdCtl.text,
                                            ),
                                          );
                                        }
                                      },
                                child: isLoading
                                    ? const CircularProgressIndicator()
                                    : GradientButton(
                                        text: 'SIGN UP',
                                        colors: const [
                                          AppColors.primaryBlue,
                                          AppColors.primaryTeal,
                                        ],
                                        onPressed: () {},
                                      ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Allready have an account? ",
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
                                    (context, animation, secondaryAnimation) =>
                                        const LoginScreen(),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      final offsetAnimation = Tween<Offset>(
                                        begin: const Offset(
                                          0.2,
                                          0,
                                        ), // slide from right
                                        end: Offset.zero,
                                      ).animate(animation);

                                      final fadeAnimation = Tween<double>(
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
                            ' Login in',
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
            ),
          ),
        ),
      ),
    );
  }
}
