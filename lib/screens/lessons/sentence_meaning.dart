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

class SentenceMeaning extends StatefulWidget {
  final DocumentSnapshot snapshot;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final Function({required BuildContext buildContext}) goToBack;
  final LessonData lessonData;
  const SentenceMeaning({required this.snapshot, required this.goToNext, required this.goToBack, required this.lessonData, super.key});

  @override
  State<SentenceMeaning> createState() => _SentenceMeaningState();
}

class _SentenceMeaningState extends State<SentenceMeaning> {
  late TextToSpeechProvider textToSpeechProvider;
  int idx = 0;
  List<Map>? data;
  List<Map>? newData;
  int subListStart = 0;
  int sublistEnd = 7;
  bool allShown = false;
  String filename = '';
  void nextLesson() {
    subListStart = subListStart + 7;
    sublistEnd = sublistEnd + 7;
    if ((data!.length - sublistEnd) < 3) {
      //To show  all remaining items
      sublistEnd = data!.length;
    }
    if (!allShown) {
      if (subListStart < data!.length) {
        idx = idx + 7;
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
    // TODO: implement initState
    super.initState();
    data = List<Map>.from(widget.snapshot['content']);
    if ((data!.length - sublistEnd) < 3) {
      //show full list
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if ((widget.snapshot.data() as Map<String, dynamic>).containsKey('note'))
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: CustomText(text: widget.snapshot['note'], size: fontSizeSmall, weight: FontWeight.w500),
                      ),
                    ListView.separated(
                      itemCount: newData?.length ?? 0,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(0),
                      shrinkWrap: true,
                      itemBuilder: (ctx, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(text: '${index + idx + 1}. ${newData![index]['question']}'),
                            SizedBox(height: getVerticalSize(8, context)),
                            CustomText(text: '${newData![index]['answer']}'),
                            if (newData![index].containsKey('note') && newData![index]['note'].toString().isNotEmpty)
                              CustomText(text: '${newData![index]['note']}'),
                            if (newData![index].containsKey('extra') && newData![index]['extra'].toString().isNotEmpty)
                              CustomText(text: '${newData![index]['extra']}'),
                          ],
                        );
                      },
                      separatorBuilder: (ctx, index) => Divider(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: getVerticalSize(30, context)),
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
            SizedBox(height: getVerticalSize(30, context)),
          ]),
        ),
      ),
    );
  }
}
