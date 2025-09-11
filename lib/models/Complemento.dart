class Complemento {
  int id;
  String nombre;

  Complemento({
    this.id =0,
    this.nombre = ''
  });

  static Complemento fromJson(Map json) {
    return Complemento(
      id: json['id'],
      nombre: json['nombre']
    );
  }
}