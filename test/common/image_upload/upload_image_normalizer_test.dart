import 'dart:typed_data';

import 'package:chack_chack/common/image_upload/upload_image_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detects backend-supported upload image bytes', () {
    expect(
      UploadImageNormalizer.detectContentType(
        Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]),
      ),
      'image/jpeg',
    );
    expect(
      UploadImageNormalizer.detectContentType(
        Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]),
      ),
      'image/png',
    );
    expect(
      UploadImageNormalizer.detectContentType(
        Uint8List.fromList([
          0x52,
          0x49,
          0x46,
          0x46,
          0x00,
          0x00,
          0x00,
          0x00,
          0x57,
          0x45,
          0x42,
          0x50,
        ]),
      ),
      'image/webp',
    );
  });

  test('treats HEIC and HEIF paths as needing JPEG normalization', () {
    expect(UploadImageNormalizer.needsJpegNormalization('IMG_0001.HEIC'), true);
    expect(
      UploadImageNormalizer.needsJpegNormalization('/tmp/photo.heif'),
      true,
    );
    expect(
      UploadImageNormalizer.needsJpegNormalization('/tmp/photo.jpg'),
      false,
    );
    expect(
      UploadImageNormalizer.needsJpegNormalization('/tmp/photo.png'),
      false,
    );
    expect(
      UploadImageNormalizer.needsJpegNormalization('/tmp/photo.webp'),
      false,
    );
  });

  test('builds a jpg file name for normalized upload files', () {
    expect(
      UploadImageNormalizer.normalizedJpegName('IMG_0001.HEIC'),
      'IMG_0001.jpg',
    );
    expect(
      UploadImageNormalizer.normalizedJpegName('/tmp/photo.heif'),
      'photo.jpg',
    );
    expect(UploadImageNormalizer.normalizedJpegName('photo'), 'photo.jpg');
  });
}
