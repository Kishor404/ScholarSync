import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cgpa_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/course_controller.dart';
import '../controllers/document_controller.dart';
import '../controllers/theme_controller.dart';
//import '../widgets/banner_ad_widget.dart'; 
// import '../screens/cgpa_screen.dart';
// import '../screens/course_screen.dart';
// import '../screens/vault_screen.dart';

class HomeScreen extends GetView<HomeController> {
  HomeScreen({super.key, this.onNavigate});

  final void Function(int)? onNavigate;

  // Safely get controllers (create if not registered)

  final ThemeController themeController = Get.find<ThemeController>();

  final HomeController homeController = Get.find();
  final CgpaController cgpaController = Get.find();
  final CourseController courseController = Get.find();
  final DocumentController documentController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
    final palette = themeController.palette;
    final w = MediaQuery.of(context).size.width;
    final s=w/460;
    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Obx(() {
          // ----- CGPA DATA -----
          final latest = cgpaController.latestCgpa;
          final cgpa = latest?.cgpa ?? 0.0;
          final currentSem = latest?.currentSem ?? 0;

          // ----- COURSE & DOC DATA -----
          final completedCourses = courseController.completedCount;
          final totalDocuments = documentController.documents.length;
          final recentDocs = documentController.documents.reversed.take(3).toList();

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20*s, 16*s, 20*s, 5*s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                // ======== HEADER =========


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ScholarSync",
                      style: TextStyle(
                        fontSize: 22*s,
                        color: palette.minimal,
                        fontFamily: 'Righteous',
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6*s),


                Text(
                  "Welcome back !",
                  style: TextStyle(
                    fontSize: 14*s,
                    color: palette.black.withAlpha(150),
                  ),
                ),

                SizedBox(height: 20*s),


                // ======== TOP CGPA CARD =========


                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 20*s, bottom: 20*s,right: 18*s, left: 30*s),
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: BorderRadius.circular(18*s),
                    boxShadow: [
                      BoxShadow(
                        color: palette.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [

                      // Left cgpa
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cgpa == 0.0 ? "--" : cgpa.toStringAsFixed(2),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 40*s,
                                color: palette.accent,
                              ),
                            ),
                            SizedBox(height: 4*s),
                            Text(
                              "Current CGPA",
                              style: TextStyle(
                                fontSize: 14*s,
                                color: palette.accent.withAlpha(200),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 10*s),

                      // Right: sem info + button
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10*s, vertical: 6*s),
                            decoration: BoxDecoration(
                              color: palette.primary,
                              borderRadius: BorderRadius.circular(999*s),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timeline_outlined, size: 17*s, color: palette.accent),
                                SizedBox(width: 10*s),
                                Text(
                                  currentSem == 0 ? "No semesters added" : "Upto Sem $currentSem",
                                  style: TextStyle(
                                    fontSize: 14*s,
                                    fontWeight: FontWeight.w500,
                                    color: palette.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16*s),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.bg,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(horizontal: 14*s, vertical: 8*s),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              onNavigate?.call(1);
                            },

                            // ✅ ICON GOES HERE
                            icon: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFFFF5ACD),
                                  Color(0xFFB44CFF),
                                  Color(0xFF6A5CFF),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Icon(
                                Icons.auto_awesome,
                                size: 20*s, // 🔽 64 was too big for a button
                                color: Colors.white, // REQUIRED for ShaderMask
                              ),
                            ),

                            // ✅ LABEL
                            label: Text(
                              "Try New AI Features",
                              style: TextStyle(
                                fontSize: 12*s,
                                fontWeight: FontWeight.w500,
                                color: palette.black,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 22*s),

                // STATS CARDS ROW
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: "Courses completed",
                        value: completedCourses.toString(),
                        icon: Icons.playlist_add_check_rounded,
                        primary: palette.primary,
                        secondary: palette.secondary,
                        accent: palette.accent,
                        black: palette.black,
                      ),
                    ),
                    SizedBox(width: 12*s),
                    Expanded(
                      child: _StatCard(
                        title: "Documents saved",
                        value: totalDocuments.toString(),
                        icon: Icons.folder_special_outlined,
                        primary: palette.primary,
                        secondary: palette.secondary,
                        accent: palette.accent,
                        black: palette.black,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 26*s),

                // ======== BANNER AD =========

                // Obx(() {
                //   if (!homeController.shouldShowBanner) {
                //     return const SizedBox.shrink();
                //   }

                //   return Column(
                //     children: [
                //       Center(
                //         child: Container(
                //           padding: const EdgeInsets.symmetric(vertical: 6),
                //           decoration: BoxDecoration(
                //             color: palette.black.withAlpha(5),
                //             borderRadius: BorderRadius.circular(12),
                //           ),
                //           child: const BannerAdWidget(),
                //         ),
                //       ),
                //     ],
                //   );
                // }),


                // const SizedBox(height: 26),



                // QUICK ACTIONS TITLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Quick actions",
                      style: TextStyle(
                        fontSize: 14*s,
                        fontWeight: FontWeight.w600,
                        color: palette.black,
                      ),
                    ),
                    Text(
                      "Tap to open",
                      style: TextStyle(
                        fontSize: 11*s,
                        color: palette.black.withAlpha(150),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12*s),

                // QUICK ACTION GRID
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _QuickActionButton(
                      icon: Icons.calculate_outlined,
                      label: "CGPA\nCalculator",
                      onTap: () {
                        onNavigate?.call(1);
                      },
                      primary: palette.primary,
                      secondary: palette.secondary,
                      accent: palette.accent,
                      black: palette.black,
                    ),
                    _QuickActionButton(
                      icon: Icons.menu_book_outlined,
                      label: "My\nCourses",
                      onTap: () {
                        onNavigate?.call(2);
                      },
                      primary: palette.primary,
                      secondary: palette.secondary,
                      accent: palette.accent,
                      black: palette.black,
                    ),
                    _QuickActionButton(
                      icon: Icons.lock_outline,
                      label: "Document\nVault",
                      onTap: () {
                        onNavigate?.call(3);
                      },
                      primary: palette.primary,
                      secondary: palette.secondary,
                      accent: palette.accent,
                      black: palette.black,
                    ),
                  ],
                ),

                SizedBox(height: 26*s),

                // RECENT DOCUMENTS / FILL EMPTY SPACE USEFULLY
                Text(
                  "Recent documents",
                  style: TextStyle(
                    fontSize: 14*s,
                    fontWeight: FontWeight.w600,
                    color: palette.black,
                  ),
                ),
                SizedBox(height: 10*s),

                if (recentDocs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14*s, vertical: 16*s),
                    decoration: BoxDecoration(
                      color: palette.accent,
                      borderRadius: BorderRadius.circular(16*s),
                      boxShadow: [
                        BoxShadow(
                          color: palette.black.withAlpha(15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12*s),
                          decoration: BoxDecoration(
                            color: palette.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(12*s),
                          ),
                          child: Icon(
                            Icons.insert_drive_file_outlined,
                            color: palette.primary,
                            size: 25*s,
                          ),
                        ),
                        SizedBox(width: 12*s),
                        Expanded(
                          child: Text(
                            "No documents yet.\nSave your certificates, notes and PDFs in the Vault.",
                            style: TextStyle(
                              fontSize: 12*s,
                              color: palette.black.withAlpha(200),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: recentDocs.map((doc) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 10*s),
                        padding: EdgeInsets.symmetric(horizontal: 12*s, vertical: 12*s),
                        decoration: BoxDecoration(
                          color: palette.accent,
                          borderRadius: BorderRadius.circular(16*s),
                          boxShadow: [
                            BoxShadow(
                              color: palette.black.withAlpha(15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12*s),
                              decoration: BoxDecoration(
                                color: palette.primary.withAlpha(30),
                                borderRadius: BorderRadius.circular(12*s),
                              ),
                              child: Icon(
                                _iconForType(doc.type),
                                color: palette.primary,
                                size: 25*s,
                              ),
                            ),
                            SizedBox(width: 10*s),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13*s,
                                      fontWeight: FontWeight.w600,
                                      color: palette.black,
                                    ),
                                  ),
                                  SizedBox(height: 4*s),
                                  Text(
                                    doc.categories.join(' • '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11*s,
                                      color: palette.black.withAlpha(100),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  });
  }

  IconData _iconForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (t.contains('jpg') || t.contains('jpeg') || t.contains('png')) {
      return Icons.image_outlined;
    }
    if (t.contains('doc')) return Icons.description_outlined;
    return Icons.insert_drive_file_outlined;
  }
}

/// Small stat card used for "Courses completed" and "Documents saved"
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color black;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.black,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final s=w/460;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12*s, vertical: 14*s),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(14*s),
        boxShadow: [
          BoxShadow(
            color: black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10*s),
            decoration: BoxDecoration(
              color: primary.withAlpha(30),
              borderRadius: BorderRadius.circular(12*s),
            ),
            child: Icon(icon, size: 22*s, color: primary),
          ),
          SizedBox(width: 10*s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11*s,
                    color: black.withAlpha(200),
                  ),
                ),
                SizedBox(height: 4*s),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18*s,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable quick action button (CGPA, Courses, Vault)
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color black;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.black,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final s=w/460;

    return InkWell(
      borderRadius: BorderRadius.circular(18*s),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(18*s),
          boxShadow: [
            BoxShadow(
              color: black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6*s, vertical: 10*s),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12*s),
                decoration: BoxDecoration(
                  color: primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(16*s),
                ),
                child: Icon(
                  icon,
                  size: 22*s,
                  color: primary,
                ),
              ),
              SizedBox(height: 10*s),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11*s,
                  fontWeight: FontWeight.w500,
                  color: black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
