class Pedido {
  // int? _elegir;
  int? _restaurante;
  int? _platillo;
  String? _nombrePlatillo;
  int? _cantidad;
  String? _nota;
  String? _precio;
  String? _total;
  final List _adiciones = [];
  // int? _contador;
  // String? _codigo;
  // int? _favorito;  

  Map<String, dynamic> get map {
    return {
      "id" : _platillo,
      "nombre": _nombrePlatillo,
      "cantidad": _cantidad,
      "precio" : _precio,
      "total" : _total,
      "nota" : _nota,
      "costo_adiciones": _adiciones.fold(0, (previousValue, element) {
        return (double.parse(previousValue.toString()) + double.parse(element['precio'])).toString();
      }),
      "adiciones" : _adiciones
    };
  }
  int get restaurant{
    return _restaurante!;
  }

  int get platillo {
    return _platillo!;
  }

  String get nombre{
    return _nombrePlatillo!;
  }

  int get cantidad {
    return _cantidad!;
  }

  String get precio {
    return _precio!;
  }

  String get total{
    return _total!;
  }

  List get adiciones{
    return _adiciones;
  }

  set restaurante(int value) {
    _restaurante = value;
  }

  set platillo(int value) {
    _platillo = value;
  }
  
  set nombrePlatillo(String value) {
    _nombrePlatillo = value;
  }

  set cantidad(int value) {
    _cantidad = value;
  }

  set nota(String value) {
    _nota = value;
  }
  
  set precio(String value) {
    _precio = value;
  }

  set total(String value) {
    _total = value;
  }

  void agregarAdicionSimple(List adicion) {    
    var result = adicion.where((element) => element != "");
    if(result.isNotEmpty) {
      print(adicion);
      _adiciones.insertAll(0, adicion);
    }
  }

  void agregarAdicion(Map adicion) {
    print(adicion);
    if(_adiciones.isEmpty) {
      _adiciones.add(adicion);
    } else {            
      _adiciones.add(adicion);
      final index = _adiciones.indexWhere((element) => element["id"] == adicion['id']);
      print(index);
    }
    print(_adiciones);
  }

  void quitarAdicion(int adicion) {
    final index = _adiciones.indexWhere((element) => element["id"] == adicion);
    _adiciones.removeAt(index);
  }

  Pedido();

}