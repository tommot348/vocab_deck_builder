import 'dart:convert';
import 'dart:io';
import 'package:shared_storage/shared_storage.dart' as storage;
import 'package:path_provider/path_provider.dart';
import 'config.dart';

class IOHelper {
  static const appname = "VocabDeckBuilder";

  static Future<bool> fileExists(String filename) async {
    var path = await getApplicationDocumentsDirectory();
    var file = File("${path.path}/$appname/$filename");
    return file.exists();
  }

  static Future deleteFile(String filename) async {
    var path = await getApplicationDocumentsDirectory();
    var file = File("${path.path}/$appname/$filename");
    await file.delete();
  }

  static Future saveFile(String filename, String data) async {
    var path = await getApplicationDocumentsDirectory();
    var file = File("${path.path}/$appname/$filename");
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    file.writeAsString(data, mode: FileMode.write);
  }

  static Future<String> loadFile(String filename) async {
    var path = await getApplicationDocumentsDirectory();
    var file = File("${path.path}/$appname/$filename");
    return await file.readAsString();
  }

  static Future<Uri?> _openBasePath() async {
    Uri? result;
    try {
      result = await storage.openDocumentTree();
    } catch (e) {
      //not needed
    }
    return result;
  }

  static Future<Uri?> _getBaseUri() async {
    Uri? base;
    var basePath = Config().basePath;
    if (basePath == "") {
      var bp = await _openBasePath();
      if (bp != null) {
        base = bp;
        Config().basePath = bp.toString();
      }
    } else {
      base = Uri.parse(basePath);
    }
    return base;
  }

  static Future<bool> isBasePathWritable() async {
    Uri? base = await _getBaseUri();
    if (base == null) {
      return false;
    }
    return await storage.canWrite(base) ?? false;
  }

  static Future<bool> saveFileExternal(String filename, String data,
      [String mimeType = "text/csv"]) async {
    Uri? base = await _getBaseUri();
    if (base == null) {
      return false;
    }
    var utf8data = const Utf8Encoder().convert(data);
    var nameParts = filename.split("/");
    if (nameParts.length > 1) {
      filename = nameParts.last;
    }
    var file = await storage.child(base, filename);
    var exists = await file?.exists() ?? false;
    if (!exists || file == null) {
      file = await storage.createFileAsBytes(
        base,
        mimeType: mimeType,
        displayName: filename,
        bytes: utf8data,
      );
      return file != null;
    } else {
      return await file.writeToFileAsBytes(bytes: utf8data) ?? false;
    }
  }

  static Future deleteFileExternal(String filename) async {
    var base = await _getBaseUri();
    if (base == null) {
      return;
    }
    var file = await storage.child(base, filename);
    await file?.delete();
  }
}
