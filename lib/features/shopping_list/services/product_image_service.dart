import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ProductImageService {
  ProductImageService({
    this.captureImage,
    this.retrieveLostImage,
    Future<Directory> Function()? documentsDirectory,
  }) : _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory;

  final ImagePicker _picker = ImagePicker();
  final Future<XFile?> Function()? captureImage;
  final Future<XFile?> Function()? retrieveLostImage;
  final Future<Directory> Function() _documentsDirectory;

  Future<String?> captureProductImage() async {
    final capture = captureImage;
    final image = capture == null
        ? await _picker.pickImage(
            source: ImageSource.camera,
            imageQuality: 80,
            maxWidth: 1200,
          )
        : await capture();

    if (image == null) {
      return null;
    }

    return _storeImage(image);
  }

  Future<String?> retrieveLostProductImage() async {
    final retrieve = retrieveLostImage;
    final image = retrieve == null
        ? await _retrieveLostCameraImage()
        : await retrieve();
    if (image == null) return null;
    return _storeImage(image);
  }

  Future<XFile?> _retrieveLostCameraImage() async {
    final response = await _picker.retrieveLostData();
    if (response.isEmpty) return null;
    if (response.exception != null) throw response.exception!;

    final files = response.files;
    return files == null || files.isEmpty ? null : files.first;
  }

  Future<String> _storeImage(XFile image) async {
    final documentsDirectory = await _documentsDirectory();
    final directory = Directory(
      path.join(documentsDirectory.path, 'product_images'),
    );
    await directory.create(recursive: true);

    final extension = path.extension(image.path);
    final fileName =
        'product_${DateTime.now().microsecondsSinceEpoch}'
        '${extension.isEmpty ? '.jpg' : extension}';
    final savedImage = await File(image.path)
        .copy(path.join(directory.path, fileName));
    return savedImage.path;
  }
}
