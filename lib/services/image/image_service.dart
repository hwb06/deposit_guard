import 'dart:io';

import 'package:deposit_guard/core/utils/app_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';


/// Picks photos, compresses them and stores them in a private app folder.
/// The database keeps only the file name; use [fileFor] to resolve it.
class ImageService {
  ImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  static const String _folder = 'issue_photos';
  static const double _maxSide = 1600;
  static const int _quality = 80;

  final ImagePicker _picker;
  late final Directory _directory;

  Future<void> init() async {
    final docs = await getApplicationDocumentsDirectory();
    _directory = Directory(p.join(docs.path, _folder));
    if (!await _directory.exists()) {
      await _directory.create(recursive: true);
    }
  }

  File fileFor(String name) => File(p.join(_directory.path, name));

  /// Returns the stored file name, or null if the user cancelled.
  Future<String?> pick(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      imageQuality: _quality,
    );
    if (picked == null) return null;

    final extension = p.extension(picked.path);
    final name =
        '${AppUtils.generateId()}${extension.isEmpty ? '.jpg' : extension}';
    await File(picked.path).copy(fileFor(name).path);
    return name;
  }

  Future<void> delete(String? name) async {
    if (name == null) return;
    final file = fileFor(name);
    if (await file.exists()) await file.delete();
  }
}