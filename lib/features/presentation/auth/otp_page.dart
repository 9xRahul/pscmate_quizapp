// lib/features/auth/presentation/pages/otp_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pscmate/features/presentation/auth/bloc/auth_bloc.dart';

class OtpPage extends StatefulWidget {
  final String verificationId;
  const OtpPage({super.key, required this.verificationId});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _showSnack(String txt) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(txt)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) _showSnack(state.message);
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text('We sent an OTP to your phone. Enter it below.'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  prefixIcon: Icon(Icons.message),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final otp = _otpController.text.trim();
                            if (otp.isEmpty) {
                              _showSnack('Enter OTP');
                              return;
                            }
                            // We stored verificationId inside Bloc earlier; but this page also receives it.
                            context.read<AuthBloc>().add(OtpSubmitted(otp));
                          },
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Verify & Sign in'),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // go back to login so user can resend
                  Navigator.of(context).pop();
                },
                child: const Text('Back / Resend OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
