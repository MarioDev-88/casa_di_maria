import 'package:elotes_make/models/Cards.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:elotes_make/system/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardService {
  getUsuarioTarjeta() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final _url = Uri.http('zesty.com.mx', '/apps/apiapps/v1/usuariotarjetas/');
    final _res = await http.post(
      _url,
      headers: headers,
      body: jsonEncode({
        "id_usuario" : prefs.getInt("id")
      })
    );
    if(_res.statusCode == 200) {
      print(_res.body);
      List _response = jsonDecode(_res.body);
      return _response.map((e) => Cards.fromJson(e)).toList();
    }
  }
}