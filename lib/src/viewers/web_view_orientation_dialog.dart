import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WebViewOrientationDialog extends StatefulWidget {
  final bool isVertical;
  const WebViewOrientationDialog({super.key, required this.isVertical});

  @override
  State<WebViewOrientationDialog> createState() => _WebViewOrientationDialogState();
}

class _WebViewOrientationDialogState extends State<WebViewOrientationDialog> {

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  } // end init state

  @override
  Widget build(BuildContext context) {
    bool isVertical = widget.isVertical;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String mobileLandscapeSvg = '''<svg
                                fill="none"
                                viewBox="0 0 ${width/2} ${width/2}"
                                stroke-width="1.5"
                                stroke="currentColor"
                                class="size-6"
                                version="1.1"
                                id="svg1"
                                width="${width/4}px"
                                height="${height/4}px"
                                xmlns="http://www.w3.org/2000/svg"
                                xmlns:svg="http://www.w3.org/2000/svg">
                                  <defs
                                    id="defs1" />
                                  <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    d="M 22.5,10.5 V 8.25 C 22.5,7.0073593 21.492641,6 20.25,6 H 3.75 C 2.507359,6 1.5,7.0073593 1.5,8.25 v 7.5 C 1.5,16.992641 2.507359,18 3.75,18 h 16.5 c 1.242641,0 2.25,-1.007359 2.25,-2.25 V 13.5 m 0,-3 H 21 V 11.957895 13.5 h 1.5 m 0,-3 v 3 m -18.75,-3 v 3"
                                    id="path1" />
                              </svg>''';
    String mobilePortraitSvg = '''
                              <svg 
                                xmlns="http://www.w3.org/2000/svg" 
                                fill="none" 
                                viewBox="0 0 ${width/2} ${width/2}" 
                                stroke-width="1.5" 
                                stroke="currentColor" 
                                class="size-6"
                                width="${width/4}px"
                                height="${height/4}px"
                                >
                                <path 
                                  stroke-linecap="round" 
                                  stroke-linejoin="round" 
                                  d="M10.5 1.5H8.25A2.25 2.25 0 0 0 6 3.75v16.5a2.25 2.25 0 0 0 2.25 2.25h7.5A2.25 2.25 0 0 0 18 20.25V3.75a2.25 2.25 0 0 0-2.25-2.25H13.5m-3 0V3h3V1.5m-3 0h3m-3 18.75h3" />
                              </svg>
                             ''';

    return AlertDialog.adaptive(
        backgroundColor: Colors.grey,
        content: Center(child: isVertical
            ? SvgPicture.string(
          mobilePortraitSvg,
        )
            : SvgPicture.string(mobileLandscapeSvg,)));
  }
}
