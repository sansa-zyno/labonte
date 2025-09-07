class QuestionModel {
  String question;
  String option1;
  String option2;
  String option3;
  String? option4;
  String? option5;
  String correctOption;
  bool answered;

  QuestionModel({
    required this.question,
    required this.option1,
    required this.option2,
    required this.option3,
    this.option4,
    this.option5,
    required this.correctOption,
    required this.answered,
  });

  factory QuestionModel.fromMap(Map map, String type) {
    /// shuffling the options
    if (type == '3-Choice') {
      List<String> options = [
        map["option1"],
        map["option2"],
        map["option3"],
      ];
      options.shuffle();

      return QuestionModel(
        question: map["question"],
        option1: options[0],
        option2: options[1],
        option3: options[2],
        correctOption: map["option1"],
        answered: false,
      );
    } else if (type == '4-Choice') {
      List<String> options = [
        map["option1"],
        map["option2"],
        map["option3"],
        map["option4"],
      ];
      options.shuffle();

      return QuestionModel(
        question: map["question"],
        option1: options[0],
        option2: options[1],
        option3: options[2],
        option4: options[3],
        correctOption: map["option1"],
        answered: false,
      );
    } else {
      List<String> options = [
        map["option1"],
        map["option2"],
        map["option3"],
        map["option4"],
        map["option5"],
      ];
      options.shuffle();

      return QuestionModel(
        question: map["question"],
        option1: options[0],
        option2: options[1],
        option3: options[2],
        option4: options[3],
        option5: options[4],
        correctOption: map["option1"],
        answered: false,
      );
    }
  }
}
