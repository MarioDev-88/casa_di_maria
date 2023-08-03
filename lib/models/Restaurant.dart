class Restaurant{
  bool menuCompleto;
  bool incluirPopulares;
  bool incluirGaleria;
  String descripcion;
  String direccion;
  bool pagoTarjeta;
  bool pagoTerminal;
  List? formatoHorarioTest;
  List? formatoHorarioWeb;
  String pedidoMinimo;
  String tiempoAprox;
  String costoEnvio;

  String get costo_envio{
    return costoEnvio;
  }

  Restaurant({
    this.menuCompleto = false, 
    this.incluirPopulares = false, 
    this.incluirGaleria = false, 
    this.descripcion = "", 
    this.direccion = "", 
    this.pagoTarjeta = false, 
    this.pagoTerminal = false, 
    this.formatoHorarioTest, 
    this.formatoHorarioWeb, 
    this.pedidoMinimo = "", 
    this.tiempoAprox = "", 
    required this.costoEnvio});

  static Restaurant fromJson(Map json) {
    return Restaurant(
      menuCompleto: json['menu_completo'], 
      incluirPopulares: json['incluir_populares'], 
      incluirGaleria: json['incluir_galeria'], 
      descripcion: json['descripcion'], 
      direccion: json['direccion'], 
      pagoTarjeta: json['pago_tarjeta'], 
      pagoTerminal: json['terminal_domicilio'], 
      formatoHorarioTest: json['formato_horario_test'] ?? [], 
      formatoHorarioWeb: json['formato_horario_web'] ?? [], 
      pedidoMinimo: json['pedido_minimo'], 
      tiempoAprox: json['tiempo_aprox'], 
      costoEnvio: json['costo_envio']);
  }
}