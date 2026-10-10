import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/safe_assist_home.dart';

void main() {
  runApp(const SafeAssistApp());
}

class SafeAssistApp extends StatelessWidget {
  const SafeAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeAssist',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SafeAssistHome(),
    );
  }
}
