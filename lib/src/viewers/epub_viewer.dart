import 'dart:convert';
import 'dart:io';
import 'package:epub_comic_reader/src/utils/orientation_utils.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:epub_comic_reader/src/utils/tutorial_utility.dart';
import 'package:http/http.dart' as http;
import 'package:epub_comic_reader/epub_comic_reader.dart' as epub;
import 'package:flutter/material.dart';
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
    this.onDropDownItemSelected,
  });

  //  APP BAR TITLE GLOBAL KEY
  GlobalKey appBarTitleKey = GlobalKey();
  //  APP BAR ACTION BUTTON THEME GLOBAL KEY
  GlobalKey appBarActionThemeKey = GlobalKey();
  //  APP BAR DROP DOWN BUTTON GLOBAL KEY
  GlobalKey appBarDropDownKey = GlobalKey();
  //  APP BAR ORIENTATION BUTTON GLOBAL KEY
  GlobalKey orientationButtonKey = GlobalKey();
  //  APP BAR FULL SCREEN GLOBAL KEY
  GlobalKey screenKey = GlobalKey();

  //  TUTORIAL - TITLES AND DESCRIPTIONS
  String issueTitle = 'The Issue\'s title';
  String issueDescription = 'This is where you will always find the name of whatever it is you are reading';
  String themeTitle = 'Theme button switch';
  String themeDescription = 'Switch between themes here, primarily affects the application bar';
  String dropDownTitle = 'Change language here';
  String dropDownDescription = 'Change to a language of your own choosing from the options presented';
  String orientationTitle = 'Orientation Button';
  String orientationDescription = 'This button allows you to switch between a vertical reader and a horizontal one. '
      'Press down on the screen for a few seconds toggle the button ';
  String screenTitle = 'Full Screen';
  String screenDescription = 'Double tap the screen to toggle between full screen';

  //  EPUB BOOK REFERENCE
  EpubBookRef? epubBookRef;

  //  CURRENT HTML STRING
  String? currentHtmlString;

  //  SAVE EPUB FILE AS HTML TO RENDER
  Future<String> saveHtmlFile (String htmlString) async {
    try {
      // Get the application's document directory
      final directory = await getApplicationDocumentsDirectory();

      // Create a specific folder for caching EPUB files
      final epubHtml = Directory('${directory.path}/epub_html');
      if (!await epubHtml.exists()) {
        await epubHtml.create(recursive: true);
      }

      // Define the file path
      final filePath = '${epubHtml.path}/$title.html';

      // Check if the file already exists
      final file = File(filePath);
      if (!await file.exists()) {
        // Save the file if it doesn't exist
        file.writeAsStringSync(htmlString);
      }
      //  CLEAR UP MEMORY
      epubBookRef!.closeBook();
      //  ENSURE GC INIT
      return filePath;
    } catch (error) {
      debugPrint(error.toString());
      throw Exception(error);
    }
  } // end save html file

  Future<String> overwriteHtmlFile (String htmlString) async {
    // Get the application's document directory
    final directory = await getApplicationDocumentsDirectory();

    // Create a specific folder for caching EPUB files
    final epubHtml = Directory('${directory.path}/epub_html');
    if (!await epubHtml.exists()) {
      await epubHtml.create(recursive: true);
    }

    // Define the file path
    final filePath = '${epubHtml.path}/$title.html';

    final file = File(filePath);
      // Save the file if it doesn't exist
    file.writeAsStringSync(htmlString);

    //  CLEAR UP MEMORY
    epubBookRef!.closeBook();
    //  ENSURE GC INIT
    return filePath;
  }
  //  SWITCH ORIENTATION
  Future<String> changeToHorizontal () async {
    //  CONVERT HTML STRING
    var result = OrientationUtils.horizontalStringSummon(currentHtmlString!);
    //  SAVE HTML STRING TO LOCAL
    return await overwriteHtmlFile(result);
  } // end change to horizontal

  Future<String> changeToVertical () async {
    //  CONVERT HTML STRING
    var result = OrientationUtils.verticalStringSummon(currentHtmlString!);
    //  SAVE HTML STRING TO LOCAL
    return await overwriteHtmlFile(result);
  } // end change to vertical

  //  set tutorial properties
  void setTutorialProperties(
      String titleLeadingAction,
      String descriptionLeadingAction,
      String titleOrientationAction,
      String descriptionOrientationAction,
      String titleScreenAction,
      String descriptionScreen,{
          String? titleThemeAction,
          String? descriptionThemeAction,
          String? titleDropdownAction,
          String? descriptionDropdownAction
      }
      ) {
    //  SET PROPERTIES THAT ARE NOT NULLABLE
    issueTitle = titleLeadingAction;
    issueDescription = descriptionLeadingAction;
    orientationTitle = titleOrientationAction;
    orientationDescription = descriptionOrientationAction;
    screenTitle = titleScreenAction;
    screenDescription = descriptionScreen;

    //  SET NULLABLE PROPERTIES
    themeTitle = titleThemeAction ?? themeTitle;
    themeDescription = descriptionThemeAction ?? themeDescription;
    dropDownTitle = titleDropdownAction ?? dropDownTitle;
    dropDownDescription = descriptionDropdownAction ?? dropDownDescription;
  } // end set tutorial properties

  //  set global keys
  void setGlobalKeys(
      GlobalKey appBar, GlobalKey themeButton,
      GlobalKey dropDown, GlobalKey orientation,
      GlobalKey screen
      ) {
    appBarTitleKey = appBar;
    appBarActionThemeKey = themeButton;
    appBarDropDownKey = dropDown;
    orientationButtonKey = orientation;
    screenKey = screen;
  } // end set global keys

  //  save epub file to local user storage
  Future<String> saveEpubToLocalStorage(List<int> bytes, String filename) async {
    // Get the application's document directory
    final directory = await getApplicationDocumentsDirectory();

    // Create a specific folder for caching EPUB files
    final epubCacheFolder = Directory('${directory.path}/epub_cache');
    if (!await epubCacheFolder.exists()) {
      await epubCacheFolder.create(recursive: true);
    }

    // Define the file path
    final filePath = '${epubCacheFolder.path}/$filename';

    // Check if the file already exists
    final file = File(filePath);
    if (!await file.exists()) {
      // Save the file if it doesn't exist
      await file.writeAsBytes(bytes);
    }

    return filePath;
  } // end save epub to local storage

  //  render Ebook
  Future<Widget>  renderEbookReader(bool defaultOrientation) async {
    Widget widget;
    if (defaultOrientation) {
      //  RETURN VERTICAL
      widget =  await buildWidgetBuilderDefault();
    }else{
      //  RETURN HORIZONTAL
      widget =  await buildWidgetBuilderHorizontal();
    }// end if-else

    return widget;
  } // end render Ebook reader
  //  fetch book
  Future<EpubBookRef> fetchBook() async {
    //  FETCH THE EBOOK FROM URL
    final response = await http.get(Uri.parse(ebookUri));
    //  GET APPLICATION DOCUMENT DIRECTORY
    final directory = await getApplicationDocumentsDirectory();
    final epubCacheFolder = Directory('${directory.path}/epub_cache');
    final filePath = '${epubCacheFolder.path}/$title.epub';

    //  CHECK IF THE FILE ALREADY EXISTS
    final file_ = File(filePath);
    if (await file_.exists()) {
      //  WE OPEN THE FILE SINCE IT IS ALREADY THERE
      epubBookRef = await EpubReader.openBook(file_.readAsBytesSync());
      return epubBookRef!;
    }else{
      //  WE OPEN A FILE AND SAVE IT FROM THE URI
      if (response.statusCode == 200 ) {
        //  SAVE THE EPUB DATA LOCALLY
        final localFilePath = await saveEpubToLocalStorage(response.bodyBytes, '$title.epub');
        //  OPEN THE SAVED EPUB FILE
        final file = File(localFilePath);
        epubBookRef = await EpubReader.openBook(file.readAsBytesSync());
        return epubBookRef!;
      }else{
        throw Exception('Failed to load epub from url: $ebookUri');
      } // end if - else
    }// end if-else

  } // end fetch book

  //  epub widget builder
  Future<Widget> buildWidgetBuilderDefault () async {
   // READ THE BOOK AND RETURN THE WEB VIEW STACK
    //  READ BOOK AND GET HTML STRING
    var book = await fetchBook();
    var htmlString = await buildStringBuffer(book);
    //  SAVE THE HTML FILE TO USER MEMORY -  PERHAPS LOCAL STORAGE
    var htmlFile  = await saveHtmlFile(htmlString);
    //  UPDATE CURRENT HTML STRING
    currentHtmlString = htmlString;
    //  ADD GLOBAL KEYS FOR APP BAR
    return epub.WebViewStack(
      htmlString: htmlFile,
      title: title,
      appBarTheme: appBarTheme,
      defaultOrientation: true,
      isLightMode: isLightMode,
      changeAppBarTheme: changeAppBarTheme,
      dropDownItemList: dropDownItemList,
      dropDownButtonIcon: dropDownButtonIcon,
      initialValue: initialValue,
      onDropDownItemSelected: onDropDownItemSelected,
      readerInstance: this,
    );
  } // end build widget builder

  //  epub build horizontal scrolling widget
  Future<Widget> buildWidgetBuilderHorizontal () async {
    //  OPEN THE EPUB FILE
    var book = await fetchBook();
    //  GET THE HTML STRING
    var htmlString = await buildStringBufferForHorizontal(book);
    //  SAVE THE HTML FILE TO USER MEMORY -  PERHAPS LOCAL STORAGE
    var htmlFile = await saveHtmlFile(htmlString);
    //  SAVE TO CURRENT HTML STRING
    currentHtmlString = htmlString;
    //  RETURN THE RELEVANT WIDGET
    return epub.WebViewStack(
      htmlString: htmlFile,
      title: title,
      appBarTheme: appBarTheme,
      isLightMode: isLightMode,
      defaultOrientation: false,
      changeAppBarTheme: changeAppBarTheme,
      dropDownItemList: dropDownItemList,
      dropDownButtonIcon: dropDownButtonIcon,
      initialValue: initialValue,
      onDropDownItemSelected: onDropDownItemSelected,
      readerInstance: this,
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
      BuildContext context,{
        GlobalKey? titleKey,
        GlobalKey? orientationKey,
        GlobalKey? fullScreenKey,
        Function(TargetFocus target)? onClickTarget,
        Function(TargetFocus target, TapDownDetails tapDownDetails)? onClickTargetWithTapPosition,
        Function(TargetFocus target)? onClickOverlay,
        bool Function()? onSkip,
        Function()? onFinish
      }
      ) {

    var targetMap = <String,dynamic>{
      'index_0' : {
        'globalKey' : titleKey ?? appBarTitleKey,
        'identify' : 'Target 1',
        'title' : issueTitle,
        'titleTextStyle' : TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0
        ),
        'description' : issueDescription,
        'descriptionTextStyle' : TextStyle(color: Colors.white),
      },
      'index_3' : {
        'globalKey' : orientationKey ?? orientationButtonKey,
        'identify' : 'Target 2',
        'title' : orientationTitle,
        'titleTextStyle' : TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20.0
        ),
        'description' : orientationDescription,
        'descriptionTextStyle' : TextStyle(color: Colors.white)
      },
      'index_4' : {
        'globalKey' : fullScreenKey ?? screenKey,
        'identify' : 'Target 3',
        'title' : screenTitle,
        'titleTextStyle' : TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20.0
        ),
        'description' : screenDescription,
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
      BuildContext context,{
        GlobalKey? titleKey,
        GlobalKey? orientationKey,
        GlobalKey? fullScreenKey,
        GlobalKey? themeKey,
        GlobalKey? languageKey,
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
        'globalKey' : titleKey ?? appBarTitleKey,
        'identify' : 'Target 1',
        'title' : issueTitle,
        'titleTextStyle' : TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0
        ),
        'description' : issueDescription,
        'descriptionTextStyle' : TextStyle(color: Colors.white),
      },
      'index_1' : {
        'globalKey' : themeKey ?? appBarActionThemeKey,
        'identify' : 'Target 2',
        'title' : themeTitle,
        'titleTextStyle' : TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0
        ),
        'description' : themeDescription,
        'descriptionTextStyle' : TextStyle(color: Colors.white)
      },
      'index_2' : {
        'globalKey' : languageKey ?? appBarDropDownKey,
        'identify' : 'Target 3',
        'title' : dropDownTitle,
        'titleTextStyle' : TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0
        ),
        'description' : dropDownDescription,
        'descriptionTextStyling' : TextStyle(color: Colors.white)
      },
      'index_3': {
        'globalKey' : orientationKey ?? orientationButtonKey,
        'identify' : 'Target 4',
        'title' : orientationTitle,
        'titleTextStyle' : TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0
        ),
        'description' : orientationDescription,
        'descriptionTextStyle' : TextStyle(color: Colors.white)
      },
      'index_4' : {
        'globalKey' : fullScreenKey ?? screenKey,
        'identify' : 'Target 5',
        'title' : screenTitle,
        'titleTextStyle' : TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0
        ),
        'description' : screenDescription,
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
      Color shadowColor,
      Map<String,dynamic> indexLeading,
      Map<String,dynamic> indexOrientation,
      Map<String,dynamic> indexFullScreen,{
        Map<String,dynamic>? indexActionButtonOne,
        Map<String,dynamic>? indexActionButtonTwo,
        Function(TargetFocus target)? onClickTarget,
        Function(TargetFocus target, TapDownDetails tapDownDetails)? onClickTargetWithTapPosition,
        Function(TargetFocus target)? onClickOverlay,
        bool Function()? onSkip,
        Function()? onFinish
      }
      ) {

    //  INDEX TARGETS { title, titleTextStyle, description, descriptionTextStyle,}

    var targetMap = <String,dynamic>{
      //  INDEX LEADING
      'index_0' : {
        'globalKey' : appBarTitleKey,
        'identify' : 'Target 1',
        'title' : indexLeading['title'],
        'titleTextStyle' : indexLeading['titleTextStyle'],
        'description' : indexLeading['description'],
        'descriptionTextStyle' : indexLeading['descriptionTextStyle'],
      },
      //  ACTION BUTTON ONE
      'index_1' : {
        'globalKey' : appBarActionThemeKey,
        'identify' : 'Target 2',
        'title' : indexActionButtonOne?['title'] ?? themeTitle ,
        'titleTextStyle' : indexActionButtonOne?['titleTextStyle'] ?? TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0
        ),
        'description' : indexActionButtonOne?['description'] ?? themeDescription,
        'descriptionTextStyle' : indexActionButtonOne?['descriptionTextStyle'] ?? TextStyle(color: Colors.white)
      },
      //  ACTION BUTTON TWO
      'index_2' : {
        'globalKey' : appBarDropDownKey,
        'identify' : 'Target 3',
        'title' : indexActionButtonTwo?['title'] ?? dropDownTitle,
        'titleTextStyle' : indexActionButtonTwo?['titleTextStyle'] ?? TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0
        ),
        'description' : indexActionButtonTwo?['description'] ?? dropDownDescription,
        'descriptionTextStyling' : indexActionButtonTwo?['descriptionTextStyle'] ?? TextStyle(color: Colors.white)
      },
      //  INDEX ORIENTATION
      'index_3': {
        'globalKey' : orientationButtonKey,
        'identify' : 'Target 4',
        'title' : indexOrientation['title'],
        'titleTextStyle' : indexOrientation['titleTextStyle'],
        'description' : indexOrientation['description'],
        'descriptionTextStyle' : indexOrientation['descriptionTextStyle']
      },
      //  INDEX FULL SCREEN
      'index_4' : {
        'globalKey' : screenKey,
        'identify' : 'Target 5',
        'title' : indexFullScreen['title'],
        'titleTextStyle' : indexFullScreen['titleTextStyle'],
        'description' : indexFullScreen['description'],
        'descriptionTextStyle' : indexFullScreen['descriptionTextStyle']
      }
    };
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
