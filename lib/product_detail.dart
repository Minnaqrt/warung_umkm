import 'product.dart';
class ProductDetail extends Product {
  final int quantity;
  final int totalPrice;

  ProductDetail({
    required int id,
    required String name,
    required String description,
    required int price,
    required String image,
    required this.quantity,
    required this.totalPrice,
  }) : super(
          id: id,
          name: name,
          description: description,
          price: price,
          image: image,
        );

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: int.parse(json['id'].toString()),
      name: json['nama_produk'] ?? 'Unknown',
      description: json['deskripsi'] ?? 'No description available',
      price: json['harga'] != null ? int.parse(json['harga'].toString()) : 0,
      image: json['image'] ?? '',
      quantity: json['quantity'] != null ? int.parse(json['quantity'].toString()) : 0,
      totalPrice: json['total_price'] != null ? int.parse(json['total_price'].toString()) : 0,
    );
  }
}
