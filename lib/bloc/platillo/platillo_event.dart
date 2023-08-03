
part of 'platillo_bloc.dart';

@immutable
abstract class PlatilloEvent{}

class InitialPlatillo extends PlatilloEvent {
  final int newCantidad;
  final String newPrecio;

  InitialPlatillo(this.newCantidad, this.newPrecio);
}

class InitialPlatilloAdicionesEvent extends PlatilloEvent {
  final List<String> newPrecioSencillo;
  final List<String> newPrecioMultiple;

  InitialPlatilloAdicionesEvent(this.newPrecioSencillo, this.newPrecioMultiple);
}

class ChangeQuantityEvent extends PlatilloEvent{
  ChangeQuantityEvent();
}

class ChangeQuantityLessEvent extends PlatilloEvent{
  ChangeQuantityLessEvent();
}

class ChangeAdicionSimplePrecioEvent extends PlatilloEvent {
  final String newAdicionSimple;
  final int posicion;
  final List<String> newPrecioSencillo;

  ChangeAdicionSimplePrecioEvent(this.newAdicionSimple, this.posicion, this.newPrecioSencillo);
}

class ChangeAdicionMultiplePrecioEvent extends PlatilloEvent {
  final String newAdicionMultiple;
  final int posicion;
  final List<String> newPrecioListaMultiple;

  ChangeAdicionMultiplePrecioEvent(this.newAdicionMultiple, this.posicion, this.newPrecioListaMultiple);
}