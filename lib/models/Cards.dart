class Cards{
  final String idTarjeta;
  final String cuatroDigitos;
  final String tipoTarjeta;

  String get fourDigit {
    return cuatroDigitos;
  }

  String get typeCard {
    return tipoTarjeta;
  }


  String get idCard {
    return idTarjeta;
  }

  const Cards({
    required this.idTarjeta,
    required this.cuatroDigitos,
    required this.tipoTarjeta
  });

  static Cards fromJson(Map json) {
    return Cards(
      idTarjeta : json['id_tarjeta'],
      cuatroDigitos : json['cuatrodigitos'],
      tipoTarjeta : json['tipotarjeta']
    );
  }
}