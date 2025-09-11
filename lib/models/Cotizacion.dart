class Cotizacion {
  int id;
  String folio;
  String evento;
  int expiracion;
  String? url_cotizacion;
  String? url_contrato;
  String? fecha_evento;
  String? hora_inicio;
  String? hora_fin;
  bool? contrato;

  Cotizacion({
    required this.id,
    required this.folio,
    required this.evento,
    required this.expiracion,
    this.url_cotizacion,
    this.url_contrato,
    this.contrato,
    this.fecha_evento,
    this.hora_fin,
    this.hora_inicio
  });

  static Cotizacion fromJson(Map json) {
    return Cotizacion(
      id : json['id'],
      folio : json['folio'],
      evento: json['evento'],
      expiracion: json['expiracion'],
      url_cotizacion : json['url_cotizacion'],
      url_contrato: json['url_contrato'],
      contrato: json['contrato'],
      fecha_evento: json['fecha_evento'],
      hora_fin: json['hora_fin'],
      hora_inicio: json['hora_inicio']
    );
  }

}