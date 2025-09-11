class Platillos {
  final int id;
  final String nombre;
  final String precio;

  const Platillos({
    required this.id,
    required this.nombre,
    required this.precio
  });

  static Platillos fromJson(Map json) {
    return Platillos(
      id: json['id'],
      nombre: json['nombre'],
      precio: json['precio'] ?? "0"
    );
  }
}