import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elotes_make/system/globals.dart';

class Navbar extends StatefulWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {

  String _nombreUsuario = '';
  String _correoUsuario = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero  ,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_nombreUsuario), 
            accountEmail: Text(_correoUsuario)),
          const Divider(),
          ListTile(
            title: const Text('Perfil'),
            leading: const Icon(Icons.account_box),
            onTap: () => Navigator.pushNamed(context, "perfil"),
          ),
          const Divider(),
          ListTile(
            title: const Text('Historial'),
            leading: const Icon(Icons.history),
            onTap: () => Navigator.pushNamed(context, "historial"),
          ),
          const Divider(),
          ListTile(
            title: const Text('Aviso de privacidad'),
            leading: const Icon(Icons.privacy_tip),
            onTap: () {
              Navigator.pushNamed(context, "politicas");
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Cerrar sesión'),
            leading: const Icon(Icons.logout),
            onTap: _logout,
          ),
          const Divider(),
          ListTile(
            title: const Text('Eliminar cuenta'),
            leading: const Icon(Icons.delete_forever),
            onTap: _eliminarCuenta,
          )
        ],
      ),
    );
  }

  _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text(appName),
        content: Text('¿Esta seguro/a que desea salir de $appName?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(onPressed: () async {
            await prefs.remove('nombre');
            await prefs.remove('id');
            await prefs.remove('email');
            await prefs.remove('telefono');
            await prefs.remove('monedero');
            await prefs.remove('destacado');
            await prefs.remove('prime');
            await prefs.remove('premiere');
            await prefs.remove('pago');
            await prefs.remove('card');
            await prefs.remove('habilitar_tarjeta');
            await prefs.remove('customer_conekta');
            await prefs.remove('active');
            Navigator.popAndPushNamed(context, 'login');
          }, child: const Text('Si, cerrar sesión'))
        ],
      );
    });    
  }

  _eliminarCuenta() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text(appName),
        content: Text('¿Esta seguro/a que desea salir de $appName?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(onPressed: () async {
            await prefs.remove('nombre');
            await prefs.remove('id');
            await prefs.remove('email');
            await prefs.remove('telefono');
            await prefs.remove('monedero');
            await prefs.remove('destacado');
            await prefs.remove('prime');
            await prefs.remove('premiere');
            await prefs.remove('pago');
            await prefs.remove('card');
            await prefs.remove('habilitar_tarjeta');
            await prefs.remove('customer_conekta');
            await prefs.remove('active');
            Navigator.popAndPushNamed(context, 'login');
          }, child: const Text('Si, cerrar sesión'))
        ],
      );
    });
  }

  _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombreUsuario = prefs.getString('nombre') ?? '';
      _correoUsuario = prefs.getString('email') ?? '';
    });
  }
}