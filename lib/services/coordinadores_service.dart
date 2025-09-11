import 'package:cotizador_casa_di_maria/models/Coordinador.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cotizador_casa_di_maria/system/globals.dart';

class CoordinadoresService {
  Future getCoordinadores(String nombre) async {
    String path = '/api/v1/getcolaboradores/';    
    final _urlCategories = Uri.http(dominio, path, {'nombre__icontains': nombre});
    final _res = await http.get(_urlCategories);

    if(_res.statusCode == 200) {
      final Map<String, dynamic> responseMap = jsonDecode(_res.body);
      final List<dynamic> objectsList = responseMap['objects'];

      return objectsList.map((e) => Coordinador.fromJson(e)).toList();
    }
  }

  Future addCoordinador(String nombre) async {
    final _urlAddCoordinador = Uri.http(dominio, '/api/v1/createcolaborador/');
    final _res = await http.post(_urlAddCoordinador, body: jsonEncode({'nombre': nombre}));

    if(_res.statusCode == 201) {
      return true;
    }
    return false;
  }

  Future deleteCoordinador(int id) async {
    final _urlDeleteCoordinador = Uri.http(dominio, '/api/v1/deletecolaborador/${id}/');
    final _res = await http.delete(_urlDeleteCoordinador);
    if(_res.statusCode == 204) {
      return true;
    }
    return false;
  }
}