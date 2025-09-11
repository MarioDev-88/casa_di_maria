class Coordinador {
  int id;
  String nombre;
  bool status;

  Coordinador({
    this.id = 0,
    this.nombre = "",
    this.status = false
  });

  static Coordinador fromJson(Map json) {
    return Coordinador(
      id: json['id'],
      nombre: json['nombre'],
      status: json['status']
    );
  }
}