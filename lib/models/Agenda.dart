class Agenda {
  int? id;
  String? fecha_evento;
  String? hora_inicio;
  String? hora_fin;
  bool? contrato;

  Agenda({
    this.id,
    this.fecha_evento,
    this.hora_inicio,
    this.hora_fin,
    this.contrato
  });

  static Agenda fromJson(Map json) {
    return Agenda(
      id : json['id'],
      contrato: json['contrato'],
      fecha_evento: json['fecha_evento'],
      hora_fin: json['hora_fin'],
      hora_inicio: json['hora_inicio']
    );
  }
}