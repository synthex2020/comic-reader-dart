
# Dart Epub Comic Reader

A package to read epub files, primarily based of the epub books used by Black Valley Comics. This was forked from the epubx package that can be found on pub.dev 


## Deployment

To use the package we first must call an instance of the package.

### Basic Usage 
```dart
import 'package:epub_comic_reader/epubx.dart' as reader;

return FutureBuilder<Widget>(
    future: epub.EpubViewManager(
        ebookUri: 'https-link-to-epub-file',
        title: 'String title',
        appBarTheme: AppBarTheme(),
        //  nullable 
        isLightMode: true,
        //  nullable
        changeAppBarTheme: () {
            //  SOME FUNCTION 
        },
        //  nullable 
        dropDownItemList: <String>[],
        //  nullable 
        dropDownButtonIcon: Icon(Icons.chosen_icon),
        //  nullable 
        initialValue: 'Initial Value',
        //  nullable 
        onDropDownItemSelected: (String? string) {
            //  SOME FUNCTION 
        }
    ).renderEbookReader(true) ,
    builder: (context, snapshot) {
        if (snapshot.hasData) {
            return snapshot.data;
        }else{
            return CircularProgressIndicator();
        } // end if-else 
    }  // end future builder 
);
```
renderEbookReader(boolean: orientation) 
- Vertical - True 
- Horizontal - False 

Please note. If functions for the drop down button are declared the items list must not be empty. 


## Authors

- [Mthandazo Edwin Siziba](https://www.github.com/octokatherine)
- [Tehillah Kangamba](https://github.com/TehillahK)







