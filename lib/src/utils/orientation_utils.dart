import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// THIS CLASS IS MEANT TO ASSIST IN CHANGING ORIENTATION THROUGH
/// CLASS SPECIFIC METHODS

class OrientationUtils {
  static String horizontalMarker =
      '<html lang="en">'
      '<head>'
      '<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes, maximum-scale=5">'
      '<style>'
      'body { margin: 0; padding: 0; overflow: hidden; display: flex; flex-direction: row; touch-action: manipulation; }'
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
      '  margin: 0 0px !important;'
      '  object-fit: contain;'
      '  padding: 0px;'
      '}'
      '</style>'
      '</head>'
      '<body>'
      '<div class="horizontal-container">';
  static  String verticalMarker =
  '<html lang="en"><head><meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes, maximum-scale=5"><style>body { margin: 0; padding: 0; overflow: hidden; display: flex; flex-direction: column; height: 100vh; touch-action: manipulation;}.vertical-container {  display: flex;  flex-direction: column;  overflow-y: auto;  overflow-x: hidden;  width: 100%;  box-sizing: border-box;  padding: 0px !important;}.vertical-container img {  max-width: 100%;  margin-bottom: 0px;  object-fit: contain;}</style></head><body><div class="vertical-container">';

  //  FETCH HTML STRING HORIZONTAL
  static String horizontalStringSummon (String string) {
    var result = '';
    result = string.replaceAll(verticalMarker, horizontalMarker);
    return result;
  } // end horizontal string summon

  //  FETCH HTML STRING VERTICAL
  static String verticalStringSummon (String string) {
    var result = '';
    result = string.replaceAll(horizontalMarker, verticalMarker);
    return result;
  } // end vertical string summon


} // end class