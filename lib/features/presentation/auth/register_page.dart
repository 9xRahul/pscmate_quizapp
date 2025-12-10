// lib/features/auth/presentation/pages/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pscmate/features/data/datasources/firebase_auth_datasource.dart';
import 'package:pscmate/features/data/repositories/auth_repository_impl.dart';
import 'package:pscmate/features/presentation/auth/bloc/bloc/auth_bloc.dart';

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
      appBar: AppBar(title: const Text('Register')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) _showSnack(state.message);
          if (state is AuthAuthenticated) {
            // Registration succeeded -> go home
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailCtl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter email';
                    if (!v.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pwdCtl,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter password';
                    if (v.length < 6) return 'Password min 6 chars';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pwd2Ctl,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirm password';
                    if (v != _pwdCtl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return ElevatedButton(
                      onPressed: isLoading
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
                          : const Text('Register'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
