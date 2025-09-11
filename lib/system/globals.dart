import 'package:flutter/foundation.dart';

String dominio = '104.248.52.156';
String appName = 'Casa di Maria';
String appId = '1';
String restId = '';
double porcentajeConekta = 3.0;
String osname = defaultTargetPlatform.name;
String versionApp = "";
final _url = Uri.http('104.248.52.156', '/api/v1/');
final _currDt = DateTime.now();
final headers = {
  'APPNAME' : appName,
  'APPID' : appId,
  'RESTID' : restId,
  'Content-Type': 'application/json',
  'APPDAY' : _currDt.weekday.toString(),
  'APPHOUR' : _currDt.hour.toString() + ':' + _currDt.minute.toString() + ':' + _currDt.second.toString()
};