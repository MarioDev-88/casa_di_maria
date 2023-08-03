import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:elotes_make/system/globals.dart';
import 'package:elotes_make/models/Platillos.dart';

class PlatillosService {
  Future getPlatillos(int id) async {
    final _urlPlatillos = Uri.http('zesty.com.mx', '/apps/apiapps/v1/platilloscategoria/');
    final _res = await http.post(
      _urlPlatillos,
      headers: headers,
      body: jsonEncode({
        "id_categoria" : id,
        "page" : 1,
        "page_total" : 0
      })
    );
    if(_res.statusCode == 200) {
      final List<dynamic> _response = jsonDecode(_res.body);
      return _response.map((e) => Platillos.fromJson(e)).toList();
    }
  }

  Future getPlatilloPopulares() async {
    final _urlPlatillos = Uri.http('zesty.com.mx', '/apps/apiapps/v1/populares/');
    final _res = await http.post(
      _urlPlatillos,
      headers: headers
    );
    if(_res.statusCode == 200) {
      final List<dynamic> _response = jsonDecode(_res.body);
      return _response.map((e) => Platillos.fromJson(e)).toList();
    }
  }

  Future getPlatilloGaleria() async {
    final _urlPlatillos = Uri.http('zesty.com.mx', '/apps/apiapps/v1/secciongaleria/');
    final _res = await http.post(
      _urlPlatillos,
      headers: headers
    );
    if(_res.statusCode == 200) {
      final List<dynamic> _response = jsonDecode(_res.body);
      return _response.map((e) => Platillos.fromJson(e)).toList();
    }
  }

  Future<Platillos> getPlatillo(int id) async {
    final _urlPlatillos = Uri.http('zesty.com.mx', '/apps/apiapps/v1/detalleplatillo/');
    final _res = await http.post(
      _urlPlatillos,
      headers: headers,
      body: jsonEncode({
        "id_platillo" : id
      })
    );
    if(_res.statusCode == 200) {
      final Map<String, dynamic> _response = jsonDecode(_res.body);
      return Platillos.fromJson(_response);
    } else {
      throw Exception();
    }
  }
}