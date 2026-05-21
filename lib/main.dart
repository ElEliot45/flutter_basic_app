import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Importa Firebase
import 'firebase_options.dart';
import 'promociones/screens/login_screen.dart';
import 'promociones/screens/home_screen.dart';
import 'promociones/utils/app_theme.dart';
import 'services/authservice.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PromoManager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_rounded, color: AppTheme.accent, size: 60),
            SizedBox(height: 20),
            CircularProgressIndicator(color: AppTheme.accent),
          ],
        ),
      ),
    );
  }
}
