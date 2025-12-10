// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pscmate/features/data/datasources/firebase_auth_datasource.dart';
import 'package:pscmate/features/data/repositories/auth_repository_impl.dart';
import 'package:pscmate/features/presentation/auth/bloc/bloc/auth_bloc.dart';
import 'package:pscmate/features/presentation/auth/otp_page.dart';
import 'package:pscmate/features/presentation/auth/register_page.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static Route route() => MaterialPageRoute(builder: (_) => const LoginPage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AuthBloc(AuthRepositoryImpl(FirebaseAuthDataSource()))
            ..add(const AuthCheckRequested()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PSC Mate - Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            _showSnack(state.message);
          } else if (state is AuthAuthenticated) {
            // go to home
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is AuthPhoneCodeSent) {
            // navigate to OTP page with verificationId
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OtpPage(verificationId: state.verificationId),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const FlutterLogo(size: 96),
                const SizedBox(height: 12),
                const Text(
                  'Welcome to PSC Mate',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // Email/password form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter email';
                          }
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter password';
                          }
                          if (v.length < 6) return 'Password min 6 chars';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                    EmailSignInRequested(
                                      _emailController.text.trim(),
                                      _passwordController.text,
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.login),
                        label: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Sign in with Email'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                const Text('OR', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),

                // Google Sign-in
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: isLoading
                      ? null
                      : () => context.read<AuthBloc>().add(
                          const GoogleSignInRequested(),
                        ),
                  icon: Image.asset(
                    'assets/google_logo.png',
                    width: 20,
                    height: 20,
                  ), // add asset or use Icon
                  label: const Text('Sign in with Google'),
                ),

                const SizedBox(height: 12),

                // Phone number
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone (with country code)',
                          hintText: '+91xxxxxxxxxx',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              final phone = _phoneController.text.trim();
                              if (phone.isEmpty) {
                                _showSnack(
                                  'Enter phone number with country code',
                                );
                                return;
                              }
                              context.read<AuthBloc>().add(
                                PhoneNumberSubmitted(phone),
                              );
                            },
                      child: const Text('Send OTP'),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
