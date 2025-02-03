/// STRUCTURE
///  [OPEN WEB-VIEW OF READ EPUB FROM URI]
import 'package:epub_comic_reader/epub_comic_reader.dart' as reader;
import 'package:epub_comic_reader/src/viewers/web_view_orientation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewStack extends StatefulWidget {
  //  HTML STRING
  final String htmlString;
  //  DOCUMENT TITLE
  final String title;
  //  CURRENT THEME
  final AppBarTheme appBarTheme;
  //  DEFAULT ORIENTATION
  final bool defaultOrientation;
  //  AN INSTANCE OF READER
  final reader.EpubViewManager readerInstance;
  //  IS-LIGHT MODE
  final bool? isLightMode;
  //  CHANGE THEME FUNCTION - NULLABLE
  final Function()? changeAppBarTheme;
  //  DROP DOWN BUTTON LIST - NULLABLE
  final List<String>? dropDownItemList;
  //  DROP DOWN BUTTON ICON - NULLABLE
  final Widget? dropDownButtonIcon;
  //  DROP DOWN INITIAL VALUE - NULLABLE
  final String? initialValue;
  //  DROP DOWN ON-SELECTED FUNCTION - NULLABLE
  final Function(String? value)? onDropDownItemSelected;

  const WebViewStack({
    super.key,
    required this.htmlString,
    required this.title,
    required this.appBarTheme,
    required this.defaultOrientation,
    required this.readerInstance,
    this.dropDownItemList,
    this.dropDownButtonIcon,
    this.initialValue,
    this.changeAppBarTheme,
    this.onDropDownItemSelected,
    this.isLightMode,
  });

  @override
  State<WebViewStack> createState() => _WebViewStackState();

} // END CLASS

class _WebViewStackState extends State<WebViewStack> {
  WebViewController? webViewController;

  var loadingPercent = 0;

  bool displayAppBar = true;
  bool displayFullScreenButton = true;
  bool isScrolling = false;
  bool isVertical = true;
  bool showFloatingActionButton = true;
  String selectedItem = '';

  GlobalKey titleKey = GlobalKey();
  GlobalKey themeKey = GlobalKey();
  GlobalKey dropDownKey = GlobalKey();
  GlobalKey orientationKey = GlobalKey();
  GlobalKey screenKey = GlobalKey();
  

  bool? isLightMode;
  String? initialValue;
  Widget? dropDownButtonIcon;
  bool? defaultOrientation;
  String? currentHtmlFile;
  List<String>? dropDownItemsList;
  AppBarTheme? appBarTheme;

  
  Function()? changeAppBar;
  Function(String? value)? onDropDownItemSelected;

  String mobileLandscapeSvg = '''
                              <svg
                                fill="none"
                                viewBox="0 0 24 24"
                                stroke-width="1.5"
                                stroke="currentColor"
                                class="size-6"
                                version="1.1"
                                id="svg1"
                                width="576"
                                height="576"
                                xmlns="http://www.w3.org/2000/svg"
                                xmlns:svg="http://www.w3.org/2000/svg">
                                  <defs
                                    id="defs1" />
                                  <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    d="M 22.5,10.5 V 8.25 C 22.5,7.0073593 21.492641,6 20.25,6 H 3.75 C 2.507359,6 1.5,7.0073593 1.5,8.25 v 7.5 C 1.5,16.992641 2.507359,18 3.75,18 h 16.5 c 1.242641,0 2.25,-1.007359 2.25,-2.25 V 13.5 m 0,-3 H 21 V 11.957895 13.5 h 1.5 m 0,-3 v 3 m -18.75,-3 v 3"
                                    id="path1" />
                              </svg>

                              ''';
  String mobilePortraitSvg = '''
                              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 1.5H8.25A2.25 2.25 0 0 0 6 3.75v16.5a2.25 2.25 0 0 0 2.25 2.25h7.5A2.25 2.25 0 0 0 18 20.25V3.75a2.25 2.25 0 0 0-2.25-2.25H13.5m-3 0V3h3V1.5m-3 0h3m-3 18.75h3" />
                              </svg>
                             ''';
  String bookSvg = '''
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="size-6">
  <path d="M11.25 4.533A9.707 9.707 0 0 0 6 3a9.735 9.735 0 0 0-3.25.555.75.75 0 0 0-.5.707v14.25a.75.75 0 0 0 1 .707A8.237 8.237 0 0 1 6 18.75c1.995 0 3.823.707 5.25 1.886V4.533ZM12.75 20.636A8.214 8.214 0 0 1 18 18.75c.966 0 1.89.166 2.75.47a.75.75 0 0 0 1-.708V4.262a.75.75 0 0 0-.5-.707A9.735 9.735 0 0 0 18 3a9.707 9.707 0 0 0-5.25 1.533v16.103Z" />
</svg>
 ''';
  int characterLimit = 20;


  void setFullScreen() {
    setState(() {
      //  SET APP BAR
      if (displayAppBar) {
        displayAppBar = false;
        showFloatingActionButton = false;
      } else {
        displayAppBar = true;
      }// end if - else
    });
  } // end set full screen

  void switchOrientation () {
    if (isVertical){
      setState(() {
        isVertical = false;
        //  SET NEW ORIENTATION
        widget.readerInstance.changeToHorizontal().then((String result) {
          currentHtmlFile = result;
        }).whenComplete(() {
          webViewController?.loadFile(currentHtmlFile!);
        });
      });

    }else{
      setState(() {
        isVertical = true;
        widget.readerInstance.changeToVertical().then((String result) {
          currentHtmlFile = result;
        }).whenComplete(() {
          webViewController?.loadFile(currentHtmlFile!);
        });
      });
    }// end if - else
    webViewController?.reload();
    //  SHOW CASE CHANGE IN ORIENTATION TO THE USER
    showAdaptiveDialog(
        context: context,
        builder: (context) => WebViewOrientationDialog(
          isVertical: isVertical,
        )
    );
  } // end switch orientation

  void switchFloatingActionButton () {
    setState(() {
      if (showFloatingActionButton){
        showFloatingActionButton = false;
      }else{
        showFloatingActionButton = true;
      }// end if-else
    });
  } // end show floating action button

  bool checkSizeBasedOnActions () {
    bool result = false;

    if (onDropDownItemSelected == null ) {
      result = true;
    } // end if

    if (changeAppBar != null) {
      result = true;
    }// end if

    return result;
  } // end check size based on actions


  @override
  void initState() {
    //  implement initState
    //  THROW EXCEPTION ON LIGHT MODE BEING EMPTY WHEN APP BAR THEME CHANGE IS NOT
    super.initState();
    //  LOAD THE HTML STRING HERE
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
              onProgress: (int progress) {
                //  UPDATE A LOADING BAR
                setState(() {
                  loadingPercent = progress;
                });
              },
              onPageStarted: (String url) {
                setState(() {
                  loadingPercent = 0;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  loadingPercent = 100;
                });
              },
              onHttpError: (HttpResponseError error) {
                print('There was an http error, $error');
              },
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith('https://www.youtube.com/')) {
                  return NavigationDecision.prevent;
                }else{
                  return NavigationDecision.navigate;
                }// end if - else
              } // end on navigation request
          ))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFile(currentHtmlFile ?? widget.htmlString)
      ..enableZoom(true);
    //  DEFAULT ORIENTATION
    isVertical = widget.defaultOrientation;
    //  DEFAULT DROP DOWN BUTTON ASPECTS
    if (widget.dropDownButtonIcon != null && widget.dropDownItemList != null && widget.onDropDownItemSelected != null) {
      //  CHECK INITIAL VALUE
      if (widget.initialValue != null) {
        //  SET INITIAL VALUE
        initialValue = widget.initialValue;
        //  SET DROP DOWN BUTTON ICON
        dropDownButtonIcon = widget.dropDownButtonIcon;
        //  SET DROP DOWN FUNCTION
        onDropDownItemSelected = widget.onDropDownItemSelected;
        //  SET DROP DOWN ITEMS LIST
        if (widget.dropDownItemList!.isNotEmpty){
          dropDownItemsList?.addAll(widget.dropDownItemList ?? []);
        }else{
          throw Exception('DropDownItemsList cannot be an empty list.');
        }//end if - else
      }else{
        throw Exception('Initial Value cannot be empty.');
      }// end if-else
    }// end if statement

    //  DEFAULT THEMING ASPECTS
    if (widget.isLightMode != null && widget.changeAppBarTheme != null) {
      //  SET IS LIGHT MODE
      isLightMode = widget.isLightMode;
      //  SET CHANGE APP BAR THEME
      changeAppBar = widget.changeAppBarTheme;
    } // end if statement

    //  REQUIRED VARIABLES
    appBarTheme = widget.appBarTheme;

    //  DROP DOWN VALUE
    selectedItem = widget.initialValue ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //  SET UP GLOBAL KEYS
      widget.readerInstance.setGlobalKeys(
          titleKey,
          themeKey,
          dropDownKey,
          orientationKey,
          screenKey
      );

      print(titleKey.currentContext.toString());
      print(widget.readerInstance.appBarTitleKey.currentContext.toString());
    });
  }//end init state

  @override
  void dispose() {
    // implement dispose
    super.dispose();
    //  CLEAR CACHE AND LOCAL STORAGE
    webViewController?.clearCache();
    webViewController?.clearLocalStorage();
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    //  FLOATING BUTTON - SHOW ON LONG PRESS - TODO: PLACE IN A CHARACTER LIMIT AFTER THAT ELLIPSES
    return Scaffold(
      appBar: displayAppBar ? AppBar(
        title: SizedBox(width: checkSizeBasedOnActions() ?  width/2 : width/6, child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.centerLeft,
          child:  Text(
            widget.title.length > characterLimit 
                ? '${widget.title.substring(0, (characterLimit -1))}...'
                : '${widget.title}',
            key: titleKey,
          ),
        ),),
        shape: appBarTheme?.shape,
        centerTitle: appBarTheme?.centerTitle,
        elevation: appBarTheme?.elevation,
        systemOverlayStyle: appBarTheme?.systemOverlayStyle,
        toolbarTextStyle: appBarTheme?.toolbarTextStyle,
        titleTextStyle: appBarTheme?.titleTextStyle,
        titleSpacing: appBarTheme?.titleSpacing,
        iconTheme: appBarTheme?.iconTheme,
        actionsIconTheme: appBarTheme?.actionsIconTheme,
        toolbarHeight: appBarTheme?.toolbarHeight,
        shadowColor: appBarTheme?.shadowColor,
        surfaceTintColor: appBarTheme?.surfaceTintColor,
        backgroundColor: appBarTheme?.backgroundColor,
        foregroundColor: appBarTheme?.foregroundColor,
        actions: [
          //  THEME SELECTION
          changeAppBar != null
              ? IconButton(
              onPressed: () {
                setState(() {
                  //  CHANGE IS LIGHT MODE
                  if (isLightMode!){
                    isLightMode = false;
                  }else{
                    isLightMode = true;
                  }// end if - else
                  //  RUN CHANGE APP BAR METHOD
                  changeAppBar!();
                });
              },
              key: themeKey,
              icon: isLightMode!
                  ? Icon(Icons.light_mode_outlined)
                  : Icon(Icons.dark_mode_outlined)
          )
              : Container(),

          //  DROP DOWN MENU
          onDropDownItemSelected != null 
              ? Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, width/40, 0.0),
                  child: Column(
                    key: dropDownKey,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //  ICON
                      Expanded(
                        flex: 5 ,
                        child: DropdownButton(
                        items: ['One','Two','Three'].map((String item) {
                          return DropdownMenuItem(
                              value: item,
                              child: Text(item)
                          );
                        }).toList(),
                        onChanged: (String? language) {
                          setState(() {
                            selectedItem = language ?? 'ERROR';
                            onDropDownItemSelected!(language);
                          });
                        },
                        icon: dropDownButtonIcon,
                        underline: const SizedBox(),

                      ),
                      ),
                      //  VALUE
                      Expanded(
                          flex: 3,
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(width/10, 0.0, 0.0, 0.0),
                              child: Text(selectedItem),
                          )
                      )

                    ],
                  )
              )
              : Container(),
        ],
      ) : null,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollStartNotification){
                  setState(() {
                    isScrolling = true;
                  });
                }else if (notification is ScrollEndNotification) {
                  setState(() {
                    isScrolling = false;
                  });
                } // end if - else
                //  CONSUME THE NOTIFICATION
                return true;
              },
              child: WebViewWidget(controller: webViewController!)
          ),
          // Transparent GestureDetector overlay
          GestureDetector(
            behavior: HitTestBehavior.translucent, // Ensures taps pass through transparent areas
            onDoubleTap: () {
              if (!isScrolling) {
                setFullScreen();
              }
            },
            onLongPress: () => switchFloatingActionButton(),
          ),
          if (loadingPercent < 100)
            Positioned.fill(child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.fromLTRB(width/90, 0.0, width/90, 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //  SVG ICON
                    SvgPicture.string(bookSvg, height: height/8, width: width/8,),
                    //  PERCENT VALUE
                    Text('${loadingPercent.toStringAsFixed(1)}%', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    ),),
                    SizedBox(height: height/100,),
                    //  LOADING BAR
                    LinearProgressIndicator(
                      value: loadingPercent/100.0,
                      minHeight: height/90,
                    )
                  ],
                ),
              ),
            )),
          Positioned.fill(
              child: Align(
            alignment: Alignment.center,
            child: Container(
              key: screenKey,
              width: width/5,
              height: height/8,
            ),
          ))
        ],
      ),
      floatingActionButton: Offstage(
        offstage: !showFloatingActionButton,
        child: FloatingActionButton(
          key: orientationKey,
          onPressed: () => switchOrientation(),
          child: isVertical
              ? SvgPicture.string(mobilePortraitSvg, )
              : SvgPicture.string(mobileLandscapeSvg,) ,

        ),
      ),
    );
  }
}

