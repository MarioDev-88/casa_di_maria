import 'dart:async';

import 'package:cotizador_casa_di_maria/models/Complemento.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cotizador_casa_di_maria/system/globals.dart';
import 'package:cotizador_casa_di_maria/models/Platillos.dart';

class PlatillosService {
  Future getPlatillo() async {
    String path = '/api/v1/getplatillos/';    
    final _urlCategories = Uri.http(dominio, path);
    final _res = await http.get(_urlCategories);

    if(_res.statusCode == 200) {
      final Map<String, dynamic> responseMap = jsonDecode(_res.body);
      final List<dynamic> objectsList = responseMap['objects'];

      return objectsList.map((e) => Platillos.fromJson(e)).toList();
    }
  }

  Future getPlatilloJoven() async {
    String path = '/api/v1/getplatillojoven/';    
    final _urlCategories = Uri.http(dominio, path);
    final _res = await http.get(_urlCategories);

    if(_res.statusCode == 200) {
      final Map<String, dynamic> responseMap = jsonDecode(_res.body);
      final List<dynamic> objectsList = responseMap['objects'];

      return objectsList.map((e) => Platillos.fromJson(e)).toList();
    }
  }

  Future getComplemento() async {
    String path = '/api/v1/getcomplemento/';    
    final _urlCategories = Uri.http(dominio, path);
    final _res = await http.get(_urlCategories);

    if(_res.statusCode == 200) {
      final Map<String, dynamic> responseMap = jsonDecode(_res.body);
      final List<dynamic> objectsList = responseMap['objects'];

      return objectsList.map((e) => Complemento.fromJson(e)).toList();
    }
  }

  Future editPlatillo(int id, String precio) async {
    String path = '/api/v1/editplatillo/${id}/';    
    final _urlCategories = Uri.http(dominio, path);
    final _res = await http.patch(_urlCategories, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'precio': precio}));

    if(_res.statusCode == 202) {
      return true;
    }
    return false;
  }
}