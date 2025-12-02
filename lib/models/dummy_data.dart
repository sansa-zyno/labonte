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
