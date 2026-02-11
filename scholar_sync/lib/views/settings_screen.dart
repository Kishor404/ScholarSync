import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cgpa_calc_controller.dart';
import '../controllers/cgpa_controller.dart';
import '../controllers/course_controller.dart';
import '../controllers/document_controller.dart';
import '../controllers/theme_controller.dart';
//import '../widgets/banner_ad_widget.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final ThemeController themeController = Get.find<ThemeController>();

  final CgpaCalcController cgpaCalcController =
      Get.isRegistered<CgpaCalcController>()
          ? Get.find<CgpaCalcController>()
          : Get.put(CgpaCalcController());

  final CgpaController cgpaController = Get.isRegistered<CgpaController>()
      ? Get.find<CgpaController>()
      : Get.put(CgpaController());

  final CourseController courseController =
      Get.isRegistered<CourseController>()
          ? Get.find<CourseController>()
          : Get.put(CourseController());

  final DocumentController documentController =
      Get.isRegistered<DocumentController>()
          ? Get.find<DocumentController>()
          : Get.put(DocumentController());

  @override
  Widget build(BuildContext context) {
    // Entire screen listens to theme changes
    return Obx(() {
      final palette = themeController.palette;
      final screenSize = MediaQuery.of(context).size;
      final screenWidth = screenSize.width;

      // Improved responsive scaling
      final isMobile = screenWidth < 600;
      final isTablet = screenWidth >= 600 && screenWidth < 1200;

      // Dynamic scaling factor with better breakpoints
      late double s;
      if (isMobile) {
        s = screenWidth / 460; // Original mobile scaling
      } else if (isTablet) {
        s = screenWidth / 600; // Tablet scaling
      } else {
        s = screenWidth / 800; // Desktop scaling
      }

      // Adaptive max width for desktop
      late double maxContentWidth;
      if (isMobile) {
        maxContentWidth = double.infinity;
      } else if (isTablet) {
        maxContentWidth = 600;
      } else {
        maxContentWidth = 800;
      }

      return Scaffold(
        backgroundColor: palette.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20 * s, 16 * s, 20 * s, 20 * s),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Header ----
                    _buildHeader(palette, s, isMobile),

                    SizedBox(height: 22 * s),

                    // ---- Data Section ----
                    _buildDataSection(context, palette, s, isMobile),

                    SizedBox(height: 22 * s),

                    // ---- Preferences Section ----
                    _buildPreferencesSection(palette, context, s, isMobile),

                    SizedBox(height: 22 * s),

                    // ---- About Section ----
                    _buildAboutSection(context, palette, s, isMobile),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // ============== HEADER ==============
  Widget _buildHeader(AppPalette palette, double s, bool isMobile) {
    return Text(
      "Settings",
      style: TextStyle(
        fontSize: isMobile ? 22 * s : 26 * s,
        color: palette.black,
        fontFamily: 'Righteous',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ============== DATA & STORAGE SECTION ==============
  Widget _buildDataSection(
      BuildContext context, AppPalette palette, double s, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: _cardDecoration(palette),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Data & Storage",
            style: TextStyle(
              fontSize: isMobile ? 13 * s : 14 * s,
              fontWeight: FontWeight.w600,
              color: palette.black,
            ),
          ),
          SizedBox(height: 6 * s),
          Text(
            "Manage the data stored on this device.",
            style: TextStyle(
              fontSize: isMobile ? 11 * s : 12 * s,
              color: palette.black.withAlpha(150),
            ),
          ),
          SizedBox(height: 12 * s),

          // Clear all data
          _SettingsTile(
            icon: Icons.delete_forever_rounded,
            iconColor: palette.primary,
            textColor: palette.black,
            title: "Clear ALL data",
            subtitle: "Remove CGPA, subjects, courses and documents.",
            onTap: () {
              _confirmActionWithDelete(
                context,
                title: "Clear all data?",
                message:
                    "This will delete CGPA records, subjects, courses and documents.\n\nType \"delete\" to confirm.",
                onConfirm: () async {
                  await cgpaCalcController.clearAllCgpaData();
                  await courseController.clearAllCourses();
                  await documentController.clearAllDocuments();
                  if (!context.mounted) return;
                  Get.back();
                  _showSnack("All data cleared", context);
                },
              );
            },
          ),

          Divider(height: 18 * s),

          // Clear CGPA data
          _SettingsTile(
            icon: Icons.calculate_rounded,
            iconColor: palette.primary,
            textColor: palette.black,
            title: "Clear CGPA data",
            subtitle: "Reset all CGPA entries, GPAs and subject grades.",
            onTap: () {
              _confirmActionWithDelete(
                context,
                title: "Clear CGPA data?",
                message:
                    "All CGPA records, GPA per semester and subject grades will be removed.\n\nType \"delete\" to confirm.",
                onConfirm: () async {
                  await cgpaCalcController.clearAllCgpaData();
                  if (!context.mounted) return;
                  Get.back();
                  _showSnack("CGPA data cleared", context);
                },
              );
            },
          ),

          // Clear course data
          _SettingsTile(
            icon: Icons.menu_book_rounded,
            iconColor: palette.primary,
            textColor: palette.black,
            title: "Clear course data",
            subtitle: "Remove saved courses and linked certificates.",
            onTap: () {
              _confirmActionWithDelete(
                context,
                title: "Clear course data?",
                message:
                    "All saved courses and linked course documents will be removed.\n\nType \"delete\" to confirm.",
                onConfirm: () async {
                  await courseController.clearAllCourses();
                  if (!context.mounted) return;
                  Get.back();
                  _showSnack("Course data cleared", context);
                },
              );
            },
          ),

          // Clear document vault
          _SettingsTile(
            icon: Icons.folder_off_rounded,
            textColor: palette.black,
            iconColor: palette.primary,
            title: "Clear document vault",
            subtitle: "Delete all saved documents from the Vault.",
            onTap: () {
              _confirmActionWithDelete(
                context,
                title: "Clear documents?",
                message:
                    "All documents in the Vault will be deleted from this device.\n\nType \"delete\" to confirm.",
                onConfirm: () async {
                  await documentController.clearAllDocuments();
                  if (!context.mounted) return;
                  Get.back();
                  _showSnack("Documents cleared", context);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ============== PREFERENCES SECTION ==============
  Widget _buildPreferencesSection(
      AppPalette palette, BuildContext context, double s, bool isMobile) {
    final RxBool haptics = true.obs;
    final RxBool smartTips = true.obs;

    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: _cardDecoration(palette),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Experience",
            style: TextStyle(
              fontSize: isMobile ? 13 * s : 14 * s,
              fontWeight: FontWeight.w600,
              color: palette.black,
            ),
          ),
          SizedBox(height: 6 * s),
          Text(
            "Fine-tune how the app behaves.",
            style: TextStyle(
              fontSize: isMobile ? 11 * s : 12 * s,
              color: palette.black.withAlpha(150),
            ),
          ),
          SizedBox(height: 12 * s),

          Obx(
            () => _SettingsSwitchTile(
              icon: Icons.vibration_rounded,
              iconColor: palette.primary,
              textColor: palette.black,
              title: "Haptic feedback",
              subtitle: "Small vibrations when you tap important buttons.",
              value: haptics.value,
              onChanged: (v) => haptics.value = v,
            ),
          ),

          SizedBox(height: 6 * s),

          Obx(
            () => _SettingsSwitchTile(
              icon: Icons.tips_and_updates_rounded,
              iconColor: palette.primary,
              textColor: palette.black,
              title: "Smart tips",
              subtitle: "Show study tips and shortcuts on the home screen.",
              value: smartTips.value,
              onChanged: (v) => smartTips.value = v,
            ),
          ),
        ],
      ),
    );
  }

  // ============== ABOUT SECTION ==============
  Widget _buildAboutSection(
      BuildContext context, AppPalette palette, double s, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: _cardDecoration(palette),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About",
            style: TextStyle(
              fontSize: isMobile ? 13 * s : 14 * s,
              fontWeight: FontWeight.w600,
              color: palette.black,
            ),
          ),
          SizedBox(height: 10 * s),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: palette.primary,
            textColor: palette.black,
            title: "About ScholarSync",
            subtitle: "Version 1.0.0 • Made for students",
            onTap: () {
              _showAboutBottomSheet(context, palette, s, isMobile);
            },
          ),
        ],
      ),
    );
  }

  // ============== ABOUT BOTTOM SHEET ==============
  void _showAboutBottomSheet(
    BuildContext context, AppPalette palette, double s, bool isMobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ⭐ IMPORTANT
      backgroundColor: palette.accent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

        return SafeArea(
          top: false, // allow rounded corners at top
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20 * s,
              18 * s,
              20 * s,
              (24 * s) + bottomPadding, // ⭐ prevents overlap
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag indicator
                Center(
                  child: Container(
                    width: 42 * s,
                    height: 4 * s,
                    margin: EdgeInsets.only(bottom: 14 * s),
                    decoration: BoxDecoration(
                      color: palette.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),

                // App header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6 * s),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: palette.primary.withAlpha(50),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 48 * s,
                          height: 48 * s,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ScholarSync",
                            style: TextStyle(
                              fontSize: isMobile ? 15 * s : 16 * s,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Your academic companion for CGPA, courses and documents.",
                            style: TextStyle(
                              fontSize: isMobile ? 10 * s : 11 * s,
                              color: palette.black.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16 * s),

                Text(
                  "Built by Kishor404",
                  style: TextStyle(
                    fontSize: isMobile ? 11 * s : 12 * s,
                    fontWeight: FontWeight.w500,
                    color: palette.black,
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  "This app helps you track semesters, organize course info and keep important documents safe in one place.",
                  style: TextStyle(
                    fontSize: isMobile ? 10 * s : 11 * s,
                    color: palette.black.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // ============== HELPERS ==============
  BoxDecoration _cardDecoration(AppPalette palette) {
    return BoxDecoration(
      color: palette.accent,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: palette.black.withAlpha(10),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  void _confirmActionWithDelete(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) {
    final TextEditingController controller = TextEditingController();
    String currentText = '';

    final palette = themeController.palette;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    late double s;
    if (screenWidth < 600) {
      s = screenWidth / 460;
    } else if (screenWidth >= 600 && screenWidth < 1200) {
      s = screenWidth / 600;
    } else {
      s = screenWidth / 800;
    }

    Get.dialog(
      StatefulBuilder(
        builder: (ctx, setState) {
          final bool isValid = currentText.trim().toLowerCase() == 'delete';

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: palette.error),
                SizedBox(width: 8 * s),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12 * s,
                    color: palette.black.withAlpha(150),
                  ),
                ),
                SizedBox(height: 12 * s),
                TextField(
                  controller: controller,
                  onChanged: (val) {
                    setState(() {
                      currentText = val;
                    });
                  },
                  style: TextStyle(fontSize: 13 * s),
                  decoration: InputDecoration(
                    labelText: 'Type "delete" to confirm',
                    labelStyle: TextStyle(fontSize: 12 * s),
                    filled: true,
                    fillColor: palette.black.withAlpha(20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 12 * s,
                    color: palette.black.withAlpha(200),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isValid
                    ? () async {
                        await onConfirm();
                      }
                    : null,
                child: Text(
                  "Delete",
                  style: TextStyle(
                    fontSize: 12 * s,
                    color: palette.accent,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSnack(String message, BuildContext context) {
    final palette = themeController.palette;
    
    // Use a smaller, fixed scaling factor for the snackbar to keep it compact
    final double s = MediaQuery.of(context).size.width < 600 ? 1.0 : 0.8;

    Get.rawSnackbar(
      messageText: Text(
        message,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: palette.accent,
          fontSize: 13 * s,
          fontWeight: FontWeight.w500,
        ),
      ),
      // This makes it float and stay small
      //maxWidth: 300 * s, 
      snackPosition: SnackPosition.BOTTOM,
      //margin: EdgeInsets.only(bottom: 40 * s, left: 20, right: 20),
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 10 * s),
      backgroundColor: palette.error,
      animationDuration: const Duration(milliseconds: 300),
      duration: const Duration(seconds: 2),
      boxShadows: [
        BoxShadow(
          color: palette.black.withAlpha(20),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

// ============== SETTINGS TILE ==============
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    late double s;
    if (screenWidth < 600) {
      s = screenWidth / 460;
    } else if (screenWidth >= 600 && screenWidth < 1200) {
      s = screenWidth / 600;
    } else {
      s = screenWidth / 800;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6 * s),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8 * s),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 20 * s, color: iconColor),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2 * s),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11 * s,
                        color: textColor.withAlpha(150),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18 * s, color: textColor.withAlpha(200)),
          ],
        ),
      ),
    );
  }
}

// ============== SWITCH TILE ==============
class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    late double s;
    if (screenWidth < 600) {
      s = screenWidth / 460;
    } else if (screenWidth >= 600 && screenWidth < 1200) {
      s = screenWidth / 600;
    } else {
      s = screenWidth / 800;
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8 * s),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(30),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 20 * s, color: iconColor),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2 * s),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 11 * s,
                    color: textColor.withAlpha(150),
                  ),
                ),
              ],
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}