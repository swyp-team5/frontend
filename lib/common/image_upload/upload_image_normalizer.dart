import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

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

  static Future<File?> normalizeAssetForUpload(AssetEntity asset) async {
    final originalFile = await asset.originFile;
    if (originalFile == null) {
      return null;
    }

    final bytes = await originalFile.readAsBytes();
    if (detectContentType(bytes) != null &&
        !needsJpegNormalization(originalFile.path)) {
      return originalFile;
    }

    final jpegBytes = await asset.thumbnailDataWithSize(
      ThumbnailSize(asset.width, asset.height),
      format: ThumbnailFormat.jpeg,
      quality: 95,
    );

    if (jpegBytes == null || jpegBytes.isEmpty) {
      return null;
    }

    final normalizedFile = File(
      '${Directory.systemTemp.path}'
      '${Platform.pathSeparator}'
      '${DateTime.now().microsecondsSinceEpoch}_'
      '${normalizedJpegName(originalFile.path)}',
    );
    return normalizedFile.writeAsBytes(jpegBytes, flush: true);
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
