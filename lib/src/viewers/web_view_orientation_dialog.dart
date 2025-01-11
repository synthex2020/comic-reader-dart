import 'package:epub_comic_reader/epub_comic_reader.dart';
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

    return AlertDialog.adaptive(
        backgroundColor: Colors.grey,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: height/6,
              width: width/3,
              child: isVertical
                  ? Icon(Icons.stay_primary_portrait, color: Colors.black, size: width/4,)
                  : Icon(Icons.stay_primary_landscape, color: Colors.black, size: width/4,),
            )
          ],
        ));
  }
}
