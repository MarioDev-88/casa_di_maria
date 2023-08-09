import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../models/Pedido.dart';

part 'carrito_event.dart';
part 'carrito_state.dart';

class CarritoBloc extends Bloc<CarritoEvent, CarritoState>{
  CarritoBloc() : super(CarritoInitialState()) {
    on<CarritoInitialEvent>((event, emit) {
      emit(CarritoInitialState());
    });

    on<CarritoServicioEvent>((event, emit) {
      state.servicio = event.servicio;
      emit(CarritoServicioState(event.servicio, state.total, state.pedido!));
    });

    on<CarritoUpdateEvent>((event, emit) {
      if(!event.edit) {
        state.pedido!.add(event.newPedido);
        state.total = (double.parse(state.total) + double.parse(event.newTotal)).toString();
      } else {
        double _total = 0.0;
        state.pedido![event.index] = event.newPedido;
        state.pedido!.forEach((element) {
          _total += double.parse(element.total);
        });        
        state.total = _total.toString();
      }
      emit(CarritoUpdateState( state.total, state.pedido!));
    });

    on<CarritoDeleteEvent>((event, emit) {
      final pedido = state.pedido!.elementAt(event.index);
      state.total = (double.parse(state.total) - double.parse(pedido.total)).toString();
      state.pedido!.remove(pedido);
      emit(CarritoUpdateState( state.total, state.pedido!));
    });
  }

}