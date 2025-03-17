import 'dart:async';
import 'dart:io';

import 'package:epub_comic_reader/epub_comic_reader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';



class NetworkUtils {

  final String tempDirectory;
  bool _initialized = false;
  NetworkUtils({required this.tempDirectory});

  // Function to initialize flutter_downloader
  Future<void> _initializeDownloader() async {
    if (!_initialized) {
      try {
        await FlutterDownloader.initialize(debug: true);
        //await FlutterDownloader.registerCallback(downloadCallback);
        await DownloadUtils.initialize();
        _initialized = true;
      } catch (error) {
        debugPrint('[NETWORK UTILS] : ${error.toString()}');
      }// end try-catch
    }
  } // end method

  //  DOWNLOADING USING ANOTHER METHOD
  Future<String> _downloadEpubFile(String epubUri, String filename) async {
    //  DOWNLOAD FILE
    var filePath = '$tempDirectory/$filename';

    await DownloadUtils.downloadEPUB(epubUri, filename);
    //  ENSURE WRITING
    await Future.delayed(Duration(seconds: 5));

    return await filePath;
  } // end download epub file

  Future<String> downloadEpubFile(String epubUri, String filename) async {
    await _initializeDownloader();
    return await _downloadEpubFile(epubUri, filename);
  }

} // end class