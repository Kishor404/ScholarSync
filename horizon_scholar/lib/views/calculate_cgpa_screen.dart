import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cgpa_calc_controller.dart';
import '../models/subject_model.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/user_pref_controller.dart';

class CalculateCgpaScreen extends StatefulWidget {
  const CalculateCgpaScreen({super.key});

  @override
  State<CalculateCgpaScreen> createState() => _CalculateCgpaScreenState();
}

class _CalculateCgpaScreenState extends State<CalculateCgpaScreen> {
  final CgpaCalcController calcController = Get.find<CgpaCalcController>();
  final ThemeController themeController = Get.find<ThemeController>();

  int _selectedSemester = 1;

  List<SubjectModel> _subjectsForSem(List<SubjectModel> all, int sem) {
    return all.where((s) => s.semester == sem).toList();
  }

  // ============== BUILD ==============

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
      appBar: AppBar(
        backgroundColor: palette.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.black),
        title: Text(
          "Calculate CGPA",
          style: TextStyle(
            fontSize: isMobile ? 20 * s : 24 * s,
            color: palette.black,
            fontFamily: 'Righteous',
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(() {
          final subjects = calcController.subjects;
          final gpaMap = calcController.gpaPerSem;
          final cgpa = calcController.cgpa.value;

          // Optimization: This sort is fine as semester subjects are usually few (<15)
          final subjectsForSem = _subjectsForSem(subjects, _selectedSemester);
          subjectsForSem.sort((a, b) => a.code.compareTo(b.code));

          return Column(
            children: [
              // TOP SUMMARY CARD
              _buildSummaryCard(palette, s, isMobile, cgpa, gpaMap),

              SizedBox(height: 6 * s),

              // SEMESTER CHIPS + ADD SUBJECT
              _buildSemesterBar(context, palette, s, isMobile),

              SizedBox(height: 6 * s),

              // SUBJECT LIST
              _buildSubjectList(
                context,
                palette,
                s,
                isMobile,
                subjectsForSem,
              ),
            ],
          );
        }),
      ),
    );
  }

  // ============== SUMMARY CARD ==============
  Widget _buildSummaryCard(
    AppPalette palette,
    double s,
    bool isMobile,
    double cgpa,
    Map<int, double> gpaMap,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20 * s, 8 * s, 20 * s, 8 * s),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 25 * s, horizontal: 25 * s),
        decoration: BoxDecoration(
          color: palette.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          //scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // CGPA text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cgpa == 0.0 ? "--" : cgpa.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: isMobile ? 28 * s : 32 * s,
                      color: palette.accent,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    "Current CGPA",
                    style: TextStyle(
                      fontSize: isMobile ? 11 * s : 12 * s,
                      color: palette.accent.withAlpha(150),
                    ),
                  ),
                ],
              ),

              SizedBox(width: 24 * s),

              // Sem-wise GPA summary
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Semester $_selectedSemester GPA",
                    style: TextStyle(
                      fontSize: isMobile ? 11 * s : 12 * s,
                      color: palette.accent,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  if (gpaMap.isEmpty)
                    Text(
                      "No data",
                      style: TextStyle(
                        fontSize: isMobile ? 11 * s : 12 * s,
                        color: palette.accent,
                      ),
                    )
                  else
                    Text(
                      gpaMap[_selectedSemester] == null
                          ? "--"
                          : "${gpaMap[_selectedSemester]?.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: isMobile ? 18 * s : 20 * s,
                        fontWeight: FontWeight.w600,
                        color: palette.accent,
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============== SEMESTER BAR ==============
  Widget _buildSemesterBar(
    BuildContext context,
    AppPalette palette,
    double s,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 4 * s),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(8, (index) {
                  final sem = index + 1;
                  final isSelected = _selectedSemester == sem;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.0 * s),
                    child: ChoiceChip(
                      label: Text(
                        "Sem $sem",
                        style: TextStyle(fontSize: isMobile ? 11 * s : 12 * s),
                      ),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: palette.primary,
                      backgroundColor: palette.black.withAlpha(20),
                      labelStyle: TextStyle(
                        color: isSelected ? palette.accent : palette.black,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedSemester = sem;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(width: 8 * s),
          ElevatedButton(
            onPressed: () => _showAddSubjectOptions(
              context,
              _selectedSemester,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15*s,vertical:9 * s),
            ),
            child: Row(
              children: [
                Icon(Icons.add, color: palette.accent, size: 18 * s),
                SizedBox(width: 4 * s),
                Text(
                  "Subject",
                  style: TextStyle(
                    color: palette.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 12 * s,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============== SUBJECT LIST ==============
  Widget _buildSubjectList(
    BuildContext context,
    AppPalette palette,
    double s,
    bool isMobile,
    List<SubjectModel> subjectsForSem,
  ) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * s),
        child: subjectsForSem.isEmpty
            ? Center(
                child: Text(
                  "No subjects for this semester.\nTap + to add.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 12 * s : 13 * s,
                    color: palette.black.withAlpha(150),
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.only(bottom: 20 * s),
                itemCount: subjectsForSem.length,
                itemBuilder: (context, index) {
                  final subject = subjectsForSem[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 10 * s),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * s,
                      vertical: 10 * s,
                    ),
                    decoration: BoxDecoration(
                      color: palette.accent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                          color: palette.black.withAlpha(10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // subject name & credits (and code)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.code.isNotEmpty
                                    ? "${subject.code} - ${subject.name}"
                                    : subject.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isMobile ? 13 * s : 14 * s,
                                  fontWeight: FontWeight.w600,
                                  color: palette.black,
                                ),
                              ),
                              SizedBox(height: 4 * s),
                              Text(
                                "${subject.credits.toStringAsFixed(1)} credits",
                                style: TextStyle(
                                  fontSize: isMobile ? 10 * s : 11 * s,
                                  color: palette.black.withAlpha(150),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 8 * s),

                        // grade dropdown
                        SizedBox(
                          width: isMobile ? 100 * s : 110 * s,
                          child: DropdownButtonFormField<String>(
                            value: subject.grade.isEmpty ? null : subject.grade,
                            items: calcController.gradePoints.keys
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(
                                      g,
                                      style: TextStyle(fontSize: 12 * s),
                                    ),
                                  ),
                                )
                                .toList(),
                            hint: Text(
                              "Grade",
                              style: TextStyle(fontSize: 12 * s),
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                calcController.updateSubjectGrade(
                                  subject,
                                  val,
                                );
                              }
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10 * s,
                                vertical: 8 * s,
                              ),
                              filled: true,
                              fillColor: palette.black.withAlpha(20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 4 * s),

                        // delete subject
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: isMobile ? 18 * s : 20 * s,
                            color: palette.error,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 36 * s,
                            minHeight: 36 * s,
                          ),
                          onPressed: () {
                            _showDeleteConfirmation(
                              context,
                              subject,
                              palette,
                              s,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget bottomSheetSafeWrapper({
    required BuildContext context,
    required Widget child,
    required double s,
  }) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset + (12 * s)),
        child: child,
      ),
    );
  }


  // ============== DELETE CONFIRMATION ==============
  void _showDeleteConfirmation(
    BuildContext context,
    SubjectModel subject,
    AppPalette palette,
    double s,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: palette.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: palette.error),
              SizedBox(width: 8 * s),
              Expanded(
                child: Text(
                  "Delete Subject?",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14 * s,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "This subject will be removed from:\n\n"
            "• CGPA calculation\n"
            "• Internal marks page\n\n"
            "This action cannot be undone.",
            style: TextStyle(
              fontSize: 13 * s,
              color: palette.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: palette.primary, fontSize: 12 * s),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();

                await calcController.removeSubjectAndCleanup(subject);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${subject.name} removed from CGPA & Internal Marks",
                      ),
                    ),
                  );
                }
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12 * s,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============== SUBJECT PICKER (TEMPLATES) ==============

  void _showSubjectPickerBottomSheet(BuildContext context, int semester) {
    final filteredSubjects = <SubjectModel>[].obs;

    final allTemplates = calcController.templates;
    allTemplates.sort((a, b) => a.code.compareTo(b.code));
    filteredSubjects.assignAll(allTemplates);

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return bottomSheetSafeWrapper(
          context: ctx,
          s: s,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (_, scrollController) {
              return Padding(
                padding: EdgeInsets.fromLTRB(20 * s, 16 * s, 20 * s, 20 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Text(
                          "Choose Subject",
                          style: TextStyle(
                            fontSize: 16 * s,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * s),

                    // Search box
                    TextField(
                      onChanged: (val) {
                        final query = val.toLowerCase();
                        if (query.isEmpty) {
                          filteredSubjects.assignAll(allTemplates);
                        } else {
                          final results = allTemplates.where((s) {
                            final code = s.code.toLowerCase();
                            final name = s.name.toLowerCase();
                            return code.contains(query) || name.contains(query);
                          }).toList();
                          filteredSubjects.assignAll(results);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Search by code or name",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: palette.accent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 12 * s),

                    // List of subjects
                    Expanded(
                      child: Obx(() {
                        if (filteredSubjects.isEmpty) {
                          return Center(
                            child: Text(
                              "No subjects found.\nTap 'Add new subject manually' instead.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13 * s,
                                color: palette.black,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: filteredSubjects.length,
                          itemBuilder: (_, index) {
                            final subject = filteredSubjects[index];
                            final alreadyAdded = calcController.subjectExists(
                              code: subject.code,
                              semester: semester,
                            );

                            final displayCode =
                                subject.code.isEmpty ? "No Code" : subject.code;

                            return Card(
                              color: palette.accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                enabled: !alreadyAdded,
                                title: Text(
                                  "$displayCode - ${subject.name}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13 * s,
                                    color: alreadyAdded
                                        ? palette.black.withAlpha(120)
                                        : palette.black,
                                  ),
                                ),
                                subtitle: Text(
                                  alreadyAdded
                                      ? "Already added to this semester"
                                      : "${subject.credits.toStringAsFixed(1)} credits",
                                  style: TextStyle(fontSize: 12 * s),
                                ),
                                trailing: alreadyAdded
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : null,
                                onTap: alreadyAdded
                                    ? null
                                    : () async {
                                        await calcController
                                            .addSubjectFromTemplate(
                                          subject,
                                          semester,
                                        );
                                        await calcController.recalculateAll();
                                        if (context.mounted) {
                                          Navigator.of(ctx).pop();
                                        }
                                      },
                              ),
                            );
                          },
                        );
                      }),
                    ),

                    SizedBox(height: 8 * s),

                    // Add new button at bottom
                    Align(
                      alignment: Alignment.center,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _showAddSubjectDialog(context, semester);
                        },
                        icon: Icon(
                          Icons.add,
                          size: 18 * s,
                          color: palette.primary,
                        ),
                        label: Text(
                          "Can't find your subject? Add manually",
                          style: TextStyle(
                            color: palette.primary,
                            fontSize: 12 * s,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        );
      },
    );
  }

  // ============== DEPT-BASED SUBJECT PICKER ==============

  void _showDeptBasedSubjectPicker(BuildContext context, int semester) {
    final palette = themeController.palette;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    late double siz;
    if (screenWidth < 600) {
      siz = screenWidth / 460;
    } else if (screenWidth >= 600 && screenWidth < 1200) {
      siz = screenWidth / 600;
    } else {
      siz = screenWidth / 800;
    }

    final regs = ['2021', '2025'];
    final depts = [
      {'code': 'CB', 'label': 'CSBS - Computer Science and Business Systems'},
      {'code': 'AD', 'label': 'AIDS - Artificial Intelligence And Data Science'},
      {'code': 'CE', 'label': 'Civil'},
      {'code': 'CS', 'label': 'CSE - Computer Science and Engineering'},
      {'code': 'AM', 'label': 'CSE (AIML) - Computer Science and Engineering (AIML)'},
      {'code': 'EC', 'label': 'ECE - Electronics and Communication Engineering'},
      {'code': 'EE', 'label': 'EEE - Electrical and Electronics Engineering'},
      {'code': 'IT', 'label': 'IT - Information Technology'},
      {'code': 'ME', 'label': 'Mechanical'},
    ];

    final UserPrefController prefCtrl = Get.find<UserPrefController>();
    final selectedCodes = <String>{}.obs;
    final filteredSubjects = <SubjectModel>[].obs;

    void updateFiltered() {
      final reg = prefCtrl.selectedReg.value;
      final dept = prefCtrl.selectedDept.value;


      if (reg == null || dept == null) {
        filteredSubjects.clear();
        return;
      }

      final result = calcController.templates.where((s) {
        return calcController.subjectMatchesMeta(
          s,
          regulation: reg,
          department: dept,
          semester: semester,
        );
      }).toList()
        ..sort((a, b) => a.code.compareTo(b.code));

      filteredSubjects.assignAll(result);
    }

    Widget section(String title, List<SubjectModel> list) {
      if (list.isEmpty) return const SizedBox();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(6 * siz, 12 * siz, 6 * siz, 6 * siz),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14 * siz,
                fontWeight: FontWeight.bold,
                color: palette.primary,
              ),
            ),
          ),
          ...list.map((s) {
            final alreadyAdded = calcController.subjectExists(
              code: s.code,
              semester: semester,
            );

            return Card(
              color: palette.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(() {
                return CheckboxListTile(
                  value: selectedCodes.contains(s.code),
                  onChanged: alreadyAdded
                      ? null
                      : (val) {
                          if (val == true) {
                            selectedCodes.add(s.code);
                          } else {
                            selectedCodes.remove(s.code);
                          }
                        },
                  title: Text(
                    "${s.code} - ${s.name}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13 * siz,
                      color: alreadyAdded
                          ? palette.black.withAlpha(120)
                          : palette.black,
                    ),
                  ),
                  subtitle: Text(
                    alreadyAdded
                        ? "Already added"
                        : "${s.credits.toStringAsFixed(1)} credits",
                    style: TextStyle(fontSize: 12 * siz),
                  ),
                );
              }),
            );
          }),
        ],
      );
    }
    updateFiltered();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return bottomSheetSafeWrapper(
          context: ctx,
          s: siz,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            minChildSize: 0.6,
            maxChildSize: 0.95,
            builder: (_, scrollController) {
              return Padding(
                padding: EdgeInsets.fromLTRB(20 * siz, 16 * siz, 20 * siz, 20 * siz),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      children: [
                        Text(
                          "Choose by Department",
                          style: TextStyle(
                            fontSize: 16 * siz,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    SizedBox(height: 12 * siz),

                    // REGULATION
                    Obx(() {
                      return DropdownButtonFormField<String>(
                        value: prefCtrl.selectedReg.value,
                        style: TextStyle(fontSize: 14*siz, color: palette.black),
                        decoration: InputDecoration(
                          label: Text("Regulation", style: TextStyle(fontSize: 14*siz)),
                          filled: true,
                          fillColor: palette.accent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: regs
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text("Reg $r"),
                                ))
                            .toList(),
                        onChanged: (val) async {
                          await prefCtrl.setReg(val); // 💾 save
                          selectedCodes.clear();
                          updateFiltered();
                        },
                      );
                    }),

                    SizedBox(height: 10 * siz),

                    // DEPARTMENT
                    Obx(() {
                      return DropdownButtonFormField<String>(
                        value: prefCtrl.selectedDept.value,
                        style: TextStyle(fontSize: 14*siz, color: palette.black),
                        decoration: InputDecoration(
                          label: Text("Department", style: TextStyle(fontSize: 12*siz)),
                          filled: true,
                          fillColor: palette.accent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: depts
                            .map((d) => DropdownMenuItem(
                              value: d['code'],
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                                ),
                                child: Text(
                                  d['label']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: TextStyle(fontSize: 13 * siz),
                                ),
                              )
                            ))
                            .toList(),
                        onChanged: (val) async {
                          await prefCtrl.setDept(val); // 💾 save
                          selectedCodes.clear();
                          updateFiltered();
                        },
                      );
                    }),

                    SizedBox(height: 12 * siz),

                    // SUBJECT LIST
                    Expanded(
                      child: Obx(() {
                        if (prefCtrl.selectedReg.value == null ||
                            prefCtrl.selectedDept.value == null) {
                          return Center(
                            child: Text(
                              "Select regulation and department\nfor Semester $semester",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13 * siz,
                                color: palette.black,
                              ),
                            ),
                          );
                        }

                        if (filteredSubjects.isEmpty) {
                          return Center(
                            child: Text(
                              "No subjects mapped for this combination.",
                              style: TextStyle(
                                fontSize: 13 * siz,
                                color: palette.black,
                              ),
                            ),
                          );
                        }

                        final grouped =
                            calcController.groupByCategory(filteredSubjects);

                        return ListView(
                          controller: scrollController,
                          children: [
                            section("Subjects", grouped['core'] ?? []),
                            section("Professional Electives", grouped['pe'] ?? []),
                            section("Open Electives", grouped['oe'] ?? []),
                          ],
                        );
                      }),
                    ),

                    SizedBox(height: 8 * siz),

                    // ADD BUTTON
                    Obx(() {
                      final enabled = selectedCodes.isNotEmpty;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: enabled
                                ? palette.primary
                                : palette.black.withAlpha(150),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14 * siz),
                          ),
                          onPressed: enabled
                              ? () async {
                                  final toAdd = filteredSubjects
                                      .where((s) =>
                                          selectedCodes.contains(s.code))
                                      .toList();

                                  Navigator.of(ctx).pop();

                                  for (final s in toAdd) {
                                    await calcController.addSubjectFromTemplate(
                                      s,
                                      semester,
                                    );
                                  }

                                  await calcController.recalculateAll();

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Added ${toAdd.length} subject(s) to Sem $semester",
                                        ),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          child: Text(
                            enabled
                                ? "Add selected subjects"
                                : "Select subjects to add",
                            style: TextStyle(
                              color: palette.accent,
                              fontSize: 13 * siz,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          )
        );
      },
    );
  }

  // ============== ADD SUBJECT OPTIONS ==============

  void _showAddSubjectOptions(BuildContext context, int semester) {
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return bottomSheetSafeWrapper(
          context: ctx,
          s: s,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20 * s, 16 * s, 20 * s, 20 * s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Add subject to semester",
                      style: TextStyle(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 12 * s),
                ListTile(
                  leading: const Icon(Icons.account_tree_outlined),
                  title: Text(
                    "Choose using department",
                    style: TextStyle(fontSize: 16 * s),
                  ),
                  subtitle: Text(
                    "Regulation • Department • Multi-select",
                    style: TextStyle(fontSize: 12 * s),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showDeptBasedSubjectPicker(context, semester);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt_outlined),
                  title: Text(
                    "Choose from subject list",
                    style: TextStyle(fontSize: 16 * s),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showSubjectPickerBottomSheet(context, semester);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: Text(
                    "Add new subject manually",
                    style: TextStyle(fontSize: 16 * s),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showAddSubjectDialog(context, semester);
                  },
                ),
              ],
            ),
          )
        );
      },
    );
  }

  // ============== ADD SUBJECT DIALOG ==============

  void _showAddSubjectDialog(BuildContext context, int semester) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final creditsCtrl = TextEditingController();
    final palette = themeController.palette;
    final isDuplicate = false.obs;

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

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: palette.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20 * s, 18 * s, 20 * s, 10 * s),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Add Subject",
                        style: TextStyle(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10 * s),

                  // Subject code
                  TextField(
                    controller: codeCtrl,
                    onChanged: (val) {
                      isDuplicate.value = calcController.subjectExists(
                        code: val,
                        semester: semester,
                      );
                    },
                    style: TextStyle(fontSize: 13 * s),
                    decoration: InputDecoration(
                      labelText: "Subject Code",
                      labelStyle: TextStyle(fontSize: 12 * s),
                      errorText: isDuplicate.value ? "Subject already exists" : null,
                      prefixIcon: const Icon(Icons.qr_code_2),
                      filled: true,
                      fillColor: palette.accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 10 * s),

                  // Subject name
                  TextField(
                    controller: nameCtrl,
                    style: TextStyle(fontSize: 13 * s),
                    decoration: InputDecoration(
                      labelText: "Subject Name",
                      labelStyle: TextStyle(fontSize: 12 * s),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      prefixIcon: const Icon(Icons.menu_book_outlined),
                      filled: true,
                      fillColor: palette.accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 10 * s),

                  // Credits
                  TextField(
                    controller: creditsCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 13 * s),
                    decoration: InputDecoration(
                      labelText: "Credits",
                      labelStyle: TextStyle(fontSize: 12 * s),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      prefixIcon: const Icon(Icons.numbers),
                      filled: true,
                      fillColor: palette.accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 16 * s),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: palette.primary,
                            fontSize: 12 * s,
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      Obx(() {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDuplicate.value
                                ? palette.black.withAlpha(150)
                                : palette.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isDuplicate.value
                              ? null
                              : () async {
                                  final name = nameCtrl.text.trim();
                                  final code = codeCtrl.text.trim();
                                  final creditsStr = creditsCtrl.text.trim();
                                  final grade = "O";

                                  if (name.isEmpty ||
                                      code.isEmpty ||
                                      creditsStr.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Code, name and credits are required",
                                          style: TextStyle(fontSize: 12 * s),
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final credits =
                                      double.tryParse(creditsStr) ?? 0;
                                  if (credits <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Credits must be > 0",
                                          style: TextStyle(fontSize: 12 * s),
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  await calcController.addSubject(
                                    name: name,
                                    code: code,
                                    credits: credits,
                                    semester: semester,
                                    grade:
                                        grade.isEmpty ? "" : grade,
                                  );

                                  if (context.mounted) {
                                    Navigator.of(ctx).pop();
                                  }
                                },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10 * s,
                              vertical: 6 * s,
                            ),
                            child: Text(
                              "Save",
                              style: TextStyle(
                                color: palette.accent,
                                fontSize: 12 * s,
                              ),
                            ),
                          ),
                        );
                      })
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
