import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PdfDownloadService {
  final Dio _dio = Dio();

  Future<String> downloadPdf(String url, String fileName, String savePath) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final file = File(savePath);
      await file.writeAsBytes(response.data);
      return savePath;
    } catch (e) {
      print('Download error: $e');
      return '';
    }
  }

  Future<void> deletePdf(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Delete error: $e');
    }
  }
}