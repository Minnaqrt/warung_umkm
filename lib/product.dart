class Product {
  final int id;
  final String name;
  final String description;
  final int price;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['id'].toString()),
      name: json['nama_produk'] ?? 'Unknown',
      description: json['deskripsi'] ?? 'No description available',
      price: json['harga'] != null ? int.parse(json['harga'].toString()) : 0,
      image: json['image'] ?? '',
    );
  }
}
