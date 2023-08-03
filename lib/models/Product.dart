class Product {
  final String nombre;
  final String foto;
  final String price;
  final String priceNormal;
  final int id;

  const Product({
    required this.id,
    required this.nombre,
    required this.foto,
    required this.price,
    required this.priceNormal
  });

  static Product fromJson(Map json) {
    return Product(
      id: json['id'], 
      nombre: json['nombre'], 
      foto: json['foto_platillo'] ?? '', //https://firebasestorage.googleapis.com/v0/b/zesty-testing.appspot.com/o/logoElotesMake.png?alt=media&token=b6ccb0c5-1909-412f-92a0-6bb049566f75,
      price: json['precio'],
      priceNormal: json['precio_normal']
    );
  }
}