import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_constants.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/provider/tts_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/decision.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class HTMLPage extends StatefulWidget {
  final DocumentSnapshot snapshot;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final Function({required BuildContext buildContext}) goToBack;
  final LessonData lessonData;
  const HTMLPage({required this.snapshot, required this.goToNext, required this.goToBack, required this.lessonData, super.key});

  @override
  State<HTMLPage> createState() => _HTMLPageState();
}

class _HTMLPageState extends State<HTMLPage> {
  late TextToSpeechProvider textToSpeechProvider;
  String filename = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    if (widget.snapshot['type'] != 'html-intro') {
      filename = 'Lesson${widget.lessonData.lessonIndex}_${widget.snapshot.id}';
      textToSpeechProvider.playFullAudio(result: widget.snapshot['content'], snapshot: widget.snapshot, filename: filename);
    }
  }

  @override
  Widget build(BuildContext context) {
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: appBarSpace),
            widget.snapshot['type'] == 'html-intro'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          if (widget.snapshot.id != '0') {
                            widget.goToBack(buildContext: context);
                          } else {
                            //Fix for when exerciseIndex==0(Home screen) and  currentSublessonIndex==0 and gotoBack is pressed
                            changeScreenRemoveUntill(context, BottomNavbar(pageIndex: 0));
                          }
                        },
                        child: Icon(Icons.arrow_back),
                      ),
                      SizedBox(height: getVerticalSize(15, context)),
                      CustomText(
                        text: widget.snapshot['title'],
                        size: getFontSize(18, context),
                        weight: FontWeight.w500,
                      ),
                    ],
                  )
                : Padding(
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
            if (!(widget.snapshot['type'] == 'html-intro'))
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
            SizedBox(height: getVerticalSize(20, context)),
            Flexible(
              fit: widget.snapshot['type'] == 'html-intro' ? FlexFit.loose : FlexFit.tight,
              child: widget.snapshot['type'] == 'html-intro'
                  ? HtmlWidget(widget.snapshot['content'] ?? '',
                      enableCaching: true,
                      textStyle: TextStyle(
                        fontSize: getFontSize(fontSizeMedium, context),
                        color: Colors.black,
                        height: getVerticalSize(1.4, context),
                      ), onTapUrl: (url) {
                      // launchURL(url);
                      return true;
                    })
                  : Center(
                      //To center the loading indicator while loading image especially
                      child: SingleChildScrollView(
                        child: HtmlWidget(widget.snapshot['content'] ?? '',
                            enableCaching: true,
                            textStyle: TextStyle(
                              fontSize: getFontSize(fontSizeMedium, context),
                              color: Colors.black,
                              height: getVerticalSize(1.4, context),
                            ), onTapUrl: (url) {
                          // launchURL(url);
                          return true;
                        }),
                      ),
                    ),
            ),
            widget.snapshot['type'] == 'html-intro' ? SizedBox(height: getVerticalSize(30, context)) : SizedBox.shrink(),
            widget.snapshot['type'] == 'html-intro'
                ? Align(
                    alignment: Alignment.centerRight,
                    child: CustomButton(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      height: getVerticalSize(38, context),
                      width: getHorizontalSize(120, context),
                      text: 'Continue',
                      textColor: AppColors.primaryColor,
                      border: Border.all(color: AppColors.primaryColor, width: 1.5),
                      icon: const Icon(
                        Icons.keyboard_arrow_right,
                        size: 20,
                        color: AppColors.primaryColor,
                      ),
                      onpressed: () {
                        // changeScreen(context, DecisionScreen(id: '${int.parse(widget.snapshot.id) + 1}', previousPageIndex: 1));
                        widget.goToNext(buildContext: context);
                      },
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                widget.goToNext(buildContext: context);
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: getVerticalSize(15, context)),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
