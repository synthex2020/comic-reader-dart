import 'dart:convert';

import 'package:epub_comic_reader/src/utils/tutorial_utility.dart';
import 'package:http/http.dart' as http;
import 'package:epub_comic_reader/epub_comic_reader.dart' as epub;
import 'package:flutter/material.dart';
import 'package:quiver/pattern.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../epub_reader.dart';
import '../ref_entities/epub_book_ref.dart';

//  A Zoomable stateful widget - can change between chapters, languages, volumes

class EpubViewManager {

  /// This class holds our final viewer and is optimized for comic based epubs
  /// TAKES ARGS ->
  /// [
  /// EBOOK URI (String) ,
  /// TITLE (String), APP BAR THEME (AppBarTheme),
  /// DEFAULT ORIENTATION (BOOL),
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

  //  render Ebook
  Future<Widget>  renderEbookReader(bool defaultOrientation) async {
    if (defaultOrientation) {
      //  RETURN VERTICAL
      return await buildWidgetBuilderDefault();
    }else{
      //  RETURN HORIZONTAL
      return await buildWidgetBuilderHorizontal();
    }// end if-else
  } // end render Ebook reader
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
    //  ADD GLOBAL KEYS FOR APP BAR
    return epub.WebViewStack(
      htmlString: htmlString,
      title: title,
      appBarTheme: appBarTheme,
      defaultOrientation: true,
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
      defaultOrientation: false,
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
            'body { margin: 0; padding: 0; overflow: hidden; display: flex; flex-direction: column; height: 100vh; }'
            '.vertical-container {'
            '  display: flex;'
            '  flex-direction: column;' // Vertical arrangement of elements
            '  overflow-y: auto;' // Enable vertical scrolling
            '  overflow-x: hidden;' // Disable horizontal scrolling
            '  width: 100%;'
            '  box-sizing: border-box;'
            '  padding: 10px;' // Add padding for spacing
            '}'
            '.vertical-container img {'
            '  max-width: 100%;' // Scale images to fit the container width
            '  margin-bottom: 10px;' // Add spacing between images
            '  object-fit: contain;' // Maintain image aspect ratio
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

  //  run basic tutorial - app bar has just the title
  void runBasicTutorial (
      BuildContext context,
      GlobalKey titleKey,
      GlobalKey orientationKey,
      GlobalKey fullScreenKey,{
        Function(TargetFocus target)? onClickTarget,
        Function(TargetFocus target, TapDownDetails tapDownDetails)? onClickTargetWithTapPosition,
        Function(TargetFocus target)? onClickOverlay,
        bool Function()? onSkip,
        Function()? onFinish
      }
      ) {

    var targetMap = <String,dynamic>{
      'index_0' : {
        'globalKey' : titleKey,
        'identify' : 'Target 1',
        'title' : 'The Issue\'s title',
        'titleTextStyle' : TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0
        ),
        'description' : 'This is where you will always find the name of whatever it is you are reading',
        'descriptionTextStyle' : TextStyle(color: Colors.white),
      },
      'index_1' : {
        'globalKey' : orientationKey,
        'identify' : 'Target 2',
        'title' : 'Orientation Button',
        'titleTextStyle' : TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20.0
        ),
        'description' : 'This button allows you to switch between a vertical reader and a horizontal one. '
            'Press down on the screen for a few seconds toggle the button ',
        'descriptionTextStyle' : TextStyle(color: Colors.white)
      },
      'index_3' : {
        'globalKey' : fullScreenKey,
        'identify' : 'Target 3',
        'title' : 'Full Screen',
        'titleTextStyle' : TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20.0
        ),
        'description' : 'Double tap the screen to toggle between full screen',
        'descriptionTextStyle' : TextStyle(color: Colors.white)
      }
    };

    //  CREATE TUTORIAL UTILITY
    var utility = TutorialUtility(
        keyTargetsMap: targetMap,
        shadowColor: Colors.black,
        context: context
    );
    //  CREATE THE LIST
    var targetList = utility.createTargetList();
    //  CREATE TUTORIAL
    var tutorial = utility.createTutorial(
        targetList,
        onClickTarget: onClickTarget,
        onClickTargetWithTapPosition: onClickTargetWithTapPosition,
        onClickOverlay: onClickOverlay,
        onSkip: onSkip,
        onFinish: onFinish
    );
    //  RUN TUTORIAL
    utility.runTutorial(tutorial);
  } // end run basic tutorial

  //  run basic type 2 tutorial - app bar has theme + language selection
  void runBasicType2Tutorial (
      BuildContext context,
      GlobalKey titleKey,
      GlobalKey orientationKey,
      GlobalKey fullScreenKey,
      GlobalKey themeKey,
      GlobalKey languageKey, {
        Function(TargetFocus target)? onClickTarget,
        Function(TargetFocus target, TapDownDetails tapDownDetails)? onClickTargetWithTapPosition,
        Function(TargetFocus target)? onClickOverlay,
        bool Function()? onSkip,
        Function()? onFinish
      }
      ) {

    //  { "index_0" : {} , "index_1" : {}     }
    //  globalKey : GlobalKey Object
    //  identify : String ,
    //  title : String,
    //  titleTextStyle: TextStyle,
    //  descriptionTextStyle: TextStyle,
    //  description: String,

    var targetMap = <String,dynamic>{
      'index_0' : {
        'globalKey' : titleKey,
        'identify' : 'Target 1',
        'title' : 'The Issue\'s title',
        'titleTextStyle' : TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0
        ),
        'description' : 'This is where you will always find the name of whatever it is you are reading',
        'descriptionTextStyle' : TextStyle(color: Colors.white),
      },
      'index_1' : {
        'globalKey' : themeKey,
        'identify' : 'Target 2',
        'title' : 'Theme button switch',
        'titleTextStyle' : TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0
        ),
        'description' : 'Switch between themes here, primarily affects the application bar',
        'descriptionTextStyle' : TextStyle(color: Colors.white)
      },
      'index_2' : {
        'globalKey' : languageKey,
        'identify' : 'Target 3',
        'title' : 'Change language here',
        'titleTextStyle' : TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0
        ),
        'description' : 'Change to a language of your own choosing from the options presented',
        'descriptionTextStyling' : TextStyle(color: Colors.white)
      },
      'index_3': {
        'globalKey' : orientationKey,
        'identify' : 'Target 4',
        'title' : 'Orientation Button',
        'titleTextStyle' : TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0
        ),
        'description' : 'This button allows you to switch between a vertical reader and a horizontal one. '
            'Press down on the screen for a few seconds toggle the button ',
        'descriptionTextStyle' : TextStyle(color: Colors.white)
      },
      'index_4' : {
        'globalKey' : fullScreenKey,
        'identify' : 'Target 5',
        'title' : 'Full Screen',
        'titleTextStyle' : TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0
        ),
        'description' : 'Double tap the screen to toggle between full screen',
        'descriptionTextStyle' : TextStyle(color: Colors.white)
      }
    };
    //  CREATE TUTORIAL UTILITY
    var utility = TutorialUtility(
        keyTargetsMap: targetMap,
        shadowColor: Colors.black,
        context: context
    );
    //  CREATE THE LIST
    var targetList = utility.createTargetList();
    //  CREATE TUTORIAL
    var tutorial = utility.createTutorial(
        targetList,
        onClickTarget: onClickTarget,
        onClickTargetWithTapPosition: onClickTargetWithTapPosition,
        onClickOverlay: onClickOverlay,
        onSkip: onSkip,
        onFinish: onFinish
    );
    //  RUN TUTORIAL
    utility.runTutorial(tutorial);
  } // end run basic type 2 tutorials

  //  run custom tutorial
  void runCustomTutorial (
      BuildContext context,
      GlobalKey titleKey,
      GlobalKey themeKey,
      GlobalKey dropDownKey,
      GlobalKey orientationKey,
      GlobalKey fullScreenKey,
      Color shadowColor,
      Map<String,dynamic> targetMap,{
        Function(TargetFocus target)? onClickTarget,
        Function(TargetFocus target, TapDownDetails tapDownDetails)? onClickTargetWithTapPosition,
        Function(TargetFocus target)? onClickOverlay,
        bool Function()? onSkip,
        Function()? onFinish
      }
      ) {
    //  CREATE TUTORIAL UTILITY
    var utility = TutorialUtility(
        keyTargetsMap: targetMap,
        shadowColor: shadowColor,
        context: context
    );
    //  CREATE THE LIST
    var targetList = utility.createTargetList();
    //  CREATE TUTORIAL
    var tutorial = utility.createTutorial(
      targetList,
      onClickTarget: onClickTarget,
      onClickTargetWithTapPosition: onClickTargetWithTapPosition,
      onClickOverlay: onClickOverlay,
      onSkip: onSkip,
      onFinish: onFinish
    );
    //  RUN TUTORIAL
    utility.runTutorial(tutorial);
  } // end run custom tutorial



}// end class
