import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:cotizador_casa_di_maria/models/Restaurant.dart';
import 'package:cotizador_casa_di_maria/system/globals.dart';

class RestaurantService {
  Future<Restaurant> getDetalle() async {
    final _urlDetalle = Uri.https('zesty.com.mx', '/apps/apiapps/v1/detallesrestaurante/');
    final res = await http.post(
      _urlDetalle,
      headers: headers,
      body: jsonEncode({})
    );
    if(res.statusCode == 200) {
       final Map<String, dynamic> data = jsonDecode(res.body);
       return Restaurant.fromJson(data);
    } else {
      throw Exception();
    }
    //return {};
  }
}