import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:elotes_make/themes/custom.dart';
import 'package:elotes_make/system/globals.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Uri _whatsapp = Uri.parse("https://wa.me/526623156835");
  final _url = Uri.https('zesty.com.mx', '/apps/apiapps/v1/forget/');
  final _url_login = Uri.https('zesty.com.mx', '/apps/apiapps/v1/checkusuario/');
  TextEditingController _emailRecovery = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailRecovery.clear();
    _emailController.clear();
    _pwdController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(title: const Text('Iniciar sesión'), automaticallyImplyLeading: false),
      body:          
          ListView(
            padding: const EdgeInsets.all(10.0),
            children: [
              Container(
                margin: const EdgeInsets.only(right: 100.0 , left: 100.0),
                child: Image.asset(
                  'assets/logo.png'
                ),
              ),
              _crearCorreo(),
              _crearPwd(),
              _crearBoton(context),
              Visibility(
                visible: Platform.isIOS,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, 'select');
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: const Text('Iniciar como invitado', 
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0
                      )),
                      margin: const EdgeInsets.all(10.0),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: const Text('¿Todavía no tienes una cuenta?', 
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0
                    )),
                    margin: const EdgeInsets.all(10.0),
                  ),
                  const SizedBox(width: 10.0,),
                  Container(
                    child: GestureDetector(
                      child: const Text('Registrate',
                        style: TextStyle(
                        color: Color(0xfeea3410),
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0
                      )),
                      onTap: () {
                        Navigator.pushNamed(context, 'register');
                      },
                    )
                  ),                  
                ],                
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Container(
                      child: const Text('Problemas al ingresar? Manda WhatsApp', 
                      style: TextStyle(
                        fontSize: 18.0,
                        decoration: TextDecoration.underline                    
                      )),
                       margin: const EdgeInsets.all(10.0)
                    ),
                    onTap: _enviarWhatsapp,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: const Text('Olvide mi contraseña',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.green,
                        fontWeight: FontWeight.w900,
                      )),                      
                    onTap: () {
                      _mostrarAlerta(context);
                    },                    
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Powered by ', 
                      style: TextStyle(
                        fontWeight: FontWeight.w700
                      )
                    ),
                    Image.asset(
                      'assets/zesty.png',
                      width: 100.0,
                      height: 100.0,
                    ),
                  ],
                ),
              )
            ],
          )
    );
  }

  Widget _crearCorreo() {
    return Container(     
      margin: const EdgeInsets.only(right: 50.0, left: 50.0, top:20.0),
      child: TextField(
        controller: _emailController,
        autocorrect: false,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0)
          ),
          hintText: '',
          label: const Text('Correo electrónico'),
        ),
      ),
    );
  }

  Widget _crearPwd() {
    return Container(
      margin: const EdgeInsets.only(right: 50.0, left: 50.0, top:20.0),
      child: TextField(
        controller: _pwdController,
        obscureText: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0)
          ),
          hintText: '',
          label: const Text('Contraseña'),
        ),
      ),
    );
  }

  Widget _crearBoton(BuildContext context) {
    return Container(
      height: 50.0,
      margin: const EdgeInsets.only(left: 50.0, right: 50.0, top: 30.0),
      child: TextButton(
        onPressed: (){
          if(_emailController.text.isEmpty || _pwdController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Correo / Contraseña son requeridos'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              )
            );
          } else {
            login(_emailController.text, _pwdController.text);
          }
        }, 
        child: const Text(
          'Iniciar sesión',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(customTheme.primary)
        ),
      ),
    );
  }

  void _mostrarAlerta(BuildContext context) async {
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (context){
      return AlertDialog(
        title: const Text('Cambio de contraseña'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        content: SingleChildScrollView(
          child: ListBody (
            children: [
              const Text('Ingresa tu correo electrónico y te enviaremos un enlace para restablecer la contraseña'),
              TextField(        
                controller: _emailRecovery,      
                autofocus: true,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Correo electrónico'
                ),
              )
            ],
          )
        ),
        actions: [
          TextButton(
            onPressed: () => {
              Navigator.of(context).pop()       
            }, 
            child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              forgetEmail(_emailRecovery.text);
            }, 
            child: const Text('Enviar'))
        ],
      );
    });
  }

  void login(String email, String pwd) async {
    final res = await http.post(
      _url_login,
      headers: headers,
      body: jsonEncode({
        'correo' : email,
        'password' : pwd
      })
    );    
    if(res.statusCode == 200) {
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
      _emailController.clear();
      _pwdController.clear();
      Navigator.pushNamed(context, 'select');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Correo / Contraseña incorrectos'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }

  void forgetEmail(String email) async {
    print(email);
    final res = await http.post(
      _url,
      headers: headers,
      body: jsonEncode( {
        'correo' : email
      })
    );
    print(res.body);
    if(res.statusCode == 200) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Correo electrónico enviado!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }
  
  _enviarWhatsapp() async{
    if(await canLaunchUrl(_whatsapp)) {
      await launchUrl(_whatsapp, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("WhatsApp no esta instalado en el dispositivo"),
        ),
      );
    }
  }
}