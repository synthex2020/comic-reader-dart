/// STRUCTURE
///  [OPEN WEB-VIEW OF READ EPUB FROM URI]
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewStack extends StatefulWidget {
  final String htmlString;

  const WebViewStack({
    super.key,
    required this.htmlString,
  });

  @override
  State<WebViewStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  WebViewController? webViewController;

  var loadingPercent = 0;

  @override
  void initState() {
    // TODO: implement initState
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

  }//end init state

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        WebViewWidget(controller: webViewController!),
        if (loadingPercent < 100)
          LinearProgressIndicator(
            value: loadingPercent/100.0,
          )
      ],
    );
  }
}

