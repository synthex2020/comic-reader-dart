
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:epub_comic_reader/epub_comic_reader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  IsolateNameServer.lookupPortByName('encryption_send_port')?.send([id, status, progress]);
} // end download callback

class EncryptionUtils {
  static final ReceivePort _port = ReceivePort();
  static String? _localPath;
  static bool _isListening = false;
  static bool _encryptionComplete = false;

  static Future<void> initialize() async {
    _bindBackgroundIsolate();
    try {
      await FlutterDownloader.registerCallback(downloadCallback, step: 1);
    }catch (error) {
      debugPrint('[ENCRYPTION UTILS][WARNING] : Call back is likely already registered : ${error.toString()}');
    }// end try-catch d

    var permissionGranted = await _checkPermission();
    if (permissionGranted) {
      await _prepareSaveDir();
    }
  } // end init

  static Future<void> _prepareSaveDir() async {
    final dir = await getApplicationCacheDirectory();
    _localPath = dir.path;
  } // end prepare save dir

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

  static void _bindBackgroundIsolate() {

    if (IsolateNameServer.lookupPortByName('encryption_send_port') != null) return;

    var isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'encryption_send_port',
    );
    if (!isSuccess) {
      IsolateNameServer.removePortNameMapping('encryption_send_port');
      _bindBackgroundIsolate();
    }
    if (!_isListening) {
      _isListening = true;
      _port.listen((dynamic data) {
        // final taskId = (data as List<dynamic>)[0] as String;
        // final status = DownloadTaskStatus.fromInt(data[1] as int);
        // final progress = data[2] as int;
        // print('Download ($taskId) status: $status, progress: $progress%');
        // Free the isolate when download is complete or failed
        if (_encryptionComplete) {
          print('Encryption complete');
          _unBindBackgroundIsolate();
        } // end if
      });
    } // end if
  } // end background isolate binding

  static void _unBindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('encryption_send_port');
    _port.close();
    _isListening = false;
  } // end unbind background isolate

  static Future<File> encryptAndSaveFile(String epubContent, String filename, int fileSize) async {
    if (_localPath == null) await _prepareSaveDir();

    var storage = StorageUtil();
    var encryptedFile = await storage.saveEncryptedCompressedEpub(epubContent, filename, fileSize);
    return encryptedFile;
  } // end download epub
}// end clas