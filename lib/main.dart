import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whacka_app/screens/home_screen.dart';
import 'package:whacka_app/theme/app_theme.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const WhackaApp());
}

class WhackaApp extends StatelessWidget {
  const WhackaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whacka',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
