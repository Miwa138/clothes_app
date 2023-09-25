class Product {
  int id;
  String title;
  String description;
  double price;
  List<ProductImage> images;

  Product({required this.id, required this.title, required this.description, required this.price, required this.images});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price
    };
  }
}

class ProductImage {
  int id;
  String url;

  ProductImage({required this.id, required this.url});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url
    };
  }
}
