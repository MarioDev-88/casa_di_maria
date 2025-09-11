class CostoFijo {
  int id;
  String nombre;
  String precio;

  CostoFijo({
    this.id = 0,
    this.nombre = "",
    this.precio = "0"
  });

  static CostoFijo fromJson(Map json) {
    return CostoFijo(
      id: json['id'],
      nombre: json['nombre'],
      precio: json['precio']
    );
  }
}