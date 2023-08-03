part of 'platillo_bloc.dart';

abstract class PlatilloState {
  int cantidad;
  String precio;
  String total;
  String precioSimple;
  String precioMultiple;
  List<String>? precioSencillo;
  List<String>? precioListaMultiple;

  PlatilloState({
    this.cantidad = 1, 
    this.precio = "0",
    this.total = "0",
    this.precioSimple = "0",
    this.precioMultiple = "0",
    this.precioSencillo,
    this.precioListaMultiple
  });

}

class PlatilloInitialState extends PlatilloState {
  PlatilloInitialState(int cantidad, String price): super(cantidad: cantidad, precio: price, precioSencillo: [], precioListaMultiple: []);
}

class PlatilloIncrementState extends PlatilloState {
  final int newCantidad;
  final String newPrecio;
  final String newTotal;
  final String newPrecioSimple;
  final List<String> newPrecioSencillo;
  final String newPrecioMultiple;
  final List<String> newPrecioListaMultiple;

  PlatilloIncrementState(this.newCantidad, this.newPrecio, this.newTotal,this.newPrecioSimple, this.newPrecioSencillo, this.newPrecioMultiple, this.newPrecioListaMultiple) 
    : super(cantidad: newCantidad, precio: newPrecio, total: newTotal, precioSencillo: newPrecioSencillo, precioSimple: newPrecioSimple, precioMultiple: newPrecioMultiple, precioListaMultiple: newPrecioListaMultiple);
}

class InitialPlatilloAdicionesState extends PlatilloState {
  final List<String> newPrecioSencillo;
  final List<String> newPrecioListaMultiple;

  InitialPlatilloAdicionesState(this.newPrecioSencillo, this.newPrecioListaMultiple);
}

class PlatilloAdicionSimpleState extends PlatilloState {
  final String newTotal;
  final List<String> newPrecioSencillo;
  final int newCantidad;
  final String newPrecio;
  final String newPrecioSimple;
  PlatilloAdicionSimpleState(this.newTotal, this.newPrecioSencillo, this.newCantidad, this.newPrecio, this.newPrecioSimple) 
    : super(total: newTotal, precioSencillo: newPrecioSencillo, precio: newPrecio, cantidad: newCantidad, precioSimple: newPrecioSimple);
}

class PlatilloAdicionMultipleState extends PlatilloState {
  final String newTotal;
  final List<String> newPrecioListaMultiple;
  final int newCantidad;
  final String newPrecio;
  final String newPrecioMultiple;
  final List<String> newPrecioSencillo;
  final String newPrecioSimple;

  PlatilloAdicionMultipleState(this.newTotal, this.newPrecioListaMultiple, this.newCantidad, this.newPrecio, this.newPrecioMultiple, this.newPrecioSencillo, this.newPrecioSimple)
    : super(total: newTotal, precioMultiple: newPrecioMultiple, precio: newPrecio, cantidad: newCantidad, precioListaMultiple: newPrecioListaMultiple, precioSencillo: newPrecioSencillo, precioSimple: newPrecioSimple);
}