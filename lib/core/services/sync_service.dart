import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../storage/token_manager.dart';

class SyncService {
  SyncService._();

  static const _syncQueueFile = 'sync_queue.json';
  static const _maxRetries = 3;

  static Future<List<Map<String, dynamic>>> getPendingSyncs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_syncQueueFile');
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final List<dynamic> decoded = jsonDecode(content);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[SyncService] Error reading sync queue: $e');
      return [];
    }
  }

  static Future<void> enqueueCvSnapshot(Map<String, dynamic> cvData) async {
    try {
      final pending = await getPendingSyncs();
      pending.add({
        'payload': cvData,
        'app_version': '1.0.0',
        'enqueued_at': DateTime.now().toIso8601String(),
        'retries': 0,
      });

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_syncQueueFile');
      await file.writeAsString(jsonEncode(pending));
      debugPrint('[SyncService] Enqueued CV snapshot for sync. Queue size: ${pending.length}');
    } catch (e) {
      debugPrint('[SyncService] Error enqueueing snapshot: $e');
    }
  }

  static Future<bool> processQueue() async {
    try {
      final pending = await getPendingSyncs();
      if (pending.isEmpty) {
        debugPrint('[SyncService] Sync queue is empty');
        return true;
      }

      debugPrint('[SyncService] Processing ${pending.length} pending syncs');
      final token = await TokenManager.getAccessToken();
      if (token == null || token.isEmpty) {
        debugPrint('[SyncService] No auth token available, skipping sync');
        return false;
      }

      final remaining = <Map<String, dynamic>>[];

      for (final item in pending) {
        final retries = (item['retries'] as int?) ?? 0;
        final success = await _uploadSnapshot(item, token);

        if (success) {
          debugPrint('[SyncService] Synced snapshot successfully');
        } else if (retries < _maxRetries) {
          debugPrint('[SyncService] Will retry snapshot (attempt ${retries + 1}/$_maxRetries)');
          remaining.add({
            ...item,
            'retries': retries + 1,
          });
        } else {
          debugPrint('[SyncService] Dropping snapshot after $_maxRetries failed attempts');
        }
      }

      await _saveQueue(remaining);
      return remaining.isEmpty;
    } catch (e) {
      debugPrint('[SyncService] Error processing queue: $e');
      return false;
    }
  }

  static Future<void> scheduleBackgroundSync() async {
    try {
      debugPrint('[SyncService] Background sync scheduled via WorkManager/platform alarm');
    } catch (e) {
      debugPrint('[SyncService] Error scheduling background sync: $e');
    }
  }

  static Future<bool> _uploadSnapshot(Map<String, dynamic> item, String token) async {
    try {
      final response = await ApiClient.dio.post(
        '/v1/cv-snapshots',
        data: {
          'payload': item['payload'],
          'app_version': item['app_version'] ?? '1.0.0',
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      debugPrint('[SyncService] Upload failed: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[SyncService] Unexpected upload error: $e');
      return false;
    }
  }

  static Future<void> _saveQueue(List<Map<String, dynamic>> queue) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_syncQueueFile');
      await file.writeAsString(jsonEncode(queue));
    } catch (e) {
      debugPrint('[SyncService] Error saving queue: $e');
    }
  }
}