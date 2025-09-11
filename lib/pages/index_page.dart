import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:location/location.dart';

import 'package:cotizador_casa_di_maria/system/globals.dart';
class IndexPage extends StatefulWidget {
  const IndexPage({ Key? key }) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {

  // final Location location = Location();

  @override
  void initState() {
    // TODO: implement initState  
    //getLoc();  
    super.initState();      
    _loadPreferences();  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(""), backgroundColor: const Color(0xFFF5F1F1),),
      backgroundColor: const Color(0xFFF5F1F1),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(          
            image: DecorationImage(image: AssetImage("assets/fondo_casadimaria.jpeg"), fit: BoxFit.cover)
          ),
          child: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: 
                [
                  Image.asset(
                    'assets/LogoCasaDiMaria.png', // Asegúrate de añadir esta imagen a tu proyecto
                  ),
                  const CircularProgressIndicator()
                ]
              ),
          ),
        ),
      ),
    );
  }

  _loadPreferences() async {
    //final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    //final version = packageInfo.version;
    //versionApp = version;
    final SharedPreferences prefs = await SharedPreferences.getInstance();    
    final active = prefs.getBool('active') ?? false;
    Future.delayed(const Duration(seconds: 2), () {
      if(!active || prefs.getInt("id") == null) {
        Navigator.popAndPushNamed(context, 'login');
      } else {
        Navigator.popAndPushNamed(context, 'select');
      }      
    });
    
  }

  getLoc() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool _serviceEnabled;
    // PermissionStatus _permissionGranted;
    // LocationData _currentPosition;
    // _serviceEnabled = await location.serviceEnabled();
    // if (!_serviceEnabled) {
    //   _serviceEnabled = await location.requestService();
    //   if (!_serviceEnabled) {
    //     return;
    //   }
    // }
    // _permissionGranted = await location.hasPermission();
    // if (_permissionGranted == PermissionStatus.denied) {
    //   _permissionGranted = await location.requestPermission();
    //   if (_permissionGranted != PermissionStatus.granted) {
    //     return;
    //   }
    // }
    // _currentPosition = await location.getLocation();
    // prefs.setDouble("latitude", _currentPosition.latitude!);
    // prefs.setDouble("longitude", _currentPosition.longitude!);
  }
}