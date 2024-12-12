import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

//  HAVE A SLIVER APP BAR HIDE ON TAP

class WebViewFullScreen extends StatefulWidget {
  final String htmlString;
  final WebViewController controller;

  const WebViewFullScreen({
    super.key,
    required this.htmlString,
    required this.controller
  });

  @override
  State<WebViewFullScreen> createState() => _WebViewFullScreenState();
}

class _WebViewFullScreenState extends State<WebViewFullScreen> {
  bool screenState = true;
  WebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    //  LOAD HTML
    webViewController = widget.controller;
  } // end init


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          //  WEB VIEWER
          WebViewWidget(controller: webViewController!)
        ],
      ),
    );
  } // end build context
}
