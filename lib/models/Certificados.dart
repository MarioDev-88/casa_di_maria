class Certificados {
  final String titulo;
  final String descripcion;
  final String costo;
  final int perfil;
  final int id;
  final String restaurante;
  final int id_restaurante;
  final bool srpago;
  final bool pago_tarjeta;
  final bool pago_terminal;
  final bool promo;

  const Certificados({
    required this.titulo,
    required this.descripcion,
    required this.costo,
    required this.perfil,
    required this.id,
    required this.restaurante,
    required this.id_restaurante,
    required this.srpago,
    required this.pago_tarjeta,
    required this.pago_terminal,
    required this.promo
  });

  static Certificados fromJson(Map json) {
    return Certificados(
      titulo: json['titulo'], 
      descripcion: json['descripcion'], 
      costo: json['costo'], 
      perfil: json['perfil'], 
      id: json['id'], 
      restaurante: json['restaurante'], 
      id_restaurante: json['id_restaurante'], 
      srpago: json['srpago'], 
      pago_tarjeta: json['pago_tarjeta'], 
      pago_terminal: json['pago_terminal'], 
      promo: json['promo']);
  }
}