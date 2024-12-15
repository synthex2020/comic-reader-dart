import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:epub_comic_reader/epub_comic_reader.dart' as epub;
import 'package:image/image.dart' as image;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'example_reader.dart';

void main() => runApp(EpubWidget());

class EpubWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EpubState();
}

class EpubState extends State<EpubWidget> {
  Future<epub.EpubBookRef>? book;

  final _urlController = TextEditingController();

  void fetchBookButton() {
    setState(() {
      book = fetchBook(_urlController.text);
    });
  }

  void fetchBookPresets(String link) {
    setState(() {
      book = fetchBook(link);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fetch Epub Example",
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: ExampleReader(),
      )

    );
  }
}

Widget buildEpubWidget(epub.EpubBookRef book) {
  var chapters = book.getChapters();
  var cover = book.readCover();

  return Container(
      child: Column(
    children: <Widget>[
      Text(
        "Title",
        style: TextStyle(fontSize: 20.0),
      ),
      Text(
        book.Title!,
        style: TextStyle(fontSize: 15.0),
      ),
      Padding(
        padding: EdgeInsets.only(top: 15.0),
      ),
      Text(
        "Author",
        style: TextStyle(fontSize: 20.0),
      ),
      Text(
        book.Author!,
        style: TextStyle(fontSize: 15.0),
      ),
      Padding(
        padding: EdgeInsets.only(top: 15.0),
      ),
      FutureBuilder<List<epub.EpubChapterRef>>(
          future: chapters,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: <Widget>[
                  Text("Chapters", style: TextStyle(fontSize: 20.0)),
                  Text(
                    snapshot.data!.length.toString(),
                    style: TextStyle(fontSize: 15.0),
                  )
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Container();
          }),
      Padding(
        padding: EdgeInsets.only(top: 15.0),
      ),
      FutureBuilder<epub.Image?>(
        future: cover,
        builder: (context, AsyncSnapshot<epub.Image?> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                Text("Cover", style: TextStyle(fontSize: 20.0)),
                Image.memory(
                    Uint8List.fromList(image.encodePng(snapshot.data!))),
              ],
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Container();
        },
      ),
      FutureBuilder<String>(
          future: buildBlackValleyComicsContent(book),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('An error has occurred');
            }// end if

            if (snapshot.hasData) {
              return HtmlWidget(snapshot.data!, renderMode: RenderMode.column,);
            }else {
              return CircularProgressIndicator();
            }// end if-else
          } // end if-else
      ),
    ],
  ));
}

Future<List<String>> extractHtmlChapters(epub.EpubBookRef book) async {
  final chapters = await book.getChapters();
  return Future.wait(chapters.map((chapter) => chapter.readHtmlContent()));
} // end extract html chapters

Widget buildContentViewer (String htmlContent) {
  return HtmlWidget(
    htmlContent,
  );
}// end content viewer

Future<String> buildBlackValleyComicsContent(epub.EpubBookRef book) async {
  // START BUILDING HTML CONTENT
  final htmlBuffer = StringBuffer(
    '<html><body style="display: flex; flex-direction:column; align-items:center;>'
  );
  //  LOOPING THROUGH THE CONTENT
  final content = book?.Content;
  final images = content?.Images;

  //  EMBEDDING THE IMAGES
  if (images != null) {
    for (final imageEntry in images.entries) {
      final imageKey = imageEntry.key;
      final imageFileRef = await imageEntry.value;

      //  READ BINARY DATA
      final imageData = await imageFileRef.readContentAsBytes();
      if (imageData != null) {
        // Convert binary content to Base64
        final base64Data = base64Encode(imageData);
        final mimeType = imageFileRef.ContentMimeType ?? 'image/*';

        // Embed image in HTML
        htmlBuffer.writeln(
            '<img src="data:$mimeType;base64,$base64Data" alt="$imageKey" style="max-width: 100%; margin: 10px 0;" />');
      }//end if

    }// end for loop
  }

  htmlBuffer.writeln('</body></html>');
  return htmlBuffer.toString();
} // end function

// Needs a url to a valid url to an epub such as
// https://www.gutenberg.org/ebooks/11.epub.images
// or
// https://www.gutenberg.org/ebooks/19002.epub.images
Future<epub.EpubBookRef> fetchBook(String url) async {
  // Hard coded to Alice Adventures In Wonderland in Project Gutenberb
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the EPUB
    return epub.EpubReader.openBook(response.bodyBytes);
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load epub');
  }
}
