import 'package:elotes_make/models/Categories.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:elotes_make/system/globals.dart';

class CategoriesService {
  Future getCategories() async {
    final _urlCategories = Uri.http('zesty.com.mx', '/apps/apiapps/v1/menucompleto/');
    final _res = await http.post(
      _urlCategories,
      headers: headers
    );

    if(_res.statusCode == 200) {
      final List<dynamic> _response = jsonDecode(_res.body);
      return _response.map((e) => Categories.fromJson(e)).toList();
    }
  }
}