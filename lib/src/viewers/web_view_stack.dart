/// STRUCTURE
///  [OPEN WEB-VIEW OF READ EPUB FROM URI]
import 'package:epub_comic_reader/src/viewers/web_view_full_screen.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewStack extends StatefulWidget {
  //  HTML STRING
  final String htmlString;
  //  DOCUMENT TITLE
  final String title;
  //  CURRENT THEME
  final AppBarTheme appBarTheme;
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
    this.dropDownItemList,
    this.dropDownButtonIcon,
    this.initialValue,
    this.changeAppBarTheme,
    this.onDropDownItemSelected,
    this.isLightMode

  });

  @override
  State<WebViewStack> createState() => _WebViewStackState();

} // END CLASS

class _WebViewStackState extends State<WebViewStack> {
  WebViewController? webViewController;

  var loadingPercent = 0;

  bool displayAppBar = true;
  bool displayFullScreenButton = true;
  String selectedItem = '';

  bool? isLightMode;
  String? initialValue;
  Widget? dropDownButtonIcon;
  List<String>? dropDownItemsList;
  AppBarTheme? appBarTheme;
  
  Function()? changeAppBar;
  Function(String? value)? onDropDownItemSelected;


  void setFullScreen() {
    setState(() {
      //  SET APP BAR
      if (displayAppBar) {
        displayAppBar = false;
      } else {
        displayAppBar = true;
      }// end if - else
    });
  } // end set full screen

  @override
  void initState() {
    // TODO: implement initState
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
      ..loadHtmlString(widget.htmlString);

    //  DEFAULT DROP DOWN BUTTON ASPECTS
    if (dropDownButtonIcon != null && dropDownItemsList != null && onDropDownItemSelected != null) {
      //  CHECK INITIAL VALUE
      if (initialValue != null) {
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
    if (isLightMode != null && changeAppBar != null) {
      //  SET IS LIGHT MODE
      isLightMode = widget.isLightMode;
      //  SET CHANGE APP BAR THEME
      changeAppBar = widget.changeAppBarTheme;
    } // end if statement

    //  REQUIRED VARIABLES
    appBarTheme = widget.appBarTheme;

  }//end init state

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: displayAppBar ? AppBar(
        title: Text(widget.title),
        backgroundColor: appBarTheme?.backgroundColor,
        actions: [
          //  DROP DOWN MENU
          onDropDownItemSelected != null 
              ? Expanded(
                  child:  Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, width/40, 0.0),
                      child: DropdownButton(
                          items: dropDownItemsList?.map((String item) {
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
                  )
          )
              : Container(),
          //  THEME SELECTION
          changeAppBar != null
              ? Expanded(
                  child: IconButton(
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
                      icon: isLightMode!
                          ? Icon(Icons.light_mode_outlined)
                          : Icon(Icons.dark_mode_outlined)
                  )
          )
              : Container(),
        ],
      ) : null,
      body: GestureDetector(
        onTap: () {
          setFullScreen();
        },
        child: Stack(
          children: [
            WebViewWidget(controller: webViewController!),
            if (loadingPercent < 100)
              LinearProgressIndicator(
                value: loadingPercent/100.0,
              ),
          ],
        ),
      ),
    );
  }
}

