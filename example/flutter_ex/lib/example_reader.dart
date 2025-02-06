import 'package:flutter/material.dart';
import 'package:epub_comic_reader/epub_comic_reader.dart';

class ExampleReader extends StatefulWidget {
  const ExampleReader({super.key});

  @override
  State<ExampleReader> createState() => _ExampleReaderState();
}

class _ExampleReaderState extends State<ExampleReader> {
  EpubViewManager? manager;

  @override
  void initState () {
    super.initState();

    //  SET UP VIEW MANAGER
    manager = EpubViewManager(
        ebookUri: 'https://zfzqwolxrejrzidhmsai.supabase.co/storage/v1/object/public/pages/books/clr4hw6ud00054kp5aya14svi.epub',
        title: 'Testing Epub Reader - Comic Book Reader',
        appBarTheme: AppBarTheme(),
        isLightMode: true,
        changeAppBarTheme: null,
        dropDownItemList: <String>['One', 'Two', 'Three'],
        dropDownButtonIcon: null,
        initialValue: 'One',
        onDropDownItemSelected: null
    );
    //  RUN TUTORIAL AFTER BUILD RENDERING IS COMPLETE
    //  RUN TUTORIAL WITH PERSONAL MESSAGES
    manager?.setTutorialProperties(
        'titleLeadingAction',
        'descriptionLeadingAction',
        'titleOrientationAction',
        'descriptionOrientationAction',
        'titleScreenAction',
        'descriptionScreen'
    );
    //  RUN CUSTOM TUTORIAL

    // Future.delayed(Duration(seconds: 3), () => manager?.runCustomTutorial(
    //     context,
    //     Colors.redAccent,
    //     {
    //       'title' : 'title',
    //       'titleTextStyle' : TextStyle(
    //           fontWeight: FontWeight.bold,
    //           color: Colors.white,
    //           fontSize: 20.0
    //       ),
    //       'description' : 'description',
    //       'descriptionTextStyle' : TextStyle(
    //           color: Colors.white,
    //       )
    //     },
    //     {
    //       'title' : 'title',
    //       'titleTextStyle' : TextStyle(
    //           fontWeight: FontWeight.bold,
    //           color: Colors.white,
    //           fontSize: 20.0
    //       ),
    //       'description' : 'description',
    //       'descriptionTextStyle' : TextStyle(
    //         color: Colors.white,
    //       )
    //     },
    //     {
    //       'title' : 'title',
    //       'titleTextStyle' : TextStyle(
    //           fontWeight: FontWeight.bold,
    //           color: Colors.white,
    //           fontSize: 20.0
    //       ),
    //       'description' : 'description',
    //       'descriptionTextStyle' : TextStyle(
    //         color: Colors.white,
    //       )
    //     }
    // ));

  }// end init state

  @override
  void dispose() {
    super.dispose();
    //  CLEAR APPLICATION MEMORY
    manager?.closeReader();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
        future: manager?.renderEbookReader(true),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()),);
          } // end if

          if (snapshot.hasData) {
            return snapshot.data!;
          }else{
            return Center(child: CircularProgressIndicator(),);
          }// end if-else
        }
    );
  }
}
