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
  //  INITIAL THEME
  final bool isDarkMode;
  final String epubUri;

  const EpubViewer({
    super.key, required this.isDarkMode,
    required this.epubUri
  });

  @override
  State<EpubViewer> createState() => _EpubViewerState();
} // end class

class _EpubViewerState extends State<EpubViewer> {

  //   SVG ICONS

  String nextPageIcon = '';
  String prevPageIcon = '';
  String languagesOptionsIcon = '';
  String landscapeIcon = '';
  String portraitIcon = '';

  //  EPUB - Current epub book
  EpubBookReference? book;

  //  change theme

  //  next page button

  //  previous page button

  //  change language button ( fetch new epub url with needed language)

  @override
  void initState() {
    // TODO: implement initState
    //  SET CURRENT EPUB BOOK
    book = EpubBookReference(ebookUri: widget.epubUri);
    //  SET NEXT AND PREV ISSUES
    //  DETERMINE THE THEME IN PLACE

    super.initState();
  } // end init

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boolean = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reader'),
        elevation: 8,
      ),
      backgroundColor: Colors.white,
      body: Container(
        height: height,
        width: width,
        child: InteractiveViewer(
            minScale: 0.6,
            maxScale: 1.6,
            boundaryMargin: const EdgeInsets.all(20),
            child: Padding(
          padding: EdgeInsets.all(width/80),
          child: SingleChildScrollView(
            child: FutureBuilder<EpubBookRef>(
                future: book!.fetchBook(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('An error occurred when fetching epub file. ${snapshot.error}');
                  }// end if

                  if (snapshot.hasData) {
                    return FutureBuilder<Widget>(
                        future: book!.buildWidgetBuilderDefault(snapshot.data) ,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error building with html widget ${snapshot.error}');
                          }//end if

                          if (snapshot.hasData) {
                            return snapshot.data ?? Container();
                          }else{
                            return CircularProgressIndicator();
                          }// end if-else
                        } // end builder
                    );
                  }else{
                    return CircularProgressIndicator();
                  }// end if-else
                }// end builder
            ),
          ),
        )
        ),
      ),
    );
  }//end build

} // end class


class EpubBookReference {
  /// This class holds our final viewer and is optimized for comic based epubs
  /// [TAKES ARGS - STRING - > EBOOK URI ]
  final String ebookUri;

  EpubBookReference({required this.ebookUri});

  //  PRIVATE METHODS

  //  fetch book
  Future<EpubBookRef> fetchBook() async {
    //  FETCH THE EBOOK FROM URL
    final response = await http.get(Uri.parse(ebookUri));

    if (response.statusCode == 200 ) {
      return EpubReader.openBook(response.bodyBytes);
    }else{
      throw Exception('Failed to load epub from url: $ebookUri');
    } // end if - else
  } // end fetch book
  //  epub widget builder
  Future<Widget> buildWidgetBuilderDefault (EpubBookRef? book) async {
    var cover = book!.readCover();
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

  //  epub widget builder for horizontal viewer ( Rendition object )
  // (http://epubjs.org/documentation/0.3/#rendition)
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

}// end class
