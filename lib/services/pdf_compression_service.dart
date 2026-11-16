import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_pdf_compression/simple_pdf_compression.dart';

/// Servicio que comprime los PDFs de assets una vez y los almacena en el
/// directorio temporal de la app para reducir el peso en memoria al cargarlos.
class PdfCompressionService {
  PdfCompressionService._();

  /// Directorio donde se almacenan los PDFs comprimidos.
  static Future<Directory> get _cacheDir async {
    final dir = await getTemporaryDirectory();
    final pdfDir = Directory('${dir.path}/compressed_pdfs');
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    return pdfDir;
  }

  /// Genera un nombre de archivo único basado en la ruta del asset original.
  static String _generateFileName(String assetPath) {
    final fileName = assetPath.split('/').last;
    final parts = fileName.split('.');
    final ext = parts.last;
    final nameWithoutExt = parts.sublist(0, parts.length - 1).join('.');
    return '${nameWithoutExt}_compressed.$ext';
  }

  /// Devuelve la ruta del PDF comprimido si ya existe, de lo contrario lo
  /// comprime y guarda. Si el PDF original es menor a 2 MB, lo copia sin
  /// comprimir para evitar degradación innecesaria.
  static Future<File> getCompressedPdf(String assetPath) async {
    try {
      final cacheDir = await _cacheDir;
      final fileName = _generateFileName(assetPath);
      final cachedFile = File('${cacheDir.path}/$fileName');

      // Si ya existe una versión comprimida, usarla directamente.
      if (await cachedFile.exists()) {
        debugPrint(
          'PdfCompressionService: Usando PDF comprimido en caché: $fileName',
        );
        return cachedFile;
      }

      // Cargar el PDF original desde assets.
      final byteData = await rootBundle.load(assetPath);
      final originalBytes = byteData.buffer.asUint8List();
      final originalSizeKB = originalBytes.length ~/ 1024;

      debugPrint(
        'PdfCompressionService: PDF original $fileName - $originalSizeKB KB',
      );

      // Si el PDF es pequeño (< 2 MB), copiarlo sin comprimir.
      if (originalSizeKB < 2048) {
        await cachedFile.writeAsBytes(originalBytes);
        debugPrint('PdfCompressionService: PDF pequeño, copiado sin comprimir');
        return cachedFile;
      }

      // Guardar temporalmente el PDF original para comprimirlo.
      final tempOriginal = File(
        '${cacheDir.path}/temp_${_generateFileName(assetPath)}',
      );
      await tempOriginal.writeAsBytes(originalBytes);

      // Comprimir el PDF usando simple_pdf_compression.
      final compressor = PDFCompression();
      final compressedFile = await compressor.compressPdf(
        tempOriginal,
        quality: 60,
        thresholdSize: 500 * 1024, // 500 KB objetivo
      );

      // Mover el archivo comprimido al nombre final.
      if (await compressedFile.exists()) {
        await compressedFile.copy(cachedFile.path);
        await compressedFile.delete();
      }

      // Limpiar el archivo temporal original.
      if (await tempOriginal.exists()) {
        await tempOriginal.delete();
      }

      final compressedSize = await cachedFile.length();
      final savings =
          ((1 - compressedSize / originalBytes.length) * 100).toStringAsFixed(1);
      debugPrint(
        'PdfCompressionService: PDF comprimido - '
        '${(compressedSize / 1024).toStringAsFixed(0)} KB (ahorro: $savings%)',
      );

      return cachedFile;
    } catch (e) {
      debugPrint('PdfCompressionService: Error al comprimir PDF: $e');
      rethrow;
    }
  }

  /// Devuelve los bytes del PDF comprimido para usar directamente con
  /// Syncfusion PDF Viewer.
  static Future<Uint8List> getCompressedPdfBytes(String assetPath) async {
    final file = await getCompressedPdf(assetPath);
    return file.readAsBytes();
  }

  /// Limpia todos los PDFs comprimidos en caché. Útil para forzar una
  /// recompressión o liberar espacio.
  static Future<void> clearCache() async {
    try {
      final cacheDir = await _cacheDir;
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        debugPrint('PdfCompressionService: Caché de PDFs limpiada');
      }
    } catch (e) {
      debugPrint('PdfCompressionService: Error al limpiar caché: $e');
    }
  }
}
