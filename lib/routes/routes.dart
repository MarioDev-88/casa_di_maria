import 'package:flutter/material.dart';

import 'package:elotes_make/pages/historial_page.dart';
import 'package:elotes_make/pages/orden_page.dart';
import 'package:elotes_make/pages/perfil_page.dart';
import 'package:elotes_make/pages/politicas_privacidad_page.dart';
import 'package:elotes_make/pages/detalle_platillo.dart';
import 'package:elotes_make/pages/galeria_page.dart';
import 'package:elotes_make/pages/populares_page.dart';
import 'package:elotes_make/pages/platillos_page.dart';
import 'package:elotes_make/pages/categories_page.dart';
import 'package:elotes_make/pages/checkin_page.dart';
import 'package:elotes_make/pages/add_card_page.dart';
import 'package:elotes_make/pages/pago_vale.dart';
import 'package:elotes_make/pages/vales_consumo_page.dart';
import 'package:elotes_make/pages/direction_page.dart';
import 'package:elotes_make/pages/restaurant_page.dart';
import 'package:elotes_make/pages/select_main.dart';
import 'package:elotes_make/pages/login_page.dart';
import 'package:elotes_make/pages/register_page.dart';
import 'package:elotes_make/pages/index_page.dart';

Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    '/' : (BuildContext context) => const IndexPage(),
    'login' : (BuildContext context) => const LoginPage(),
    'register' : (BuildContext context) => const RegisterPage(),
    'select' : (BuildContext context) => const SelectMainPage(),
    'checkin' : (BuildContext context) => const CheckinPage(),
    'direction' : (BuildContext context) => const DirectionPage(),
    'restaurant' : (BuildContext context) => const RestaurantPage(),
    'beneficios' : (BuildContext context) => const ValesConsumoPage(),
    'pago_vale' : (BuildContext context) => const PagoValePage(),
    'add_card' : (BuildContext context) => const AddCardPage(),
    'categories' : (BuildContext context) => const CategoriesPage(),
    'platillos' : (BuildContext context) => const PlatillosPage(),
    'populares' : (BuildContext context) => const PopularesPage(),
    'galeria' : (BuildContext context) => const GaleriaPage(),
    'platillo' : (BuildContext context) => const DetallePage(),
    'politicas' : (BuildContext context) => const PoliticasPage(),
    'perfil' : (BuildContext context) => const PerfilPage(),
    'orden' : (BuildContext context) => const OrdenPage(),
    'historial' : (BuildContext context) => const HistorialPage(),
  };
}