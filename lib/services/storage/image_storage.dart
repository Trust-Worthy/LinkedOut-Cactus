import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageStorage {
  // Save bytes to a file in app documents under 'avatars' and return the absolute path
  static Future<String> saveAvatar(Uint8List bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory(p.join(dir.path, 'avatars'));
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }
    final filePath = p.join(avatarsDir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return filePath;
  }

  static Future<void> deleteFileIfExists(String? path) async {
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // ignore
    }
  }
}
