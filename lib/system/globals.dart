import 'package:flutter/foundation.dart';


String appName = 'Elotes Make';
String appId = '4';
String restId = '434';
double porcentajeConekta = 3.0;
String osname = defaultTargetPlatform.name;
String versionApp = "";
final _currDt = DateTime.now();
final headers = {
  'APPNAME' : appName,
  'APPID' : appId,
  'RESTID' : restId,
  'Content-Type': 'application/json',
  'APPDAY' : _currDt.weekday.toString(),
  'APPHOUR' : _currDt.hour.toString() + ':' + _currDt.minute.toString() + ':' + _currDt.second.toString()
};