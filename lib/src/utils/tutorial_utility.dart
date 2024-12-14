
import 'package:flutter/cupertino.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

/// A CLASS TO CREATE A TUTORIAL FOR THE READER
/// IN GENERAL THERE ARE THREE TYPES INCLUDING OTHER
///   1. TUTORIAL FOR BASIC APP BAR
///   2. TUTORIAL FOR FULL APP BAR
///   3. TUTORIAL FOR CUSTOMIZED VIEWER

class TutorialUtility {
  //  KEY TARGETS MAP ( KEY VALUE ( KEY NAME ) , DESCRIPTION, TEXT-STYLE  )
  //  { "index_0" : {} , "index_1" : {}     }
  final Map<String,dynamic> keyTargetsMap;
  //  COLOR SHADOW
  final Color shadowColor;
  //  BUILD CONTEXT
  final BuildContext context;

  TutorialUtility({
    required this.keyTargetsMap,
    required this.shadowColor,
    required this.context
  });

  //  GET NEW TARGET LIST -> TAKES A NEW MAPPING
  void createNewTargetMap(Map<String,dynamic> map) {
    if (map.isNotEmpty){
      keyTargetsMap.clear();
      keyTargetsMap.addAll(map);
    }//end if
  } // end create new target map

  //  CREATE TARGETS LIST -> RETURNS LIST<TargetFocus>
  List<TargetFocus> createTargetList() {
    var result = <TargetFocus>[];
    var keys = keyTargetsMap.keys;

    for (var key in keys) {
      //  globalKey : GlobalKey Object
      //  identify : String ,
      //  title : String,
      //  titleTextStyle: TextStyle,
      //  descriptionTextStyle: TextStyle,
      //  description: String,
      var indexKey = keyTargetsMap[key];
      result.add(TargetFocus(
        identify: indexKey['identify'],
        keyTarget: indexKey['globalKey'],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    indexKey['title'],
                    style: indexKey['titleTextStyle'],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      indexKey['description'],
                      style: indexKey['descriptionTextStyle'],
                    ),
                  )
                ],
              ),
            )
          )
        ]
      ));
    }// end for loop

    return result;
  } // end create target list

  //  CREATE TUTORIAL -> RETURNS AN INSTANCE OF A TUTORIAL COACH MARK
  TutorialCoachMark createTutorial (
      List<TargetFocus> targets,{
        Function(TargetFocus target)? onClickTarget,
        Function(TargetFocus target, TapDownDetails tapDownDetails)? onClickTargetWithTapPosition,
        Function(TargetFocus target)? onClickOverlay,
        bool Function()? onSkip,
        Function()? onFinish
      }
      ) {
    return TutorialCoachMark(
      targets: targets,
      colorShadow: shadowColor,
      onClickTarget: onClickTarget != null
          ? (target) => onClickTarget(target)
          : (target) => print(target),
      onClickTargetWithTapPosition: onClickTargetWithTapPosition != null
          ? (target, tapDetails) => onClickTargetWithTapPosition(target, tapDetails)
          : (target, tapDetails) {
        print('target: $target');
        print('clicked at position local: ${tapDetails.localPosition}');
      },
      onClickOverlay: onClickOverlay != null
          ? (target) => onClickOverlay(target)
          : (target) => print(target),
      onSkip: onSkip ?? () {
        print('Skip');
        return true;
      },
      onFinish: onFinish ?? () => print('finish')
    );
  } // end create tutorial

  //  RUN TUTORIAL --> Takes an instance of TutorialCoachMark
  void runTutorial(TutorialCoachMark tutorial) {
    tutorial.show(context: context);
  }// end run tutorial


} // end class

