import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cotizador_casa_di_maria/themes/custom.dart';
import 'package:cotizador_casa_di_maria/system/globals.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final Uri _whatsapp = Uri.parse("https://wa.me/526623156835");
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.clear();
    _pwdController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1F1),
      body: SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/LogoCasaDiMaria.png',
                  ),
                  const Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDAA520), // Color mostazas
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      floatingLabelBehavior: FloatingLabelBehavior.always,                    
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu usuario';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _pwdController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      floatingLabelBehavior: FloatingLabelBehavior.always,                    
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Aquí iría la lógica de autenticación
                          if(_emailController.text.isEmpty || _pwdController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Usuario / Contraseña son requeridos'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              )
                            );
                          } else {
                            login(_emailController.text, _pwdController.text);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDAA520), // Color mostazas
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Ingresar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
      ),
    );
  }

  void login(String email, String pwd) async {
    final Uri _url = Uri.http(dominio, '/api/v1/login/', {'id': email, 'pwd': pwd});
    final res = await http.get(
      _url,      
    );    
    if(res.statusCode == 200) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = jsonDecode(res.body);    
      prefs.setInt('id', response['id']);
      prefs.setString('nombre', response['nombre']);
      prefs.setString('identificacion', response['identificacion']);
      // prefs.setString('telefono', response['telefono']);
      // prefs.setString('monedero', response['monedero']);
      // prefs.setBool('destacado', response['destacado']);
      // prefs.setBool('prime', response['prime']);
      // prefs.setBool('premiere', response['premiere']);
      // prefs.setString('pago', "Efectivo");
      // prefs.setString('card', "");
      // prefs.setBool('habilitar_tarjeta', response['habilitar_tarjeta']);
      // prefs.setString('customer_conekta', response['customer_conekta'] ?? "");
      prefs.setBool('active', true);
      // _emailController.clear();
      // _pwdController.clear();
      Navigator.pushReplacementNamed(context, 'select');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Usuario / Contraseña incorrectos'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }

  // void forgetEmail(String email) async {
  //   print(email);
  //   final res = await http.post(
  //     _url,
  //     headers: headers,
  //     body: jsonEncode( {
  //       'correo' : email
  //     })
  //   );
  //   print(res.body);
  //   if(res.statusCode == 200) {
  //     Navigator.of(context).pop();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         backgroundColor: Colors.green,
  //         content: Text('Correo electrónico enviado!'),
  //         duration: Duration(seconds: 2),
  //         behavior: SnackBarBehavior.floating,
  //       )
  //     );
  //   }
  // }
  
  // _enviarWhatsapp() async{
  //   if(await canLaunchUrl(_whatsapp)) {
  //     await launchUrl(_whatsapp, mode: LaunchMode.externalApplication);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("WhatsApp no esta instalado en el dispositivo"),
  //       ),
  //     );
  //   }
  // }
}