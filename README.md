
# Dart Epub Comic Reader

A package to read epub files, primarily based of the epub books used by Black Valley Comics. This was forked from the epubx package that can be found on pub.dev 

This package uses the package tutorial coach mark to create a tutorial to explain to the user how to use the reader. 

![Screenshot](https://firebasestorage.googleapis.com/v0/b/siziba-dev.appspot.com/o/package%20examples%2F01.png?alt=media&token=89271f5e-9cb0-4d5f-a355-e3a59f29f82e)

![ScreenshotSecond](https://firebasestorage.googleapis.com/v0/b/siziba-dev.appspot.com/o/package%20examples%2F2.png?alt=media&token=a4271091-d0e2-4038-9e0f-f3ef43512461)

![VideoExample](https://firebasestorage.googleapis.com/v0/b/siziba-dev.appspot.com/o/package%20examples%2FUntitled%20video%20-%20Made%20with%20Clipchamp.mp4?alt=media&token=1b79de0a-782b-4efb-8f1b-633825d5a79b)

## Authors

- [Mthandazo Edwin Siziba](https://www.github.com/octokatherine)
- [Tehillah Kangamba](https://github.com/TehillahK)


## Deployment

To use the package we first must call an instance of the package.

renderEbookReader(boolean: orientation) 
- Vertical - True 
- Horizontal - False 

Please note. If functions for the drop down button are declared the items list must not be empty. 
### Basic Usage 
```dart
import 'package:epub_comic_reader/epub_comic_reader.dart';

EpubViewManager? manager;

@override
void initState () {
    manager = EpubViewManager(
        ebookUri: 'https//link-to-epubfile.epub',
        title: 'Testing 001',
        appBarTheme: AppBarTheme(),
        isLightMode: true,
        changeAppBarTheme: () {
          print('Change app bar theme');
        },
        dropDownItemList: <String>['One', 'Two', 'Three'],
        dropDownButtonIcon: Icon(Icons.settings),
        initialValue: 'One',
        onDropDownItemSelected: (String? string) {
          print('Item selected ${string.toString()}');
        }
    );
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

```

### Basic Usage with default tutorial 

```dart
import 'package:epub_comic_reader/epub_comic_reader.dart';

EpubViewManager? manager;

@override
void initState () {
    manager = EpubViewManager(
        ebookUri: 'https//link-to-epubfile.epub',
        title: 'Testing 001',
        appBarTheme: AppBarTheme(),
        isLightMode: true,
        changeAppBarTheme: () {
          print('Change app bar theme');
        },
        dropDownItemList: <String>['One', 'Two', 'Three'],
        dropDownButtonIcon: Icon(Icons.settings),
        initialValue: 'One',
        onDropDownItemSelected: (String? string) {
          print('Item selected ${string.toString()}');
        }
    );

    //  USE THIS TO CUSTOMIZE THE DISPLAYED TEXT IN SET TUTORIAL 
    manager?.setTutorialProperties(
        'titleLeadingAction',
        'descriptionLeadingAction',
        'titleOrientationAction',
        'descriptionOrientationAction',
        'titleScreenAction',
        'descriptionScreen'
    );

    Future.delayed(Duration(seconds: 3) () => manager?.runBasicTutorial(context));

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
```









## Features

- Customizable Application Bar 
- Customizable tutorials
- Landscape and Potrait orientation toggle 

### Customizing the Application Bar 
The application Bar is configured upon the creation of an instance of EpubViewManager. Hence any customizations, for now, must be completed at the time when we create an instance of EpubViewManager. 

Please note, the following are consirdered to be nullable, however if you choose to utilize these variables, their dependecies cannot be null. 

```dart
import 'package:epub_comic_reader/epub_comic_reader.dart';

EpubViewManager? manager;

@override
void initState () {
    manager = EpubViewManager(
        ebookUri: 'https//link-to-epubfile.epub',
        //  STRING TITLE - LEADING WIDGET ON APP BAR 
        title: 'Testing 001',
        //  APP BAR THEME PROPERTIES AND STATE MANAGMENT 
        appBarTheme: AppBarTheme(),
        //  INITIAL LIGHT MODE 
        isLightMode: true,
        //  NULLABLE FUNCTION HANDLES WHAT HAPPEANS WHEN THEME BUTTON IS TOGGLED 
        changeAppBarTheme: () {
          print('Change app bar theme');
        },
        //  NULLABLE LIST OF ELEMENTS TO BE IN THE DROP DOWN BUTTON - (TRAILING WIDGET ON APP BAR )
        dropDownItemList: <String>['One', 'Two', 'Three'],
        //  NULLABLE ICON TO BE DISPLAYED ON DROP DOWN BUTTON 
        dropDownButtonIcon: Icon(Icons.settings),
        //  NULLABLE INITIAL VALUE TO BE DISPLAYED ON DROP DOWN BUTTON 
        initialValue: 'One',
        //  NULLABLE FUNCTION TO HANDLE WHEN AN OPTION IS SELECTED IN DROP DOWN 
        onDropDownItemSelected: (String? string) {
          print('Item selected ${string.toString()}');
        }
    );
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
```

### Customizing the tutorials 

There are mainly two ways to customize the tutorials. You can either specify the description and titles displayed in said tutorial or you can modify the color of the overlay as well as the titles and descriptions. 

Note, you can also choose between two types of basic tutorials, runBasicTutorial(context) or runBasicType2Tutorial(context). The difference between them being that the former caters for an app bar with only a leading widget rendered and the latter caters to an application bar with a fully rendered leading and trailing widgets, that is the "theme" button and "dropdown button" are present. 

```dart 
import 'package:epub_comic_reader/epub_comic_reader.dart';

EpubViewManager? manager;

@override
void initState () {
    manager = EpubViewManager(
        ebookUri: 'https//link-to-epubfile.epub',
        title: 'Testing 001',
        appBarTheme: AppBarTheme(),
        isLightMode: true,
        changeAppBarTheme: () {
          print('Change app bar theme');
        },
        dropDownItemList: <String>['One', 'Two', 'Three'],
        dropDownButtonIcon: Icon(Icons.settings),
        initialValue: 'One',
        onDropDownItemSelected: (String? string) {
          print('Item selected ${string.toString()}');
        }
    );
    //  SET THE TITLES AND DESCRIPTIONS NEEDED FOR TUTORIALS 
    manager?.setTutorialProperties(
        'titleLeadingAction',
        'descriptionLeadingAction',
        'titleOrientationAction',
        'descriptionOrientationAction',
        'titleScreenAction',
        'descriptionScreen'
    );
    //  RUNNING TUTORIAL AFTER ALL RELEVANT WIDGETS HAVE BEEN RENDERED 
    Future.delayed(Duration(seconds: 3), () => manager?.runBasicTutorial(context));
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
```


## Example

```dart
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
        ebookUri: 'https//some-link-to-some-epub-file.epub',
        title: 'Testing 001',
        appBarTheme: AppBarTheme(),
        isLightMode: true,
        changeAppBarTheme: () {
          print('Change app bar theme');
        },
        dropDownItemList: <String>['One', 'Two', 'Three'],
        dropDownButtonIcon: Icon(Icons.settings),
        initialValue: 'One',
        onDropDownItemSelected: (String? string) {
          print('Item selected ${string.toString()}');
        }
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

    Future.delayed(Duration(seconds: 3), () => manager?.runCustomTutorial(
        context,
        Colors.redAccent,
        {
          'title' : 'title',
          'titleTextStyle' : TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20.0
          ),
          'description' : 'description',
          'descriptionTextStyle' : TextStyle(
              color: Colors.white,
          )
        },
        {
          'title' : 'title',
          'titleTextStyle' : TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20.0
          ),
          'description' : 'description',
          'descriptionTextStyle' : TextStyle(
            color: Colors.white,
          )
        },
        {
          'title' : 'title',
          'titleTextStyle' : TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20.0
          ),
          'description' : 'description',
          'descriptionTextStyle' : TextStyle(
            color: Colors.white,
          )
        }
    ));

  }// end init state

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

```


## Appendix

Note. Some methods have the nullable options based of the type GlobalKey, it is advised to let them be null unless you wish to do something with state managment within the app bar itself, however, you should take note that the AppBar instance in the reader takes in your current BuildContext, adding it to your parent tree. 

| Function name  |  Function Parameters  | Function Description |
|:-----|:--------:|------:|
| void setTutorialProperties   |String titleLeadingAction, String descriptionLeadingAction, String titleOrientationAction, String descriptionOrientationAction, String titleScreenAction, String descriptionScreen,{ String? titleThemeAction, String? descriptionThemeAction, String? titleDropdownAction, String descriptionDropdownAction} | Allows you to set the titles and descriptions for any basicType tutorial, these become the default values even for nullable cases |
| void runBasicTutorial |  BuildContext context  |Renders tutorial that assumes that only the leading widget is present in the AppBar() |
| void runBasicType2Tutorial  | BuildContext context| Renders a tutorial that takes into account all the widgets on the app bar, the default assumes you have a theme button and a choose language drop down buttons as the trailing widgets in the AppBar() |
| void runCustomTutorial | BuildContext context, Color shadowColor, Map<String,dynamic> indexLeading, Map<String,dynamic> indexOrientation, Map<String,dynamic> indexFullScreen,{ Map<String,dynamic>? indexActionButtonOne, Map<String,dynamic>? indexActionButtonTwo, Function(TargetFocus target)? onClickTarget, Function(TargetFocus target, TapDownDetails tapDownDetails)? onClickTargetWithTapPosition, Function(TargetFocus target)? onClickOverlay, bool Function()? onSkip, Function()? onFinish } | Runs custom tutorial with specified colors and textstyles paired with chosen tutorial titles and descriptions |
| Future<Widget> renderEbookReader| bool defualtOrientation | Renders the contents of the reader based on the given oreientation, true for vertical and false for horizontal |
| Future<Widget> buildWidgetBuilderDefault| **void**| Renders the contents of the reader in the default orientation which is vertical, or Portrait |
| Future<Widget> buildWidgetBuilderHorizontal| **void** | Renders the contents of the reader in a horizontal layout  |

