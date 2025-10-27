import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_constants.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/provider/tts_provider.dart';
import 'package:french_app/screens/decision.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class ListType extends StatefulWidget {
  final DocumentSnapshot snapshot;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final Function({required BuildContext buildContext}) goToBack;
  final LessonData lessonData;
  const ListType({required this.snapshot, required this.goToBack, required this.goToNext, required this.lessonData, super.key});

  @override
  State<ListType> createState() => _ListTypeState();
}

class _ListTypeState extends State<ListType> {
  late TextToSpeechProvider textToSpeechProvider;
  int idx = 0;
  List<String>? data;
  List<String>? newData;
  int subListStart = 0;
  int sublistEnd = 12;
  String filename = '';
  void nextLesson() {
    subListStart = subListStart + 12;
    sublistEnd = sublistEnd + 12;
    if ((data!.length - sublistEnd) < 3) {
      //To show  all remaining items
      sublistEnd = data!.length;
    }
    if (subListStart < data!.length) {
      idx = idx + 12;
      setState(() {
        int safeStart = max(0, min(subListStart, data!.length - 1));
        int safeEnd = max(safeStart, min(sublistEnd, data!.length));
        newData = data!.sublist(safeStart, safeEnd);
      });
      filename = 'Lesson${widget.lessonData.lessonIndex}_${widget.snapshot.id}_$subListStart$sublistEnd';
      textToSpeechProvider.playFullAudio(result: newData, lessonIndex: widget.lessonData.lessonIndex, snapshot: widget.snapshot, filename: filename);
      //To make subListStart == data!.length after all items has been shown
      if (sublistEnd == data!.length) {
        subListStart = sublistEnd;
      }
    } else {
      widget.goToNext(buildContext: context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = List<String>.from(widget.snapshot['content']);
    if (data!.length < 12) {
      newData = data!.sublist(subListStart, data!.length);
    } else {
      newData = data!.sublist(subListStart, sublistEnd);
    }
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
                    await textToSpeechProvider.playFullAudio(
                        result: newData, lessonIndex: widget.lessonData.lessonIndex, snapshot: widget.snapshot, filename: filename);
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
              Expanded(
                flex: 10,
                child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(0),
                    itemCount: newData?.length,
                    itemBuilder: (ctx, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: '${index + idx + 1}.',
                              size: getFontSize(16, context),
                            ),
                            SizedBox(
                              width: getHorizontalSize(8, context),
                            ),
                            Expanded(
                              child: CustomText(
                                text: newData![index],
                                size: getFontSize(16, context),
                              ),
                            )
                          ],
                        ),
                      );
                    }),
              ),
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
