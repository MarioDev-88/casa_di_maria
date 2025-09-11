import 'package:cotizador_casa_di_maria/themes/custom.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({ Key? key }) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String? _nombre = "";
  String? _telefono = "";
  String? _correo = "";
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombre = prefs.getString('nombre');
      _telefono = prefs.getString("telefono");
      _correo = prefs.getString("email");
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: const Image(image: AssetImage("assets/usercircle.png")),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(_nombre!, style: TextStyle(color: customTheme.primary, fontSize: 19.0, fontWeight: FontWeight.w700),),
                const SizedBox(height: 30),
                const Divider(),
                Text(_telefono!, style: TextStyle(color: Colors.grey, fontSize: 19.0, fontWeight: FontWeight.w700),),
                const Divider(),
                Text(_correo!, style: TextStyle(color: Colors.grey, fontSize: 19.0, fontWeight: FontWeight.w700),),
              ],
            ),
          ),
      ),
    );
  }
}