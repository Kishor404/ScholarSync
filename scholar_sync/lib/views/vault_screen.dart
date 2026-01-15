import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;

import '../controllers/document_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/document_model.dart';
//import '../controllers/ad_controller.dart';

class VaultScreen extends StatelessWidget {
  VaultScreen({super.key});

  final DocumentController controller = Get.put(DocumentController());
  final ThemeController themeController = Get.find<ThemeController>();
  //final AdController adController = Get.find<AdController>();

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

    // Adaptive grid columns based on screen size
    late int gridColumns;
    if (isMobile) {
      gridColumns = 2; // 2 columns for mobile
    } else if (isTablet) {
      gridColumns = 3; // 3 columns for tablet
    } else {
      gridColumns = 4; // 4 columns for desktop
    }

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20 * s, 20 * s, 20 * s, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Header Section ----
              _buildHeader(palette, s, isMobile),

              SizedBox(height: 18 * s),

              // ---- Category Bar ----
              _CategoryBar(
                controller: controller,
                primary: palette.primary,
              ),

              SizedBox(height: 16 * s),

              // ---- Document Grid ----
              _buildDocumentGrid(
                context,
                palette,
                s,
                isMobile,
                gridColumns,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        height: 56 * s,
        width: 56 * s,
        child: FloatingActionButton(
          heroTag: 'vault_screen_fab',
          backgroundColor: palette.primary,
          onPressed: () => _showAddDocumentDialog(context),
          child: Icon(Icons.add, color: palette.accent, size: 28 * s),
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
          "Document Vault",
          style: TextStyle(
            fontSize: isMobile ? 22 * s : 26 * s,
            color: palette.minimal,
            fontFamily: 'Righteous',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4 * s),
        Text(
          "Store and manage your documents efficently",
          style: TextStyle(
            fontSize: isMobile ? 12 * s : 14 * s,
            color: palette.black.withAlpha(150),
          ),
        ),
      ],
    );
  }

  // ============== DOCUMENT GRID ==============
  Widget _buildDocumentGrid(
    BuildContext context,
    dynamic palette,
    double s,
    bool isMobile,
    int gridColumns,
  ) {
    return Expanded(
      child: Obx(() {
        final docs = controller.filteredDocuments;

        if (docs.isEmpty) {
          return Center(
            child: Text(
              'No documents yet.\nTap + to add one.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 13 * s : 14 * s,
                color: palette.black.withAlpha(150),
              ),
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.only(bottom: 80 * s),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridColumns,
            crossAxisSpacing: 12 * s,
            mainAxisSpacing: 12 * s,
            childAspectRatio: 0.72,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            return _DocumentCard(
              document: doc,
              cardColor: palette.secondary,
              primary: palette.primary,
              onOpen: () => _openDocument(doc),
              onEdit: () => _showEditDocumentDialog(context, doc),
              onDownload: () => _downloadDocument(context, doc),
              onToggleFav: () => controller.toggleFavorite(doc),
            );
          },
        );
      }),
    );
  }

  // ============== DOWNLOAD DOCUMENT ==============
Future<void> _downloadDocument(
  BuildContext context,
  DocumentModel doc,
) async {
  try {
    if (doc.path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No document to download")),
      );
      return;
    }

    final file = File(doc.path);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File not found")),
      );
      return;
    }

    final bytes = await file.readAsBytes();
    var fileName = p.basename(doc.path);

    // ✅ FIX: Get unique filename BEFORE saving
    fileName = _getUniqueFileName(fileName);

    // SYSTEM SAVE-AS DIALOG
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Download document',
      fileName: fileName,  // ✅ Now uses Test(1).png instead of Test.png (1)
      bytes: bytes,
    );

    if (savePath == null) return;

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Document downloaded successfully")),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Download failed: $e")),
    );
  }
}

// ============== GET UNIQUE FILENAME ==============
String _getUniqueFileName(String fileName) {
  // Split filename into name and extension
  final lastDotIndex = fileName.lastIndexOf('.');
  final name = lastDotIndex > 0 
    ? fileName.substring(0, lastDotIndex) 
    : fileName;
  final ext = lastDotIndex > 0 
    ? fileName.substring(lastDotIndex) 
    : '';

  // Get Downloads directory
  final saveDir = Directory('/storage/emulated/0/Download');
  
  // File doesn't exist, return as is
  if (!File('${saveDir.path}/$fileName').existsSync()) {
    return fileName;
  }

  // File exists, find unique name: name(1).ext, name(2).ext, etc.
  int counter = 1;
  while (File('${saveDir.path}/$name($counter)$ext').existsSync()) {
    counter++;
  }
  
  return '$name($counter)$ext';
}

  // ============== OPEN DOCUMENT ==============
  Future<void> _openDocument(DocumentModel doc) async {
    await OpenFilex.open(doc.path);
  }

  // ============== ADD DOCUMENT DIALOG ==============
  Future<void> _showAddDocumentDialog(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final selectedCategories = <String>[].obs;
    final isFav = false.obs;

    final pickedPath = RxnString();
    final pickedType = RxnString();

    final palette = themeController.palette;

    await showDialog(
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
                child: Obx(
                  () => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- Header ----
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add Document",
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

                      // ---- Select File ----
                      Text(
                        "Select File",
                        style: TextStyle(
                          fontSize: 13 * s,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6 * s),

                      FilledButton.icon(
                        onPressed: () async {
                          try {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                              withData: false,
                            );

                            if (result == null || result.files.isEmpty) return;

                            final file = result.files.single;

                            if (file.path == null) return;

                            pickedPath.value = file.path!;
                            pickedType.value = p
                                .extension(file.path!)
                                .replaceFirst('.', '')
                                .toLowerCase();

                            if (titleCtrl.text.trim().isEmpty) {
                              titleCtrl.text =
                                  p.basenameWithoutExtension(file.path!);
                            }
                          } catch (e) {
                            debugPrint("FilePicker error: $e");
                          }
                        },
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
                          pickedPath.value == null
                              ? "Choose file"
                              : p.basename(pickedPath.value!),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13 * s),
                        ),
                      ),
                      SizedBox(height: 16 * s),

                      // ---- Title ----
                      TextField(
                        controller: titleCtrl,
                        style: TextStyle(fontSize: 14 * s),
                        decoration: InputDecoration(
                          labelText: "Document Title",
                          labelStyle: TextStyle(fontSize: 13 * s),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          filled: true,
                          fillColor: palette.black.withAlpha(10),
                          prefixIcon: Icon(Icons.title, size: 24 * s),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 16 * s),

                      // ---- Categories ----
                      Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 13 * s,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6 * s),

                      Wrap(
                        spacing: 8 * s,
                        runSpacing: 6 * s,
                        children: controller.categories
                            .where((c) =>
                                c != "All" && c != "Course" && c != "Fav")
                            .map(
                              (c) => ChoiceChip(
                                backgroundColor: palette.black.withAlpha(20),
                                selectedColor: palette.primary,
                                label: Text(
                                  c,
                                  style: TextStyle(
                                    color: selectedCategories.contains(c)
                                        ? palette.accent
                                        : palette.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12 * s,
                                  ),
                                ),
                                showCheckmark: false,
                                selected: selectedCategories.contains(c),
                                onSelected: (val) {
                                  if (val) {
                                    selectedCategories.add(c);
                                  } else {
                                    selectedCategories.remove(c);
                                  }
                                },
                              ),
                            )
                            .toList(),
                      ),

                      TextButton.icon(
                        onPressed: () async {
                          final newCat =
                              await _showAddCategoryPrompt(context, controller);
                          if (newCat != null) selectedCategories.add(newCat);
                        },
                        icon: Icon(Icons.add, color: palette.primary),
                        label: Text(
                          "New",
                          style: TextStyle(
                            fontSize: 13 * s,
                            color: palette.primary,
                          ),
                        ),
                      ),

                      SizedBox(height: 12 * s),

                      // ---- Buttons ----
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 13 * s,
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
                            onPressed: () async {
                              if (pickedPath.value == null ||
                                  pickedType.value == null ||
                                  titleCtrl.text.trim().isEmpty) {return;}

                              final doc = DocumentModel(
                                title: titleCtrl.text.trim(),
                                path: pickedPath.value!,
                                type: pickedType.value!,
                                isFav: isFav.value,
                                categories: selectedCategories.toList(),
                              );

                              await controller.addDocument(doc);
                              if (!ctx.mounted) return;
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
                                  fontSize: 13 * s,
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
          ),
        );
      },
    );
  }

  // ============== CONFIRM DELETE DIALOG ==============
  Future<bool> _confirmDeleteDialog(BuildContext context) async {
    final palette = themeController.palette;

    return await showDialog<bool>(
          context: context,
          builder: (ctx) {
            final screenSize = MediaQuery.of(context).size;
            final w = screenSize.width;
            final s = w / 460;

            // Responsive dialog width
            final dialogWidth = w > 600 ? 500.0 : w * 0.85;

            return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              backgroundColor: palette.bg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: dialogWidth),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20 * s, 18 * s, 20 * s, 12 * s),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- Header ----
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: palette.error),
                              SizedBox(width: 8 * s),
                              Text(
                                "Delete Document?",
                                style: TextStyle(
                                  fontSize: 14 * s,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 10 * s),

                      // ---- Message ----
                      Text(
                        "Are you sure you want to delete this document?",
                        style: TextStyle(
                          fontSize: 13 * s,
                          color: palette.black,
                        ),
                      ),

                      SizedBox(height: 18 * s),

                      // ---- Buttons ----
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: palette.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 13 * s,
                              ),
                            ),
                          ),
                          SizedBox(width: 8 * s),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10 * s,
                                vertical: 6 * s,
                              ),
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                  color: palette.accent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13 * s,
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
            );
          },
        ) ??
        false;
  }

  // ============== EDIT DOCUMENT DIALOG ==============
  Future<void> _showEditDocumentDialog(
    BuildContext context,
    DocumentModel doc,
  ) async {
    final titleCtrl = TextEditingController(text: doc.title);
    final selectedCategories = doc.categories.toList().obs;
    final isFav = doc.isFav.obs;
    final isCourseDoc = doc.categories.contains('Course');
    final palette = themeController.palette;

    await showDialog(
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
                child: Obx(
                  () => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- Header ----
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Edit Document",
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

                      // ---- Title ----
                      TextField(
                        controller: titleCtrl,
                        style: TextStyle(fontSize: 13 * s),
                        decoration: InputDecoration(
                          label: Text(
                            "Document title",
                            style: TextStyle(fontSize: 13 * s),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          filled: true,
                          fillColor: palette.black.withAlpha(10),
                          prefixIcon: Icon(Icons.title, size: 24 * s),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 16 * s),

                      // ---- Categories ----
                      Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 13 * s,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6 * s),

                      Wrap(
                        spacing: 8 * s,
                        runSpacing: 6 * s,
                        children: controller.categories
                            .where(
                              (c) => c != 'All' && c != 'Course' && c != 'Fav',
                            )
                            .map(
                              (c) => ChoiceChip(
                                backgroundColor: palette.black.withAlpha(20),
                                selectedColor: palette.primary,
                                label: Text(
                                  c,
                                  style: TextStyle(
                                    color: selectedCategories.contains(c)
                                        ? palette.accent
                                        : palette.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12 * s,
                                  ),
                                ),
                                showCheckmark: false,
                                selected: selectedCategories.contains(c),
                                onSelected: (val) {
                                  if (val) {
                                    selectedCategories.add(c);
                                  } else {
                                    selectedCategories.remove(c);
                                  }
                                },
                              ),
                            )
                            .toList(),
                      ),

                      TextButton.icon(
                        onPressed: () async {
                          final newCat =
                              await _showAddCategoryPrompt(context, controller);
                          if (newCat != null) {
                            selectedCategories.add(newCat);
                          }
                        },
                        icon: Icon(
                          Icons.add,
                          size: 16 * s,
                          color: palette.primary,
                        ),
                        label: Text(
                          'New',
                          style: TextStyle(
                            fontSize: 13 * s,
                            color: palette.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 12 * s),

                      // ---- Favorite Switch ----
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Mark as favourite',
                          style: TextStyle(fontSize: 14 * s),
                        ),
                        value: isFav.value,
                        activeTrackColor: palette.primary,
                        activeColor: palette.accent,
                        onChanged: (v) => isFav.value = v,
                      ),

                      SizedBox(height: 14 * s),

                      // ---- Buttons ----
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Delete Button
                          FilledButton(
                            onPressed: isCourseDoc
                                ? null
                                : () async {
                                    final confirmed =
                                        await _confirmDeleteDialog(context);
                                    if (confirmed == true) {
                                      await controller.deleteDocument(doc);
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: palette.error,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  palette.black.withAlpha(40),
                              disabledForegroundColor:
                                  palette.black.withAlpha(150),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 12 * s,
                                horizontal: 24 * s,
                              ),
                            ),
                            child: Text(
                              "Delete",
                              style: TextStyle(fontSize: 13 * s),
                            ),
                          ),
                          // Cancel + Save
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 13 * s,
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
                                onPressed: () async {
                                  final newTitle = titleCtrl.text.trim();
                                  if (newTitle.isEmpty) return;

                                  doc.title = newTitle;
                                  doc.isFav = isFav.value;
                                  doc.categories = selectedCategories.toList();

                                  await controller.updateDocument(doc);
                                  if (!ctx.mounted) return;
                                  Navigator.of(ctx).pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10 * s,
                                    vertical: 6 * s,
                                  ),
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 13 * s,
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
          ),
        );
      },
    );
  }

  // ============== ADD CATEGORY PROMPT ==============
  Future<String?> _showAddCategoryPrompt(
    BuildContext context,
    DocumentController controller,
  ) async {
    final ctrl = TextEditingController();
    final palette = themeController.palette;
    final screenSize = MediaQuery.of(context).size;
    final w = screenSize.width;
    final s = w / 460;

    // Responsive dialog width
    final dialogWidth = w > 600 ? 500.0 : w * 0.85;

    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: palette.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20 * s, 18 * s, 20 * s, 12 * s),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Header ----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "New Category",
                        style: TextStyle(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * s),

                  // ---- Input ----
                  TextField(
                    controller: ctrl,
                    style: TextStyle(fontSize: 14 * s),
                    decoration: InputDecoration(
                      labelText: "Category name",
                      labelStyle: TextStyle(fontSize: 13 * s),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      filled: true,
                      fillColor: palette.black.withAlpha(10),
                      prefixIcon: const Icon(Icons.label_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 14 * s),

                  // ---- Buttons ----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 13 * s,
                            color: palette.black,
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
                          final name = ctrl.text.trim();
                          if (name.isEmpty) return;

                          controller.addCategory(name);
                          Navigator.of(ctx).pop(name);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * s,
                            vertical: 6 * s,
                          ),
                          child: Text(
                            "Add",
                            style: TextStyle(
                              fontSize: 13 * s,
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
        );
      },
    );
  }
}

// ============== CATEGORY BAR WIDGET ==============
class _CategoryBar extends StatelessWidget {
  _CategoryBar({
    required this.controller,
    required this.primary,
  });

  final DocumentController controller;
  final Color primary;
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Improved responsive scaling
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    late double s;
    if (isMobile) {
      s = screenWidth / 460;
    } else if (isTablet) {
      s = screenWidth / 600;
    } else {
      s = screenWidth / 800;
    }

    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...controller.categories.map((cat) {
              final isSelected = controller.selectedCategory.value == cat;
              return Padding(
                padding: EdgeInsets.only(right: 8.0 * s),
                child: ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      fontSize: isMobile ? 12 * s : 13 * s,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: primary,
                  backgroundColor: palette.black.withAlpha(20),
                  showCheckmark: false,
                  avatar: null,
                  labelStyle: TextStyle(
                    color: isSelected ? palette.accent : palette.black,
                  ),
                  onSelected: (_) => controller.selectCategory(cat),
                ),
              );
            }),
            SizedBox(width: 4 * s),
            GestureDetector(
              onTap: () async {
                final screen =
                    context.findAncestorWidgetOfExactType<VaultScreen>();
                if (screen is VaultScreen) {
                  await screen._showAddCategoryPrompt(context, controller);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * s,
                  vertical: 8 * s,
                ),
                decoration: BoxDecoration(
                  color: palette.secondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.add, size: 18 * s),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============== DOCUMENT CARD WIDGET ==============
class _DocumentCard extends StatelessWidget {
  _DocumentCard({
    required this.document,
    required this.cardColor,
    required this.primary,
    required this.onOpen,
    required this.onEdit,
    required this.onDownload,
    required this.onToggleFav,
  });

  final DocumentModel document;
  final Color cardColor;
  final Color primary;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDownload;
  final VoidCallback onToggleFav;

  bool get _isImage {
    final t = document.type.toLowerCase();
    return t == 'jpg' || t == 'jpeg' || t == 'png';
  }

  bool get _isPdf => document.type.toLowerCase() == 'pdf';

  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Improved responsive scaling
    final isMobile = screenWidth < 600;

    late double s;
    if (isMobile) {
      s = screenWidth / 460;
    } else if (screenWidth >= 600 && screenWidth < 1200) {
      s = screenWidth / 600;
    } else {
      s = screenWidth / 800;
    }

    return GestureDetector(
      onTap: onOpen,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: palette.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                  color: palette.black.withAlpha(10),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10 * s),
                    decoration: BoxDecoration(
                      color: palette.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildPreview(context),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
                  child: Text(
                    document.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w500,
                      color: palette.accent,
                    ),
                  ),
                ),
                SizedBox(height: 4 * s),
              ],
            ),
          ),
          // Download button
          Positioned(
            top: 16 * s,
            left: 16 * s,
            child: Container(
              width: 30 * s,
              height: 30 * s,
              decoration: BoxDecoration(
                color: palette.accent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.download, size: 18 * s),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: 32 * s,
                  minHeight: 32 * s,
                ),
                onPressed: onDownload,
              ),
            ),
          ),
          // Edit button
          Positioned(
            top: 16 * s,
            right: 16 * s,
            child: Container(
              width: 30 * s,
              height: 30 * s,
              decoration: BoxDecoration(
                color: palette.accent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.edit, size: 18 * s),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: 32 * s,
                  minHeight: 32 * s,
                ),
                onPressed: onEdit,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
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

    if (_isImage) {
      final file = File(document.path);
      return file.existsSync()
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox.expand(
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : Center(child: Icon(Icons.broken_image, size: 40 * s));
    } else if (_isPdf) {
      return Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 233, 233, 233),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            Icons.picture_as_pdf,
            size: 50 * s,
            color: const Color.fromARGB(255, 226, 24, 9),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: palette.bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            Icons.insert_drive_file,
            size: 40 * s,
          ),
        ),
      );
    }
  }
}