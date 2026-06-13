import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  /// Unified download function for both CV and Cover Letter.
  /// Downloads a file from [url] or uses [existingBytes], saves it to the
  /// public 'Downloads/QuickCV Pro' folder, and returns the saved file path.
  static Future<String> downloadAndSaveFile({
    String? url,
    Uint8List? existingBytes,
    required String baseFileName,
    String fileExtension = 'pdf',
    String? bearerToken,
    String subDirectory = 'QuickCV Pro',
  }) async {
    try {
      // 1. Fetch or use existing bytes
      Uint8List bytes;
      if (existingBytes != null) {
        bytes = existingBytes;
      } else if (url != null) {
        // Use proper authenticated call that handles 401 and refresh
        final response = await AuthService.authenticatedGetRaw(url);

        if (response.statusCode == 200) {
          bytes = response.bodyBytes;
        } else {
          throw 'Server returned status code ${response.statusCode}';
        }
      } else {
        throw 'No valid document source provided';
      }

      if (bytes.isEmpty) {
        throw 'Downloaded file is empty';
      }

      // 2. Handle permissions & get target directory
      Directory? targetDir;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        // On Android <= 29, we explicitly need storage permission to write to public folders.
        if (androidInfo.version.sdkInt <= 29) {
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
            if (!status.isGranted) {
              throw 'Storage permission is required to save files';
            }
          }
        }
        
        // Define public Downloads path
        targetDir = Directory('/storage/emulated/0/Download/$subDirectory');
      } else {
        // Fallback for non-Android platforms (like iOS)
        final dir = await getApplicationDocumentsDirectory();
        targetDir = Directory('${dir.path}/$subDirectory');
      }

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // 3. Ensure no duplicate filename
      File file = File('${targetDir.path}/$baseFileName.$fileExtension');
      int counter = 1;

      while (await file.exists()) {
        file = File('${targetDir.path}/${baseFileName}_$counter.$fileExtension');
        counter++;
      }

      // 4. Save file
      await file.writeAsBytes(bytes, flush: true);
      print("File successfully saved at: ${file.path}");

      return file.path;

    } catch (e) {
      print("DownloadService Error: $e");
      rethrow;
    }
  }
}
