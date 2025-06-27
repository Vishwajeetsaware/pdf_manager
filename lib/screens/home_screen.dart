import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'downloaded_reports_screen.dart';

/// The main entry point for the PDF Manager app, allowing users to pick a PDF
/// from the device or download one from a URL.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Controller for the URL input field
  final TextEditingController _urlController = TextEditingController();

  // Animation controller for the FloatingActionButton
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Constants for UI styling and messages
  static const double _padding = 16.0;
  static const double _spacing = 16.0;
  static const double _cardElevation = 4.0;
  static const double _fabElevation = 6.0;
  static const String _appTitle = 'PDF Manager';
  static const String _urlHint = 'e.g., https://example.com/sample.pdf';
  static const String _noPdfSelected = 'No PDF selected';
  static const String _invalidUrl = 'Please enter a valid URL';
  static const String _pickPdfLabel = 'Pick PDF from Device';
  static const String _downloadButtonLabel = 'Download PDF from URL';
  static const String _reportsTooltip = 'View Downloaded Reports';

  @override
  void initState() {
    super.initState();
    // Initialize FAB animation
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  /// Picks a PDF file from the device and navigates to the reports screen.
  Future<void> _pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (!mounted) return;

    if (result != null && result.files.single.path != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DownloadedReportsScreen(
            filePath: result.files.single.path,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_noPdfSelected),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Validates the URL and navigates to the reports screen for download.
  void _downloadPdfFromUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty || !Uri.parse(url).isAbsolute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_invalidUrl),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DownloadedReportsScreen(url: url),
      ),
    );
  }

  /// Navigates to the DownloadedReportsScreen to view stored PDFs.
  void _navigateToReportsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DownloadedReportsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          _appTitle,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        elevation: _cardElevation,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(_padding),
        child: ListView(
          children: [
            _buildPickPdfTile(),
            const SizedBox(height: _spacing),
            _buildUrlInputField(),
            const SizedBox(height: _spacing),
            _buildDownloadButton(),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: _navigateToReportsScreen,
          backgroundColor: Theme.of(context).primaryColor,
          elevation: _fabElevation,
          child: const Icon(
            Icons.list_alt,
            color: Colors.white,
            size: 28,
          ),
          tooltip: _reportsTooltip,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  /// Builds a card-based ListTile for picking a PDF from the device.
  Widget _buildPickPdfTile() {
    return Card(
      elevation: _cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.folder_open,
          color: Colors.blueAccent,
          size: 28,
        ),
        title: const Text(
          _pickPdfLabel,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        onTap: _pickPdfFile,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hoverColor: Colors.blue.withOpacity(0.1),
      ),
    );
  }

  /// Builds a card-based TextField for entering the PDF URL.
  Widget _buildUrlInputField() {
    return Card(
      elevation: _cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _urlController,
        decoration: const InputDecoration(
          labelText: 'Enter PDF URL',
          hintText: _urlHint,
          prefixIcon: Icon(
            Icons.link,
            color: Colors.blueAccent,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _downloadPdfFromUrl(),
      ),
    );
  }

  /// Builds an elevated button for initiating PDF download from URL.
  Widget _buildDownloadButton() {
    return ElevatedButton(
      onPressed: _downloadPdfFromUrl,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: _cardElevation,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      child: const Text(
        _downloadButtonLabel,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}