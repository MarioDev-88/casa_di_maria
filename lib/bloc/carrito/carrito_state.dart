part of 'carrito_bloc.dart';

abstract class CarritoState {
  bool servicio;
  String total;
  final List<Pedido>? pedido;

  List<Pedido> get pedidos => pedido!;

  CarritoState({
    required this.total,
    required this.servicio,
    this.pedido
  });

} 

class CarritoInitialState extends CarritoState {
  CarritoInitialState() : super(servicio: true, total: "0", pedido: []);
}

class CarritoUpdateState extends CarritoState {
  final List<Pedido> newPedido;
  final String newTotal;

  CarritoUpdateState(this.newTotal, this.newPedido) : super(servicio:true, total: newTotal, pedido: newPedido);
}

class CarritoServicioState extends CarritoState {
  final bool newServicio;
  final String newTotal;
  final List<Pedido> newPedido;
  CarritoServicioState(this.newServicio, this.newTotal, this.newPedido) : super(servicio: newServicio, total: newTotal, pedido: newPedido);
}