import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class UploadImageNormalizer {
  static const Set<String> _supportedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  static String? detectContentType(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }

    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }

    return null;
  }

  static bool needsJpegNormalization(String path) {
    final extension = _extensionOf(path);
    return !_supportedExtensions.contains(extension);
  }

  static String normalizedJpegName(String path) {
    final fileName = path.split(RegExp(r'[\\/]')).last;
    final dotIndex = fileName.lastIndexOf('.');
    final baseName = dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
    final safeBaseName = baseName.isEmpty ? 'upload_image' : baseName;
    return '$safeBaseName.jpg';
  }

  static Future<File?> normalizeFileForUpload(File file) async {
    final bytes = await file.readAsBytes();

    final detectedType = detectContentType(bytes);

    // 이미 지원되는 포맷이면, 실제 내용에 맞는 확장자로 파일명을 강제 통일
    if (detectedType != null) {
      final correctExt = _extensionForContentType(detectedType);
      final currentExt = _extensionOf(file.path);

      if (currentExt == correctExt) {
        return file; // 확장자와 내용이 일치 → 그대로 사용
      }

      // 확장자만 다르게 붙어있는 경우 → 파일명을 실제 내용에 맞게 고쳐서 복사
      final fixedFile = File(
        '${Directory.systemTemp.path}'
            '${Platform.pathSeparator}'
            '${DateTime.now().microsecondsSinceEpoch}_fixed.$correctExt',
      );
      return fixedFile.writeAsBytes(bytes, flush: true);
    }

    // 지원 안 되는 포맷(HEIC 등) → JPEG로 재인코딩
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    final jpegBytes = img.encodeJpg(decoded, quality: 95);
    final normalizedFile = File(
      '${Directory.systemTemp.path}'
          '${Platform.pathSeparator}'
          '${DateTime.now().microsecondsSinceEpoch}_'
          '${normalizedJpegName(file.path)}',
    );
    return normalizedFile.writeAsBytes(jpegBytes, flush: true);
  }

  static String _extensionForContentType(String contentType) {
    switch (contentType) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      default:
        return 'jpg';
    }
  }

  static String _extensionOf(String path) {
    final fileName = path.split(RegExp(r'[\\/]')).last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex + 1).toLowerCase();
  }
}