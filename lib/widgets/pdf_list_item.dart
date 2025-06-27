import 'package:flutter/material.dart';
import '../models/pdf_file_model.dart';

class PdfListItem extends StatelessWidget {
  final PdfFile pdfFile;
  final bool isMultiSelect;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(PdfFile) onSelectionChanged;

  PdfListItem({
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
          : Icon(Icons.picture_as_pdf, color: Colors.red),
      title: Text(pdfFile.name),
      subtitle: Text('${(pdfFile.size / 1024).toStringAsFixed(2)} KB - ${pdfFile.timestamp}'),
      onTap: isMultiSelect ? () => onSelectionChanged(pdfFile) : onTap,
      onLongPress: isMultiSelect ? null : onLongPress,
      selected: isSelected,
    );
  }
}