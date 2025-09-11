import 'package:cotizador_casa_di_maria/pages/agenda_page.dart';
import 'package:cotizador_casa_di_maria/pages/contratos_page.dart';
import 'package:cotizador_casa_di_maria/pages/cotizaciones_page.dart';
import 'package:flutter/material.dart';

import 'package:cotizador_casa_di_maria/pages/historial_page.dart';
import 'package:cotizador_casa_di_maria/pages/orden_page.dart';
import 'package:cotizador_casa_di_maria/pages/perfil_page.dart';
import 'package:cotizador_casa_di_maria/pages/politicas_privacidad_page.dart';
import 'package:cotizador_casa_di_maria/pages/categories_page.dart';
import 'package:cotizador_casa_di_maria/pages/checkin_page.dart';
import 'package:cotizador_casa_di_maria/pages/add_card_page.dart';
import 'package:cotizador_casa_di_maria/pages/pago_vale.dart';
import 'package:cotizador_casa_di_maria/pages/vales_consumo_page.dart';
import 'package:cotizador_casa_di_maria/pages/direction_page.dart';
import 'package:cotizador_casa_di_maria/pages/restaurant_page.dart';
import 'package:cotizador_casa_di_maria/pages/select_main.dart';
import 'package:cotizador_casa_di_maria/pages/login_page.dart';
import 'package:cotizador_casa_di_maria/pages/register_page.dart';
import 'package:cotizador_casa_di_maria/pages/index_page.dart';
import 'package:cotizador_casa_di_maria/pages/coordinadores_page.dart';

import '../pages/cotizar_page.dart';

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
    'politicas' : (BuildContext context) => const PoliticasPage(),
    'perfil' : (BuildContext context) => const PerfilPage(),
    'orden' : (BuildContext context) => const OrdenPage(),
    'historial' : (BuildContext context) => const HistorialPage(),
    'coordinadores': (BuildContext context) => const CoordinadoresPage(),
    'cotizar': (BuildContext context) => const CotizarPage(),
    'cotizaciones': (BuildContext context) => const CotizacionesPage(),
    'contratos': (BuildContext context) => const ContratosPage(),
    'agenda': (BuildContext context) => const AgendaPage(),
  };
}