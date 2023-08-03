import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
part 'platillo_event.dart';
part 'platillo_state.dart';

class PlatilloBloc extends Bloc<PlatilloEvent, PlatilloState> {
  PlatilloBloc(int cantidad, String price) : super(PlatilloInitialState(cantidad, price)) {
    
    on<InitialPlatillo>((event, emit) {
      state.total = (double.parse(event.newPrecio) * event.newCantidad).toString();
      emit(PlatilloIncrementState(event.newCantidad, event.newPrecio, state.total, state.precioSimple, state.precioSencillo!, state.precioMultiple, state.precioListaMultiple!));
    });

    on<InitialPlatilloAdicionesEvent>((event, emit) {
      state.precioSencillo = event.newPrecioSencillo;
      state.precioListaMultiple = event.newPrecioMultiple;
      emit(InitialPlatilloAdicionesState(state.precioSencillo!, state.precioListaMultiple!));
    });

    on<ChangeQuantityEvent>((event, emit) {
      state.cantidad++;
      state.precioSencillo = state.precioSencillo ?? [];
      state.precioListaMultiple = state.precioListaMultiple ?? [];
      state.total = ((double.parse(state.precio) + double.parse(state.precioSimple) + double.parse(state.precioMultiple)) * state.cantidad).toString();
      emit(PlatilloIncrementState(state.cantidad, state.precio, state.total, state.precioSimple, state.precioSencillo!, state.precioMultiple, state.precioListaMultiple!));
    });

    on<ChangeQuantityLessEvent>((event, emit) {
      if(state.cantidad > 1) {
        state.cantidad--;
      }
      state.precioSencillo = state.precioSencillo ?? [];
      state.precioListaMultiple = state.precioListaMultiple ?? [];
      state.total = ((double.parse(state.precio) + double.parse(state.precioSimple) + double.parse(state.precioMultiple)) * state.cantidad).toString();
      emit(PlatilloIncrementState(state.cantidad, state.precio, state.total, state.precioSimple, state.precioSencillo!, state.precioMultiple, state.precioListaMultiple!));
    });

    on<ChangeAdicionSimplePrecioEvent>((event, emit) {
      state.precioSimple = "0";
      state.precioSencillo = state.precioSencillo ?? [];
      if(state.precioSencillo!.isEmpty) {
        state.precioSencillo = event.newPrecioSencillo;
        state.precioSencillo!.insert(event.posicion, event.newAdicionSimple);
      } else {
        try {
          state.precioSencillo!.removeAt(event.posicion);
          state.precioSencillo!.insert(event.posicion, event.newAdicionSimple);          
        } catch (e) {
          state.precioSencillo!.insert(event.posicion, event.newAdicionSimple);
        }
      }
      state.precioSencillo!.forEach((el) { 
        if(el.isNotEmpty) {
          state.precioSimple = (double.parse(state.precioSimple) + double.parse(el)).toString();
        }        
      });     
      state.total = ((double.parse(state.precio) + double.parse(state.precioSimple) + double.parse(state.precioMultiple)) * state.cantidad).toString();
      emit(PlatilloAdicionSimpleState(state.total, state.precioSencillo!, state.cantidad, state.precio, state.precioSimple));
    });

    on<ChangeAdicionMultiplePrecioEvent>((event, emit) {
      state.precioMultiple = "0";
      state.precioListaMultiple = state.precioListaMultiple ?? [];
      if(state.precioListaMultiple!.indexOf(event.newAdicionMultiple) == -1) {
        state.precioListaMultiple!.add(event.newAdicionMultiple);
      } else {
        final index = state.precioListaMultiple!.indexOf(event.newAdicionMultiple);
         state.precioListaMultiple!.removeAt(index);
      }
      // if(state.precioListaMultiple!.isEmpty) {
      //   //state.precioListaMultiple = event.newPrecioListaMultiple;
      //   //state.precioListaMultiple!.insert(event.posicion, event.newAdicionMultiple);
      //   state.precioListaMultiple!.add(event.newAdicionMultiple);
      // } else {
      //   try {
      //     state.precioListaMultiple!.removeAt(event.posicion);
      //     state.precioListaMultiple!.insert(event.posicion, event.newAdicionMultiple);          
      //   } catch (e) {
      //     state.precioListaMultiple!.insert(event.posicion, event.newAdicionMultiple);
      //   }
      // }
      state.precioListaMultiple!.forEach((el){
        if(el.isNotEmpty) {
          state.precioMultiple = (double.parse(state.precioMultiple) + double.parse(el)).toString();
        }        
      }); 
      state.total = ((double.parse(state.precio) + double.parse(state.precioSimple) + double.parse(state.precioMultiple)) * state.cantidad).toString();
      emit(PlatilloAdicionMultipleState(state.total, state.precioListaMultiple!, state.cantidad, state.precio, state.precioMultiple, state.precioSencillo!, state.precioSimple));
    });    
  }

}