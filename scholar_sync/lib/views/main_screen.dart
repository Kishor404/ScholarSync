import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import 'home_screen.dart';
import 'cgpa_screen.dart';
import 'course_screen.dart';
import 'vault_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late ThemeController themeController;
  DateTime? _lastBackPress;
  bool _showExitWarning = false;
  late final pages = [
    HomeScreen(onNavigate: _changeTab),
    CGPAScreen(),
    CourseScreen(),
    VaultScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    themeController = Get.find<ThemeController>();
  }

  void _changeTab(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  void _handleBackPress(double s) {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return;
    }

    final now = DateTime.now();
    if (_lastBackPress == null || now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      HapticFeedback.lightImpact();

      // Show our custom internal "snackbar"
      setState(() => _showExitWarning = true);

      // Hide it after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showExitWarning = false);
      });
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final s = w / 460;
    final palette = themeController.palette;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress(s);
      },
      child: Scaffold(
        // The Stack allows us to put the warning behind the UI
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),
            
            // Custom Exit Warning "Snackbar"
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: _showExitWarning ? 10 * s : -50 * s, // Slides "under" the nav bar
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 10 * s),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(153),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Press back again to exit",
                    style: TextStyle(color: Colors.white, fontSize: 11 * s),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _OptimizedNavBar(
          selectedIndex: _selectedIndex,
          onTap: _changeTab,
          palette: palette,
        ),
      ),
    );
  }
}

// Separated widget to prevent full rebuild
class _OptimizedNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final dynamic palette;

  const _OptimizedNavBar({
    required this.selectedIndex,
    required this.onTap,
    required this.palette,
  });

  static const icons = [
    Icons.home_rounded,
    Icons.calculate,
    Icons.menu_book,
    Icons.lock,
    Icons.settings,
  ];

  static const labels = ["Home", "CGPA", "Courses", "Vault", "Settings"];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final s=w/460;
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12*s, vertical: 10*s),
        decoration: BoxDecoration(
          color: palette.theme,
          boxShadow: [
            BoxShadow(
              color: palette.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (int index = 0; index < icons.length; index++)
              _NavBarItem(
                icon: icons[index],
                label: labels[index],
                isSelected: selectedIndex == index,
                onTap: () => onTap(index),
                primary: palette.primary,
                theme: palette.theme,
              ),
          ],
        ),
      ),
    );

  }
}

// Isolated nav item to prevent sibling rebuilds
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primary;
  final Color theme;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.primary,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final s=w/460;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primary : theme,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22*s,
              color: isSelected ? theme : Colors.grey[700],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: theme,
                  fontWeight: FontWeight.w600,
                  fontSize: 12*s,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
