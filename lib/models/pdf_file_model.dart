import 'dart:io';

class PdfFile {
  final String path;
  final String name;
  final int size;
  final DateTime timestamp;

  PdfFile({required this.path, required this.name, required this.size, required this.timestamp});
}