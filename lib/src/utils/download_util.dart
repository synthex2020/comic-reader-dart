import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  IsolateNameServer.lookupPortByName('downloader_send_port')?.send([id, status, progress]);
} // end download callback


class DownloadUtils {
  static final ReceivePort _port = ReceivePort();
  static String? _localPath;

  static Future<void> initialize() async {
    _bindBackgroundIsolate();
    try {
      await FlutterDownloader.registerCallback(downloadCallback, step: 1);
    }catch (error) {
      debugPrint('[DOWNLOAD UTILS][WARNING] : Call back is likely already registered : ${error.toString()}');
    }// end try-catch d

    var permissionGranted = await _checkPermission();
    if (permissionGranted) {
      await _prepareSaveDir();
    }
  } // end init

  static void _bindBackgroundIsolate() {
    var isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
    if (!isSuccess) {
      IsolateNameServer.removePortNameMapping('downloader_send_port');
      _bindBackgroundIsolate();
    }
    _port.listen((dynamic data) {
      final taskId = (data as List<dynamic>)[0] as String;
      final status = DownloadTaskStatus.fromInt(data[1] as int);
      final progress = data[2] as int;
      print('Download ($taskId) status: $status, progress: $progress%');

      // Free the isolate when download is complete or failed
      if (status == DownloadTaskStatus.complete || status == DownloadTaskStatus.failed) {
        _unBindBackgroundIsolate();
      }
    });
  } // end background isolate binding

  static void _unBindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  } // end unbind background isolate

  static Future<bool> _checkPermission() async {
    if (Platform.isIOS) return true;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt > 28) return true; // No permission needed

      final status = await Permission.storage.status;
      if (status.isGranted) return true;

      return await Permission.storage.request().isGranted;
    }

    return false;
  } // end check permissions

  static Future<void> _prepareSaveDir() async {
    final dir = await getApplicationCacheDirectory();
    _localPath = dir.path;
  } // end prepare save dir

  static Future<void> downloadEPUB(String epubUrl, String filename) async {
    if (_localPath == null) await _prepareSaveDir();

    final taskId = await FlutterDownloader.enqueue(
      url: epubUrl,
      savedDir: _localPath!,
      fileName: filename,
      saveInPublicStorage: false,
      openFileFromNotification: false,
      showNotification: false,
    );
    print('Download started with taskId: $taskId');
  } // end download epub
}// end class