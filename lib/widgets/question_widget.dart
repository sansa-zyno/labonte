import 'package:flutter/material.dart';
import 'package:french_app/models/question_model.dart';
import 'package:french_app/widgets/cached_image.dart';
import 'package:french_app/widgets/option_tile.dart';

class QuestionWidget extends StatefulWidget {
  final int index;
  final String type;
  final bool isImageQuestion;
  final QuestionModel questionModel;
  final Function(bool x) callback;

  QuestionWidget({
    Key? key,
    required this.index,
    required this.type,
    required this.isImageQuestion,
    required this.questionModel,
    required this.callback,
  }) : super(key: key);

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String optionSelected = "";

  @override
  Widget build(BuildContext context) {
    super.build(context); // ⚠️ this is required!
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        widget.isImageQuestion
            ? Row(
                children: [
                  Text("Q${widget.index + 1}", style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.8))),
                  SizedBox(width: 8),
                  CachedImage(widget.questionModel.question, height: 50, fit: BoxFit.cover),
                ],
              )
            : Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: Text("Q${widget.index + 1} ${widget.questionModel.question}",
                    style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.8)))),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            if (!widget.questionModel.answered) {
              ///correct
              if (widget.questionModel.option1 == widget.questionModel.correctOption) {
                setState(() {
                  optionSelected = widget.questionModel.option1;
                  widget.questionModel.answered = true;
                });
                widget.callback(true);
              } else {
                setState(() {
                  optionSelected = widget.questionModel.option1;
                  widget.questionModel.answered = true;
                });
                widget.callback(false);
              }
            }
          },
          child: OptionTile(
            option: "a",
            description: widget.questionModel.option1,
            correctAnswer: widget.questionModel.correctOption,
            optionSelected: optionSelected,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            if (!widget.questionModel.answered) {
              ///correct
              if (widget.questionModel.option2 == widget.questionModel.correctOption) {
                setState(() {
                  optionSelected = widget.questionModel.option2;
                  widget.questionModel.answered = true;
                });
                widget.callback(true);
              } else {
                setState(() {
                  optionSelected = widget.questionModel.option2;
                  widget.questionModel.answered = true;
                });
                widget.callback(false);
              }
            }
          },
          child: OptionTile(
            option: "b",
            description: widget.questionModel.option2,
            correctAnswer: widget.questionModel.correctOption,
            optionSelected: optionSelected,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            if (!widget.questionModel.answered) {
              ///correct
              if (widget.questionModel.option3 == widget.questionModel.correctOption) {
                setState(() {
                  optionSelected = widget.questionModel.option3;
                  widget.questionModel.answered = true;
                });
                widget.callback(true);
              } else {
                setState(() {
                  optionSelected = widget.questionModel.option3;
                  widget.questionModel.answered = true;
                });
                widget.callback(false);
              }
            }
          },
          child: OptionTile(
            option: "c",
            description: widget.questionModel.option3,
            correctAnswer: widget.questionModel.correctOption,
            optionSelected: optionSelected,
          ),
        ),
        const SizedBox(height: 4),
        if (widget.type == '4-Choice' || widget.type == '5-Choice')
          GestureDetector(
            onTap: () async {
              if (!widget.questionModel.answered) {
                ///correct
                if (widget.questionModel.option4 == widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option4!;
                    widget.questionModel.answered = true;
                  });
                  widget.callback(true);
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option4!;
                    widget.questionModel.answered = true;
                  });
                  widget.callback(false);
                }
              }
            },
            child: OptionTile(
              option: "d",
              description: widget.questionModel.option4!,
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
        const SizedBox(height: 4),
        if (widget.type == '5-Choice')
          GestureDetector(
            onTap: () async {
              if (!widget.questionModel.answered) {
                ///correct
                if (widget.questionModel.option5 == widget.questionModel.correctOption) {
                  setState(() {
                    optionSelected = widget.questionModel.option5!;
                    widget.questionModel.answered = true;
                  });
                  widget.callback(true);
                } else {
                  setState(() {
                    optionSelected = widget.questionModel.option5!;
                    widget.questionModel.answered = true;
                  });
                  widget.callback(false);
                }
              }
            },
            child: OptionTile(
              option: "e",
              description: widget.questionModel.option5!,
              correctAnswer: widget.questionModel.correctOption,
              optionSelected: optionSelected,
            ),
          ),
      ],
    );
  }
}
