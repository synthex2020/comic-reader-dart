import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as image;
import 'package:epubx/epubx.dart' as epub;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'epub_reader.dart' as reader;
import 'epub_reader.dart';
import 'ref_entities/epub_book_ref.dart';

//  A Zoomable stateful widget - can change between chapters, languages, volumes
class EpubViewer extends StatefulWidget {
  final EpubBook book;
  //  THE LIST OF ISSUES THE BOOK HAS THAT IS FOR NEXT ISSUE AND PREV ISSUE
  final List<String> issues;
  //  INITIAL THEME
  final bool isDarkMode;


  const EpubViewer({
    super.key, required this.book, required this.issues,
    required this.isDarkMode
  });

  @override
  State<EpubViewer> createState() => _EpubViewerState();
} // end class

class _EpubViewerState extends State<EpubViewer> {

  //  EPUB - Current epub book

  //  EPUB URI - Next issue

  //  EPUB URI - Prev issue

  //  change theme

  //  next issue button ( takes epub url )

  //  previous issue button ( takes epub url )

  //  change language button ( fetch new epub url with needed language)

  @override
  void initState() {
    // TODO: implement initState
    //  SET CURRENT EPUB BOOK
    //  SET NEXT AND PREV ISSUES
    //  DETERMINE THE THEME IN PLACE
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
} // end class


class EpubBook {
  /// This class holds our final viewer and is optimized for comic based epubs
  /// [TAKES ARGS - STRING - > EBOOK URI ]
  final String ebookUri;

  EpubBook({required this.ebookUri});

//  PRIVATE METHODS

  //  fetch book
  Future<EpubBookRef> fetchBook(String url) async {
    //  FETCH THE EBOOK FROM URL
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200 ) {
      return EpubReader.openBook(response.bodyBytes);
    }else{
      throw Exception('Failed to load epub from url: $url');
    } // end if - else
  } // end fetch book
  //  epub widget builder
  Future<Widget> buildWidgetBuilderDefault (EpubBookRef book) async {
    var cover = book.readCover();
    return Column(
      children: [
        //  COVER IF ONE IS THERE
        FutureBuilder<epub.Image?>(
          future: cover,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } // end if

            if (snapshot.hasData) {
              return Image.memory(
                Uint8List.fromList(image.encodePng(snapshot.data!)),
              );
            }else{
              return Container();
            }// end if-else
          },
        ),

        //  HTML CONTENT
        FutureBuilder<String>(
            future: buildStringBuffer(book),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('${snapshot.error}');
              } // end if

              if (snapshot.hasData) {
                return HtmlWidget(
                  snapshot.data!,
                  renderMode: RenderMode.column,
                );
              }else{
                return const CircularProgressIndicator();
              }// end if-else
            }
        ),
      ],
    );
  } // end build widget builder

  //  epub widget builder for horizontal viewer

  //  build string buffer
  Future<String> buildStringBuffer(EpubBookRef epubBookRef) async {
    // START BUILDING HTML CONTENT
    final htmlBuffer = StringBuffer(
        '<html><body style="display: flex; flex-direction:column; align-items:center;>'
    );
    //  LOOPING THROUGH THE CONTENT
    final content = epubBookRef.Content;
    final images = content?.Images;

    //  EMBEDDING THE IMAGES
    if (images != null) {
      for (final imageEntry in images.entries) {
        final imageKey = imageEntry.key;
        final imageFileRef = imageEntry.value;

        //  READ BINARY DATA
        final imageData = await imageFileRef.readContentAsBytes();
        // Convert binary content to Base64
        final base64Data = base64Encode(imageData);
        final mimeType = imageFileRef.ContentMimeType ?? 'image/*';

        // Embed image in HTML
        htmlBuffer.writeln(
            '<img src="data:$mimeType;base64,$base64Data" alt="$imageKey" style="max-width: 100%; margin: 10px 0;" />');
      //end if

      }// end for loop
    }

    htmlBuffer.writeln('</body></html>');
    return htmlBuffer.toString();
  } // end build string buffer

//  PUBLIC METHODS

  //  change orientation

}// end class
