import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:french_app/constants/app_colors.dart';
import 'package:french_app/constants/app_constants.dart';
import 'package:french_app/constants/app_images.dart';
import 'package:french_app/helpers/common.dart';
import 'package:french_app/helpers/size_utils.dart';
import 'package:french_app/models/exercise_correction.dart';
import 'package:french_app/models/lesson_data.dart';
import 'package:french_app/provider/tts_provider.dart';
import 'package:french_app/screens/bottom_navbar.dart';
import 'package:french_app/screens/correction/input_text_correction.dart';
import 'package:french_app/widgets/cached_image.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class InputTextType extends StatefulWidget {
  final bool isReview;
  final DocumentSnapshot snapshot;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final Function({required BuildContext buildContext}) goToBack;
  final LessonData lessonData;
  final int exerciseIndex;
  final double exerciseScore;
  final List<double>? exerciseScoreTrackingList; //used in correction screen
  const InputTextType({
    required this.isReview,
    required this.snapshot,
    required this.goToNext,
    required this.goToBack,
    required this.lessonData,
    required this.exerciseIndex,
    required this.exerciseScore,
    required this.exerciseScoreTrackingList,
    super.key,
  });

  @override
  State<InputTextType> createState() => _InputTextTypeState();
}

class _InputTextTypeState extends State<InputTextType> {
  late TextToSpeechProvider textToSpeechProvider;
  List<Map>? data;
  List<TextEditingController> controllers = [];
  //
  TextEditingController oneTextViewController = TextEditingController();

  // Cached decoration to prevent recreation
  final _textFieldDecoration = const InputDecoration(
    counterText: '',
    isDense: true,
    contentPadding: EdgeInsets.only(left: 15),
    border: UnderlineInputBorder(),
  );

  List<String>? answers; //might have answers in some cases

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    if (widget.snapshot['type'] == 'list-of-input-text') {
      data = List<Map>.from(widget.snapshot['content']);
    }
    controllers = List.generate(data?.length ?? 0, (i) => TextEditingController());
    textToSpeechProvider.playPronunciation(widget.snapshot['instruction'].toString());
  }

  @override
  Widget build(BuildContext context) {
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context);
    //bool canGoback = Navigator.canPop(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (x) {
        //AppConstants.showExitExcerciseWarning(context: context, goToBack: widget.goToBack);
        widget.goToBack(buildContext: context);
      },
      child: Scaffold(
        /*appBar: AppBar(
          leading: const SizedBox(),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 0,
        ),*/
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
              AppConstants.buildHeaderUserSound(
                context: context,
                icon: textToSpeechProvider.playerState == AudioPlayerState.playing
                    ? Image.asset(AppImages.userSound, width: getHorizontalSize(62, context), height: getVerticalSize(50, context))
                    : Padding(
                        padding: const EdgeInsets.only(right: 8, top: 8),
                        child: Image.asset(AppImages.play, width: getHorizontalSize(54, context), height: getVerticalSize(41, context)),
                      ),
                loading: textToSpeechProvider.loading,
                callBack: () async {
                  if (textToSpeechProvider.playerState == AudioPlayerState.playing) {
                    // await textToSpeechProvider.pause();
                  } else if (textToSpeechProvider.playerState == AudioPlayerState.paused) {
                    // await textToSpeechProvider.resume();
                  } else {
                    await textToSpeechProvider.playPronunciation(widget.snapshot['instruction'].toString());
                  }
                },
              ),
              SizedBox(height: getVerticalSize(15, context)),
              if ((widget.snapshot.data() as Map<String, dynamic>).containsKey('instruction') && widget.snapshot['instruction'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CustomText(text: widget.snapshot['instruction'], weight: FontWeight.w500),
                ),
              CustomText(
                text: 'Note: You will need to long-press the letters in your keyboard to get the French accent\'s characters.',
                size: fontSizeSmall,
                color: AppColors.primaryColor,
                weight: FontWeight.bold,
              ),
              SizedBox(height: getVerticalSize(8, context)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if ((widget.snapshot.data() as Map<String, dynamic>).containsKey('example'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(text: widget.snapshot['example']['question']),
                            SizedBox(height: 8),
                            CachedImage(widget.snapshot['example']['image'], height: 50, fit: BoxFit.cover),
                            SizedBox(height: 8),
                            CustomText(text: widget.snapshot['example']['answer']),
                          ],
                        ),
                      ),
                    if ((widget.snapshot.data() as Map<String, dynamic>).containsKey('images'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Wrap(
                            alignment: WrapAlignment.center,
                            children: (widget.snapshot['images'] as List).map((item) {
                              int noImages = (widget.snapshot['images'] as List).length;
                              return Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CachedImage(item['img'],
                                        height: noImages == 1
                                            ? 150
                                            : noImages <= 3
                                                ? 70
                                                : 50,
                                        fit: BoxFit.cover),
                                    if (item['name'].toString().isNotEmpty) SizedBox(height: 3),
                                    if (item['name'].toString().isNotEmpty) CustomText(text: item['name'], size: 12)
                                  ],
                                ),
                              );
                            }).toList()),
                      ),
                    widget.snapshot['type'] == 'list-of-input-text'
                        ? ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: data?.length ?? 0,
                            shrinkWrap: true,
                            itemBuilder: (ctx, index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if ((data![index] as Map<String, dynamic>).containsKey('question') &&
                                      data![index]['question'].toString().isNotEmpty)
                                    !data![index]['question'].toString().startsWith('https://')
                                        ? CustomText(text: '${index + 1}. ${data![index]['question']}')
                                        : Row(
                                            children: [
                                              CustomText(text: '${index + 1}.'),
                                              SizedBox(width: getHorizontalSize(8, context)),
                                              CachedImage(data![index]['question'], height: 50, fit: BoxFit.cover),
                                            ],
                                          ),
                                  if ((data![index] as Map<String, dynamic>).containsKey('image') && data![index]['image'].toString().isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: getVerticalSize(8, context)),
                                        CachedImage(
                                          data![index]['image'],
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ],
                                    ),
                                  if ((data![index] as Map<String, dynamic>).containsKey('qtranslation') &&
                                      data![index]['qtranslation'].toString().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15, top: 1),
                                      child: CustomText(text: data![index]['qtranslation']),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      children: [
                                        if ((data![index] as Map<String, dynamic>).containsKey('prefix') &&
                                            data![index]['prefix'].toString().isNotEmpty) //prefix
                                          CustomText(text: data![index]['prefix']),
                                        SizedBox(width: getHorizontalSize(5, context)),
                                        Expanded(
                                          child: TextField(
                                            controller: controllers[index],
                                            maxLines: 1,
                                            decoration: _textFieldDecoration,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                            separatorBuilder: (ctx, index) => Divider(height: 30, color: AppColors.lightGrey3),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: TextField(
                                minLines: 1,
                                maxLines: 5,
                                controller: oneTextViewController,
                                decoration: _textFieldDecoration.copyWith(contentPadding: EdgeInsets.all(0))),
                          ),
                  ]),
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
                        ExerciseCorrection correction = ExerciseCorrection(
                            id: widget.snapshot.id,
                            lessonTitle: '${widget.snapshot['title']} - Corrections',
                            lessonInstruction: widget.snapshot['instruction'] ?? '',
                            inputText: InputText(
                              type: widget.snapshot['type'],
                              data: data,
                              images: () {
                                if ((widget.snapshot.data() as Map<String, dynamic>).containsKey('images')) {
                                  return List<Map<String, dynamic>>.from(widget.snapshot['images'] ?? []);
                                } else {
                                  return null;
                                }
                              }(),
                              controllers: controllers,
                              oneTextViewController: oneTextViewController,
                            ));
                        changeScreenReplacement(
                            context,
                            BottomNavbar(
                              pageIndex: 1,
                              newpage: InputTextCorrection(
                                isReview: widget.isReview,
                                correction: correction,
                                goToNext: widget.goToNext,
                                lessonData: widget.lessonData,
                                exerciseIndex: widget.exerciseIndex,
                                exerciseScore: widget.exerciseScore,
                                exerciseScoreTrackingList: widget.exerciseScoreTrackingList,
                              ),
                            ));
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: getVerticalSize(30, context)),
            ],
          ),
        ),
      ),
    );
  }
}
