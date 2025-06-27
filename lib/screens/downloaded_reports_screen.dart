import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../services/pdf_download_service.dart';
import '../models/pdf_file_model.dart';
import '../widgets/pdf_list_item.dart';
import 'home_screen.dart';

/// Displays a list of downloaded or picked PDF files with search and delete functionality.
class DownloadedReportsScreen extends StatefulWidget {
  final String? filePath;
  final String? url;

  const DownloadedReportsScreen({super.key, this.filePath, this.url});

  @override
  State<DownloadedReportsScreen> createState() => _DownloadedReportsScreenState();
}

class _DownloadedReportsScreenState extends State<DownloadedReportsScreen> {
  final PdfDownloadService _pdfService = PdfDownloadService();
  List<PdfFile> _pdfFiles = [];
  List<PdfFile> _filteredFiles = [];
  bool _isMultiSelect = false;
  List<PdfFile> _selectedFiles = [];
  String _searchQuery = '';
  DateTime _downloadTimestamp = DateTime.now();

  // Constants for UI styling and messages
  static const double _padding = 12.0;
  static const double _cardElevation = 4.0;
  static const String _screenTitle = 'Downloaded Reports';
  static const String _searchHint = 'Search by name';
  static const String _downloadFailed = 'Failed to download PDF';
  static const String _downloadError = 'Error downloading PDF: ';
  static const String _deleteMessage = 'Deleting file(s)...';
  static const String _undoLabel = 'Undo';
  static const String _duplicateMessage = 'A file with the name "';
  static const String _duplicateMessageSuffix = '" already exists. Overwrite it?';
  static const String _overwriteLabel = 'Overwrite';
  static const String _cancelLabel = 'Cancel';

  @override
  void initState() {
    super.initState();
    _loadPdfFiles();
    _processInput();
  }

  /// Loads PDF files from the app's documents directory.
  Future<void> _loadPdfFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.pdf'));
    setState(() {
      _pdfFiles = files
          .map((file) => PdfFile(
        path: file.path,
        name: file.path.split('/').last,
        size: file.lengthSync(),
        timestamp: _downloadTimestamp,
      ))
          .toList();
      _filterFiles();
    });
  }

  /// Checks if a file with the given name exists in the documents directory.
  Future<bool> _checkDuplicateFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.pdf'));
    return files.any((file) {
      final existingFileName = file.path.split('/').last;
      // Remove timestamp prefix (e.g., 'picked_timestamp_' or 'downloaded_timestamp_')
      final cleanExistingName = existingFileName.replaceFirst(RegExp(r'^(picked|downloaded)_\d+_'), '');
      return cleanExistingName == fileName;
    });
  }

  /// Shows a dialog to confirm overwriting a duplicate file.
  Future<bool> _showDuplicateDialog(String fileName) async {
    if (!mounted) return false;
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicate File'),
        content: Text('$_duplicateMessage$fileName$_duplicateMessageSuffix'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(_cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(_overwriteLabel),
          ),
        ],
      ),
    ) ??
        false;
  }

  /// Processes input file or URL to copy or download PDFs, checking for duplicates.
  Future<void> _processInput() async {
    if (widget.filePath != null) {
      final originalFileName = widget.filePath!.split('/').last;
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'picked_${DateTime.now().millisecondsSinceEpoch}_$originalFileName';
      final newPath = '${directory.path}/$fileName';

      // Check for duplicate file based on original name
      if (await _checkDuplicateFile(originalFileName)) {
        final shouldOverwrite = await _showDuplicateDialog(originalFileName);
        if (!shouldOverwrite || !mounted) return;
        // Delete existing file with the same original name if overwriting
        final existingFiles = directory
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.pdf') && file.path.split('/').last.contains(originalFileName));
        for (var file in existingFiles) {
          await file.delete();
        }
      }

      await File(widget.filePath!).copy(newPath);
      _downloadTimestamp = DateTime.now();
      await _loadPdfFiles();
    } else if (widget.url != null) {
      try {
        // Extract original file name from URL
        final originalFileName = widget.url!.split('/').last.endsWith('.pdf')
            ? widget.url!.split('/').last
            : 'downloaded.pdf';
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'downloaded_${DateTime.now().millisecondsSinceEpoch}_$originalFileName';
        final savePath = '${directory.path}/$fileName';

        // Check for duplicate file based on original name
        if (await _checkDuplicateFile(originalFileName)) {
          final shouldOverwrite = await _showDuplicateDialog(originalFileName);
          if (!shouldOverwrite || !mounted) return;
          // Delete existing file with the same original name if overwriting
          final existingFiles = directory
              .listSync()
              .whereType<File>()
              .where((file) => file.path.endsWith('.pdf') && file.path.split('/').last.contains(originalFileName));
          for (var file in existingFiles) {
            await file.delete();
          }
        }

        final downloadedPath = await _pdfService.downloadPdf(widget.url!, fileName, savePath);
        if (downloadedPath.isNotEmpty) {
          _downloadTimestamp = DateTime.now();
          await _loadPdfFiles();
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FutureBuilder<File>(
                future: Future.value(File(downloadedPath)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Text('Error loading PDF: ${snapshot.error}');
                    }
                    return Scaffold(
                      appBar: AppBar(title: Text(fileName)),
                      body: SfPdfViewer.file(snapshot.data!),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(_downloadFailed)),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_downloadError$e')),
        );
      }
    }
  }

  /// Filters PDF files based on the search query.
  void _filterFiles() {
    _filteredFiles = _pdfFiles
        .where((file) => file.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    setState(() {});
  }

  /// Toggles selection state for a PDF file in multi-select mode.
  void _toggleSelection(PdfFile file) {
    setState(() {
      if (_selectedFiles.contains(file)) {
        _selectedFiles.remove(file);
      } else {
        _selectedFiles.add(file);
      }
    });
  }

  /// Deletes selected PDF files with an undo option.
  Future<void> _deleteSelectedFiles() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_deleteMessage${_selectedFiles.length}'),
        action: SnackBarAction(label: _undoLabel, onPressed: () {}),
        duration: const Duration(seconds: 3),
      ),
    );
    for (var file in _selectedFiles) {
      await _pdfService.deletePdf(file.path);
    }
    setState(() {
      _pdfFiles.removeWhere((file) => _selectedFiles.contains(file));
      _filteredFiles.removeWhere((file) => _selectedFiles.contains(file));
      _selectedFiles.clear();
      _isMultiSelect = false;
    });
  }

  /// Downloads a PDF from a URL and returns its saved path, checking for duplicates.
  Future<String> _downloadAndGetPath(String url, String fileName) async {
    try {
      final originalFileName = url.split('/').last.endsWith('.pdf') ? url.split('/').last : 'downloaded.pdf';
      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/$fileName';

      // Check for duplicate file based on original name
      if (await _checkDuplicateFile(originalFileName)) {
        final shouldOverwrite = await _showDuplicateDialog(originalFileName);
        if (!shouldOverwrite || !mounted) return '';
        // Delete existing file with the same original name if overwriting
        final existingFiles = directory
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.pdf') && file.path.split('/').last.contains(originalFileName));
        for (var file in existingFiles) {
          await file.delete();
        }
      }

      await _pdfService.downloadPdf(url, fileName, savePath);
      return savePath;
    } catch (e) {
      if (!mounted) return '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_downloadError$e')),
      );
      return '';
    }
  }

  /// Navigates to the HomeScreen for uploading or downloading PDFs.
  void _navigateToHomeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_screenTitle),
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          if (_isMultiSelect && _selectedFiles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteSelectedFiles,
              tooltip: 'Delete selected PDFs',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildPdfList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToHomeScreen,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: _cardElevation,
        child: const Icon(
          Icons.upload_file,
          color: Colors.white,
        ),
        tooltip: 'Upload or Download PDF',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  /// Builds the search bar with elevation.
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(_padding),
      child: Card(
        elevation: _cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (value) {
            _searchQuery = value;
            _filterFiles();
          },
          decoration: const InputDecoration(
            labelText: _searchHint,
            prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  /// Builds the list of PDF files with elevated cards.
  Widget _buildPdfList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: _padding, vertical: 8),
      itemCount: _filteredFiles.length,
      itemBuilder: (context, index) {
        final pdf = _filteredFiles[index];
        return Card(
          elevation: _cardElevation,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: PdfListItem(
            pdfFile: pdf,
            isMultiSelect: _isMultiSelect,
            isSelected: _selectedFiles.contains(pdf),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FutureBuilder<File>(
                    future: Future.value(File(pdf.path)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Text('Error loading PDF: ${snapshot.error}');
                        }
                        return Scaffold(
                          appBar: AppBar(title: Text(pdf.name)),
                          body: SfPdfViewer.file(snapshot.data!),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              );
            },
            onLongPress: () {
              setState(() {
                _isMultiSelect = true;
                _toggleSelection(pdf);
              });
            },
            onSelectionChanged: _toggleSelection,
          ),
        );
      },
    );
  }
}