import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_constants.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/lesson_data.dart';
import 'package:french_app/provider/tts_provider.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class TableType extends StatefulWidget {
  final DocumentSnapshot snapshot;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final Function({required BuildContext buildContext}) goToBack;
  final LessonData lessonData;
  const TableType({required this.snapshot, required this.goToNext, required this.goToBack, required this.lessonData, super.key});

  @override
  State<TableType> createState() => _TwoColumnTableTypeState();
}

class _TwoColumnTableTypeState extends State<TableType> {
  late TextToSpeechProvider textToSpeechProvider;
  //6 for 2C 0r 7 for 5C
  List<Map>? data;
  List<Map>? newData;
  int subListStart = 0;
  int sublistEnd = 7;
  bool allShown = false;
  String filename = '';
  void nextLesson() {
    subListStart = subListStart + 7;
    sublistEnd = sublistEnd + 7;
    if ((data!.length - sublistEnd) <= 3) {
      //To show  all remaining items
      sublistEnd = data!.length;
    }
    if (!allShown) {
      if (subListStart < data!.length) {
        int safeStart = max(0, min(subListStart, data!.length - 1));
        int safeEnd = max(safeStart, min(sublistEnd, data!.length));
        setState(() {
          newData = data!.sublist(safeStart, safeEnd);
        });
        filename = 'Lesson${widget.lessonData.lessonIndex}_${widget.snapshot.id}_$subListStart$sublistEnd';
        textToSpeechProvider.playFullAudio(
            result: newData, lessonIndex: widget.lessonData.lessonIndex, snapshot: widget.snapshot, filename: filename);
        //To make subListStart == data!.length after all items has been shown
        if (sublistEnd == data!.length) {
          subListStart = sublistEnd;
        }
      } else {
        widget.goToNext(buildContext: context);
      }
    } else {
      widget.goToNext(buildContext: context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState/
    super.initState();

    data = List<Map>.from(widget.snapshot['content']);
    if ((data!.length - sublistEnd) <= 3) {
      //show full list whether the subtraction gives negative value or not
      sublistEnd = data!.length;
      allShown = true;
    }
    newData = data!.sublist(subListStart, sublistEnd);
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    filename = 'Lesson${widget.lessonData.lessonIndex}_${widget.snapshot.id}_$subListStart$sublistEnd';
    textToSpeechProvider.playFullAudio(result: newData, lessonIndex: widget.lessonData.lessonIndex, snapshot: widget.snapshot, filename: filename);
  }

  @override
  Widget build(BuildContext context) {
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (x) {
        if (!textToSpeechProvider.loading) {
          textToSpeechProvider.stop().then((_) {
            widget.goToBack(buildContext: context);
          });
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: appBarSpace),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).maybePop();
                      },
                      child: Icon(Icons.arrow_back),
                    ),
                    Spacer(),
                    CustomText(
                      text: widget.snapshot['title'],
                      size: getFontSize(18, context),
                      weight: FontWeight.w500,
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(height: getVerticalSize(15, context)),
              AppConstants.buildHeaderSpeaker(
                context: context,
                icon: textToSpeechProvider.playerState == AudioPlayerState.playing
                    ? Image.asset(AppImages.speaker, width: getHorizontalSize(62, context), height: getVerticalSize(50, context))
                    : Padding(
                        padding: const EdgeInsets.only(right: 8, top: 8),
                        child: Image.asset(AppImages.play, width: getHorizontalSize(54, context), height: getVerticalSize(41, context)),
                      ),
                loading: textToSpeechProvider.loading,
                callBack: () async {
                  if (textToSpeechProvider.playerState == AudioPlayerState.playing) {
                    await textToSpeechProvider.pause();
                  } else if (textToSpeechProvider.playerState == AudioPlayerState.paused) {
                    await textToSpeechProvider.resume();
                  } else {
                    await textToSpeechProvider.repeatFullAudio(filename: filename);
                  }
                },
              ),
              SizedBox(height: getVerticalSize(15, context)),
              CustomText(text: widget.snapshot['instruction'], weight: FontWeight.w500),
              SizedBox(height: getVerticalSize(15, context)),
              if ((widget.snapshot.data() as Map<String, dynamic>).containsKey('note'))
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: CustomText(text: widget.snapshot['note'], size: fontSizeSmall, weight: FontWeight.w500),
                ),
              widget.snapshot['type'].toString().contains('2C')
                  ? Expanded(
                      flex: 10,
                      child: SingleChildScrollView(
                        child: Table(
                            border: TableBorder.all(color: AppColors.blackColor1.withOpacity(0.5)),
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: List<Map<String, dynamic>>.from(newData ?? []).map((item) {
                              List<String> orderedKeys = List<String>.from(item.keys);
                              if (orderedKeys.contains('pho') && orderedKeys.contains('ex')) {
                                orderedKeys = ['pho', 'ex']; //re-order
                              } else if (orderedKeys.contains('fr') && orderedKeys.contains('en')) {
                                orderedKeys = ['fr', 'en']; //re-order
                              } else if (orderedKeys.contains('12h') && orderedKeys.contains('24h')) {
                                orderedKeys = ['12h', '24h']; //re-order
                              } else if (orderedKeys.contains('24h') && orderedKeys.contains('meaning')) {
                                orderedKeys = ['24h', 'meaning']; //re-order
                              } else if (orderedKeys.contains('suj') && orderedKeys.contains('con')) {
                                orderedKeys = ['suj', 'con']; //re-order
                              } else if (orderedKeys.contains('sin') && orderedKeys.contains('plu')) {
                                orderedKeys = ['sin', 'plu']; //re-order
                              } else if (orderedKeys.contains('fr') && orderedKeys.contains('ex')) {
                                orderedKeys = ['fr', 'ex']; //re-order
                              } else if (orderedKeys.contains('mas') && orderedKeys.contains('fem')) {
                                orderedKeys = ['mas', 'fem']; //re-order
                              }
                              return TableRow(children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CustomText(text: item[orderedKeys[0]].toString().split('\u2013')[0]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CustomText(text: item[orderedKeys[1]].toString().split('\u2013')[0]),
                                ),
                              ]);
                            }).toList()),
                      ),
                    )
                  : widget.snapshot['type'].toString().contains('3C')
                      ? Expanded(
                          flex: 10,
                          child: SingleChildScrollView(
                            child: Table(
                                border: TableBorder.all(color: AppColors.blackColor1.withOpacity(0.5)),
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: List<Map<String, dynamic>>.from(newData ?? []).map((item) {
                                  List<String> orderedKeys = List<String>.from(item.keys);
                                  if (orderedKeys.contains('pho') && orderedKeys.contains('ex') && orderedKeys.contains('clc')) {
                                    orderedKeys = ['pho', 'ex', 'clc']; //re-order
                                  } else if (orderedKeys.contains('mas') && orderedKeys.contains('fem') && orderedKeys.contains('plu')) {
                                    orderedKeys = ['mas', 'fem', 'plu']; //re-order
                                  } else if (orderedKeys.contains('mas') && orderedKeys.contains('fem') && orderedKeys.contains('meaning')) {
                                    orderedKeys = ['mas', 'fem', 'meaning']; //re-order
                                  }
                                  return TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomText(text: item[orderedKeys[0]]),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomText(text: item[orderedKeys[1]]),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomText(text: item[orderedKeys[2]]),
                                    ),
                                  ]);
                                }).toList()),
                          ),
                        )
                      : widget.snapshot['type'].toString().contains('4C')
                          ? Expanded(
                              flex: 10,
                              child: SingleChildScrollView(
                                  child: Table(
                                      border: TableBorder.all(color: AppColors.blackColor1.withOpacity(0.5)),
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      children: List<Map<String, dynamic>>.from(newData ?? []).map((item) {
                                        List<String> orderedKeys = List<String>.from(item.keys);
                                        if (orderedKeys.contains('en') &&
                                            orderedKeys.contains('mas') &&
                                            orderedKeys.contains('fem') &&
                                            orderedKeys.contains('plu')) {
                                          orderedKeys = ['en', 'mas', 'fem', 'plu']; //re-order
                                        } else if (orderedKeys.contains('m') &&
                                            orderedKeys.contains('mp') &&
                                            orderedKeys.contains('f') &&
                                            orderedKeys.contains('fp')) {
                                          orderedKeys = ['m', 'mp', 'f', 'fp']; //re-order
                                        }
                                        return TableRow(children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
                                            child: CustomText(
                                                text: item[orderedKeys[0]], size: getFontSize(fontSizeSmall, context), textAlign: TextAlign.center),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
                                            child: CustomText(
                                                text: item[orderedKeys[1]], size: getFontSize(fontSizeSmall, context), textAlign: TextAlign.center),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
                                            child: CustomText(
                                                text: item[orderedKeys[2]], size: getFontSize(fontSizeSmall, context), textAlign: TextAlign.center),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
                                            child: CustomText(
                                                text: item[orderedKeys[3]], size: getFontSize(fontSizeSmall, context), textAlign: TextAlign.center),
                                          ),
                                        ]);
                                      }).toList())))
                          : Expanded(
                              flex: 10,
                              child: SingleChildScrollView(
                                  child: Table(
                                      border: TableBorder.all(color: AppColors.blackColor1.withOpacity(0.5)),
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      children: List<Map<String, dynamic>>.from(newData ?? []).map((item) {
                                        List<String> orderedKeys = List<String>.from(item.keys);
                                        if (orderedKeys.contains('m') &&
                                            orderedKeys.contains('f') &&
                                            orderedKeys.contains('mp') &&
                                            orderedKeys.contains('fp') &&
                                            orderedKeys.contains('meaning')) {
                                          orderedKeys = ['m', 'f', 'mp', 'fp', 'meaning']; //re-order
                                        } else if (orderedKeys.contains('en') &&
                                            orderedKeys.contains('fr') &&
                                            orderedKeys.contains('mas') &&
                                            orderedKeys.contains('fem') &&
                                            orderedKeys.contains('lang')) {
                                          orderedKeys = ['en', 'fr', 'mas', 'fem', 'lang']; //re-order
                                        }

                                        return TableRow(children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
                                            child: CustomText(
                                                text: item[orderedKeys[0]],
                                                size: getFontSize(fontSizeExtraSmall, context),
                                                textAlign: TextAlign.center),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
                                            child: CustomText(
                                                text: item[orderedKeys[1]],
                                                size: getFontSize(fontSizeExtraSmall, context),
                                                textAlign: TextAlign.center),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
                                            child: CustomText(
                                                text: item[orderedKeys[2]],
                                                size: getFontSize(fontSizeExtraSmall, context),
                                                textAlign: TextAlign.center),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
                                            child: CustomText(
                                                text: item[orderedKeys[3]],
                                                size: getFontSize(fontSizeExtraSmall, context),
                                                textAlign: TextAlign.center),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
                                            child: CustomText(
                                                text: item[orderedKeys[4]],
                                                size: getFontSize(fontSizeExtraSmall, context),
                                                textAlign: TextAlign.center),
                                          ),
                                        ]);
                                      }).toList()))),
              Spacer(flex: 1),
              Center(
                child: CustomButton(
                  width: getHorizontalSize(250, context),
                  text: 'Repeat audio',
                  textColor: AppColors.primaryColor,
                  border: Border.all(color: AppColors.primaryColor, width: 1.5),
                  onpressed: () {
                    textToSpeechProvider.repeatFullAudio(filename: filename);
                  },
                ),
              ),
              SizedBox(height: getVerticalSize(15, context)),
              Opacity(
                opacity: textToSpeechProvider.loading ? 0.3 : 1.0,
                child: CustomButton(
                  text: 'Ok, got it',
                  color: AppColors.buttonColor,
                  onpressed: () {
                    if (!textToSpeechProvider.loading) {
                      textToSpeechProvider.stop().then((_) {
                        nextLesson();
                      });
                    }
                  },
                ),
              ),
              Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
