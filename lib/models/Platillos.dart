class Platillos {
  final int id;
  final String foto_platillo;
  final String foto_platillo_detalle;
  final String imagekit;
  final String nombre;
  final String descripcion;
  final String descripcion_larga;
  final bool disponible_pedido;
  final String precio;
  final String precio_normal;
  final List adiciones;
  final List adiciones_;
  final List adiciones_simples;

  const Platillos({
    required this.descripcion,
    required this.descripcion_larga,
    required this.disponible_pedido,
    required this.foto_platillo,
    required this.foto_platillo_detalle,
    required this.id,
    required this.imagekit,
    required this.nombre,
    required this.precio,
    required this.precio_normal,
    required this.adiciones,
    required this.adiciones_,
    required this.adiciones_simples
  });

  static Platillos fromJson(Map json) {
    return Platillos(
      descripcion: json['descripcion'],
      descripcion_larga: json['descripcion_larga'] ?? '',
      disponible_pedido: json['disponible_pedido'],
      foto_platillo: json['foto_platillo'] ?? '',
      foto_platillo_detalle: json['foto_platillo_detalle'] ?? '',
      id: json['id'] ?? json['id_platillo'],
      imagekit: json['imagekit'] ?? '',
      nombre: json['nombre'],
      precio: json['precio'],
      precio_normal: json['precio_normal'] ?? '0',
      adiciones: json['adiciones'] ?? [],
      adiciones_: json['_adiciones'] ?? [],
      adiciones_simples: json['adiciones_simples'] ?? []
    );
  }
}