import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  /// Captures photo using camera and stores it in app's private documents directory
  Future<File?> takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final evidenceDir = Directory(p.join(appDir.path, 'evidence_photos'));
      if (!await evidenceDir.exists()) {
        await evidenceDir.create(recursive: true);
      }

      final fileName = 'EVD_${const Uuid().v4().substring(0, 8)}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = File(p.join(evidenceDir.path, fileName));
      await File(pickedFile.path).copy(savedImage.path);

      return savedImage;
    } catch (e) {
      return null;
    }
  }

  /// Picks photo from gallery
  Future<File?> pickFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final evidenceDir = Directory(p.join(appDir.path, 'evidence_photos'));
      if (!await evidenceDir.exists()) {
        await evidenceDir.create(recursive: true);
      }

      final fileName = 'EVD_GAL_${const Uuid().v4().substring(0, 8)}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = File(p.join(evidenceDir.path, fileName));
      await File(pickedFile.path).copy(savedImage.path);

      return savedImage;
    } catch (e) {
      return null;
    }
  }

  /// Safely deletes local file
  Future<bool> deleteLocalFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
