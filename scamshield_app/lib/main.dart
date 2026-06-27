import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/chat/chat_screen.dart';
import 'shared/theme.dart';

void main() {
  runApp(const ProviderScope(child: ScamShieldApp()));
}

class ScamShieldApp extends StatelessWidget {
  const ScamShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScamShield',
      theme: elderlyTheme(),
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
