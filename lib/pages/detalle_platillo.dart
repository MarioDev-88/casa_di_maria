import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:elotes_make/bloc/carrito/carrito_bloc.dart';
import 'package:elotes_make/models/Pedido.dart';
import 'package:elotes_make/bloc/platillo/platillo_bloc.dart';
import 'package:elotes_make/themes/custom.dart';
import 'package:elotes_make/models/Platillos.dart';
import 'package:elotes_make/services/platillos_service.dart';
import 'package:elotes_make/system/platillos_arguments.dart';


class DetallePage extends StatelessWidget {
  const DetallePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as PlatillosArguments;
    final PlatillosService _platillosService = PlatillosService();
    return Scaffold(
      appBar: AppBar(title: Text(args.nombre), backgroundColor: Colors.black,),      
      body: BlocProvider<PlatilloBloc>(
        lazy: false,
        create: (context) => PlatilloBloc(args.cantidad, args.precio)..add(InitialPlatillo(args.cantidad, args.precio)),
        child: BlocBuilder<PlatilloBloc, PlatilloState>(          
          builder: (context, state) {
            return InformacionPlatillo(
              platillosService: _platillosService, 
              precio: state.total, 
              precioPlatillo: args.precio,
              cantidad: state.cantidad,
              index: args.index,
              isEdit : args.edit,
              adiciones : args.adiciones
            );
          },
        )
      ),
    );
  }
}

class InformacionPlatillo extends StatefulWidget {
  final PlatillosService platillosService;
  final String precio;
  final String precioPlatillo;
  final int cantidad;
  final int index;
  final bool isEdit;
  final List adiciones;
  const InformacionPlatillo({Key? key, 
    required this.platillosService, 
    required this.precio,
    required this.cantidad,
    required this.precioPlatillo,
    this.index = 0,
    required this.isEdit,
    required this.adiciones
  }) : super(key: key);

  @override
  State<InformacionPlatillo> createState() => _InformacionPlatilloState();
}

class _InformacionPlatilloState extends State<InformacionPlatillo> {
  Pedido pedido = Pedido();
  final numberFormat = NumberFormat.currency(locale: 'es_MX', symbol:"\$");
  late List<String> _currentOptionSimple;
  late List<String> _currentSimple;
  late List<String> _currentOptionMultiple;
  late List _limiteOpcionMultiple;
  late List _limiteOpcionMultipleOriginal;
  String currentOptionSimple = "";
  Map _optionsMultiple = {};
  String servicio = "";
  final TextEditingController _notaController = TextEditingController();
  List _arrayObligatoriosSimple = [],
    _arrayObligatoriosMultiple = [],
    _arrayObligatoriosMultipleOriginal = [],
    precioSencillo = [],
    _arrayAdicionesSimples = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentOptionSimple = [];
    _currentSimple = [];
    _currentOptionMultiple = [];
    _limiteOpcionMultiple = [];
    _limiteOpcionMultipleOriginal = [];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _currentOptionSimple.clear();
    _currentSimple.clear();
    _currentOptionMultiple.clear();
    _arrayObligatoriosSimple.clear();
    _arrayObligatoriosMultiple.clear();
    _arrayObligatoriosMultipleOriginal.clear();
    _arrayAdicionesSimples.clear();
    precioSencillo.clear();
    _limiteOpcionMultiple.clear();
    _limiteOpcionMultipleOriginal.clear();
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(locale: 'es_MX', symbol:"\$");
    final args = ModalRoute.of(context)!.settings.arguments as PlatillosArguments;
    servicio = args.servicio;
    pedido.platillo = args.idCategoria;
    pedido.nombrePlatillo = args.nombre;
    pedido.cantidad = widget.cantidad;
    pedido.precio = widget.precioPlatillo;
    pedido.total = widget.precio;
    return Scaffold(
      bottomNavigationBar: GestureDetector(
          onTap: (){
            if(BlocProvider.of<CarritoBloc>(context).state.servicio) {
              bool passSimple = _arrayObligatoriosSimple.every((element) => element == false);
              bool passMulti = _arrayObligatoriosMultiple.every((element) => element == false);
              if(passSimple && passMulti) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    closeIconColor: Colors.white,
                    showCloseIcon: true,
                    backgroundColor: customTheme.secondary,
                    content: const Text("Producto agregado", style: TextStyle(fontWeight: FontWeight.w600),),
                  )
                );
                pedido.nota = _notaController.text;
                pedido.agregarAdicionSimple(_arrayAdicionesSimples);
                BlocProvider.of<CarritoBloc>(context).add(CarritoUpdateEvent(widget.precio, pedido, widget.index, widget.isEdit));              
                Navigator.pop(context, true);
              } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      showCloseIcon: true,
                      closeIconColor: Colors.white,
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.red,
                      content: Text("Este platillo tiene opciones obligatorias", style: TextStyle(fontWeight: FontWeight.w600),),
                    )
                  );
                }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  showCloseIcon: true,
                  closeIconColor: Colors.white,
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                  content: Text("Servicio a domicilio no disponible", style: TextStyle(fontWeight: FontWeight.w600),),
                )
              );
            }
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(50.0),
              topRight: Radius.circular(50.0),
            ),
            child: BottomAppBar(
              color: customTheme.secondary,
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Icon(Icons.shopping_cart_checkout, color: Colors.white,),
                  const SizedBox(width: 10,),
                  const Text('Agregar al carrito', style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w600),),
                  const SizedBox(width: 10,),
                  Text(numberFormat.format(double.parse(widget.precio)), style: const TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w600),)
                ],
              ),
            ),
          )
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: widget.platillosService.getPlatillo(args.idCategoria),
          builder: (_, AsyncSnapshot<Platillos> snapshot) {
            if(snapshot.hasData) {              
              _buildAdicionSimple(snapshot.data!);
              return _showResult(snapshot.data!, context);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  _buildAdicionSimple(Platillos platillos) {
    if(_arrayObligatoriosSimple.isEmpty) {
      _arrayObligatoriosSimple = platillos.adiciones_simples.map((el) => el['obligatorio']).toList();
    }
    if(_arrayObligatoriosMultiple.isEmpty) {
      _arrayObligatoriosMultiple = platillos.adiciones.map((e) => e['obligatorio']).toList();
      _arrayObligatoriosMultipleOriginal = [..._arrayObligatoriosMultiple];
    }
    if(_currentOptionSimple.isEmpty) {      
      _currentOptionSimple = List.generate(platillos.adiciones_simples.length, (index) => "").toList();
      _currentSimple = List.generate(platillos.adiciones_simples.length, (index) => "").toList();
      _arrayAdicionesSimples = [..._currentOptionSimple];
      if(widget.isEdit) {
        for(var i=0; i < platillos.adiciones_simples.length; i ++) {
          final indexParent = i;
          for(var index in platillos.adiciones_simples[i]['ingredientes']) {
            widget.adiciones.forEach((element) {
              if(element['id'] == index['id_adicion']) {
                _arrayObligatoriosSimple[indexParent] = false;
                _arrayAdicionesSimples[indexParent] = element;
                _currentOptionSimple[indexParent] = index['nombre'];
                BlocProvider.of<PlatilloBloc>(context)
                    .add(ChangeAdicionSimplePrecioEvent(index['precio'], indexParent, _currentSimple));
              }
            });
          }          
        }
      }
    }
    if(_limiteOpcionMultiple.isEmpty) {
      _limiteOpcionMultiple = List.generate(platillos.adiciones.length, (index) => platillos.adiciones[index]['limite']).toList();
      _limiteOpcionMultipleOriginal = [..._limiteOpcionMultiple];
    }
    if(_currentOptionMultiple.isEmpty) {
      _currentOptionMultiple = List.generate(platillos.adiciones.length, (index) => "").toList();
      if(widget.isEdit){
        for(var i=0; i < platillos.adiciones.length; i ++) {
          final indexParent = i;          
          for(var index in platillos.adiciones[i]['ingredientes']) {
            widget.adiciones.forEach((element) {
              if(element['id'] == index['id_adicion']) {
                _arrayObligatoriosMultiple[indexParent] = false;
                _optionsMultiple[index['id_adicion']] = index;
                if(_limiteOpcionMultipleOriginal[i] != 0) {
                  _limiteOpcionMultiple[i] -= 1;
                  element['precio'] = "0";
                  BlocProvider.of<PlatilloBloc>(context)
                  .add(ChangeAdicionMultiplePrecioEvent("0", indexParent, _currentOptionMultiple));
                } else {
                  BlocProvider.of<PlatilloBloc>(context)
                    .add(ChangeAdicionMultiplePrecioEvent(index['precio'], indexParent, _currentOptionMultiple));
                } 
                pedido.agregarAdicion(element);                
              }
            });
          }
        }
      }
    }
  }

  Widget _showResult(Platillos platillo, BuildContext context) {
    return ListView(
      children: [
        Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
                child: FadeInImage(
                  placeholder: const AssetImage("assets/logo.png"),
                  image: NetworkImage(platillo.foto_platillo_detalle),
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset("assets/logo.png");
                  },
                ),
              ),
              const SizedBox(height: 5,),
              Center(
                child: Text(
                  platillo.nombre,
                  style: const TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.w700
                  ),
                ),
              ),
              const SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                    platillo.descripcion,
                    style: const TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
              ),
               _showTitleComplemento(platillo),
               _showAdicionesSimples(platillo.adiciones_simples),
               _showAdicionesMultiples(platillo.adiciones),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _notaController,
                  maxLines: 3,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note_add_outlined),
                    hintText: "Incluye una nota"
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              _showBoxQuantity(),
              const SizedBox(height: 15,),
            ],
          ),
      ]
    );
  }

  Widget _showBoxQuantity() {
    return Container(
      height: 40,
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          top: BorderSide(color: Colors.black12),
          bottom: BorderSide(color: Colors.black12),
          left: BorderSide(color: Colors.black12),
          right: BorderSide(color: Colors.black12)
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              BlocProvider.of<PlatilloBloc>(context).add(ChangeQuantityLessEvent());
            },
            child: const Text('-', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.red),),
          ),
          SizedBox(
            width: 50, 
            child: Center(
              child: Text(
                  widget.cantidad.toString(),
                  style: const TextStyle(
                    fontSize: 18.0
                  ),
                )
              )
            ),
          TextButton(
            onPressed: () {
              BlocProvider.of<PlatilloBloc>(context).add(ChangeQuantityEvent());
            },
            child: const Text('+', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _showAdicionesSimples(List platillo) {
    List<Widget> _platillo = [];    
    for(var i=0; i < platillo.length; i++) {
      _platillo.add(
        Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: const Border(
                top: BorderSide(color: Colors.white)
              )
            ),       
            height: 45.0,
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 6,
                  color: customTheme.secondary,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    platillo[i]['titulo'],
                    style: TextStyle(
                      color: customTheme.secondary,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: _showLabelObligatorio(i)
                  ),
                ),
              ],
            )
          ),
          _showIngredients(platillo[i]['ingredientes'], i)
        ],
      )
      );
    }
    return Column(children: _platillo,);
  }

  Widget _showLabelObligatorio(int index) {
    String _label = "Obligatorio";
    if(_arrayObligatoriosSimple[index]) {
      return Text(
        _label,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 14.0,
        ),
      );
    } else {
      _label = 'Listo';
      return AnimatedTextKit(
        animatedTexts: [
          TyperAnimatedText(
            _label,
            textAlign: TextAlign.right,
            textStyle: TextStyle(
              color: customTheme.secondary,
              fontSize: 14.0,
              fontWeight: FontWeight.bold
            ),
          )          
        ],
        totalRepeatCount: 1,
      );
    }
  }

  Widget _showLabelMultipleObligatorio(int index) {
    String _label = "Obligatorio";
    if(_arrayObligatoriosMultiple[index]) {
      return Text(
        _label,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 14.0,
        ),
      );
    } else {
      _label = 'Listo';
      return AnimatedTextKit(
        animatedTexts: [
          TyperAnimatedText(
            _label,
            textAlign: TextAlign.right,
            textStyle: TextStyle(
              color: customTheme.secondary,
              fontSize: 14.0,
              fontWeight: FontWeight.bold
            ),
          )           
        ],
        isRepeatingAnimation: false,
        stopPauseOnTap: true,
      );
    }
  }

 Widget  _showIngredients(List ingredientes, int posicion) {
    List<Widget> _ingrediente = [];  
    final options = List.generate(ingredientes.length, (index) => ingredientes[index]['nombre']);    
    for(var i =0; i <= ingredientes.length-1; i++) {  
      if(ingredientes[i]['nombre'] != null) {
        _ingrediente.add(
        Row(
            children: [
              Expanded(
                child: 
                  RadioListTile(
                  dense: true,
                  value: options[i] as String, 
                  activeColor: customTheme.secondary,
                  groupValue: _currentOptionSimple[posicion],
                  title: Text(ingredientes[i]['nombre'], style: const TextStyle(fontSize: 18.0),),
                  subtitle: Text((ingredientes[i]['precio'] == "0") 
                      ? '' 
                      : ' + ${numberFormat.format(double.parse(ingredientes[i]['precio']))}', 
                    style: const TextStyle(fontSize: 15.0)),
                  onChanged: (newValue){
                    setState(() {
                      final adiciones = {
                        "id" : ingredientes[i]['id_adicion'],
                        "precio" : ingredientes[i]['precio'],
                        "cantidad" : 1,
                        "nombre" : ingredientes[i]['nombre']
                      };
                      if(_arrayAdicionesSimples.isEmpty) {
                        _arrayAdicionesSimples.insert(posicion, adiciones);
                      } else {
                        _arrayAdicionesSimples[posicion] = adiciones;
                      }
                      //pedido.agregarAdicionSimple(_arrayAdicionesSimples);
                      _currentOptionSimple[posicion] = newValue.toString();
                      if(_currentOptionSimple[posicion] != newValue.toString()) {
                        _arrayObligatoriosSimple[posicion] = true;
                      } else {
                        _arrayObligatoriosSimple[posicion] = false;
                      }
                    });
                    BlocProvider.of<PlatilloBloc>(context)
                      .add(ChangeAdicionSimplePrecioEvent(ingredientes[i]['precio'], posicion, _currentSimple));
                  }),
              )
            ],
          ),
      );
      }
      _ingrediente.add(const Divider());
    }
    return Column(
      children: _ingrediente,
    );
  }

  Widget _showIngredientsMultiple(List ingredientes, int posicion) {
    List<Widget> _ingrediente = [];    
    for(var i=0; i <= ingredientes.length-1; i++) {
      if(ingredientes[i]['nombre'] != null) {
        _ingrediente.add(
        Row(
          mainAxisSize: MainAxisSize.min,
            children: [     
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _optionsMultiple.containsKey(ingredientes[i]['id_adicion']),
                  activeColor: customTheme.secondary,
                  onChanged: (value){
                    setState(() {                      
                      if(value == true) {
                        final adiciones = {
                          "id" : ingredientes[i]['id_adicion'],
                          "precio" : (_limiteOpcionMultiple[posicion] == 0) ? ingredientes[i]['precio'] : "0",
                          "cantidad" : 1,
                          "nombre" : ingredientes[i]['nombre']
                        };
                        pedido.agregarAdicion(adiciones);
                        _optionsMultiple[ingredientes[i]['id_adicion']] = ingredientes[i];
                        if(_arrayObligatoriosMultipleOriginal[posicion]) {
                          _arrayObligatoriosMultiple[posicion] = false;
                        }
                        if(_limiteOpcionMultiple[posicion] != 0 ) {
                          _limiteOpcionMultiple[posicion] -= 1;
                        }
                        BlocProvider.of<PlatilloBloc>(context)
                          .add(ChangeAdicionMultiplePrecioEvent(adiciones['precio'], i, _currentOptionMultiple));
                      } else {
                        if( !_arrayObligatoriosMultiple[posicion]) {
                          _arrayObligatoriosMultiple[posicion] = true;
                        }
                        _optionsMultiple.remove(ingredientes[i]['id_adicion']);
                        pedido.quitarAdicion(ingredientes[i]['id_adicion']);
                        if(_limiteOpcionMultiple[posicion] != _limiteOpcionMultipleOriginal[posicion]) {
                          _limiteOpcionMultiple[posicion] += 1;
                        }
                        BlocProvider.of<PlatilloBloc>(context)
                          .add(ChangeAdicionMultiplePrecioRemoveEvent(ingredientes[i]['precio'], i, _currentOptionMultiple));
                      }
                    });                    
                  },
                  title: Text(ingredientes[i]['nombre'], style: const TextStyle(fontSize: 17.0),),
                  subtitle: Text((ingredientes[i]['precio'] == "0") ? '' : ' + ${numberFormat.format(double.parse(ingredientes[i]['precio']))}', style: const TextStyle(fontSize: 15.0)),
                ),
              )         
            ],
          ),
      );
      }      
      _ingrediente.add(const Divider());
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _ingrediente,
    );
  }

  Widget _showAdicionesMultiples(List platillo) {
    List<Widget> _adicionesMultiples = [];
    for(var i=0; i<= platillo.length-1; i++) {
      _adicionesMultiples.add(
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: const Border(
                  top: BorderSide(color: Colors.white)
                )
              ),       
              height: 45.0,
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 6,
                    color: customTheme.secondary,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      (_limiteOpcionMultiple[i] == 0) ?
                      "${platillo[i]['titulo']}" :
                      "${platillo[i]['titulo']} \n (Hasta ${platillo[i]['limite']} sin costo)",
                      maxLines: 2,
                      style: TextStyle(
                        color: customTheme.secondary,
                        fontSize: 17.0,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: _showLabelMultipleObligatorio(i)
                    ),
                  ),
                ],
              )
            ),
            _showIngredientsMultiple(platillo[i]['ingredientes'], i)
          ],
        )
      );
    };
    return Column(
      children: _adicionesMultiples,
    );
  }

  Widget _showTitleComplemento(Platillos platillo) {
    String _label = "Elegir:";
    if(platillo.adiciones.isEmpty && platillo.adiciones_simples.isEmpty) {
      _label = "Sin complementos";
    }
    return Container(
      color: Colors.grey.shade200,
      height: 45.0,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: Text(
        _label,
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }
}

