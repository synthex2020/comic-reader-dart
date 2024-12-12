import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:epub_comic_reader/epubx.dart' as epub;
import 'package:flutter/material.dart';
import '../epub_reader.dart';
import '../ref_entities/epub_book_ref.dart';

//  A Zoomable stateful widget - can change between chapters, languages, volumes


//  TODO: RE-LOOK WEB VIEW INTEGRATION IN MAIN IMPLEMENTATION ON THE BASIS OF DISPLAYING A HTML STRING

class EpubViewManager {

  /// This class holds our final viewer and is optimized for comic based epubs
  /// TAKES ARGS ->
  /// [
  /// EBOOK URI (String) ,
  /// TITLE (String), APP BAR THEME (AppBarTheme),
  /// IS LIGHT MODE? (Bool), CHANGE APP BAR THEME? (Function()),
  /// DROP DOWN ITEM LIST? (List<String>), DROP DOWN BUTTON ICON? (Widget?),
  /// INITIAL VALUE? (String) , ON DROP DOWN ITEM SELECTED (Function(String? value)),
  /// ]

  //  EBOOK URI
  final String ebookUri;
  //  TITLE
  final String title;
  //  APP BAR THEME
  final AppBarTheme appBarTheme;
  //  IS LIGHT MODE
  final bool? isLightMode;
  //  CHANGE APP BAR
  final Function()? changeAppBarTheme;
  //  DROP DOWN ITEM LIST
  final List<String>? dropDownItemList;
  //  DROP DOWN BUTTON ICON
  final Widget? dropDownButtonIcon;
  //  INITIAL VALUE
  final String? initialValue;
  //  ON DROP DOWN ITEM SELECTED
  final Function(String? value)? onDropDownItemSelected;

  EpubViewManager({
    required this.ebookUri,
    required this.title,
    required this.appBarTheme,
    this.isLightMode,
    this.changeAppBarTheme,
    this.dropDownItemList,
    this.dropDownButtonIcon,
    this.initialValue,
    this.onDropDownItemSelected
  });

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
  Future<Widget> buildWidgetBuilderDefault () async {
   // READ THE BOOK AND RETURN THE WEB VIEW STACK
    //  READ BOOK AND GET HTML STRING
    var book = await fetchBook();
    var htmlString = await buildStringBuffer(book);

    return epub.WebViewStack(
      htmlString: htmlString,
      title: title,
      appBarTheme: appBarTheme,
      isLightMode: isLightMode,
      changeAppBarTheme: changeAppBarTheme,
      dropDownItemList: dropDownItemList,
      dropDownButtonIcon: dropDownButtonIcon,
      initialValue: initialValue,
      onDropDownItemSelected: onDropDownItemSelected,
    );
  } // end build widget builder

  //  epub build horizontal scrolling widget
  Future<Widget> buildWidgetBuilderHorizontal () async {
    //  OPEN THE EPUB FILE
    var book = await fetchBook();
    //  GET THE HTML STRING
    var htmlString = await buildStringBufferForHorizontal(book);
    //  RETURN THE RELEVANT WIDGET
    return epub.WebViewStack(
      htmlString: htmlString,
      title: title,
      appBarTheme: appBarTheme,
      isLightMode: isLightMode,
      changeAppBarTheme: changeAppBarTheme,
      dropDownItemList: dropDownItemList,
      dropDownButtonIcon: dropDownButtonIcon,
      initialValue: initialValue,
      onDropDownItemSelected: onDropDownItemSelected,
    );
  } // end build widget builder horizontal

  //  epub widget builder for horizontal viewer ( Rendition object )
  // (http://epubjs.org/documentation/0.3/#rendition)
  Future<String> buildStringBufferForHorizontal (EpubBookRef epubBookRef) async {
    final htmlBuffer = StringBuffer(
        '<html lang="en">'
            '<head>'
            '<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">'
            '<style>'
            'body { margin: 0; padding: 0; overflow: hidden; display: flex; flex-direction: column; }'
            '.horizontal-container {'
            '  display: flex;'
            '  flex-direction: row;'
            '  overflow-x: auto;'
            '  white-space: nowrap;'
            '  align-items: center;'
            '  height: 100vh;'
            '  box-sizing: border-box;'
            '}'
            '.horizontal-container img {'
            '  max-height: 100%;'
            '  margin: 0 10px;'
            '  object-fit: contain;'
            '}'
            '</style>'
            '</head>'
            '<body>'
            '<div class="horizontal-container">');

    // Loop through images and embed them
    final content = epubBookRef.Content;
    final images = content?.Images;

    if (images != null) {
      for (final imageEntry in images.entries) {
        final imageKey = imageEntry.key;
        final imageFileRef = imageEntry.value;

        // Read binary data
        final imageData = await imageFileRef.readContentAsBytes();
        final base64Data = base64Encode(imageData);
        final mimeType = imageFileRef.ContentMimeType ?? 'image/*';

        // Embed image in HTML
        htmlBuffer.writeln(
            '<img src="data:$mimeType;base64,$base64Data" alt="$imageKey" />');
      }
    }

    htmlBuffer.writeln('</div></body></html>');
    return htmlBuffer.toString();
  }// end method

  //  build string buffer
  Future<String> buildStringBuffer(EpubBookRef epubBookRef) async {
    // START BUILDING HTML CONTENT TODO: ADJUST FOR VERTICAL DIRECTION
    final htmlBuffer = StringBuffer(
        '<html lang="en">'
            '<head>'
            '<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">'
            '<style>'
            'body { margin: 0; padding: 0; overflow: hidden; display: flex; flex-direction: column; }'
            '.vertical-container {'
            '  display: flex;'
            '  flex-direction: col;'
            '  overflow-x: auto;'
            '  white-space: nowrap;'
            '  align-items: center;'
            '  height: 100vh;'
            '  box-sizing: border-box;'
            '}'
            '.vertical-container img {'
            '  max-height: 100%;'
            '  margin: 0 10px;'
            '  object-fit: contain;'
            '}'
            '</style>'
            '</head>'
            '<body>'
            '<div class="vertical-container">');
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

    htmlBuffer.writeln('</div></body></html>');
    return htmlBuffer.toString();
  } // end build string buffer

}// end class
