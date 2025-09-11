import 'package:cotizador_casa_di_maria/models/Evento.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cotizador_casa_di_maria/system/globals.dart';

class EventoService {
  Future getEvento() async {
    String path = '/api/v1/getevento/';    
    final _urlCategories = Uri.http(dominio, path);
    final _res = await http.get(_urlCategories);

    if(_res.statusCode == 200) {
      final Map<String, dynamic> responseMap = jsonDecode(_res.body);
      final List<dynamic> objectsList = responseMap['objects'];

      return objectsList.map((e) => Evento.fromJson(e)).toList();
    }
  }
}