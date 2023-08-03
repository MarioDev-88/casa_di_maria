part of 'carrito_bloc.dart';

@immutable
abstract class CarritoEvent{}

class CarritoInitialEvent extends CarritoEvent{
  final String total;

  CarritoInitialEvent(this.total);
}

class CarritoUpdateEvent extends CarritoEvent {
  final String newTotal;
  final Pedido newPedido;
  final int index;
  final bool edit;

  CarritoUpdateEvent(this.newTotal, this.newPedido, this.index, this.edit);
}

class CarritoDeleteEvent extends CarritoEvent {
  final int index;

  CarritoDeleteEvent(this.index);
}

class CarritoServicioEvent extends CarritoEvent {
  final bool servicio;

  CarritoServicioEvent(this.servicio);
}