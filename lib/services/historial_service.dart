import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elotes_make/system/globals.dart';

class HistorialService {
  Future getHistorial() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final _urlHistorial = Uri.http('zesty.com.mx', '/apps/apiapps/v1/listadopedidos/');
    final _res = await http.post(
      _urlHistorial,
      headers: headers,
      body: jsonEncode({
        "usuario" : prefs.getInt("id")
      })
    );
    if(_res.statusCode == 200) {
      final List<dynamic> _response = jsonDecode(_res.body);
      return _response.toList();
      //return _response.map((e) => Platillos.fromJson(e)).toList();
    }
  }
}