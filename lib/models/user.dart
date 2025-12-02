class UserModel {
  final String id;
  final String? name;
  final String? email;
  final String? avatar;
  final String? country;
  final String? userFrenchLevel;
  final String? frequencyOfLearning;
  final List<String>? purposeForLearning;
  final List<String>? learningGoals;
  final String? heardAboutUs;
  final bool? isSubscribed;
  UserModel(
      {required this.id,
      this.name,
      this.email,
      this.avatar,
      this.country,
      this.userFrenchLevel,
      this.frequencyOfLearning,
      this.purposeForLearning,
      this.learningGoals,
      this.heardAboutUs,
      this.isSubscribed});

  UserModel copyWith(
      {String? id,
      String? name,
      String? email,
      String? avatar,
      String? country,
      String? userFrenchLevel,
      String? frequencyOfLearning,
      List<String>? purposeForLearning,
      List<String>? learningGoals,
      String? heardAboutUs,
      bool? isSubscribed}) {
    return UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        avatar: avatar ?? this.avatar,
        country: country ?? this.country,
        userFrenchLevel: userFrenchLevel ?? this.userFrenchLevel,
        frequencyOfLearning: frequencyOfLearning ?? this.frequencyOfLearning,
        purposeForLearning: purposeForLearning ?? this.purposeForLearning,
        learningGoals: learningGoals ?? this.learningGoals,
        heardAboutUs: heardAboutUs ?? this.heardAboutUs,
        isSubscribed: isSubscribed ?? this.isSubscribed);
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
        id: id,
        name: data['name'],
        email: data['email'],
        avatar: data['avatar'],
        country: data['country'],
        userFrenchLevel: data['userFrenchLevel'],
        frequencyOfLearning: data['frequencyOfLearning'],
        purposeForLearning: List<String>.from(data['purposeForLearning']),
        learningGoals: List<String>.from(data['learningGoals']),
        heardAboutUs: data['heardAboutUs'],
        isSubscribed: data['isSubscribed']);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'country': country,
      'userFrenchLevel': userFrenchLevel,
      'frequencyOfLearning': frequencyOfLearning,
      'purposeForLearning': purposeForLearning ?? [],
      'learningGoals': learningGoals ?? [],
      'heardAboutUs': heardAboutUs,
      'isSubscribed': isSubscribed
    };
  }
}
