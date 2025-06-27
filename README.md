PDF Manager App

# The PDF Manager is a modern Flutter application designed to streamline the process of downloading, viewing, and managing PDF files. With a clean and intuitive user interface, the app allows users to pick PDFs from their device or download them from a URL, store them locally with a clear naming convention, and manage them efficiently with features like duplicate detection, multi-select deletion, and PDF viewing using the Syncfusion PDF Viewer.
Features Overview
1. Download & Store PDF Files

# Functionality: The HomeScreen provides two primary ways to acquire PDFs:
Pick from Device: Users can select a PDF file from their device using a file picker.
Download from URL: Users can input a URL to download a PDF directly.


# Duplicate Check: The app checks for existing files with the same original name (excluding timestamp prefixes) and prompts the user with an AlertDialog to overwrite duplicates.
Naming Convention: Files are stored in the app’s documents directory with a prefix (picked_timestamp_filename or downloaded_timestamp_filename) to ensure uniqueness while maintaining the ability to check for duplicates based on the original file name.
Storage: PDFs are stored locally using the path_provider package’s getApplicationDocumentsDirectory method.

2. Display List of Downloaded Reports

# Dedicated Screen: The DownloadedReportsScreen displays all PDFs stored in the app’s documents directory in a list format.
List Item Details: Each PdfListItem widget shows:
File name (including the timestamp prefix for clarity).
File size (calculated using File.lengthSync()).
Download timestamp (recorded when the file is saved).


# Search Functionality: A search bar filters the list based on file names.
Viewing PDFs: Tapping a file opens it in the SfPdfViewer widget provided by the syncfusion_flutter_pdfviewer package.

3. Manage Downloads

# Multi-Select Mode: Long-pressing a PdfListItem activates multi-select mode, enabling checkboxes for selecting multiple files.
# Delete Functionality: A delete icon appears in the app bar when files are selected, allowing users to delete them. The list updates instantly using setState, and a SnackBar with an "Undo" option is shown (though the undo action is not implemented in the provided code).
# Immediate Updates: Deletion removes files from storage and updates the UI without requiring a manual refresh.

4. Code Quality & UI

Code Structure: The codebase is modular, with separate files for screens (home_screen.dart, downloaded_reports_screen.dart), services (pdf_download_service.dart), models (pdf_file_model.dart), and widgets (pdf_list_item.dart). Dartdoc comments provide clear documentation.
UI Design: The app features a modern UI with:
Elevated Card widgets for list items and input fields.
Rounded corners for a polished look.
Consistent styling using Theme.of(context).primaryColor.
Animations like ScaleTransition for the FloatingActionButton (FAB).


# Packages Used:
1. flutter: Core framework for UI and state management.
2. path_provider: Accesses the app’s documents directory.
3. dio: Handles PDF downloads from URLs.
4. file_picker: Enables picking PDFs from the device.
5. syncfusion_flutter_pdfviewer: Renders PDFs for viewing.
6. permission_handler: Included for potential future external storage needs (not currently used).
7. open_file: Not actively used in the provided code but included for potential file-opening functionality.
8. cupertino_icons: Provides iOS-style icons.



# How the App Works
1. HomeScreen Workflow

UI Components:
AppBar: Displays the title "PDF Manager" with a consistent theme.
Body: Contains a ListView with:
A Card-based ListTile for picking a PDF from the device.
A Card-based TextField for entering a PDF URL.
An ElevatedButton for initiating URL downloads.


# FAB: A FloatingActionButton with a ScaleTransition animation navigates to the DownloadedReportsScreen.


# Key Methods:
_pickPdfFile: Uses file_picker to select a PDF and navigates to DownloadedReportsScreen with the file path.
_downloadPdfFromUrl: Validates the URL and navigates to DownloadedReportsScreen with the URL.
_navigateToReportsScreen: Navigates to DownloadedReportsScreen to view stored PDFs.


# User Flow:
1. User opens the app and sees the HomeScreen.
2. To pick a file, they tap "Pick PDF from Device," triggering _pickPdfFile.
3. To download a PDF, they enter a URL (e.g., https://www.w3.org/WAI/ER/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf) and tap "Download PDF from URL," triggering _downloadPdfFromUrl.
4. Invalid URLs trigger a SnackBar with an error message.
5. The FAB navigates to the list of stored PDFs.



2. DownloadedReportsScreen Workflow

# UI Components:
AppBar: Displays "Downloaded Reports" and shows a delete icon when files are selected in multi-select mode.
Body: Contains a Column with:
A Card-based TextField for searching PDFs by name.
A ListView.builder displaying PdfListItem widgets for each PDF.


# FAB: Navigates back to the HomeScreen for uploading or downloading more PDFs.


# Key Methods:
_loadPdfFiles: Loads all .pdf files from the documents directory into a List<PdfFile>, updating the UI via setState.
_processInput: Handles file copying (for picked files) or downloading (for URLs), including duplicate checks and overwrites.
_checkDuplicateFile: Checks if a file with the same original name exists, ignoring timestamp prefixes.
_showDuplicateDialog: Displays an AlertDialog to confirm overwriting duplicates.
_filterFiles: Filters the PDF list based on the search query.
_toggleSelection: Manages file selection in multi-select mode.
_deleteSelectedFiles: Deletes selected files and updates the UI.
_downloadAndGetPath: Downloads a PDF, handles duplicates, and returns the saved path.


# User Flow:
1. On navigating to DownloadedReportsScreen, _loadPdfFiles populates the PDF list.
2. If a filePath or url is provided (from HomeScreen), _processInput handles copying or downloading, checking for duplicates.
3. Users can search PDFs using the search bar, triggering _filterFiles.
4. Tapping a PDF opens it in SfPdfViewer.
5. Long-pressing a PDF enables multi-select mode, allowing users to select files and delete them via the app bar’s delete icon.
6. The FAB navigates back to HomeScreen.



3. Duplicate Detection and Storage

Naming Convention: Files are saved as picked_timestamp_filename or downloaded_timestamp_filename to ensure uniqueness. For example, a file named sample.pdf picked at timestamp 1634567890123 becomes picked_1634567890123_sample.pdf.
Duplicate Check: The _checkDuplicateFile method strips the picked_timestamp_ or downloaded_timestamp_ prefix from stored file names and compares the original name to detect duplicates.
Overwrite Handling: If a duplicate is found, _showDuplicateDialog prompts the user to overwrite. If confirmed, existing files with the same original name are deleted before saving the new file.

4. PDF Viewing

Tapping a PdfListItem triggers a Navigator.push to a new screen with a FutureBuilder that loads the PDF file using SfPdfViewer.file. A CircularProgressIndicator is shown during loading, and errors are displayed if the file fails to load.

5. Deletion

In multi-select mode, users select files via checkboxes (_toggleSelection). The _deleteSelectedFiles method deletes the selected files using PdfDownloadService.deletePdf and updates the UI. A SnackBar notifies the user of the deletion with an "Undo" option (not functional in the provided code).

# Setup Instructions

Install Flutter SDK

Ensure Flutter SDK (version 3.6.0 or higher) is installed. Follow the official Flutter installation guide.
Verify installation:flutter doctor




Clone the Repository
git clone <repository-url>
cd pdf_manager


# Set Up Project Dependencies

Ensure the pubspec.yaml matches the provided configuration:name: pdf
description: "A new Flutter project."
publish_to: 'none'
version: 1.0.0+1
environment:
sdk: ^3.6.0
dependencies:
flutter:
sdk: flutter
cupertino_icons: ^1.0.8
path_provider: ^2.0.0
dio: ^4.0.0
open_file: ^3.2.0
file_picker: ^5.2.0
syncfusion_flutter_pdfviewer: ^28.1.39
permission_handler: ^11.3.1
dev_dependencies:
flutter_test:
sdk: flutter
flutter_lints: ^5.0.0
flutter:
uses-material-design: true


Install dependencies:flutter pub get




Register Syncfusion License

Obtain a Syncfusion license (free community license or commercial) from Syncfusion.
Add the license key to main.dart:import 'package:syncfusion_flutter_core/core.dart';
import 'package:flutter/material.dart';

 void main() {
SyncfusionLicenseRegistry.registerLicense('YOUR_LICENSE_KEY_HERE');
runApp(const MyApp());
 }

 class MyApp extends StatelessWidget {
const MyApp({super.key});
@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'PDF Manager',
theme: ThemeData(
primarySwatch: Colors.blue,
useMaterial3: true,
 ),
home: const HomeScreen(),
  );
 }
 }




# Set Up Emulator or Device

Configure an Android/iOS emulator or connect a physical device.
Ensure USB debugging is enabled for physical devices.


Run the App
flutter run



# Project Structure

lib/:
 main.dart: Initializes the app and registers the Syncfusion license.
 home_screen.dart: Manages PDF picking and downloading with a clean UI.
 downloaded_reports_screen.dart: Displays and manages stored PDFs with search and delete functionality.
 services/pdf_download_service.dart: Handles PDF downloading and deletion logic.
 models/pdf_file_model.dart: Defines the PdfFile class for file metadata (path, name, size, timestamp).
 widgets/pdf_list_item.dart: Custom widget for rendering PDF list items with selection support.


pubspec.yaml: Specifies dependencies and project configuration.

Sample Code for Missing Files

services/pdf_download_service.dart:import 'package:dio/dio.dart';
  import 'package:path_provider/path_provider.dart';
  import 'dart:io';

 class PdfDownloadService {
 final Dio _dio = Dio();

 /// Downloads a PDF from [url] and saves it to [savePath] with [fileName].
 Future<String> downloadPdf(String url, String fileName, String savePath) async {
 try {
 final response = await _dio.download(url, savePath);
 if (response.statusCode == 200) {
 return savePath;
 }
 return '';
 } catch (e) {
 return '';
  }
 }

/// Deletes a PDF file at [filePath].
Future<void> deletePdf(String filePath) async {
final file = File(filePath);
if (await file.exists()) {
await file.delete();
 }
}
}


models/pdf_file_model.dart:class PdfFile {
final String path;
final String name;
final int size;
final DateTime timestamp;

PdfFile({
required this.path,
required this.name,
required this.size,
required this.timestamp,
});
}


widgets/pdf_list_item.dart:import 'package:flutter/material.dart';
import '../models/pdf_file_model.dart';

class PdfListItem extends StatelessWidget {
final PdfFile pdfFile;
final bool isMultiSelect;
final bool isSelected;
final VoidCallback onTap;
final VoidCallback onLongPress;
final Function(PdfFile) onSelectionChanged;

const PdfListItem({
super.key,
required this.pdfFile,
required this.isMultiSelect,
required this.isSelected,
required this.onTap,
required this.onLongPress,
required this.onSelectionChanged,
});

@override
Widget build(BuildContext context) {
return ListTile(
leading: isMultiSelect
? Checkbox(
value: isSelected,
onChanged: (_) => onSelectionChanged(pdfFile),
)
: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
title: Text(pdfFile.name),
subtitle: Text(
'Size: ${(pdfFile.size / 1024).toStringAsFixed(2)} KB | ${pdfFile.timestamp.toString()}',
),
onTap: onTap,
onLongPress: onLongPress,
);
}
}



# Usage Instructions

 1. Launch the App

 Run flutter run to open the app on an emulator or device.
 The HomeScreen appears with options to pick a PDF or download one from a URL.


 2. Pick a PDF from Device

Tap "Pick PDF from Device" to open the file picker.
Select a PDF file (e.g., a local file like sample.pdf).
The app checks for duplicates based on the original file name.
If a duplicate exists, an AlertDialog prompts to overwrite. Confirming deletes the existing file and copies the new one to the documents directory.
The app navigates to DownloadedReportsScreen, where the file is listed.


 3. Download a PDF from URL

Enter a valid PDF URL (e.g., https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf) in the text field.
Tap "Download PDF from URL."
The app validates the URL and checks for duplicates.
If a duplicate is found, an AlertDialog prompts to overwrite. Confirming deletes the existing file and downloads the new one.
The downloaded PDF is saved to the documents directory and opened in SfPdfViewer.


 4. iew Stored PDFs

Tap the FAB (list icon) on HomeScreen to navigate to DownloadedReportsScreen.
See a list of all PDFs with their names, sizes, and timestamps.
Use the search bar to filter files by name.


 5. View a PDF

Tap a PDF in the list to open it in a new screen with SfPdfViewer.
The PDF loads with a progress indicator, and errors are displayed if loading fails.


 6. Delete PDFs

Long-press a PDF to enter multi-select mode.
Select multiple PDFs using checkboxes.
Tap the delete icon in the app bar to remove selected files.
A SnackBar confirms deletion with an "Undo" option.



# Testing Instructions

Test Data

Sample URL: Use https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf for downloading.
Local PDF: Select any PDF file from your device for picking.


Test Scenarios

Duplicate Detection: Download or pick the same PDF twice to trigger the AlertDialog. Confirm or cancel overwriting to verify behavior.
Multi-Select Deletion: Long-press a PDF, select multiple files, and delete them. Verify the list updates and the SnackBar appears.
Search: Enter a file name (or part of it) in the search bar to filter the list.
PDF Viewing: Tap a PDF to ensure it opens correctly in SfPdfViewer.
Invalid URL: Enter an invalid URL (e.g., http://example.com) to verify the error SnackBar.


Run Unit Tests

Add test cases in the test/ directory for key methods like _checkDuplicateFile, _downloadPdf, and _deleteSelectedFiles.
Run tests:flutter test



# Troubleshooting

1. Syncfusion PDF Viewer Errors: Ensure the Syncfusion license is registered in main.dart. Verify the syncfusion_flutter_pdfviewer version matches pubspec.yaml.
2. Download Failures: Check if the URL is valid and accessible. Use the sample URL for testing.
3. File Picker Issues: Ensure file_picker permissions are correctly handled (though app-specific storage typically requires no permissions).
4. Storage Issues: Verify that path_provider returns a valid documents directory path.
5. UI Glitches: Ensure setState is called appropriately to refresh the UI after file operations.

