import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:handcart/features/shopping_list/services/product_image_service.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'handcart_product_images_',
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'camera cancellation returns null without creating a photo directory',
    () async {
      var documentsDirectoryRequested = false;
      final service = ProductImageService(
        captureImage: () async => null,
        documentsDirectory: () async {
          documentsDirectoryRequested = true;
          return temporaryDirectory;
        },
      );

      expect(await service.captureProductImage(), isNull);
      expect(documentsDirectoryRequested, isFalse);
      expect(
        await Directory(path.join(temporaryDirectory.path, 'product_images'))
            .exists(),
        isFalse,
      );
    },
  );

  test(
    'copies a captured image into the application documents directory',
    () async {
      final source = File(path.join(temporaryDirectory.path, 'camera.jpg'));
      await source.writeAsBytes([1, 2, 3, 4]);
      final documentsDirectory = Directory(
        path.join(temporaryDirectory.path, 'app_documents'),
      );
      final service = ProductImageService(
        captureImage: () async => XFile(source.path),
        documentsDirectory: () async => documentsDirectory,
      );

      final savedPath = await service.captureProductImage();
      expect(savedPath, isNotNull);
      expect(
        path.dirname(savedPath!),
        path.join(documentsDirectory.path, 'product_images'),
      );
      expect(await File(savedPath).readAsBytes(), equals([1, 2, 3, 4]));
    },
  );

  test('propagates camera failures for the UI to report', () async {
    final service = ProductImageService(
      captureImage: () async => throw StateError('camera unavailable'),
      documentsDirectory: () async => temporaryDirectory,
    );

    await expectLater(
      service.captureProductImage(),
      throwsA(isA<StateError>()),
    );
  });

  test('propagates failures while copying a captured image', () async {
    final service = ProductImageService(
      captureImage: () async =>
          XFile(path.join(temporaryDirectory.path, 'missing.jpg')),
      documentsDirectory: () async => temporaryDirectory,
    );

    await expectLater(
      service.captureProductImage(),
      throwsA(isA<FileSystemException>()),
    );
  });

  test(
    'copies recovered Android camera data into persistent app storage',
    () async {
      final source = File(path.join(temporaryDirectory.path, 'recovered.jpg'));
      await source.writeAsBytes([5, 6, 7]);
      final documentsDirectory = Directory(
        path.join(temporaryDirectory.path, 'app_documents'),
      );
      final service = ProductImageService(
        retrieveLostImage: () async => XFile(source.path),
        documentsDirectory: () async => documentsDirectory,
      );

      final recoveredPath = await service.retrieveLostProductImage();
      expect(recoveredPath, isNotNull);
      expect(await File(recoveredPath!).readAsBytes(), equals([5, 6, 7]));
    },
  );
}
