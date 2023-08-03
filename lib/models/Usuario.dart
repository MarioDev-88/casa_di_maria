
class Usuario {
  final int id;
  final String correo;
  final String nombre;
  final String telefono;
  final String monedero;
  final bool habilitar_tarjeta;
  final String customer_conekta;
  final bool active;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.monedero,
    required this.habilitar_tarjeta,
    required this.customer_conekta,
    this.active = false
  });

  factory Usuario.fromJson(Map json) {
    return Usuario(
      id : json['id'],
      nombre: json['nombre'],
      correo : json['correo'],
      telefono : json['telefono'],
      monedero : json['monedero'],
      habilitar_tarjeta: json['habilitar_json'],
      customer_conekta: json['customer_conekta'],
      active: true
    );
  }
}