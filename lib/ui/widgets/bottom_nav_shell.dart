import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scamshield/core/theme/app_colors.dart';

class BottomNavShell extends StatefulWidget {
  final int currentIndex;
  final Widget child;

  const BottomNavShell({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/chat');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/family');
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: const Icon(Icons.chat_bubble_rounded),
            label: 'Trợ lý AI',
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline_rounded),
            selectedIcon: const Icon(Icons.people_rounded),
            label: 'Gia đình',
          ),
        ],
      ),
    );
  }
}

// Extension to easily wrap a screen with the bottom nav
extension BottomNavContext on BuildContext {
  void navigateToTab(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(this, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(this, '/chat');
        break;
      case 2:
        Navigator.pushReplacementNamed(this, '/family');
        break;
    }
  }
}
