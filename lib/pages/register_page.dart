import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elotes_make/system/globals.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({ Key? key }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _url = Uri.https('zesty.com.mx', '/apps/apiapps/v1/addusuario/');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final MaterialStatesController _button = MaterialStatesController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      backgroundColor: Colors.yellow,
      body: _crearForm(),
    );
  }

  Widget _crearForm() {
    return Form(
      key: _formKey,
      child: ListView(        
        children: [
          Container(
              margin: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  label: const Text('Nombre completo')
                ),
                validator: (String? value) {
                  if(value == null || value.isEmpty) {
                    return 'Ingrese su nombre';
                  }
                  return null;
                },
              ),
            ),
          Container(
              margin: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  label: const Text('Correo electrónico')
                ),
                validator: (String? value) {
                  if(value == null || value.isEmpty) {
                    return 'Ingrese su correo electrónico';
                  }
                  return null;
                },
              ),
            ),
          Container(
              margin: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: _phone,
                maxLength: 10,
                keyboardType: TextInputType.phone,
                autocorrect: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  label: const Text('Teléfono')
                ),
                validator: (String? value) {
                  if(value == null || value.isEmpty || value.length < 10) {
                    return 'Ingrese su teléfono / Teléfono menor a 10 dígitos';
                  }
                  return null;
                },
              ),
            ),
          Container(
              margin: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: _pwd,
                obscureText: true,
                autocorrect: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  label: const Text('Contraseña')
                ),
                validator: (String? value) {
                  if(value == null || value.isEmpty) {
                    return 'Ingrese su contraseña';
                  }
                  return null;
                },
              ),
            ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: const Center(
              child: Text('Al crear una cuenta estoy de acuerdo con los Términos y Condiciones'),
            ),
          ),
          Center(
            child: Container(
              width: 200.0,
              height: 50.0,
              child: ElevatedButton(
                statesController: _button,
                onPressed: () {
                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  if (_formKey.currentState!.validate()) {
                    // Process data.
                    _register();
                  }
                },
                child: const Text('Crear cuenta'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _register() async {
    final user = {
      "nombre" : _name.text,
      "correo" : _email.text,
      "telefono" : _phone.text,
      "password" : _pwd.text
    };
    final res = await http.post(
      _url,
      headers: headers,
      body: jsonEncode(user)
    );
    if(res.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Correo ya registrado'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        )
      );
    } else {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = jsonDecode(res.body);
      prefs.setInt('id', response['id']);
      prefs.setString('email', response['correo']);
      prefs.setString('nombre', response['nombre']);
      prefs.setString('telefono', response['telefono']);
      prefs.setString('monedero', response['monedero']);
      prefs.setBool('destacado', response['destacado']);
      prefs.setBool('prime', response['prime']);
      prefs.setBool('premiere', response['premiere']);
      prefs.setString('pago', "Efectivo");
      prefs.setString('card', "");
      prefs.setBool('habilitar_tarjeta', response['habilitar_tarjeta']);
      prefs.setString('customer_conekta', response['customer_conekta'] ?? "");
      prefs.setBool('active', true);
      _name.clear();
      _email.clear();
      _phone.clear();
      _pwd.clear();
      Navigator.pushNamed(context, 'select');
    }
  }
}