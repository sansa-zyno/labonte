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
import 'package:french_app/widgets/top_bar.dart';
import 'package:provider/provider.dart';

class TreeType extends StatefulWidget {
  final DocumentSnapshot snapshot;
  final Function({required BuildContext buildContext, double? score}) goToNext;
  final Function({required BuildContext buildContext}) goToBack;
  final LessonData lessonData;
  const TreeType({required this.snapshot, required this.goToNext, required this.goToBack, required this.lessonData, super.key});

  @override
  State<TreeType> createState() => _TreeTypeState();
}

class _TreeTypeState extends State<TreeType> {
  late TextToSpeechProvider textToSpeechProvider;
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  Map<String?, List<String>> treeMap = {};
  List<String> flatList = [];
  String filename = '';

  @override
  void initState() {
    super.initState();
    // Schedule the scroll after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_horizontalController.hasClients) {
        _horizontalController.animateTo(
          _horizontalController.position.maxScrollExtent / 2.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      /*if (_verticalController.hasClients) {
        _verticalController.animateTo(
          _verticalController.position.maxScrollExtent / 2,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }*/
    });

    // Build a parent -> children map
    for (var node in widget.snapshot['content']) {
      final parent = node['parent'];
      final name = node['name'];
      treeMap[parent] = [...(treeMap[parent] ?? []), name];
    }
    flatList = treeMap.values.toList().expand((innerList) => innerList).toList();
    textToSpeechProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    filename = 'Lesson${widget.lessonData.lessonIndex}_${widget.snapshot.id}';
    textToSpeechProvider.playFullAudio(result: flatList, lessonIndex: widget.lessonData.lessonIndex, snapshot: widget.snapshot, filename: filename);
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
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
            SizedBox(height: getVerticalSize(15, context)),
            CustomText(text: widget.snapshot['instruction'], weight: FontWeight.w500),
            SizedBox(height: getVerticalSize(15, context)),
            Expanded(
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  controller: _verticalController,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.5, // Double the screen width
                    height: MediaQuery.of(context).size.height * 1.5, // 1.5 times the screen height
                    child: CustomPaint(
                      painter: FamilyTreePainter(treeMap),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: getVerticalSize(30, context),
            ),
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
            )
          ],
        ),
      )),
    );
  }
}

class FamilyTreePainter extends CustomPainter {
  final Map<String?, List<String>> treeMap;
  final double nodeWidth = 80;
  final double nodeHeight = 20;
  final double horizontalSpacing = 52;
  final double verticalSpacing = 80;
  final Map<String, Offset> nodePositions = {};

  FamilyTreePainter(this.treeMap);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = (String text) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout(minWidth: 0, maxWidth: nodeWidth);
      return tp;
    };

    // Recursive function to draw nodes and compute positions
    double drawNode(String? parent, double x, double y) {
      final children = treeMap[parent] ?? [];
      double childX = x;

      // Draw children first
      for (var child in children) {
        final midX = drawNode(child, childX, y + nodeHeight + verticalSpacing);
        childX = midX + horizontalSpacing;
      }

      double nodeX;
      if (children.isEmpty) {
        nodeX = x;
      } else {
        nodeX = (x + childX - horizontalSpacing) / 2;
      }

      // Draw the current node if it's not null
      if (parent != null) {
        // Draw text
        final tp = textPainter(parent);
        tp.paint(
          canvas,
          Offset(
            nodeX + (nodeWidth - tp.width) / 2,
            y + (nodeHeight - tp.height) / 2,
          ),
        );

        // Store the node position
        nodePositions[parent] = Offset(nodeX + nodeWidth / 2, y + nodeHeight);

        // Draw connecting lines to children
        for (var child in children) {
          final childPos = nodePositions[child];
          if (childPos != null) {
            final start = nodePositions[parent]!;
            final end = childPos;

            // Draw line with gradient
            final gradient = Paint()
              ..color = Colors.black54
              ..strokeWidth = 1
              ..style = PaintingStyle.stroke;

            canvas.drawLine(start, Offset(end.dx, end.dy - nodeHeight), gradient);
          }
        }
      }

      return childX;
    }

    drawNode(null, 0, -70); // Start from root
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
