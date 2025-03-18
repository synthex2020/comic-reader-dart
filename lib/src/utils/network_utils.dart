import 'dart:async';
import 'package:dio/dio.dart';



class NetworkUtils {

  final String tempDirectory;
  int fileSize=0;

  final dio = Dio();

  NetworkUtils({required this.tempDirectory});

  FutureOr<List<int>> downloadEpubFile(String epubUri) async {
    //  USE DIO TO OBTAIN EPUB CONTENTS
    var response = await dio.get(epubUri, options: Options(
      responseType: ResponseType.bytes
    ));

    if (response.statusCode == 200 && response.data != null) {
      var responseData = await response.data!;
      fileSize = responseData.length;
      return responseData;
    } else {
      throw Exception('Failed to download EPUB. Status code: ${response.statusCode}');
    } // end if-else
  } // end download epub file

} // end class