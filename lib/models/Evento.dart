class Evento {
  int id;
  String nombre;

  Evento({
    required this.id,
    required this.nombre
  });

  static Evento fromJson(Map json) {
    return Evento(
      id: json['id'],
      nombre: json['nombre']
    );
  }
}