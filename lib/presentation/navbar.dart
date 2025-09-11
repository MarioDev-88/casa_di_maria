import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cotizador_casa_di_maria/system/globals.dart';

class Navbar extends StatefulWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {

  String _nombreUsuario = 'Usuario';
  String _correoUsuario = 'DC';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFFF5F1F1),
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagen de perfil
                const Icon(Icons.account_circle_outlined, size: 50, color: Color(0xFF253D5B)),
                const SizedBox(width: 15),
                // Información del usuario
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _nombreUsuario,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF253D5B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _correoUsuario,
                      style: const TextStyle(color: Color(0xFF253D5B), fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Cotizar', style: TextStyle(color: Color(0xFF253D5B)),),
            leading: const Icon(Icons.note_add),
            onTap: () => Navigator.pushNamed(context, "cotizar"),
          ),
          ListTile(
            title: const Text('Cotizaciones', style: TextStyle(color: Color(0xFF253D5B)),),
            leading: const Icon(Icons.request_quote),
            onTap: () => Navigator.pushNamed(context, "cotizaciones"),
          ),
          ListTile(
            title: const Text('Agenda', style: TextStyle(color: Color(0xFF253D5B)),),
            leading: const Icon(Icons.event_note),
            onTap: () {
              Navigator.pushNamed(context, "agenda");
            },
          ),
          ListTile(
            title: const Text('Contratos', style: TextStyle(color: Color(0xFF253D5B)),),
            leading: const Icon(Icons.receipt_long_outlined),
            onTap: () {
              Navigator.pushNamed(context, "contratos");
            },
          ),
          ListTile(
            title: const Text('Costos', style: TextStyle(color: Color(0xFF253D5B)),),
            leading: const Icon(Icons.price_change),
            onTap: () {
              Navigator.pushNamed(context, "register");
            },
          ),
          ListTile(
            title: const Text('Coordinadores', style: TextStyle(color: Color(0xFF253D5B)),),
            leading: const Icon(Icons.account_box_outlined),
            onTap: () {
              Navigator.pushNamed(context, "coordinadores");
            },
          ),
          ListTile(
            title: const Text('Cerrar Sesión', style: TextStyle(color: Color(0xFF253D5B)),),
            leading: const Icon(Icons.logout),
            onTap: _logout,
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
            await prefs.remove('identificacion');
            await prefs.remove('active');
            Navigator.pushReplacementNamed(context, 'login');
          }, child: const Text('Si, cerrar sesión'))
        ],
      );
    });
  }

  _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getInt("id") != "null") {
      setState(() {
        _nombreUsuario = prefs.getString('nombre') ?? '';
        _correoUsuario = prefs.getString('identificacion') ?? '';
      });
    } else {
      _nombreUsuario = "Inicia sesión";
    }
    
  }
}