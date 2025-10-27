import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_constants.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/provider/tts_provider.dart';
import 'package:french_app/screens/decision.dart';
import 'package:french_app/widgets/cached_image.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class ConversationType extends StatefulWidget {
  final DocumentSnapshot snapshot;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final Function({required BuildContext buildContext}) goToBack;
  final LessonData lessonData;
  const ConversationType({required this.snapshot, required this.goToNext, required this.goToBack, required this.lessonData, super.key});

  @override
  _ConversationTypeState createState() => _ConversationTypeState();
}

class _ConversationTypeState extends State<ConversationType> {
  late TextToSpeechProvider textToSpeechProvider;
  int idx = -1;
  ScrollController? scrollController;
  String filename = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController = ScrollController();
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    filename = 'Lesson${widget.lessonData.lessonIndex}_${widget.snapshot.id}';
    textToSpeechProvider.playFullAudio(
        result: widget.snapshot['content'], lessonIndex: widget.lessonData.lessonIndex, snapshot: widget.snapshot, filename: filename);
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: getVerticalSize(15, context)),
                    CustomText(text: widget.snapshot['instruction'], weight: FontWeight.w500),
                    SizedBox(height: getVerticalSize(15, context)),
                    if ((widget.snapshot.data() as Map<String, dynamic>).containsKey('illustration'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: CachedImage(
                          widget.snapshot['illustration'],
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ListView.builder(
                      itemCount: widget.snapshot['content'].length + 1,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(0),
                      controller: scrollController,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (index == widget.snapshot['content'].length) {
                          return Container(
                            height: 50,
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10.0),
                                          constraints: BoxConstraints(maxWidth: 200),
                                          decoration: BoxDecoration(
                                            color: Color(0xffE7E7F9),
                                            borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(8),
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(widget.snapshot['content'][index]['person1'], style: TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            constraints: BoxConstraints(maxWidth: 200),
                                            padding: const EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              color: Color(0xffE7E7F9),
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(8),
                                                topLeft: Radius.circular(8),
                                                topRight: Radius.circular(8),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  widget.snapshot['content'][index]['person2'],
                                                  style: TextStyle(fontSize: 14.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      },
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
            SizedBox(height: getVerticalSize(30, context)),
          ],
        ),
      )),
    );
  }
}
