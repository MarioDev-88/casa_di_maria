import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elotes_make/bloc/carrito/carrito_bloc.dart';
import '../themes/custom.dart';

class Carrito {
  Widget showFloatingButton() {
    return BlocBuilder<CarritoBloc, CarritoState>(
      builder: ( _ , state) {
        return badges.Badge(     
          position: badges.BadgePosition.topEnd(top: -10, end: -5),
          badgeContent: Text(
            state.pedido!.length.toString(), 
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0
            ),
          ),
          badgeStyle: badges.BadgeStyle(
            badgeColor: customTheme.primary,
            padding: const EdgeInsets.all(8.0),        
          ),
          child: FloatingActionButton(
            backgroundColor: state.servicio ? customTheme.secondary : Colors.grey,
            tooltip: 'Ver carrito',
            onPressed: state.servicio ? () async {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              if(prefs.getInt("id") == null) {
                showDialog(context: _, barrierDismissible: false, builder: (_) {
                  return AlertDialog(
                    title: const Text('Aviso'),
                    content: const Text('Lo sentimos, inicia sesión o regístrate para poder ordenar'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(_).pop(), child: const Text('Cerrar'))
                    ],
                  );
                });
              } else {
                Navigator.pushNamed(_, "orden");
              }              
            } : null,
            child: const Icon(Icons.shopping_cart),
          ),
        );
      },
    );
  }
  Widget showBottomBar() {
    final numberFormat = NumberFormat.currency(locale: 'es_MX', symbol:"\$");
    return BlocBuilder<CarritoBloc, CarritoState>(
      builder: (_, state){
        return BottomAppBar(
          color: state.servicio ? customTheme.primary : Colors.grey,  
          height: 40.0,            
          shape: const CircularNotchedRectangle(),
          child: Row(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.only(right:20.0),
                child: Text(
                  state.servicio ? 
                    numberFormat.format(double.parse(state.total)) :
                    "Cerrado",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700
                  ),
                ),
              )
            ],
          ),
      );
    }
    );
  }
}