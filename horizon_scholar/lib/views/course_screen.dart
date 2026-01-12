import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/course_controller.dart';
import '../controllers/theme_controller.dart';
//import '../controllers/ad_controller.dart';

import '../models/course_model.dart';

class CourseScreen extends StatelessWidget {
  final CourseController courseController = Get.put(CourseController());
  final ThemeController themeController = Get.find<ThemeController>();
  //final AdController adController = Get.find<AdController>();

  CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: palette.bg,

      // ---------- FAB ADD BUTTON ----------
      floatingActionButton: SizedBox(
        height: 56 * s,
        width: 56 * s,
        child: FloatingActionButton(
          heroTag: 'course_screen_fab',
          onPressed: () => _showAddCourseDialog(context),
          backgroundColor: palette.primary,
          child: Icon(
            Icons.add,
            color: palette.accent,
            size: 28 * s,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 2 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Header with Title ----
              _buildHeader(palette, s, isMobile),

              SizedBox(height: 18 * s),

              // ---- Stats card (Completed / Pending) ----
              _buildStatsCard(palette, s, isMobile),

              SizedBox(height: 22 * s),

              // ---- Filter row: status + categories + +Category ----
              _buildFilterRow(context, palette, s, isMobile),

              SizedBox(height: 18 * s),

              // ---- Course list ----
              _buildCourseList(context, palette, s, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  // ============== HEADER SECTION ==============
  Widget _buildHeader(dynamic palette, double s, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Course Manager",
          style: TextStyle(
            fontSize: isMobile ? 22 * s : 26 * s,
            color: palette.minimal,
            fontFamily: 'Righteous',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4 * s),
        Text(
          "Track your learning & certificates",
          style: TextStyle(
            fontSize: isMobile ? 12 * s : 14 * s,
            color: palette.black.withAlpha(150),
          ),
        ),
      ],
    );
  }

  // ============== STATS CARD ==============
  Widget _buildStatsCard(dynamic palette, double s, bool isMobile) {
    return Obx(() {
      final completed = courseController.completedCount;
      final pending = courseController.pendingCount;

      return Container(
        padding: EdgeInsets.symmetric(vertical: 25 * s, horizontal: 14 * s),
        decoration: BoxDecoration(
          color: palette.primary,
          borderRadius: BorderRadius.circular(18 * s),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              offset: const Offset(0, 3),
              color: palette.black.withAlpha(10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$completed",
                    style: TextStyle(
                      fontSize: isMobile ? 24 * s : 28 * s,
                      fontWeight: FontWeight.w700,
                      color: palette.accent,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    "Completed",
                    style: TextStyle(
                      fontSize: isMobile ? 12 * s : 13 * s,
                      fontWeight: FontWeight.w500,
                      color: palette.accent,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1.5 * s,
              height: 50 * s,
              color: palette.accent,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$pending",
                    style: TextStyle(
                      fontSize: isMobile ? 24 * s : 28 * s,
                      fontWeight: FontWeight.w700,
                      color: palette.accent,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    "Pending",
                    style: TextStyle(
                      fontSize: isMobile ? 12 * s : 13 * s,
                      fontWeight: FontWeight.w500,
                      color: palette.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ============== FILTER ROW ==============
  Widget _buildFilterRow(BuildContext context, dynamic palette, double s, bool isMobile) {
    return Obx(() {
      final current = courseController.selectedFilter.value;
      final categories = courseController.categoryList;

      Widget buildFilterChip(String label) {
        final isSelected = current == label;
        return Padding(
          padding: EdgeInsets.only(right: 8.0 * s),
          child: ChoiceChip(
            label: Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 12 * s : 13 * s,
                fontWeight: FontWeight.w500,
              ),
            ),
            selected: isSelected,
            showCheckmark: false,
            backgroundColor: palette.black.withAlpha(20),
            selectedColor: palette.primary,
            labelStyle: TextStyle(
              color: isSelected ? palette.accent : palette.black,
            ),
            onSelected: (_) => courseController.selectedFilter.value = label,
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            buildFilterChip('All'),
            buildFilterChip('Completed'),
            buildFilterChip('Pending'),
            ...categories.map(buildFilterChip).toList(),
            GestureDetector(
              onTap: () => _showAddCategoryDialog(context),
              child: Container(
                margin: EdgeInsets.only(left: 4 * s),
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * s,
                  vertical: 9 * s,
                ),
                decoration: BoxDecoration(
                  color: palette.secondary,
                  borderRadius: BorderRadius.circular(12 * s),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16 * s, color: palette.black),
                    SizedBox(width: 4 * s),
                    Text(
                      "Category",
                      style: TextStyle(
                        fontSize: 12 * s,
                        color: palette.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ============== COURSE LIST ==============
  Widget _buildCourseList(BuildContext context, dynamic palette, double s, bool isMobile) {
    return Expanded(
      child: Obx(() {
        final courses = courseController.filteredCourses;

        if (courses.isEmpty) {
          return Center(
            child: Text(
              "No courses yet.\nTap + to add one.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13 * s,
                color: palette.black.withAlpha(150),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 80 * s),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            final originalIndex = courseController.courseList.indexOf(course);

            return GestureDetector(
              onTap: () => _showEditCourseDialog(context, course, originalIndex),
              child: _buildCourseCard(context, palette, s, course, isMobile),
            );
          },
        );
      }),
    );
  }

  // ============== COURSE CARD ==============
  Widget _buildCourseCard(BuildContext context, dynamic palette, double s,
    CourseModel course, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: 16 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14*s),
        boxShadow: [
          BoxShadow(
            color: palette.black.withAlpha(8),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14*s),
        child: Material(
          color: palette.accent,
          child: InkWell(
            child: Padding(
              padding: EdgeInsets.all(16 * s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Enhanced Thumbnail with Border
                  Container(
                    width: (isMobile ? 65 : 80) * s,
                    height: (isMobile ? 65 : 80) * s,
                    decoration: BoxDecoration(
                      color: palette.bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: palette.black.withAlpha(15), width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: _buildCertificatePreview(course.certificationPath, context),
                    ),
                  ),
                  SizedBox(width: 16 * s),

                  // 2. Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Pill (Small and clean)
                        _buildStatusPill(course.isCompleted, palette, s),
                        SizedBox(height: 8 * s),
                        Text(
                          course.courseName,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: (isMobile ? 15 : 17) * s,
                            letterSpacing: -0.5,
                            color: palette.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4 * s),
                        Text(
                          course.courseDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * s,
                            height: 1.3,
                            color: palette.black.withAlpha(140),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Dynamic Action Area
                  SizedBox(width: 12 * s),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (course.certificationPath.isNotEmpty)
                        _buildRoundActionButton(
                          icon: Icons.file_download_outlined,
                          color: palette.black,
                          onTap: () => _downloadCertificate(context, course.certificationPath),
                          s: s,
                        ),
                      if (course.certificationPath.isNotEmpty) SizedBox(height: 12 * s),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14 * s,
                        color: palette.black.withAlpha(80),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper: A modern "Status Pill"
  Widget _buildStatusPill(bool isCompleted, dynamic palette, double s) {
    final color = isCompleted ? palette.success : palette.warning;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: color.withAlpha(25), // Semi-transparent background
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3 * s, backgroundColor: color),
          SizedBox(width: 6 * s),
          Text(
            isCompleted ? "COMPLETED" : "IN PROGRESS",
            style: TextStyle(
              fontSize: 9 * s,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Minimalist Action Button
  Widget _buildRoundActionButton({required IconData icon, required Color color, required VoidCallback onTap, required double s}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8 * s),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(15),
        ),
        child: Icon(icon, size: 18 * s, color: color),
      ),
    );
  }

  // ================== CERTIFICATE PREVIEW ==================
  Widget _buildCertificatePreview(String path, context) {
    final palette = themeController.palette;

    if (path.isEmpty) {
      return Icon(Icons.insert_drive_file, color: palette.black.withAlpha(150));
    }

    final ext = path.split('.').last.toLowerCase();

    if (ext == 'png' || ext == 'jpg' || ext == 'jpeg') {
      final file = File(path);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    if (ext == 'pdf') {
      final w = MediaQuery.of(context).size.width;
      final s = w / 460;
      return Icon(
        Icons.picture_as_pdf,
        color: palette.error,
        size: 32 * s,
      );
    }

    return Icon(Icons.insert_drive_file, color: palette.black.withAlpha(150));
  }

  // ================== ADD COURSE DIALOG ==================
  void _showAddCourseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final certPathController = TextEditingController();
    final isCompleted = false.obs;
    final selectedFileName = ''.obs;
    final selectedCategories = <String>[].obs;
    final palette = themeController.palette;

    Future<void> _pickCertificate() async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          withData: false,
        );

        if (result == null || result.files.isEmpty) return;

        final file = result.files.single;

        if (file.path == null) return;

        certPathController.text = file.path!;
        selectedFileName.value = file.name;
      } catch (e) {
        debugPrint("FilePicker error: $e");
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final screenSize = MediaQuery.of(context).size;
        final w = screenSize.width;
        final s = w / 460;

        // Responsive dialog width
        final dialogWidth = w > 600 ? 600.0 : w * 0.9;

        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: palette.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20 * s, 18 * s, 20 * s, 10 * s),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Add Course",
                          style: TextStyle(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20 * s),

                    // Course name
                    TextField(
                      controller: nameController,
                      style: TextStyle(fontSize: 14 * s),
                      decoration: InputDecoration(
                        labelText: "Course name",
                        labelStyle: TextStyle(fontSize: 14 * s),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        prefixIcon: Icon(Icons.menu_book_outlined, size: 22 * s),
                        filled: true,
                        fillColor: palette.black.withAlpha(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 10 * s),

                    // Description
                    Container(
                      decoration: BoxDecoration(
                        color: palette.black.withAlpha(10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.fromLTRB(12 * s, 14 * s, 12 * s, 14 * s),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 2 * s),
                            child: Icon(
                              Icons.description_outlined,
                              size: 22 * s,
                              color: palette.black.withAlpha(160),
                            ),
                          ),
                          SizedBox(width: 10 * s),
                          Expanded(
                            child: TextField(
                              controller: descController,
                              maxLines: 3,
                              textAlignVertical: TextAlignVertical.top,
                              style: TextStyle(fontSize: 14 * s),
                              decoration: const InputDecoration(
                                hintText: "Course description",
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15 * s),

                    // Upload certificate
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Certificate (optional)",
                            style: TextStyle(
                              fontSize: 13 * s,
                              color: palette.black.withAlpha(150),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6 * s),
                          FilledButton.icon(
                            onPressed: _pickCertificate,
                            style: FilledButton.styleFrom(
                              backgroundColor: palette.primary,
                              foregroundColor: palette.accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12 * s,
                                vertical: 10 * s,
                              ),
                            ),
                            icon: const Icon(Icons.upload_file),
                            label: Text(
                              selectedFileName.isEmpty
                                  ? "Upload certificate"
                                  : selectedFileName.value,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14 * s),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10 * s),

                    // Categories multi-select
                    Obx(() {
                      final categories = courseController.categoryList;

                      if (categories.isEmpty) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Categories",
                              style: TextStyle(
                                fontSize: 13 * s,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showAddCategoryDialog(context),
                              icon: Icon(Icons.add,
                                  size: 16 * s, color: palette.primary),
                              label: Text(
                                "Add category",
                                style: TextStyle(
                                  fontSize: 14 * s,
                                  color: palette.primary,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Categories",
                                style: TextStyle(
                                  fontSize: 13 * s,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _showAddCategoryDialog(context),
                                icon: Icon(Icons.add,
                                    size: 16 * s, color: palette.primary),
                                label: Text(
                                  "New",
                                  style: TextStyle(color: palette.primary),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6 * s),
                          Wrap(
                            spacing: 8 * s,
                            runSpacing: 6 * s,
                            children: categories.map((cat) {
                              final isSelected =
                                  selectedCategories.contains(cat);
                              return ChoiceChip(
                                backgroundColor: palette.black.withAlpha(20),
                                selectedColor: palette.secondary,
                                label: Text(cat),
                                showCheckmark: false,
                                selected: isSelected,
                                onSelected: (val) {
                                  if (val) {
                                    selectedCategories.add(cat);
                                  } else {
                                    selectedCategories.remove(cat);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: 6 * s),

                    // Completed switch
                    Obx(
                      () => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Completed",
                          style: TextStyle(fontSize: 14 * s),
                        ),
                        value: isCompleted.value,
                        activeColor: palette.accent,
                        activeTrackColor: palette.primary,
                        onChanged: (val) => isCompleted.value = val,
                      ),
                    ),
                    SizedBox(height: 8 * s),

                    // Buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 14 * s,
                              color: palette.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * s),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Course name cannot be empty"),
                                ),
                              );
                              return;
                            }

                            final course = CourseModel(
                              courseName: nameController.text.trim(),
                              isCompleted: isCompleted.value,
                              certificationPath: certPathController.text.trim(),
                              courseDescription: descController.text.trim(),
                              categories: selectedCategories.toList(),
                            );

                            courseController.addCourse(course);
                            Navigator.of(ctx).pop();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10 * s,
                              vertical: 6 * s,
                            ),
                            child: Text(
                              "Save",
                              style: TextStyle(
                                fontSize: 14 * s,
                                color: palette.accent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= DOWNLOAD COURSE CERTIFICATE ==================
  String getUniqueFileName(String fileName) {
  // Split filename into name and extension
  final lastDotIndex = fileName.lastIndexOf('.');
  final name = lastDotIndex > 0 
    ? fileName.substring(0, lastDotIndex) 
    : fileName;
  final ext = lastDotIndex > 0 
    ? fileName.substring(lastDotIndex) 
    : '';

  // File doesn't exist, return as is
  final saveDir = Directory('/storage/emulated/0/Download'); // or your default path
  if (!File('${saveDir.path}/$fileName').existsSync()) {
    return fileName;
  }

  // File exists, find unique name
  int counter = 1;
  while (File('${saveDir.path}/$name($counter)$ext').existsSync()) {
    counter++;
  }
  
  return '$name($counter)$ext';
}

Future<void> _downloadCertificate(
  BuildContext context,
  String sourcePath,
) async {
  try {
    if (sourcePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No certificate available')),
      );
      return;
    }

    final sourceFile = File(sourcePath);
    if (!sourceFile.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Certificate file not found')),
      );
      return;
    }

    var fileName = p.basename(sourcePath);
    // ✅ FIX: Get unique filename BEFORE saving
    fileName = getUniqueFileName(fileName);
    
    final bytes = await sourceFile.readAsBytes();

    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Download certificate',
      fileName: fileName,  // ✅ Now uses Test(1).png instead of Test.png (1)
      bytes: bytes,
    );

    if (savePath == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Certificate downloaded successfully')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Download failed: $e')),
    );
  }
}


  // ================== EDIT COURSE DIALOG ==================
  void _showEditCourseDialog(
    BuildContext context,
    CourseModel course,
    int index,
  ) {
    final nameController = TextEditingController(text: course.courseName);
    final descController =
        TextEditingController(text: course.courseDescription);
    final certPathController =
        TextEditingController(text: course.certificationPath);
    final isCompleted = course.isCompleted.obs;
    final selectedCategories = (course.categories).toList().obs;

    final selectedFileName = (course.certificationPath.isNotEmpty
            ? p.basename(course.certificationPath)
            : '')
        .obs;

    Future<void> _pickCertificate() async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          withData: false,
        );

        if (result == null || result.files.isEmpty) return;

        final file = result.files.single;

        if (file.path == null) return;

        certPathController.text = file.path!;
        selectedFileName.value = file.name;
      } catch (e) {
        debugPrint("FilePicker error: $e");
      }
    }

    final palette = themeController.palette;

    showDialog(
      context: context,
      builder: (ctx) {
        final screenSize = MediaQuery.of(context).size;
        final w = screenSize.width;
        final s = w / 460;

        // Responsive dialog width
        final dialogWidth = w > 600 ? 600.0 : w * 0.9;

        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: palette.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20 * s, 18 * s, 20 * s, 10 * s),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Edit Course",
                          style: TextStyle(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15 * s),

                    // Course name
                    TextField(
                      controller: nameController,
                      style: TextStyle(fontSize: 14 * s),
                      decoration: InputDecoration(
                        labelText: "Course name",
                        labelStyle: TextStyle(fontSize: 14 * s),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        prefixIcon: Icon(Icons.menu_book_outlined, size: 22 * s),
                        filled: true,
                        fillColor: palette.black.withAlpha(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 10 * s),

                    // Description
                    Container(
                      decoration: BoxDecoration(
                        color: palette.black.withAlpha(10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.fromLTRB(12 * s, 14 * s, 12 * s, 14 * s),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 2 * s),
                            child: Icon(
                              Icons.description_outlined,
                              size: 22 * s,
                              color: palette.black.withAlpha(160),
                            ),
                          ),
                          SizedBox(width: 10 * s),
                          Expanded(
                            child: TextField(
                              controller: descController,
                              maxLines: 3,
                              textAlignVertical: TextAlignVertical.top,
                              style: TextStyle(fontSize: 14 * s),
                              decoration: const InputDecoration(
                                hintText: "Course description",
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15 * s),

                    // Upload certificate
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Certificate (optional)",
                            style: TextStyle(
                              fontSize: 13 * s,
                              color: palette.black.withAlpha(150),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6 * s),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: palette.primary,
                              foregroundColor: palette.accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 15 * s,
                                vertical: 10 * s,
                              ),
                            ),
                            onPressed: _pickCertificate,
                            icon: const Icon(Icons.upload_file),
                            label: Text(
                              selectedFileName.isEmpty
                                  ? "Upload / Change certificate"
                                  : selectedFileName.value,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12 * s),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10 * s),

                    // Categories multi-select
                    Obx(() {
                      final categories = courseController.categoryList;

                      if (categories.isEmpty) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Categories",
                              style: TextStyle(
                                fontSize: 13 * s,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showAddCategoryDialog(context),
                              icon: Icon(Icons.add,
                                  size: 16 * s, color: palette.primary),
                              label: Text(
                                "Add category",
                                style: TextStyle(
                                  fontSize: 14 * s,
                                  color: palette.primary,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Categories",
                                style: TextStyle(
                                  fontSize: 13 * s,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _showAddCategoryDialog(context),
                                icon: Icon(Icons.add,
                                    size: 16 * s, color: palette.primary),
                                label: Text(
                                  "New",
                                  style: TextStyle(color: palette.primary),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6 * s),
                          Wrap(
                            spacing: 8 * s,
                            runSpacing: 6 * s,
                            children: categories.map((cat) {
                              final isSelected =
                                  selectedCategories.contains(cat);
                              return ChoiceChip(
                                backgroundColor: palette.black.withAlpha(20),
                                selectedColor: palette.secondary,
                                label: Text(cat),
                                showCheckmark: false,
                                selected: isSelected,
                                onSelected: (val) {
                                  if (val) {
                                    selectedCategories.add(cat);
                                  } else {
                                    selectedCategories.remove(cat);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: 6 * s),

                    // Completed switch
                    Obx(
                      () => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Completed",
                          style: TextStyle(fontSize: 14 * s),
                        ),
                        activeColor: palette.accent,
                        activeTrackColor: palette.primary,
                        value: isCompleted.value,
                        onChanged: (val) => isCompleted.value = val,
                      ),
                    ),
                    SizedBox(height: 8 * s),

                    // Buttons row: Delete + Update
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Delete button
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (confirmCtx) {
                                final confirmW =
                                    MediaQuery.of(context).size.width;
                                final confirmS = confirmW / 460;

                                return Dialog(
                                  backgroundColor: palette.bg,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      20 * confirmS,
                                      18 * confirmS,
                                      20 * confirmS,
                                      12 * confirmS,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.warning_amber_rounded,
                                                    color: palette.error),
                                                SizedBox(width: 8 * confirmS),
                                                Text(
                                                  "Delete Course?",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14 * confirmS,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () =>
                                                  Navigator.of(confirmCtx)
                                                      .pop(),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8 * confirmS),
                                        Text(
                                          "Are you sure you want to delete this course? This action cannot be undone.",
                                          style: TextStyle(
                                            fontSize: 13 * confirmS,
                                            color: palette.black,
                                          ),
                                        ),
                                        SizedBox(height: 16 * confirmS),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(confirmCtx)
                                                      .pop(),
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  fontSize: 14 * confirmS,
                                                  color: palette.primary,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8 * confirmS),
                                            ElevatedButton(
                                              onPressed: () {
                                                courseController
                                                    .deleteCourse(index);
                                                Navigator.of(confirmCtx).pop();
                                                Navigator.of(ctx).pop();
                                              },
                                              style:
                                                  ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    palette.error,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text(
                                                "Delete",
                                                style: TextStyle(
                                                  fontSize: 14 * confirmS,
                                                  color: palette.accent,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.delete_outline,
                            color: palette.error,
                          ),
                          label: Text(
                            "Delete",
                            style: TextStyle(
                              fontSize: 13 * s,
                              color: palette.error,
                            ),
                          ),
                        ),
                        // Cancel and Update buttons
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 12 * s,
                                  color: palette.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: 8 * s),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: palette.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (nameController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Course name cannot be empty",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final updatedCourse = CourseModel(
                                  courseName: nameController.text.trim(),
                                  isCompleted: isCompleted.value,
                                  certificationPath:
                                      certPathController.text.trim(),
                                  courseDescription:
                                      descController.text.trim(),
                                  categories: selectedCategories.toList(),
                                );

                                courseController.updateCourse(
                                  index,
                                  updatedCourse,
                                );
                                Navigator.of(ctx).pop();
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4 * s,
                                  vertical: 6 * s,
                                ),
                                child: Text(
                                  "Update",
                                  style: TextStyle(
                                    fontSize: 12 * s,
                                    color: palette.accent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================== ADD CATEGORY DIALOG ==================
  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    final palette = themeController.palette;

    showDialog(
      context: context,
      builder: (ctx) {
        final w = MediaQuery.of(context).size.width;
        final s = w / 460;

        // Responsive dialog width
        final dialogWidth = w > 600 ? 500.0 : w * 0.85;

        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: palette.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20 * s, 20 * s, 20 * s, 10 * s),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "New Category",
                    style: TextStyle(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12 * s),
                  TextField(
                    controller: controller,
                    style: TextStyle(fontSize: 14 * s),
                    decoration: InputDecoration(
                      labelText: "Category name",
                      labelStyle: TextStyle(fontSize: 14 * s),
                      filled: true,
                      fillColor: palette.black.withAlpha(10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 14 * s,
                            color: palette.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      ElevatedButton(
                        onPressed: () {
                          final name = controller.text.trim();
                          if (name.isNotEmpty) {
                            courseController.addCategory(name);
                          }
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: palette.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Add",
                          style: TextStyle(
                            fontSize: 14 * s,
                            color: palette.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}