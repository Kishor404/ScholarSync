import 'dart:async'; // Added for Debouncer
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';


// Assuming these exist based on your upload
import '../../controllers/cgpa_calc_controller.dart';
import '../../controllers/internal_calc_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/subject_model.dart';

class CalculateInternalScreen extends StatefulWidget {
  const CalculateInternalScreen({super.key});

  @override
  State<CalculateInternalScreen> createState() =>
      _CalculateInternalScreenState();
}

class _CalculateInternalScreenState extends State<CalculateInternalScreen> {
  // Controllers
  final InternalCalcController internalCtrl = Get.find<InternalCalcController>();
  final CgpaCalcController cgpaCtrl = Get.find<CgpaCalcController>();
  final CgpaCalcController calcController = Get.find<CgpaCalcController>();
  final ThemeController themeController = Get.find<ThemeController>();

  // Local State
  int selectedSemester = 1;
  int selectedInternalNo = 1;
  
  // Optimization: Loading state to prevent lag on screen open
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // OPTIMIZATION: Delay the heavy rendering slightly to allow the 
    // navigation transition to finish smoothly.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        backgroundColor: palette.bg,
        iconTheme: IconThemeData(color: palette.black),
        title: Text(
          "Internal Exam Calculation",
          style: TextStyle(
            fontSize: 22,
            color: palette.minimal,
            fontFamily: 'Righteous',
          ),
        ),
      ),
      // OPTIMIZATION: Show loader initially to fix "Lag on Open"
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: palette.primary))
          : Column(
              children: [
                // 1. Semester Summary Card (Scoped Obx inside)
                _buildSemesterSummaryCard(palette),

                // 2. Top Summary Card (Scoped Obx inside)
                _buildTopSummaryCard(palette),

                // 3. Semester Chips (No Obx needed for the list generation itself)
                _buildSemesterChips(palette),

                const SizedBox(height: 6),

                // 4. Internal Chips (Wrapped in Obx locally)
                _buildInternalChips(palette),

                const SizedBox(height: 12),

                // 5. Subject List (Heavy lifting isolated here)
                Expanded(
                  child: _SubjectListSection(
                    semester: selectedSemester,
                    internalNo: selectedInternalNo,
                    palette: palette,
                  ),
                ),
              ],
            ),
    );
  }

  // ---------------- WIDGET EXTRACTION FOR PERFORMANCE ----------------

  Widget _buildSemesterSummaryCard(dynamic palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: palette.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        // OPTIMIZATION: Only this widget rebuilds when calculation changes
        child: Obx(() {
          final semesterSummary = internalCtrl.getSemesterSummary(selectedSemester);
          final avgGpa = semesterSummary['avgGpa']!;
          final avgObtained = semesterSummary['avgObtained']!;
          final avgMax = semesterSummary['avgMax']!;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ---- Average GPA ----
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    avgGpa == 0 ? "--" : avgGpa.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      color: palette.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Average GPA (Sem $selectedSemester)",
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.accent,
                    ),
                  ),
                ],
              ),
              // ---- Average Marks ----
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        avgObtained == 0 ? "--" : avgObtained.toStringAsFixed(0),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: palette.accent,
                        ),
                      ),
                      Text(
                        avgMax == 0 ? "" : " / ${avgMax.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: palette.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Avg Total Marks",
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.accent,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTopSummaryCard(dynamic palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: palette.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        // OPTIMIZATION: Scoped Obx
        child: Obx(() {
          final totalMarks = internalCtrl.getTotalMarks(
            semester: selectedSemester,
            internalNo: selectedInternalNo,
          );
          final obtained = totalMarks['obtained']!;
          final max = totalMarks['max']!;

          final gpa = internalCtrl.gpas.firstWhereOrNull(
            (g) =>
                g.semester == selectedSemester &&
                g.internalNo == selectedInternalNo,
          )?.gpa;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gpa == null ? "--" : gpa.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                      color: palette.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "GPA of Sem $selectedSemester - IAT $selectedInternalNo",
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.black,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        obtained.toStringAsFixed(0),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: palette.primary,
                        ),
                      ),
                      Text(
                        " / ${max.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: palette.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total Marks",
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.black,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSemesterChips(dynamic palette) {
    // No Obx here because list length 8 is constant
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(8, (i) {
            final sem = i + 1;
            final isSemSelected = sem == selectedSemester;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text("Sem $sem"),
                selected: isSemSelected,
                showCheckmark: false,
                selectedColor: palette.primary,
                backgroundColor: palette.black.withAlpha(20),
                labelStyle: TextStyle(
                  color: isSemSelected ? palette.accent : palette.black,
                ),
                onSelected: (_) {
                  setState(() {
                    selectedSemester = sem;
                    selectedInternalNo = 1;
                  });
                  internalCtrl.ensureDefaultInternals(sem);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInternalChips(dynamic palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              // OPTIMIZATION: Only listen to changes in internals list
              child: Obx(() {
                final internals = internalCtrl.internals
                    .where((i) => i.semester == selectedSemester)
                    .toList();
                    
                return Row(
                  children: internals.map((i) {
                    final isSelected = i.internalNo == selectedInternalNo;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ChoiceChip(
                            label: Text(
                              i.name,
                              style: TextStyle(
                                color: isSelected ? palette.primary : palette.black,
                              ),
                            ),
                            selected: isSelected,
                            showCheckmark: false,
                            selectedColor: palette.secondary,
                            backgroundColor: palette.black.withAlpha(20),
                            onSelected: (_) {
                              setState(() {
                                selectedInternalNo = i.internalNo;
                              });
                            },
                          ),

                          // ❌ DELETE ICON OUTSIDE CHIP
                          if (i.internalNo > 2) ...[
                            const SizedBox(width: 4),
                            
                              GestureDetector(
                                onTap: () => _confirmDeleteInternal(
                                  context,
                                  i.semester,
                                  i.internalNo,
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: palette.error.withAlpha(30),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: palette.error,
                                  ),
                                )
                            )
                            
                          ],
                        ],
                      ),
                    );



                  }).toList(),
                );
              }),
            ),
          ),
          Row(
            children: [
              IconButton(
                tooltip: "Add Internal",
                onPressed: () => _showAddInternalDialog(context),
                icon: const Icon(Icons.playlist_add),
              ),
              IconButton(
                tooltip: "Add Subject",
                onPressed: () => _showAddSubjectOptions(context, selectedSemester),
                icon: Icon(Icons.add, color: palette.accent),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(palette.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteInternal(
    BuildContext context,
    int semester,
    int internalNo,
  ) {
    final palette = themeController.palette;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: palette.error),
            const SizedBox(width: 8),
            const Text(
              "Delete Internal?",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          "This will delete:\n\n"
          "• Internal exam\n"
          "• All its marks\n"
          "• Its GPA\n\n"
          "This action cannot be undone.",
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.error,
            ),
            onPressed: () async {
              Navigator.pop(context);

              await internalCtrl.deleteInternal(
                semester: semester,
                internalNo: internalNo,
              );

              // 🔁 Reset selection safely
              setState(() {
                selectedInternalNo = 1;
              });
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }


  // ------------------- POPUPS & DIALOGS -------------------

  // OPTIMIZED SUBJECT PICKER WITH DEBOUNCE
  void _showSubjectPickerBottomSheet(BuildContext context, int semester) {
    final searchText = ''.obs;
    final palette = themeController.palette;
    
    // Timer for debouncing
    Timer? _debounce;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Choose Subject",
                        style: TextStyle(
                          fontSize: 16,
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
                  const SizedBox(height: 8),

                  // Search box
                  TextField(
                    // OPTIMIZATION: Debounce search input to prevent filtering huge lists on every keystroke
                    onChanged: (val) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 400), () {
                        searchText.value = val;
                      });
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
                  const SizedBox(height: 12),

                  // List of subjects
                  Expanded(
                    child: Obx(() {
                      final templates = calcController.templates;
                      final query = searchText.value.toLowerCase();

                      // OPTIMIZATION: If list is empty/loading, return early
                      if (templates.isEmpty) return const SizedBox();

                      final filtered = templates.where((s) {
                        final code = s.code.toLowerCase();
                        final name = s.name.toLowerCase();
                        if (query.isEmpty) return true;
                        return code.contains(query) || name.contains(query);
                      }).toList();
                      
                      // OPTIMIZATION: Move sort logic. Ideally, templates should be pre-sorted in controller.
                      // If list is > 1000, sorting here is still heavy but debouncing helps.
                      filtered.sort((a, b) => a.code.compareTo(b.code));

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text(
                            "No subjects found.\nTap 'Add new subject manually' instead.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        // OPTIMIZATION: Use itemExtent if height is fixed for better scrolling performance
                        // itemExtent: 70, 
                        itemBuilder: (_, index) {
                          final subject = filtered[index];
                          final displayCode = subject.code.isEmpty ? "No Code" : subject.code;
                          final alreadyAdded = calcController.subjectExists(
                            code: subject.code,
                            semester: semester,
                          );

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
                                  color: alreadyAdded
                                      ? palette.black.withAlpha(120)
                                      : palette.black,
                                ),
                              ),
                              subtitle: Text(
                                alreadyAdded
                                    ? "Already added to this semester"
                                    : "${subject.credits.toStringAsFixed(1)} credits",
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: alreadyAdded
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : null,
                              onTap: alreadyAdded
                                  ? null
                                  : () async {
                                      await calcController.addSubjectFromTemplate(subject, semester);
                                      await calcController.recalculateAll();
                                      if (context.mounted) Navigator.of(ctx).pop();
                                    },
                            )

                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _showAddSubjectDialog(context, semester);
                      },
                      icon: Icon(Icons.add, size: 18, color: palette.primary),
                      label: Text(
                        "Can't find your subject? Add manually",
                        style: TextStyle(color: palette.primary),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeptBasedSubjectPicker(BuildContext context, int semester) {
    final palette = themeController.palette;

    // UI values
    final regs = ['2021', '2023'];
    final depts = [
      {'code': 'CB', 'label': 'CSBS'},
      {'code': 'CS', 'label': 'CSE'},
      {'code': 'AM', 'label': 'CSE (AIML)'},
      {'code': 'IT', 'label': 'IT'},
      {'code': 'AD', 'label': 'AIDS'},
      {'code': 'CE', 'label': 'Civil'},
      {'code': 'ME', 'label': 'Mech'},
      {'code': 'EC', 'label': 'ECE'},
      {'code': 'EE', 'label': 'EEE'},
    ];

    final selectedReg = RxnString();
    final selectedDept = RxnString();

    // Selected subject codes
    final selectedCodes = <String>{}.obs;

    // Filtered templates
    final filteredSubjects = <SubjectModel>[].obs;

    /// 🔹 Heavy filter logic (runs ONLY on dropdown change)
    void updateFiltered() {
      final reg = selectedReg.value;
      final dept = selectedDept.value;

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

    /// 🔹 Section builder
    Widget section(
      String title,
      List<SubjectModel> list,
    ) {
      if (list.isEmpty) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
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
                      color: alreadyAdded
                          ? palette.black.withAlpha(120)
                          : palette.black,
                    ),
                  ),
                  subtitle: Text(
                    alreadyAdded
                        ? "Already added"
                        : "${s.credits.toStringAsFixed(1)} credits",
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }),
            );
          }),
        ],
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    children: [
                      const Text(
                        "Choose by Department",
                        style: TextStyle(
                          fontSize: 16,
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
                  const SizedBox(height: 12),

                  // REGULATION
                  Obx(() {
                    return DropdownButtonFormField<String>(
                      value: selectedReg.value,
                      decoration: InputDecoration(
                        labelText: "Regulation",
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
                      onChanged: (val) {
                        selectedReg.value = val;
                        selectedCodes.clear();
                        updateFiltered();
                      },
                    );
                  }),
                  const SizedBox(height: 10),

                  // DEPARTMENT
                  Obx(() {
                    return DropdownButtonFormField<String>(
                      value: selectedDept.value,
                      decoration: InputDecoration(
                        labelText: "Department",
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
                                child: Text(d['label']!),
                              ))
                          .toList(),
                      onChanged: (val) {
                        selectedDept.value = val;
                        selectedCodes.clear();
                        updateFiltered();
                      },
                    );
                  }),
                  const SizedBox(height: 12),

                  // SUBJECT LIST
                  Expanded(
                    child: Obx(() {
                      if (selectedReg.value == null ||
                          selectedDept.value == null) {
                        return Center(
                          child: Text(
                            "Select regulation and department\nfor Semester $semester",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
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
                              fontSize: 13,
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

                  const SizedBox(height: 8),

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
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                          style: TextStyle(color: palette.accent),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper dialogs for "Add Subject Options" and "Add Subject Manually" 
  // and "Add Internal" remain largely the same, just keeping them concise.
  void _showAddSubjectOptions(BuildContext context, int semester) {
    final palette = themeController.palette;

    showModalBottomSheet(
      context: context,
      backgroundColor: palette.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Add subject to semester", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
              const SizedBox(height: 12),

              ListTile(
                leading: const Icon(Icons.account_tree_outlined),
                title: const Text("Choose using department"),
                subtitle: const Text("Regulation • Department • Multi-select", style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showDeptBasedSubjectPicker(context, semester);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.list_alt_outlined),
                title: const Text("Choose from subject list"),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showSubjectPickerBottomSheet(context, semester);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text("Add new subject manually"),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showAddSubjectDialog(context, semester);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSubjectDialog(BuildContext context, int semester) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final creditsCtrl = TextEditingController();
    final palette = themeController.palette;
    final isDuplicate = false.obs;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: palette.bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Add Subject", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: codeCtrl,
                    onChanged: (val) {
                      isDuplicate.value = calcController.subjectExists(
                        code: val,
                        semester: semester,
                      );
                    },
                    decoration: InputDecoration(
                      labelText: "Subject Code",
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

                  const SizedBox(height: 10),
                  _buildDialogTextField(nameCtrl, "Subject Name", Icons.menu_book_outlined, palette),
                  const SizedBox(height: 10),
                  _buildDialogTextField(creditsCtrl, "Credits", Icons.numbers, palette, isNumber: true),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text("Cancel", style: TextStyle(color: palette.primary)),
                      ),
                      const SizedBox(width: 8),
                      Obx(() {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDuplicate.value
                                ? palette.black.withAlpha(150)
                                : palette.primary,
                          ),
                          onPressed: isDuplicate.value
                              ? null
                              : () async {
                                  final name = nameCtrl.text.trim();
                                  final code = codeCtrl.text.trim();
                                  final creditsStr = creditsCtrl.text.trim();

                                  if (name.isEmpty || code.isEmpty || creditsStr.isEmpty) return;

                                  final credits = double.tryParse(creditsStr) ?? 0;
                                  if (credits <= 0) return;

                                  await calcController.addSubject(
                                    name: name,
                                    code: code,
                                    credits: credits,
                                    semester: semester,
                                    grade: "O",
                                  );

                                  if (context.mounted) Navigator.of(ctx).pop();
                                },
                          child: Text("Save", style: TextStyle(color: palette.accent)),
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

  Widget _buildDialogTextField(TextEditingController ctrl, String label, IconData icon, dynamic palette, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: palette.accent,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  void _showAddInternalDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Internal"),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: "Internal 1")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await internalCtrl.addInternal(selectedSemester, ctrl.text.trim().isEmpty ? "Internal" : ctrl.text.trim());
              if(context.mounted) Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

// ------------------- ISOLATED LIST COMPONENT -------------------

/// OPTIMIZATION: Separated the list into its own widget.
/// This ensures the expensive sorting/filtering happens only when necessary,
/// and is scoped within this part of the widget tree.
class _SubjectListSection extends StatelessWidget {
  final int semester;
  final int internalNo;
  final dynamic palette;

  const _SubjectListSection({
    required this.semester,
    required this.internalNo,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final CgpaCalcController cgpaCtrl = Get.find<CgpaCalcController>();

    return Obx(() {
      // OPTIMIZATION: filtering happens here, inside a scoped Obx
      final subjects = cgpaCtrl.subjects
          .where((s) => s.semester == semester)
          .toList();
      
      // Sort in place to avoid creating another list copy if possible, 
      // or just chain it.
      subjects.sort((a, b) => a.code.compareTo(b.code));

      if (subjects.isEmpty) {
        return Center(
          child: Text(
            "No subjects added for this semester",
            style: TextStyle(fontSize: 13, color: palette.black),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          // OPTIMIZATION: Use itemExtent or prototypeItem if tiles are fixed height 
          // to drastically improve scroll performance for large lists.
          // prototypeItem: _InternalSubjectTile(subject: subjects[0], semester: semester, internalNo: internalNo),
          itemCount: subjects.length,
          itemBuilder: (_, index) {
            return _InternalSubjectTile(
              subject: subjects[index],
              semester: semester,
              internalNo: internalNo,
              key: ValueKey(subjects[index].code), // Add Key for performance
            );
          },
        ),
      );
    });
  }
}
class _InternalSubjectTile extends StatefulWidget {
  final SubjectModel subject;
  final int semester;
  final int internalNo;

  const _InternalSubjectTile({
    super.key,
    required this.subject,
    required this.semester,
    required this.internalNo,
  });

  @override
  State<_InternalSubjectTile> createState() => _InternalSubjectTileState();
}

class _InternalSubjectTileState extends State<_InternalSubjectTile> {
  final InternalCalcController internalCtrl = Get.find<InternalCalcController>();
  final CgpaCalcController cgpaCtrl = Get.find<CgpaCalcController>();
  final ThemeController themeController = Get.find<ThemeController>();

  late TextEditingController markCtrl;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    final existing = internalCtrl.markList.firstWhereOrNull(
      (m) =>
          m.semester == widget.semester &&
          m.internalNo == widget.internalNo &&
          m.subjectCode == widget.subject.code,
    );

    markCtrl = TextEditingController(
      text: existing?.marks.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    markCtrl.dispose();
    super.dispose();
  }

  // ---------------- MARK UPDATE LOGIC ----------------

  void _onMarkChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      double obtained = double.tryParse(val) ?? 0;

      // 🔒 SAFETY CLAMP
      if (obtained > 100) obtained = 100;
      if (obtained < 0) obtained = 0;

      // 1️⃣ Save / update mark
      await internalCtrl.addOrUpdateMark(
        semester: widget.semester,
        internalNo: widget.internalNo,
        subject: widget.subject,
        obtainedMarks: obtained,
        maxMarks: 100,
      );

      // 2️⃣ Recalculate INTERNAL GPA
      await internalCtrl.calculateInternalGpa(
        widget.semester,
        widget.internalNo,
      );

      // 3️⃣ Recalculate CGPA
      await cgpaCtrl.recalculateAll();
    });
  }

  // ---------------- DELETE CONFIRM ----------------

  void _confirmDelete(BuildContext context) {
    final palette = themeController.palette;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: palette.error),
            const SizedBox(width: 8),
            const Text("Delete Subject?", style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          "This subject will be removed from:\n\n"
          "• CGPA calculation\n"
          "• Internal marks\n\n"
          "This action cannot be undone.",
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: palette.error),
            onPressed: () async {
              Navigator.pop(context);
              await cgpaCtrl.removeSubjectAndCleanup(widget.subject);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.accent,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            offset: const Offset(0, 2),
            color: palette.black.withAlpha(20),
          ),
        ],
      ),
      child: Row(
        children: [
          // ---- SUBJECT INFO ----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subject.code.isNotEmpty
                      ? "${widget.subject.code} - ${widget.subject.name}"
                      : widget.subject.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "${widget.subject.credits.toStringAsFixed(1)} credits",
                  style: TextStyle(fontSize: 11, color: palette.black.withAlpha(150)),
                ),
              ],
            ),
          ),

          // ---- MARK INPUT ----
          SizedBox(
            width: 80,
            child: TextField(
              controller: markCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;
                  final v = int.tryParse(newValue.text) ?? 0;
                  return v <= 100 ? newValue : oldValue;
                }),
              ],
              decoration: InputDecoration(
                hintText: "Marks",
                filled: true,
                fillColor: palette.bg.withAlpha(150),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onMarkChanged,
            ),
          ),

          const SizedBox(width: 6),

          // ---- DELETE ----
          IconButton(
            tooltip: "Delete subject",
            icon: Icon(Icons.delete_outline, color: palette.error),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }
}
