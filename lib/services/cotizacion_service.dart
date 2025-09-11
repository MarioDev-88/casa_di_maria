import 'package:cotizador_casa_di_maria/models/Agenda.dart';
import 'package:cotizador_casa_di_maria/models/Cotizacion.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cotizador_casa_di_maria/system/globals.dart';

class CotizacionService {
  Future getCotizacion(String? folio, String? coordinador, String? telefono) async {
    String path = '/api/v1/getcotizacion/';    
    final _urlCategories = Uri.http(dominio, path, {'folio__icontains': folio, 'colaborador_nombre': coordinador, 'telefono_novio__icontains': telefono});
    final _res = await http.get(_urlCategories, headers: {'Content-Type': 'application/json; charset=UTF-8', 'Accept': 'application/json; charset=UTF-8'});

    if(_res.statusCode == 200) {
      final Map<String, dynamic> responseMap = jsonDecode(_res.body);
      final List<dynamic> objectsList = responseMap['objects'];

      return objectsList.map((e) => Cotizacion.fromJson(e)).toList();
    }
  }

  Future getContrato(String? folio, String? coordinador, String? telefono, String? desde, String? hasta) async {
    String path = '/api/v1/getcontratos/';    
    final _urlCategories = Uri.http(dominio, path, {'folio__icontains': folio, 'colaborador_nombre': coordinador, 'telefono_novio__icontains': telefono, "desde":desde, "hasta":hasta});
    final _res = await http.get(_urlCategories, headers: {'Content-Type': 'application/json; charset=UTF-8', 'Accept': 'application/json; charset=UTF-8'});

    if(_res.statusCode == 200) {
      final Map<String, dynamic> responseMap = jsonDecode(_res.body);
      final List<dynamic> objectsList = responseMap['objects'];

      return objectsList.map((e) => Cotizacion.fromJson(e)).toList();
    }
  }

  Future getAgenda(String? desde, String? hasta) async {
    String path = '/api/v1/getagenda/';    
    final _urlCategories = Uri.http(dominio, path, {"desde": desde, "hasta": hasta});
    final _res = await http.get(_urlCategories);
    if(_res.statusCode == 200) {
      final Map<String, dynamic> responseMap = jsonDecode(_res.body);
      final List<dynamic> objectsList = responseMap['objects'];
      return objectsList.map((e) => Agenda.fromJson(e)).toList();
    }
  }

  Future<Map<String, dynamic>> createCotizacion(Map data) async {
    final _urlCategories = Uri.http(dominio, '/api/v1/crearcotizacion/');
    final _res = await http.post(
      _urlCategories,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data)
    );
    final _response = jsonDecode(_res.body);
    print(_response);    

    if(_res.statusCode == 201) {
      return {
        'creado': true,
        'data': _response
      };
    }
    return _response;
  }

  Future crearContrato(int id) async {
     String path = '/api/v1/generarcontrato/';
     final _urlCategories = Uri.http(dominio, path);
     final _res = await http.post(_urlCategories, 
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_cotizacion': id}));

      final _response = jsonDecode(_res.body);
      if(_res.statusCode == 201) {
        return {
          'data': _response
        };
      }
  }
}