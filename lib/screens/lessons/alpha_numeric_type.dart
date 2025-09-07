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

class AlphaNumericType extends StatefulWidget {
  final DocumentSnapshot snapshot;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final Function({required BuildContext buildContext}) goToBack;
  final LessonData lessonData;
  const AlphaNumericType({required this.snapshot, required this.goToNext, required this.goToBack, required this.lessonData, super.key});

  @override
  State<AlphaNumericType> createState() => _AlphaNumericTypeState();
}

class _AlphaNumericTypeState extends State<AlphaNumericType> {
  late TextToSpeechProvider textToSpeechProvider;
  Map<String, dynamic> newMap = {};
  String selectedText = '';
  String filename = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.snapshot['type'] == 'alphabet') {
      newMap = widget.snapshot['content'] as Map<String, dynamic>;
    } else {
      newMap = Map.fromEntries(
        (widget.snapshot['content'] as Map<String, dynamic>).entries.toList()..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key))),
      );
    }
    selectedText = newMap.entries.toList()[0].value;
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    filename = 'Lesson${widget.lessonData.lessonIndex}_${widget.snapshot.id}';
    textToSpeechProvider.playFullAudio(result: newMap, snapshot: widget.snapshot, filename: filename);
  }

  @override
  Widget build(BuildContext context) {
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            SizedBox(height: appBarSpace),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      if (!textToSpeechProvider.loading) {
                        textToSpeechProvider.stop().then((_) {
                          widget.goToBack(buildContext: context);
                        });
                      }
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
                  await textToSpeechProvider.playFullAudio(result: newMap, snapshot: widget.snapshot, filename: filename);
                }
              },
            ),
            SizedBox(height: getVerticalSize(20, context)),
            CustomText(
              text: selectedText,
              size: getFontSize(16, context),
              weight: FontWeight.w500,
            ),
            SizedBox(height: getVerticalSize(30, context)),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 15,
                  runSpacing: 30,
                  children: newMap.entries
                      .map((item) => InkWell(
                            onTap: () {
                              setState(() {
                                selectedText = item.value;
                              });
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomText(
                                  text: item.key,
                                  size: getFontSize(16, context),
                                  weight: FontWeight.w500,
                                ),
                                SizedBox(height: getVerticalSize(8, context)),
                                CustomText(
                                  text: item.value,
                                  color: AppColors.blackColor3.withOpacity(0.7),
                                )
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            SizedBox(
              height: getVerticalSize(30, context),
            ),
            CustomButton(
              width: getHorizontalSize(250, context),
              text: 'Repeat audio',
              textColor: AppColors.primaryColor,
              border: Border.all(color: AppColors.primaryColor, width: 1.5),
              onpressed: () {
                //playing from cache
                textToSpeechProvider.repeatFullAudio(filename: filename);
              },
            ),
            SizedBox(
              height: getVerticalSize(15, context),
            ),
            Opacity(
              opacity: textToSpeechProvider.loading ? 0.3 : 1.0,
              child: CustomButton(
                text: 'Ok, got it',
                color: AppColors.buttonColor,
                onpressed: () {
                  if (!textToSpeechProvider.loading) {
                    textToSpeechProvider.stop().then((_) {
                      widget.goToNext(buildContext: context);
                    });
                  }
                },
              ),
            ),
            SizedBox(
              height: getVerticalSize(30, context),
            ),
          ],
        ),
      ),
    );
  }
}
