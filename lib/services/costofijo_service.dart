import 'package:cotizador_casa_di_maria/models/CostoFijo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cotizador_casa_di_maria/system/globals.dart';

class CostoFijoService {
  Future getCostoFijo() async {
    String path = '/api/v1/getcostofijo/';    
    final _urlCategories = Uri.http(dominio, path);
    final _res = await http.get(_urlCategories);

    if(_res.statusCode == 200) {
      final Map<String, dynamic> responseMap = jsonDecode(_res.body);
      final List<dynamic> objectsList = responseMap['objects'];

      return objectsList.map((e) => CostoFijo.fromJson(e)).toList();
    }
  }

  Future editCostoFijo(int id, String precio) async {
    String path = '/api/v1/editcostofijo/${id}/';    
    final _urlCategories = Uri.http(dominio, path);
    final _res = await http.patch(_urlCategories, headers: {'Content-Type': 'application/json'}, body: jsonEncode({"precio": precio}));

    if(_res.statusCode == 202) {
      return true;
    }
    return false;
  }
}