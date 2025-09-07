class DummyData {
  static List<Package> packagess = [
    Package(
        storeProduct: StoreProduct(
      title: 'Lifetime',
      description: 'This is for a lifetime',
      offerPrice: '\u20a61,990',
      priceString: '\u20a62,000',
    )),
    Package(
        storeProduct: StoreProduct(
      title: 'Monthly',
      description: 'This is for monthly',
      offerPrice: '\u20a6450',
      priceString: '\u20a6500',
    )),
    Package(
        storeProduct: StoreProduct(
      title: 'Yearly',
      description: 'This is for yearly',
      offerPrice: '\u20a6990',
      priceString: '\u20a61,000',
    ))
  ];

  /* static List<Map>? questions = [
    {
      'question': 'What is a verb ?',
      'option1': 'Action word',
      'option2': 'Not action word',
      'option3': 'Bad word',
      'option4': 'Great word',
    },
    {
      'question': 'What is a Noun?',
      'option1': 'Naming word',
      'option2': 'Ceremony word',
      'option3': 'Fancy word',
      'option4': 'Causual word',
    },
    {
      'question': 'A cat is ?',
      'option1': 'Carnivorous',
      'option2': 'Herbivorous',
      'option3': 'Omnivorous',
      'option4': 'None',
    },
    {
      'question': 'How many legs does a dog have?',
      'option1': '4',
      'option2': '5',
      'option3': '3',
      'option4': '1',
    },
    {
      'question': 'Which of these countries is african?',
      'option1': 'Congo',
      'option2': 'Ukrain',
      'option3': 'Russia',
      'option4': 'Palestine',
    }
  ];*/

  /*static remove(int index) {
    questions!.removeAt(index);
    questions = questions;
  }*/

  /*static shuffle() {
    questions!.shuffle();
    questions = questions;
  }*/

  /*static reset() {
    questions = [
      {
        'question': 'What is a verb ?',
        'option1': 'Action word',
        'option2': 'Not action word',
        'option3': 'Bad word',
        'option4': 'Great word',
      },
      {
        'question': 'What is a Noun?',
        'option1': 'Naming word',
        'option2': 'Ceremony word',
        'option3': 'Fancy word',
        'option4': 'Causual word',
      },
      {
        'question': 'A cat is ?',
        'option1': 'Carnivorous',
        'option2': 'Herbivorous',
        'option3': 'Omnivorous',
        'option4': 'None',
      },
      {
        'question': 'How many legs does a dog have?',
        'option1': '4',
        'option2': '5',
        'option3': '3',
        'option4': '1',
      },
      {
        'question': 'Which of these countries is african?',
        'option1': 'Congo',
        'option2': 'Ukrain',
        'option3': 'Russia',
        'option4': 'Palestine',
      }
    ];
  }*/
}

class Package {
  StoreProduct storeProduct;
  Package({required this.storeProduct});
}

class StoreProduct {
  String title;
  String description;
  String offerPrice;
  String priceString;
  StoreProduct({required this.title, required this.description, required this.offerPrice, required this.priceString});
}
