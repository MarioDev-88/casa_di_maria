import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:elotes_make/models/Restaurant.dart';
import 'package:elotes_make/services/restaurant_service.dart';
import 'package:elotes_make/bloc/carrito/carrito_bloc.dart';
import 'package:elotes_make/models/Pedido.dart';
import 'package:elotes_make/system/globals.dart';
import 'package:elotes_make/themes/custom.dart';

import '../models/Cards.dart';
import '../services/card_service.dart';
import '../services/orden_service.dart';
import '../system/add_card_arguments.dart';
import '../system/platillos_arguments.dart';

class OrdenPage extends StatefulWidget {
  const OrdenPage({Key? key}) : super(key: key);

  @override
  State<OrdenPage> createState() => _OrdenPageState();
}

class _OrdenPageState extends State<OrdenPage> {
  final RestaurantService _restaurantService = RestaurantService();
  Restaurant response = Restaurant(costoEnvio: "0");  

  @override
  void initState() {
    // TODO: implement initState    
    super.initState();      
    Future.delayed(Duration(seconds: 1), () {
      _restaurantService.getDetalle().then((value) {
        setState(() {
          response = value;
        });
      },);  
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Orden'),
        actions: [
          IconButton(onPressed: (){
            showDialog(context: context, barrierDismissible: false, builder: (_) {
              return AlertDialog(
                title: const Text('Aviso'),
                content: Text('Si tiene algún problema al hacer su pedido, por favor llame a soporte técnico de $appName'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                  TextButton(onPressed: () async {
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: '6623156835',
                    );
                    await launchUrl(launchUri);
                  }, child: Text('LLamar soporte $appName'))
                ],
              );
            });
          }, icon: const Icon(Icons.help))
        ],
      ),
      body: BlocBuilder<CarritoBloc, CarritoState>(
        builder: (context, state) => InformacionOrdenPage(pedido: state.pedido!, data: response, total: state.total),
      )
    );
  }
}

class InformacionOrdenPage extends StatefulWidget {
  final List<Pedido> pedido;
  final Restaurant data;
  final String total;
  const InformacionOrdenPage({
    Key? key,
    required this.pedido,
    required this.data,
    required this.total}) : super(key: key);

  @override
  State<InformacionOrdenPage> createState() => _InformacionOrdenPageState();
}

class _InformacionOrdenPageState extends State<InformacionOrdenPage> {
  final numberFormat = NumberFormat.currency(locale: 'es_MX', symbol:"\$");
  OrdenService _ordenService = OrdenService();
  final CardService _cardService = CardService();
  late String _total = "0";
  late String _finalTotal = "0";
  String servicio = "";
  late List<Pedido> _productos;
  late List<Cards> _cards;
  String pago = "Efectivo";
  String _idTarjeta = '';
  bool _visibleCardInfo = false;
  bool _visiblePropina = false;
  double cobroTarjeta = 0.0;
  int propina = 5;
  TextEditingController txtPropina = TextEditingController();
  TextEditingController txtPhone = TextEditingController();
  TextEditingController txtReferencia = TextEditingController();
  TextEditingController txtPagarCon = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      getServicio();
    });
     setTotales();     
  }

    @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    txtPropina.dispose();
  }

  getServicio() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _cards = await _cardService.getUsuarioTarjeta();
       
    setState(() {
      if(prefs.getString("servicio") == null) {
        prefs.setString("servicio", "Servicio a domicilio");    
        servicio = "Servicio a domicilio";  
        print(servicio);
      } else {
        servicio = prefs.getString("servicio").toString();
        print(servicio);
      }
      
      if(_cards.isNotEmpty) {
        _idTarjeta = _cards[0].idCard;
      }
    });        
  }

  setTotales() {
    Future.delayed(const Duration(seconds: 2), () {      
      setState(() {
        _total = (double.parse(widget.total)).toString();
        if(servicio == "Servicio a domicilio") {
          _finalTotal = (double.parse(widget.total) + double.parse(widget.data.costoEnvio)).toString();
        } else {
          _finalTotal = double.parse(widget.total).toString();
        }        
        txtPropina.text = propina.toString();
        _productos = widget.pedido;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: GestureDetector(
        onTap: (_finalTotal == "0") ? null : _showModalOrden,
        child: BottomAppBar(        
          color: customTheme.primary,
          padding: const EdgeInsets.all(5.0),
          child: (_finalTotal == "0") ? 
            Center(heightFactor: 1,
            widthFactor: 1, child: SizedBox(child: CircularProgressIndicator(color: customTheme.secondary,))) : Text(
            'Realizar pedido ${numberFormat.format(double.parse(_finalTotal))}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade300,
                        child: Image.asset("assets/zp-ico-15.png", scale: 1.5, width: 5, height: 5,),
                      ),                  
                    ),
                  ),
                  Text('Orden de pedido ( ${widget.pedido.length} Articulo)',
                    style: const TextStyle(
                      fontSize: 20.0
                    ),
                  ),
                  IconButton(onPressed: (){
                    showModalBottomSheet(context: context, 
                    useSafeArea: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      )
                    ),
                    builder: (context) {   
                      return StatefulBuilder(
                        builder:(context, StateSetter setStateModal) {
                          return ClipRRect(
                            child: Container(
                              padding: const EdgeInsets.all(15.0),
                              child: _showProductos(widget.pedido, setStateModal),
                            ),
                          );
                        },
                      );            
                    });
                  }, 
                    icon: const Icon(
                      Icons.chevron_right,
                      size: 32.0,
                    )
                  )
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton.icon(onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: customTheme.secondary,
                    shape: const LinearBorder()
                  ),
                  icon: const Icon(Icons.add, color: Colors.white,),
                  label: const Text('Agregar platillo / Volver al menu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
                ),
              ),
              const SizedBox(height: 10.0,),
              SizedBox(
                child: Column(
                  children: (servicio == "Servicio a domicilio") ? _showOpciones(widget.data) : [],
                ),
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 19.0,
                        fontWeight: FontWeight.w600
                      ),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Text(
                      "${numberFormat.format(double.parse(widget.total))}",
                      style: const TextStyle(                      
                        fontSize: 19.0,
                        fontWeight: FontWeight.w600
                      ),),
                  )
                ],
              ),
              const SizedBox(height: 8.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        '+ Costo de envió',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                        ),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Text(
                        (servicio == "Servicio a domicilio") ? 
                          "${numberFormat.format(double.parse(widget.data.costoEnvio))}" :
                          "${numberFormat.format(0)}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                        ),),
                    )
                ],
              ),
              const SizedBox(height: 8.0,),
              Visibility(
                visible: _visibleCardInfo,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        '+ Comisión por tarjeta',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 17.0,
                          fontWeight: FontWeight.w600
                        ),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Text(
                        "${numberFormat.format(cobroTarjeta)}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                        ),),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 8.0,),
              Visibility(
                visible: _visiblePropina,
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [                    
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        '+ Propina conductor sugerida \$',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                        ),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: SizedBox(
                        height: 40,
                        width: 100,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              if(value.isEmpty) {
                                propina = 0;
                                txtPropina.text = "0";
                                _finalTotal = (double.parse(_finalTotal) - 5).toString(); 
                              } else {
                                propina = int.parse(value);
                                _finalTotal = (double.parse(_finalTotal) - propina).toString();
                              }
                            });
                          },
                          autocorrect: false,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                          controller: txtPropina,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _showOpciones(Restaurant data) {
    double _totalNew = (double.parse(_total) + propina); // Total + propina
    _totalNew += double.parse(data.costoEnvio); // Total + envio
    cobroTarjeta = (_totalNew * porcentajeConekta / 100) + 2.5;
    cobroTarjeta += (cobroTarjeta * 0.16);
    List<Widget> componentes = [];
    //if(data) {
      componentes.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: RadioListTile(
                dense: true,
                contentPadding: const EdgeInsets.only(left: 10.0),                
                activeColor: customTheme.primary,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Efectivo', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500)),
                subtitle: Text("Ahorro de ${numberFormat.format(cobroTarjeta)}",  style: const TextStyle(fontSize: 15.0,  fontWeight: FontWeight.w600)),
                value: "Efectivo", 
                groupValue: pago,
                onChanged: (value){
                  setState(() {
                    pago = value.toString();
                    propina = 5;
                    _visibleCardInfo = false;
                    _visiblePropina = false;
                    _finalTotal = (double.parse(widget.total) + double.parse(widget.data.costoEnvio)).toString();
                  });                  
                }
              )
            ),
          ],
        )
      );
      if(data.pagoTerminal) {
        componentes.add(
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 10.0),
                  activeColor: customTheme.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Terminal a domicilio',  style: TextStyle(fontSize: 18.0,  fontWeight: FontWeight.w500)),
                  value: "Terminal a domicilio", 
                  groupValue: pago,
                  onChanged: (value){                    
                    setState(() {
                      propina = 0;
                      pago = value.toString();
                      _visibleCardInfo = true;
                      _visiblePropina = false;
                    });
                    _finalTotal = (double.parse(_finalTotal) + cobroTarjeta).toString();
                  }
                )
              )
            ],
          )
        );
      }
      if(data.pagoTarjeta) {
        componentes.add(
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 10.0),
                  activeColor: customTheme.primary,
                  controlAffinity: ListTileControlAffinity.leading,                  
                  title: Row(
                    children: [
                      const Text('Tarjeta débito / crédito', style: TextStyle(fontSize: 18.0,  fontWeight: FontWeight.w500),),
                      IconButton(onPressed: (){
                        _checkTarjeta();
                      }, icon: const Icon(Icons.add_box_rounded), color: customTheme.primary,)
                    ],
                  ),
                  subtitle: (_cards.isEmpty) ? const Text('Sin tarjeta agregada') : Text('${_cards[0].typeCard} ${_cards[0].fourDigit}', style: TextStyle(fontSize: 18.0),),
                  value: "Tarjeta", 
                  groupValue: pago,
                  onChanged: (value){
                    setState(() {
                      pago = value.toString();
                      if(propina == 0) {
                        propina = 5;
                      }
                      _visibleCardInfo = true;
                      _visiblePropina = true;
                      _finalTotal = (double.parse(_finalTotal) + cobroTarjeta + propina).toString();
                      _checkTarjeta();
                    });
                  }
                )
              )
            ],
          )
        );
      }      
    //}

    return componentes;
  }

  Widget _showProductos(List<Pedido> pedido, StateSetter setStateModal) {
    final _pedido = [...pedido];
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _pedido.length,
      itemBuilder: (context, index) {        
        final producto = _pedido[index];
        final result = producto.adiciones.where((element) => element != "").toList();
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          minVerticalPadding: 1.0,          
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              '${producto.cantidad.toString()}x',
              style: TextStyle(
                fontSize: 17.0,
                color: customTheme.secondary,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          trailing: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: () async {
                Navigator.of(context).pop();
                final result = await Navigator.pushNamed(context, 'platillo', arguments: PlatillosArguments(
                  idCategoria: producto.platillo,
                  nombre: producto.nombre,
                  servicio: servicio,
                  precio: producto.precio,
                  edit: true,
                  cantidad: producto.cantidad,
                  index: index,
                  adiciones: producto.adiciones
                ));

                if(result != null) {
                  setTotales();
                }
              }, color: customTheme.secondary, icon: const Icon(Icons.edit)),
              IconButton(onPressed: (){
                showDialog(context: context, barrierDismissible: false, builder: (_) {
                  return AlertDialog(
                    title: const Text('Aviso'),
                    content: const Text('¿Seguro/a que desea eliminar este platillo?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                      TextButton(onPressed: () {                     
                        BlocProvider.of<CarritoBloc>(context).add(CarritoDeleteEvent(index)); 
                        setStateModal(() {
                          setTotales();
                          _pedido.removeAt(index);                          
                        });
                        Navigator.of(context).pop();
                      }, child: const Text('Si, eliminar'))
                    ],
                  );
                });
              }, color: customTheme.primary, icon: const Icon(Icons.delete_outline)),
            ],
          ),
          title: Text(
            '${producto.nombre} (${numberFormat.format(double.parse(producto.total))})',
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600
            ),
          ),
          subtitle: _showAdiciones(result),
        );
      },
    );
  }

  Widget _showAdiciones(List adiciones) {
    List<Widget> _adiciones = [];
    for(var i=0; i <= adiciones.length-1; i++) {
      _adiciones.add(
        Text('${adiciones[i]['nombre']} (${numberFormat.format(double.parse(adiciones[i]['precio']))})')
      );
    }
    return Row(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _adiciones,
      )
    ],);
  }

  _showModalOrden() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    txtPhone.text = prefs.getString("telefono").toString();
    prefs.setString("pago", pago);
    String direccionActual = prefs.getString('actualAddress') ?? '';
    if(widget.pedido.isNotEmpty) {
      showDialog(context: context,  barrierDismissible: false,
        builder: (BuildContext dialogContex) {
        return AlertDialog(
          scrollable: true,
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.all(5.0),
          title: Container(
            height: 80,
            color: Colors.yellow,
            child: Center(
              child: Text(
                (servicio == "Servicio a domicilio") ? 'Tu pedido sera entregado \nen:' : appName,
                textAlign: TextAlign.center,            
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    child: Text(
                      (servicio == "Servicio a domicilio") ? direccionActual : 'Recoger en lugar',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0,),
                Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    'Total: ${numberFormat.format(double.parse(_finalTotal))}',
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0
                    )
                  ),
                ),
                const SizedBox(height: 10.0,),
                Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    'Nombre: ${prefs.getString('nombre')}',
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0
                    )
                  ),
                ),
                const SizedBox(height: 16.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    controller: txtPhone,
                    maxLength: 10,
                    autocorrect: false,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))
                      ),
                      label: Text('Teléfono')
                    ),
                  ),
                ),
                const SizedBox(height: 16.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    autocorrect: false,
                    controller: txtReferencia,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))
                      ),
                      label: Text('Referencia y/o comentario')
                    ),
                  ),
                ),
                const SizedBox(height: 16.0,),
                (prefs.getString("servicio") == "Servicio a domicilio") ?
                (prefs.getString("pago") == "Efectivo") ?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextFormField(
                    controller: txtPagarCon,
                    autocorrect: false,
                    validator: (String? value) {
                      if(value!.isEmpty) {
                        return 'Por favor indique la cantidad con la que pagará';
                      }
                      return null;
                    },
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))
                      ),
                      label: Text('¿ Con cuanto pagarás?')
                    ),
                  ),
                ) : Container() : Container()
              ],
            ),
          ),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 40.0,
                  child: ElevatedButton(
                    onPressed: _sendOrder, 
                    child: const Text('Finalizar pedido', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),),
                  ),
                ),
                const SizedBox(height: 16.0,),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 40.0,
                  child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Volver al menu'))),
              ],
            )          
          ],
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          showCloseIcon: true,
          content: Text("Agregue productos para completar la orden.", style: TextStyle(fontWeight: FontWeight.w600),),
        )
      );
    }
  }

  _sendOrder() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map json = {
      'id_restaurante' : restId,
      'id_usuario' : prefs.getInt("id"),
      'correo' : prefs.getString("email"),
      'costo_envio' : (prefs.getString("servicio") == "Servicio a domicilio") ? double.parse(widget.data.costoEnvio) : 0,
      'subtotal' : _total,
      'total' : _finalTotal,
      'detalle' : {
        "platillos" : _productos.map((e) => e.map).toList(),
        "platform" : osname,
        "latitude" : prefs.getDouble("latitude"),
        "longitude" : prefs.getDouble("longitude")
      },
      'servicio' : prefs.getString("servicio"),
      'nombre_completo' : prefs.getString("nombre"),
      'telefono' : txtPhone.text,
      'calle' : (prefs.getString("servicio") == "Servicio a domicilio") ? prefs.getString("calle") : '',
      'entre' : (prefs.getString("servicio") == "Servicio a domicilio") ? prefs.getString("entre") : '',
      'numero' : (prefs.getString("servicio") == "Servicio a domicilio") ? prefs.getString("numero") : '',
      'colonia' : (prefs.getString("servicio") == "Servicio a domicilio") ? prefs.getString("colonia") : '',
      'codigo_postal' : (prefs.getString("servicio") == "Servicio a domicilio") ? prefs.getString("codigo_postal") : '',
      'nota' : txtReferencia.text,
      'pagar_con' : txtPagarCon.text,
      'en_margen' : 0,
      'metodo_pago' : prefs.getString("pago"),
      'km' : 0
    };    

    if(prefs.getString("servicio") == "Ordena y recoja") {
      json['pagar_con'] = 0;
    }

    if(prefs.getString("pago") == 'Terminal a domicilio') {
      json["servicio"] =  'Servicio a domicilio (Terminal a domicilio)';
      json['pagar_con'] = 0;
    }
    
    if(prefs.getString("pago") == "Tarjeta") {
      json['customer_token'] = prefs.getString("customer_token");
      json['tarjeta'] = prefs.getString("card");
      json['propina'] = txtPropina.text;
      json['comision_tarjeta'] = cobroTarjeta;
      json['pagar_con'] = 0;
    }

    if(prefs.getString("servicio") == "Servicio a domicilio") {
      if(prefs.getString("pago") == "Terminal a domicilio") {
         _alertOrden(json);
      } else if(prefs.getString("pago") == "Tarjeta") {
        _alertOrdenCard(json);
      } 
      else {
        if(txtPagarCon.text.isNotEmpty && double.parse(txtPagarCon.text) > double.parse(_finalTotal)) {   
          _alertOrden(json);
        } else {
          Fluttertoast.showToast(
            msg: "Por favor indique la cantidad con la que pagará o revise que sea mayor al total a pagar",
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
          );
        }
      }      
    } else if(prefs.getString("servicio") == "Ordena y recoja") {
      _alertOrden(json);
    }
  }

  //Alert generar pedido T
  _alertOrdenCard(Map json) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _isLoading = true;
    Map<String, dynamic> data = {};
    Navigator.of(context).pop();
    Widget _loading = Visibility(
      visible: _isLoading,
      child: const SizedBox(
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Generando pedido'),
              SizedBox(width: 10.0,),
              CircularProgressIndicator()
            ],
          )
        ),
      ),
    );
    Widget _header = Container(
      color: customTheme.primary,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(                          
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(60.0)),
                  border: Border.all(
                    color: Colors.white
                  )
                ),
                child: Center(child: Image.asset("assets/zp-ico-25.png", width: 80, height: 80,))
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 80,
            child: Image.asset("assets/zp-ico-30.png")
          )
        ],
      ),
    );          
    showDialog(context: context, barrierDismissible: false, builder: (context) {
      return AlertDialog(
        titlePadding: !_isLoading ? EdgeInsets.zero : const EdgeInsets.all(10.0),
        contentPadding: !_isLoading ? EdgeInsets.zero : const EdgeInsets.all(10.0),
        title: !_isLoading ? _header : _loading,
      );
    });
    _ordenService.sendOrderCard(json).then((response) {            
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = response['status'] ? false : true;
          data = response['data'];    
        });
        Navigator.of(context).pop();
        showDialog(context: context, barrierDismissible: false, builder: (_) {      
          if(response['status']) {
            return AlertDialog(
            titlePadding: !_isLoading ? EdgeInsets.zero : const EdgeInsets.all(10.0),
            contentPadding: !_isLoading ? EdgeInsets.zero : const EdgeInsets.all(10.0),
            title: !_isLoading ? _header : _loading,
            content: Visibility(
              visible: (_isLoading) ? false : true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text('¡Muchas Gracias!', style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600
                    ),),
                  ),
                  const SizedBox(height: 10.0,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(prefs.getString("nombre")!, style: const TextStyle(
                      fontSize: 24.0
                    )),
                  ),
                  const SizedBox(height: 10.0,),
                  const SizedBox(
                    width: 50.0,
                    height: 5.0,
                    child: Divider(color: Colors.orange, thickness: 3.0, height: 5.0,),
                  ),
                  const SizedBox(height: 10.0,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Pedido #${data['folio'] ?? ""}', style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600
                    ),),
                  ),
                  const SizedBox(height: 10.0,),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Enviaremos el status del pedido a tu email de registro', 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600
                    )),
                  ),
                  const SizedBox(height: 10.0,),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Dudas en: pedidos@zesty.com.mx',
                    textAlign: TextAlign.center,
                      style: TextStyle(
                      fontSize: 17.0,
                    )),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: (){
                txtPagarCon.clear();
                txtReferencia.clear();
                json = {};
                prefs.remove("pago");
                prefs.remove("servicio");
                Navigator.popUntil(context, ModalRoute.withName('select'));
                BlocProvider.of<CarritoBloc>(context).add(CarritoInitialEvent("0"));
              }, child: const Text('Cerrar'),)
            ],
          );
          } else {
            return AlertDialog(
            title: const Text('Aviso'),
            content: Text('${data['message']}'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Ok'),)
            ],
          );
          }         
        });
      });            
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error al generar pedido, intente mas tarde'),
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          )
        );
    }); 
  }

  // Alert generar pedido SD, OR ,TD
  _alertOrden(Map json) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _isLoading = true;
    Map<String, dynamic> data = {};
    Navigator.of(context).pop();
    Widget _loading = Visibility(
      visible: _isLoading,
      child: const SizedBox(
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Generando pedido'),
              SizedBox(width: 10.0,),
              CircularProgressIndicator()
            ],
          )
        ),
      ),
    );
    Widget _header = Container(
      color: customTheme.primary,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Center(
              child: SizedBox(
                height: 160,
                child: Center(child: Image.asset("assets/zp-ico-25.png", width: 80, height: 80,))
              ),
            ),
          ),
          Positioned(
            bottom: 35,
            right: 100,
            child: SizedBox(
              height: 32, width: 32,
              child:  Image.asset("assets/zp-ico-30.png", height: 32, width: 32,),
            )
          )
        ],
      ),
    );          
    showDialog(context: context, barrierDismissible: false, builder: (context) {
      return AlertDialog(
        titlePadding: !_isLoading ? EdgeInsets.zero : const EdgeInsets.all(10.0),
        contentPadding: !_isLoading ? EdgeInsets.zero : const EdgeInsets.all(10.0),
        title: !_isLoading ? _header : _loading,
      );
    });
    _ordenService.sendOrder(json).then((response) {            
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = response['status'] ? false : true;
          data = response['data'];    
        });
        Navigator.of(context).pop();
        showDialog(context: context, barrierDismissible: false, builder: (_) {                
          return AlertDialog(
            titlePadding: !_isLoading ? EdgeInsets.zero : const EdgeInsets.all(10.0),
            contentPadding: !_isLoading ? EdgeInsets.zero : const EdgeInsets.all(10.0),
            title: !_isLoading ? _header : _loading,
            content: Visibility(
              visible: (_isLoading) ? false : true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text('¡Muchas Gracias!', style: TextStyle(
                      fontSize: 21.0,
                      fontWeight: FontWeight.w600
                    ),),
                  ),
                  const SizedBox(height: 5.0,),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(prefs.getString("nombre")!, style: const TextStyle(
                      fontSize: 21.0
                    )),
                  ),
                  const SizedBox(height: 5.0,),
                  const SizedBox(
                    width: 50.0,
                    height: 5.0,
                    child: Divider(color: Colors.orange, thickness: 3.0, height: 5.0,),
                  ),
                  const SizedBox(height: 5.0,),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text('Pedido #${data['folio'] ?? ""}', style: const TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600
                    ),),
                  ),
                  const SizedBox(height: 5.0,),
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text('Enviaremos el status del pedido a tu email de registro', 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600
                    )),
                  ),
                  const SizedBox(height: 5.0,),
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text('Dudas en: pedidos@zesty.com.mx',
                    textAlign: TextAlign.center,
                      style: TextStyle(
                      fontSize: 14.0,
                    )),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: (){
                txtPagarCon.clear();
                txtReferencia.clear();
                json = {};
                prefs.remove("pago");
                prefs.remove("servicio");
                Navigator.popUntil(context, ModalRoute.withName('select'));
                BlocProvider.of<CarritoBloc>(context).add(CarritoInitialEvent("0"));
              }, child: const Text('Cerrar'),)
            ],
          );
        });
      });            
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error al generar pedido, intente mas tarde'),
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          )
        );
    }); 
  }

  void _checkTarjeta() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(_idTarjeta == '') {
      showDialog(context: context, barrierDismissible: false, builder: (context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: const Text('No se encontró ninguna tarjeta, ¿Desea agregar una?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(onPressed: _openAddCard, child: const Text('Agregar tarjeta'))
          ],
        );
      });
    } else {
      setState(() {                      
        prefs.setString("pago", "Tarjeta");
        prefs.setString("card", _idTarjeta);      
      });
      _openAddCard();      
    }    
  }

  void _openAddCard() async {
    final result = await Navigator.pushNamed(
      context, 
      'add_card',
      arguments: AddCardArguments(_idTarjeta)
    );
    if(result == null) {
      Future.delayed(const Duration(seconds: 1), () {
        getServicio();
      });
    }
  }
}