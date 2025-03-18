
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:epub_comic_reader/epub_comic_reader.dart';
import 'package:path_provider/path_provider.dart';

class StorageUtil {


  final int MAX_CACHE_SIZE_MB = 500; // 500MB max cache
  final int LARGE_FILE_THRESHOLD_MB = 100; // 100MB limit for cache

  var key;
  var iv;

  // Get cache directory
  Future<Directory> getCacheDirectory() async {
    return await getTemporaryDirectory();
  } // end get cache directory

  // Get persistent storage directory
  Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  } // end get documents directory

  // Check total cache size used
  Future<int> getCacheUsage() async {
    final dir = await getCacheDirectory();
    int totalSize = 0;
    for (var file in dir.listSync()) {
      if (file is File) {
        totalSize += await file.length();
      }
    }
    return totalSize;
  } // end get cache usage

  // Clear cache if storage is full
  Future<void> clearOldCache() async {
    final dir = await getCacheDirectory();
    final cacheUsage = await getCacheUsage();
    final maxCacheBytes = MAX_CACHE_SIZE_MB * 1024 * 1024;

    if (cacheUsage > maxCacheBytes) {
      for (var file in dir.listSync()) {
        if (file is File) {
          await file.delete();
        }
      }
    }
  } // end clear old cache

  // **Encrypt & Compress EPUB File Before Saving**
  Future<File> saveEncryptedCompressedEpub(String epubContent, String fileName, int fileSize) async {
    final fileSizeMB = fileSize / (1024 * 1024);

    // Choose storage location
    Directory targetDir;
    if (fileSizeMB > LARGE_FILE_THRESHOLD_MB) {
      targetDir = await getDocumentsDirectory(); // Persistent storage
    } else {
      targetDir = await getCacheDirectory(); // Cache storage
    }

    // Manage cache if needed
    if (fileSizeMB <= LARGE_FILE_THRESHOLD_MB) {
      await clearOldCache();
    }

    // Convert EPUB string to bytes
    List<int> epubBytes = epubContent.codeUnits;

    // Compress EPUB using ZIP
    final archive = Archive()
      ..addFile(ArchiveFile(fileName, epubBytes.length, epubBytes));
    final compressedData = ZipEncoder().encode(archive);

    // Encrypt compressed EPUB
    // Use a secure 32-byte key (change this in production!)
    // final keyBytes = sha256.convert(utf8.encode('nt5y75fLOB+SFrBgnACBH1kIVsqHERAWJxjP0zszk64=')).bytes;
    // key = encrypt.Key(Uint8List.fromList(keyBytes));
    // iv = encrypt.IV.fromLength(16); // Random IV
    //
    // final encrypter = encrypt.Encrypter(encrypt.AES(key));
    // final encryptedData = encrypter.encryptBytes(compressedData!, iv: iv).bytes;

    // Save encrypted EPUB
    final encryptedFile = File('${targetDir.path}/$fileName.html');
    await encryptedFile.writeAsBytes(compressedData!);

    return encryptedFile;
  } // end save encrypted file

  Future<bool> checkForExistingHtmlFiles(String fileName) async {
    //  POSSIBLE FILE LOCATIONS
    final cacheDirectory = await getApplicationCacheDirectory();
    final temporaryDirectory = await getTemporaryDirectory();
    final documentDirectory = await getApplicationDocumentsDirectory();

    //  LIST OF FILES TO LOOK THROUGH
    final possibilities = <File>[
      File('${cacheDirectory.path}/$fileName.enc'),
      File('${temporaryDirectory.path}/$fileName.enc'),
      File('${documentDirectory.path}/$fileName.enc'),
    ];

    //  FIND THE STORED FILE IF ITS THERE
    var resultant = false;
    for (var file in possibilities) {
      if (file.existsSync()) {
        resultant = true;
        break;
      } // end loop
    } // end for loop

    return resultant;
  } // end check for existing html files

  // **Decrypt & Decompress EPUB When Needed**
  Future<String> decryptDecompressEpub(String fileName, bool orientation) async {
    //  CHECK KEY
    // if (key == null) {
    //   // Use a secure 32-byte key (change this in production!)
    //   final keyBytes = sha256.convert(utf8.encode('nt5y75fLOB+SFrBgnACBH1kIVsqHERAWJxjP0zszk64=')).bytes;
    //   key = encrypt.Key(Uint8List.fromList(keyBytes));
    //   iv = encrypt.IV.fromLength(16); // Random IV
    // }

    //  POSSIBLE FILE LOCATIONS 
    final cacheDirectory = await getApplicationCacheDirectory();
    final temporaryDirectory = await getTemporaryDirectory();
    final documentDirectory = await getApplicationDocumentsDirectory();
    
    //  LIST OF FILES TO LOOK THROUGH 
    final possibilities = <File>[
      File('${cacheDirectory.path}/$fileName.html'),
      File('${temporaryDirectory.path}/$fileName.html'),
      File('${documentDirectory.path}/$fileName.html'),
    ];
    
    //  FIND THE STORED FILE IF ITS THERE 
    File? encryptedFile;
    for (var file in possibilities) {
      if (file.existsSync()) {
        encryptedFile = file;
        break;
      } // end loop
    } // end for loop

    //  AWAIT USED TO ENSURE ASYNC HAS A CHANCE TO CATCH UP
    if (await !encryptedFile!.existsSync()) {
      throw Exception('Encrypted EPUB not found');
    } // end if

    // Read encrypted data
    final encryptedBytes = await encryptedFile.readAsBytes();

    // Decrypt data
    // final encrypter = encrypt.Encrypter(encrypt.AES(key));
    // final decryptedData = encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);

    // Decompress EPUB
    final archive = ZipDecoder().decodeBytes(encryptedBytes);
    var htmlFile = File('${cacheDirectory.path}/temporary.html');

    for (var file in archive) {
      if (file.isFile) {
        var string = String.fromCharCodes(file.content as List<int>);
        var finalString = '';
        //  CHECK ORIENTATION
        if (orientation) {
          //  VERTICAL
          finalString = OrientationUtils.verticalStringSummon(string);
        }else {
          //  HORIZONTAL
          finalString = OrientationUtils.horizontalStringSummon(string);
        }// end if-else
        await htmlFile.writeAsString(finalString);
        return htmlFile.path;
      }
    }
    throw Exception('Decryption or decompression failed');
  } // end decrypt and compress

  // Get file size before downloading
  Future<int> getFileSize(String url) async {
    final request = await HttpClient().headUrl(Uri.parse(url));
    final response = await request.close();
    return response.contentLength;
  } // end get file size before downloading

  // Delete all cache files manually
  Future<void> clearCacheManually() async {
    final dir = await getCacheDirectory();
    for (var file in dir.listSync()) {
      if (file is File) {
        await file.delete();
      }
    }
  } // end delete cache files manually

} // end class

