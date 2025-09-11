import 'package:flutter/material.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:cotizador_casa_di_maria/bloc/carrito/carrito_bloc.dart';
import 'package:cotizador_casa_di_maria/presentation/delegates/search_product_delegate.dart';
import 'package:cotizador_casa_di_maria/models/Anuncios.dart';
import 'package:cotizador_casa_di_maria/system/arguments.dart';
import 'package:cotizador_casa_di_maria/themes/custom.dart';
import 'package:cotizador_casa_di_maria/system/globals.dart';
//import '../presentation/carrito.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({Key? key}) : super(key: key);

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  final numberFormat = NumberFormat.currency(locale: 'es_MX', symbol:"\$");
  DateTime now = DateTime.now();  
  late int dayOfWeek;
  String getHour = DateFormat('Hms').format(DateTime.now());
  //final carrito = Carrito();
  var unescape = HtmlUnescape();
  ScrollController _scrollController = ScrollController();
  final _urlAnuncios = Uri.https('zesty.com.mx', '/apps/apiapps/v1/anuncios/');
  final _urlDetalle = Uri.https('zesty.com.mx', '/apps/apiapps/v1/detallesrestaurante/');  
  List<AnuncioItem> _listaAnuncios = [];
  List<String> _listado = [];
  List lunes_viernes = [1, 2, 3, 4, 5];
  late String _servicio;
  String _descripcion = '';
  String _direccion = '';
  String _direccionUsuario = '';
  bool _tarjeta = false;
  String _horarioServicio = '';
  String _horario = '';
  List _horarioServicio2 = [];
  bool _menu_completo = false;
  bool _incluirPopulares = false;
  bool _incluirGaleria = false;
  String _pedidoMinimo = "0";
  String _tiempoEspera = "";
  String _costoEnvio = "0";

  @override
  void initState() {
    super.initState();        
    _fetchDetalle();
    _fetchAnuncios();
    dayOfWeek = now.weekday;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _listaAnuncios.clear();
    super.dispose();
  }

  /*Future<bool> _onWillPop() async {
    if(BlocProvider.of<CarritoBloc>(context).state.pedidos.isNotEmpty){
      return (await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aviso'),
          content: const Text('Tiene un pedido pendiente en este restaurante, si continua, el pedido se borrara automáticamente'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(onPressed: () {
              Navigator.of(context).pop();
              BlocProvider.of<CarritoBloc>(context).add(CarritoInitialEvent("0"));  
              Navigator.pop(context, false);                
            }, child: const Text('Continuar'))
          ],
        ),
      )) ?? false;
    } 
    Navigator.pop(context, false);
    return false;
  }*/

  @override
  Widget build(BuildContext context) {    
    final args = ModalRoute.of(context)!.settings.arguments as AppArguments;
    _servicio = args.servicio;
    return WillPopScope(
      onWillPop: null,
      child: Scaffold(
        appBar: AppBar(
          title: Text(appName),
          actions: [
            IconButton(
              onPressed: (){
                showSearch(context: context, delegate: ProductSearchDelegate(_servicio));
              }, 
              icon: const Icon(Icons.search)
            )
          ],
        ),
        //floatingActionButton: carrito.showFloatingButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        //bottomNavigationBar: carrito.showBottomBar(),
        backgroundColor: Colors.yellow,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _boxDirection(),
                _boxSlider(),
                Center(
                  child: GestureDetector(
                    child: Text(
                      'Mas información',
                      style: TextStyle(
                        color: customTheme.primary,
                        fontSize: 18.0
                      ),
                    ),
                    onTap: _showInformacion,
                  ),
                ),
                const SizedBox(height: 10.0,),
                _boxInfo(),
                const SizedBox(height: 10.0,),
                _crearListview()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _boxDirection() {
    return Container(
      height: 70.0,
      decoration: BoxDecoration(
        color: Colors.orange.shade400
      ),
      child: _boxServiceType()
    );
  }

  Widget _boxSlider() {
    return SizedBox(
      height: 120.0,
      child: ListView.separated(
        separatorBuilder: (context, _) => const SizedBox(width: 4,),
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _listaAnuncios.length,
        itemBuilder: (context, index) {
          final image = _listaAnuncios[index];
          return Container(            
            padding: const EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: FadeInImage(
                fadeInCurve: Curves.fastOutSlowIn,
                fit: BoxFit.cover,
                placeholder: const AssetImage('assets/logo.png'),
                image: NetworkImage(image.imageUrl),
              ),
            ),            
          );
        }),
      );
  }

  void _fetchDetalle() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();    
    final _response = await http.post(
      _urlDetalle,
      headers: headers,
      body: jsonEncode({})
    );
    if(_response.statusCode == 200) {
      final data = jsonDecode(_response.body);
      setState(() {
        if(prefs.getInt("id") != "null") {
          if(_servicio == "Servicio a domicilio") {
            _listado.addAll(prefs.getStringList('address') as Iterable<String>);
            _direccionUsuario = prefs.getString('actualAddress') ?? '';
          }
        } else {
          _direccionUsuario = "Inicia sesión o regístrate";
        }        
        _menu_completo = data['menu_completo'];
        _incluirPopulares = data['incluir_populares'];
        _incluirGaleria = data['incluir_galeria'];
        _descripcion = data['descripcion'];
        _direccion = data['direccion'];
        _tarjeta = data['pago_tarjeta'];
        _horarioServicio = unescape.convert(data['formato_horario_test'].toString());
        _horario = unescape.convert(data['formato_horario_web'].toString());
        _pedidoMinimo = data['pedido_minimo'];
        _tiempoEspera = data['tiempo_aprox'];
        _costoEnvio = data['costo_envio'];
        _horarioServicio2 = (_servicio == "Servicio a domicilio") ? data['horario_servicio2'] : data['horario_web'];
        servicioDisponible(_horarioServicio2);
      });
    }
  }

  void _fetchAnuncios() async {
    
    var _res = await http.post(
      _urlAnuncios,
      headers: headers,
      body: jsonEncode({})
    );
    if(_res.statusCode == 200) {
      
      List response = jsonDecode(_res.body);
      response.forEach((element) {
        _listaAnuncios.add(AnuncioItem(imageUrl: 'https://zesty.com.mx'+element['foto']));
      });
    }
  }
  
  Widget _boxInfo() {
    if(_servicio == "Servicio a domicilio") {
      return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: Container(
            height: 70.0,
            color: customTheme.secondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text('Pedido mínimo', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(numberFormat.format(double.parse(_pedidoMinimo)), style: const TextStyle(
                    color: Colors.yellow, fontWeight: FontWeight.w700
                  ),),
                ),
                SizedBox(
                  child: Container(      
                    width: 100,
                    height: 5.0,              
                    color: Colors.black,
                  ),
                )
              ],
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: Container(
            height: 70,
            color: customTheme.secondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text('Tiempo de espera', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text('$_tiempoEspera min', style: const TextStyle(
                    color: Colors.yellow, fontWeight: FontWeight.w700
                  )),
                ),
                SizedBox(
                  child: Container(      
                    width: 115,
                    height: 5.0,              
                    color: Colors.black,
                  ),
                )
              ],
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: Container(
            height: 70,
            color: customTheme.secondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text('Costo envió', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(numberFormat.format(double.parse(_costoEnvio)), style: const TextStyle(
                    color: Colors.yellow, fontWeight: FontWeight.w700
                  )),
                ),
                SizedBox(
                  child: Container(      
                    width: 100,
                    height: 5.0,              
                    color: Colors.black,
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
    }
    return Container();
  }
  
  Widget _crearListview() {
    return Column(
      children: [
        ListTile(
          onTap: () => Navigator.pushNamed(context, 'categories', arguments: AppArguments(_servicio, '', '')),
          title: const Text(
            'Menú Completo',
            style: TextStyle(
              fontSize: 20.0
            ),
          ),
          subtitle: const Text(
            'Puedes consultar todo nuestro menú aquí',
            style: TextStyle(
              fontSize: 13.0
            )
          ),
          trailing: const Icon(Icons.keyboard_arrow_right),
          leading: Image.asset(
            'assets/zp-ico-01-black.png',
            width: 40.0,
          ),
          enabled: _menu_completo,
        ),
        const Divider(),
        ListTile(
          onTap: () => Navigator.pushNamed(context, 'populares', arguments: AppArguments(_servicio, '', '')),
          title: const Text(
            'Platillos Populares',
            style: TextStyle(
              fontSize: 20.0
            )
          ),
          subtitle: const Text(
            'Mira los platillos favoritos de nuestros clientes',
            style: TextStyle(
              fontSize: 13.0
            )
          ),
          leading: Image.asset(
            'assets/zp-ico-02-black.png',
            width: 40.0,
          ),
          trailing: const Icon(Icons.keyboard_arrow_right),
          enabled: _incluirPopulares,
        ),
        const Divider(),
        ListTile(
          onTap: () => Navigator.pushNamed(context, 'galeria', arguments: AppArguments(_servicio, '', '')),
          title: const Text(
            'Galería de productos',
            style: TextStyle(
              fontSize: 20.0
            )
          ),
          subtitle: const Text(
            'Enamorate de nuestros platillos en nuestra galería de imágenes',
            style: TextStyle(
              fontSize: 13.0
            )
          ),
          leading: Image.asset(
            'assets/zp-ico-03-black.png',
            width: 40.0,
          ),
          trailing: const Icon(Icons.keyboard_arrow_right),          
          enabled: _incluirGaleria,
        ),
      ],
    );
  }

  void _showInformacion() async {
    showGeneralDialog(      
      context: context, 
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: const Text('Información'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                  child: Text(
                  _descripcion,
                  textAlign: TextAlign.start,
                ),
              ),
              const Divider(),
              Container(
                width: double.infinity,
                child: const Text(
                'Dirección',
                style: TextStyle(                  
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              ),
              SizedBox(
                width: double.infinity,
                child: Text(_direccion),
              ),
              const Divider(),
              Container(
                width: double.infinity,
                child: const Text(
                  'Horario de envió',
                  style: TextStyle(                  
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Text(_horarioServicio.replaceAll('[', '').replaceAll(']', '')),
              ),
              const Divider(),
              Container(
                width: double.infinity,
                child: const Text(
                  'Horario',
                  style: TextStyle(                  
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Text(_horario.replaceAll('[', '').replaceAll(']', '')),
              ),
              const Divider(),
              Container(
                width: double.infinity,
                child: const Text(
                  'Forma de pago',
                  style: TextStyle(                  
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Text((_tarjeta) ? 'Efectivo / Tarjeta de débito / crédito' : 'Efectivo'),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: const Text('Cerrar')
            )
          ],
        );
      },
    );
  }
  
  Widget _boxServiceType() { 
    if(_servicio == 'Servicio a domicilio') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
              _direccionUsuario.replaceAll('[', '').replaceAll(']', ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800
                ),
              ),
            ),
            ElevatedButton(
              onPressed: (){
                _showChangeDirection();
              },
              child: const Text('Cambiar'),
            )
          ],
        )
      );
    } else {
      return Center(
        child: Text(
          _servicio,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w600
          ),
        )
      );
    }
    
  }
  
  void _showChangeDirection() {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        content: Container(
          width: double.maxFinite,
          color: customTheme.primary,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,       
                mainAxisAlignment: MainAxisAlignment.spaceAround,                 
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/zp_pedidos.png',
                      width: 100.0,
                    ),
                  ),
                  const Text(
                    'Selecciona una \n dirección de entrega',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0
                    ),
                  )
                ],
              ),
              _crearListDirection(),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.popAndPushNamed(context, 'direction');
            }, 
            child: const Text('Agregar nueva direccion'))
        ],
      );
    });
  }
  
  Widget _crearListDirection() {
    return Container(
      color: Colors.white,
      width: double.maxFinite,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _listado.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_listado[index]),
            onTap: () {
              setState(() {
                _direccionUsuario = _listado[index];
              });
              Navigator.of(context).pop();
            },
          );
        } ),
    );
  }  

  servicioDisponible(List horarios) {
    var getNow = '${now.hour.toString()}:${now.minute.toString()}:${now.second.toString()}';
    if(now.hour.toString().length == 1) {
      getNow = '0${now.hour.toString()}:${now.minute.toString()}:${now.second.toString()}';
    }
    for(Map x in horarios) {
      if(x.containsKey("8")) {
        x.forEach((key, value) {             
          String _desde = value[0]['desde'];
          String _hasta = value[0]['hasta'];
          /*if(_desde.compareTo(getNow) < 0 && _hasta.compareTo(getNow) > 0){
            BlocProvider.of<CarritoBloc>(context).add(CarritoServicioEvent(true));
          } else {
            _showAlertClose();
          }*/
        });
      } else if(x.containsKey("7")) {
        for(var dia in lunes_viernes) {
          if(dayOfWeek == dia) {
            x.forEach((key, value) {
              String _desde = value[0]['desde'];
              String _hasta = value[0]['hasta'];
              /*if(_desde.compareTo(getNow) < 0 && _hasta.compareTo(getNow) > 0){
                BlocProvider.of<CarritoBloc>(context).add(CarritoServicioEvent(true));
              } else {
                _showAlertClose();
              }*/
            });
          }
        }
      } else if(x.containsKey(dayOfWeek)) {
        x.forEach((key, value) {
          String _desde = value[0]['desde'];
          String _hasta = value[0]['hasta'];
          /*if(_desde.compareTo(getNow) < 0 && _hasta.compareTo(getNow) > 0){
            BlocProvider.of<CarritoBloc>(context).add(CarritoServicioEvent(true));
          } else {
            _showAlertClose();
          }*/
        });
      }
    }
  }
}