import 'package:flutter/material.dart';

class ExerciseCorrection {
  String id;
  String type;
  String lessonTitle;
  String lessonInstruction;
  Reading? reading;
  FillInTheGap? fillInTheGap;
  InputText? inputText;
  Matching? matching;

  ExerciseCorrection({
    required this.id,
    required this.type,
    required this.lessonTitle,
    required this.lessonInstruction,
    this.reading,
    this.fillInTheGap,
    this.inputText,
    this.matching,
  });
}

class Reading {
  String passage;
  String recognizedText;
  int correctCount;
  int totalCount;
  String? note;

  Reading({
    required this.passage,
    required this.recognizedText,
    required this.correctCount,
    required this.totalCount,
    this.note,
  });
}

class FillInTheGap {
  List<String> questions;
  List<String> answers;
  List<List<TextEditingController>> controllers;
  List<List<TextEditingController>> wordAllControllers;

  FillInTheGap({required this.questions, required this.answers, required this.controllers, required this.wordAllControllers});
}

class InputText {
  List<Map>? data;
  List<Map<String, dynamic>>? images;
  List<TextEditingController> controllers;
  TextEditingController oneTextViewController;
  InputText({required this.data, required this.images, required this.controllers, required this.oneTextViewController});
}

class Matching {
  List<Map<String, dynamic>> questions;
  List<String> englishOptions;
  Map<int, int> userAnswers;
  Matching({required this.questions, required this.englishOptions, required this.userAnswers});
}
