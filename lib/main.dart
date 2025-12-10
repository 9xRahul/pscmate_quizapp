import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

// 👇 ADD THIS LINE

import 'package:pscmate/features/data/datasources/firebase_auth_datasource.dart';
import 'package:pscmate/features/data/repositories/auth_repository_impl.dart';
import 'package:pscmate/features/presentation/auth/bloc/bloc/auth_bloc.dart';
import 'package:pscmate/features/presentation/auth/login_page.dart';
import 'package:pscmate/features/presentation/auth/register_page.dart';
import 'package:pscmate/features/presentation/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 CHANGE THIS:
  // await Firebase.initializeApp();
  // TO THIS:
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey:
          'AIzaSyCNWYQP_1kTNZ0Bn7JUxMI7sLW4WHY8rb8', // from google-services.json -> api_key[0].current_key
      appId:
          '1:689927529820:android:454630b6375bdfc0f9cd99', // from google-services.json -> client[0].client_info.mobilesdk_app_id
      messagingSenderId: '689927529820', // project_info.project_number
      projectId: 'psc-mate-18589', // project_info.project_id
      storageBucket: 'psc-mate-18589.firebasestorage.app', // optional
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide AuthBloc globally so all pages share same instance
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AuthBloc(AuthRepositoryImpl(FirebaseAuthDataSource()))
                ..add(const AuthCheckRequested()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PSC Mate',
        theme: ThemeData(
          colorSchemeSeed: Colors.deepPurple,
          useMaterial3: true,
        ),
        home: const SplashPage(),

        // App routes
        routes: {
          '/login': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
          '/home': (_) => const HomePage(),
        },
      ),
    );
  }
}

//
// ------------------------------
// Splash Page - Auto Navigate
// ------------------------------
//

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
