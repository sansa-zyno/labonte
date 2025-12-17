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
import 'package:french_app/widgets/cached_image.dart';
import 'package:french_app/widgets/custom_button.dart';
import 'package:french_app/widgets/custom_text.dart';
import 'package:french_app/widgets/top_bar.dart';
import 'package:provider/provider.dart';

class ImageType extends StatefulWidget {
  final DocumentSnapshot snapshot;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final Function({required BuildContext buildContext}) goToBack;
  final LessonData lessonData;
  const ImageType({required this.snapshot, required this.goToNext, required this.goToBack, required this.lessonData, super.key});

  @override
  State<ImageType> createState() => _ImageTypeState();
}

class _ImageTypeState extends State<ImageType> {
  late TextToSpeechProvider textToSpeechProvider;
  List<Map>? images;
  List<Map>? newImageList;
  int subListStart = 0;
  int sublistEnd = 4;
  bool allShown = false;
  String filename = '';
  void nextLesson() {
    if (!(widget.snapshot['type'] == 'image-no-container')) {
      subListStart = subListStart + 4;
      sublistEnd = sublistEnd + 4;
      if ((images!.length - sublistEnd) < 2) {
        //To show  all remaining items
        sublistEnd = images!.length;
      }
      if (!allShown) {
        if (subListStart < images!.length) {
          int safeStart = max(0, min(subListStart, images!.length - 1));
          int safeEnd = max(safeStart, min(sublistEnd, images!.length));
          setState(() {
            newImageList = images!.sublist(safeStart, safeEnd);
          });
          filename = 'Lesson${widget.lessonData.lessonIndex}_${widget.snapshot.id}_$subListStart$sublistEnd';
          textToSpeechProvider.playFullAudio(
              result: newImageList, lessonIndex: widget.lessonData.lessonIndex, snapshot: widget.snapshot, filename: filename);
          //To make subListStart == data!.length after all items has been shown
          if (sublistEnd == images!.length) {
            subListStart = sublistEnd;
          }
        } else {
          widget.goToNext(buildContext: context);
        }
      } else {
        // dev.log('all shown');
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
    images = List<Map>.from(widget.snapshot['content']);
    if (widget.snapshot['type'] == 'image-no-container') {
      newImageList = images;
    } else {
      if ((images!.length - sublistEnd) < 4) {
        //show full list
        sublistEnd = images!.length;
        allShown = true;
      }
      newImageList = images!.sublist(subListStart, sublistEnd);
    }
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    filename = 'Lesson${widget.lessonData.lessonIndex}_${widget.snapshot.id}_$subListStart$sublistEnd';
    textToSpeechProvider.playFullAudio(
        result: newImageList, lessonIndex: widget.lessonData.lessonIndex, snapshot: widget.snapshot, filename: filename);
  }

  @override
  Widget build(BuildContext context) {
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context);
    double width = MediaQuery.of(context).size.width;
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
              TopBar(
                type: widget.snapshot['type'],
                title: widget.snapshot['title'],
                callBack: () {
                  Navigator.of(context).maybePop();
                },
              ),
              SizedBox(height: getVerticalSize(15, context)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Spacer(flex: 3),
                  AppConstants.buildHeaderSpeaker(
                    context: context,
                    icon: textToSpeechProvider.playerState == AudioPlayerState.playing
                        ? Image.asset(AppImages.speaker, width: getHorizontalSize(62, context), height: getVerticalSize(50, context))
                        : Padding(
                            padding: getPadding(context: context, right: 8, top: 8),
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
                  Spacer(flex: 1),
                  Padding(
                    padding: getPadding(context: context, left: width < 600 ? 0 : 20),
                    child: GestureDetector(
                      onTap: () {
                        textToSpeechProvider.repeatFullAudio(filename: filename);
                      },
                      child: Row(children: [
                        CustomText(text: 'Repeat audio', size: getFontSize(10, context)),
                        SizedBox(width: getHorizontalSize(3, context)),
                        Image.asset(AppImages.speaker, height: getSize(8.5, context), color: Colors.black45)
                      ]),
                    ),
                  )
                ],
              ),
              SizedBox(height: getVerticalSize(15, context)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((widget.snapshot.data() as Map<String, dynamic>).containsKey('instruction'))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(text: widget.snapshot['instruction'], size: getFontSize(13, context), weight: FontWeight.w500),
                            SizedBox(height: getVerticalSize(10, context)),
                          ],
                        ),
                      if ((widget.snapshot.data() as Map<String, dynamic>).containsKey('note'))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: getVerticalSize(5, context)),
                            CustomText(text: widget.snapshot['note'], size: getFontSize(13, context)),
                            SizedBox(height: getVerticalSize(8, context)),
                          ],
                        ),
                      if ((widget.snapshot.data() as Map<String, dynamic>).containsKey('example'))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: getVerticalSize(8, context)),
                            CustomText(text: widget.snapshot['example']['title'], size: getFontSize(13, context)),
                            SizedBox(height: getVerticalSize(5, context)),
                            CachedImage(widget.snapshot['example']['image'], height: 75, fit: BoxFit.cover),
                            SizedBox(height: getVerticalSize(8, context)),
                            CustomText(text: widget.snapshot['example']['body'], size: getFontSize(13, context)),
                            SizedBox(height: getVerticalSize(10, context)),
                          ],
                        ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        //transitionBuilder: (Widget child, Animation<double> animation) {
                        //  return FadeTransition(opacity: animation, child: child);
                        //},
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(1.0, 0.0), // Slide in from right
                              end: Offset.zero,
                            ).animate(animation),
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.8, // Slightly smaller at the start
                                end: 1.0,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: widget.snapshot['type'] == 'image'
                            ? GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.all(0),
                                itemCount: newImageList!.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: width < 600 ? 1.0 : 1.5,
                                  mainAxisSpacing: 15,
                                  crossAxisSpacing: 15,
                                ),
                                itemBuilder: (ctx, index) {
                                  Map<String, dynamic> usedMap = newImageList![index] as Map<String, dynamic>;
                                  if (usedMap.entries.toList()[1].key == 'image') {
                                    usedMap = Map.fromEntries(usedMap.entries.toList().reversed);
                                  }
                                  return Column(
                                    children: [
                                      usedMap.entries.toList()[1].key != '*'
                                          ? CustomText(
                                              text: '${usedMap.entries.toList()[1].key}',
                                              size: getFontSize(16, context),
                                              weight: FontWeight.w500,
                                            )
                                          : SizedBox.shrink(),
                                      usedMap.entries.toList()[1].key != '*' ? SizedBox(height: getVerticalSize(8, context)) : SizedBox.shrink(),
                                      Container(
                                        decoration: BoxDecoration(color: AppColors.lightGrey3, borderRadius: BorderRadius.circular(15)),
                                        child: Column(
                                          children: [
                                            SizedBox(height: 10),
                                            CachedImage('${newImageList![index]['image']}', height: getSize(50, context), fit: BoxFit.fitWidth),
                                            Divider(),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                              child: CustomText(text: '${usedMap.entries.toList()[1].value}', textAlign: TextAlign.center),
                                            ),
                                            SizedBox(height: 15)
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                })
                            : widget.snapshot['type'] == 'image-no-container'
                                ? GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.all(0),
                                    itemCount: newImageList!.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: width < 600 ? 0.78 : 1.0,
                                      crossAxisSpacing: 15,
                                      mainAxisSpacing: 0,
                                    ),
                                    itemBuilder: (ctx, index) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CachedImage('${newImageList![index]['image']}', height: getSize(50, context), fit: BoxFit.fitWidth),
                                          CustomText(
                                              text: '${newImageList![index]['name']}',
                                              size: width < 600 ? fontSizeExtraSmall : fontSizeMedium,
                                              textAlign: TextAlign.center),
                                        ],
                                      );
                                    })
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.only(top: 10),
                                    itemCount: newImageList!.length,
                                    itemBuilder: (ctx, index) {
                                      List<String> orderedKeys = List<String>.from(newImageList![index].keys);
                                      orderedKeys.remove('image');
                                      orderedKeys.remove('or');
                                      orderedKeys.insert(1, 'image');
                                      orderedKeys.insert(2, 'or');
                                      return Container(
                                        padding: EdgeInsets.all(15),
                                        margin: EdgeInsets.only(bottom: 15),
                                        decoration: BoxDecoration(color: AppColors.lightGrey3, borderRadius: BorderRadius.circular(15)),
                                        child: Row(
                                          children: [
                                            CachedImage('${newImageList![index]['image']}',
                                                width: getSize(50, context), height: getSize(50, context), fit: BoxFit.cover),
                                            SizedBox(width: getHorizontalSize(15, context)),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(text: '${orderedKeys[0]}'),
                                                  SizedBox(height: getVerticalSize(8, context)),
                                                  CustomText(text: '${newImageList![index][orderedKeys[0]]}'),
                                                  if (newImageList![index].containsKey('or'))
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        SizedBox(height: getVerticalSize(8, context)),
                                                        Padding(padding: const EdgeInsets.only(left: 60), child: CustomText(text: 'Or')),
                                                        SizedBox(height: getVerticalSize(8, context)),
                                                        CustomText(text: '${newImageList![index]['or'].entries.toList()[0].key}'),
                                                        SizedBox(height: getVerticalSize(8, context)),
                                                        CustomText(text: '${newImageList![index]['or'].entries.toList()[0].value}'),
                                                      ],
                                                    )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }),
                      ),
                    ],
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
