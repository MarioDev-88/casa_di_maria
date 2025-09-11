import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cotizador_casa_di_maria/system/platillos_arguments.dart';
import 'package:cotizador_casa_di_maria/models/Product.dart';
import 'package:cotizador_casa_di_maria/services/product_service.dart';

class ProductSearchDelegate extends SearchDelegate {   
  final numberFormat = NumberFormat.currency(locale: 'es_MX', symbol:"\$");
  List<String> searchTerms = [];  
  final String _servicio;

  @override
  String get searchFieldLabel => 'Busca aquí tus platillos';

  ProductSearchDelegate(this._servicio);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: (){
          if(query.isEmpty) {
            close(context, null);
          }
          query = '';          
      }, icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: (){ 
      close(context, null);
    }, 
    icon: AnimatedIcon(
      icon: AnimatedIcons.menu_arrow,
      progress: transitionAnimation,
    ));
  }

  @override
  Widget buildResults(BuildContext context) {
    final productService = ProductService();
    return FutureBuilder(
      future: productService.getProductByName(query),
      builder: (_, AsyncSnapshot snap) {
        if(snap.hasData) {
          return _showResults(snap.data);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final productService = ProductService();
    return FutureBuilder(
      future: productService.getProductByName(query),
      builder: (_, AsyncSnapshot snap) {
        if(snap.hasData) {
          return _showResults(snap.data);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _showResults(List<Product> product) {
    return ListView.builder(
      itemCount: product.length,
      itemBuilder: (_, index) {
        return ListTile(
          onTap: () {
            Navigator.pushNamed(_, "platillo", arguments: 
              PlatillosArguments(idCategoria: product[index].id, nombre: product[index].nombre, servicio: _servicio, precio:(_servicio == "Servicio a domicilio") ? product[index].price : product[index].priceNormal, adiciones: []));
          },
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/logo.png'),
                    image: NetworkImage(product[index].foto),
                    width: 80.0,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset("assets/logo.png", width: 80.0, fit: BoxFit.cover,);
                    },
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(                    
                    width: 150.0,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(                  
                        product[index].nombre,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  SizedBox(
                    width: 150.0,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(                                        
                        (_servicio == "Servicio a domicilio") ? 
                          numberFormat.format(double.parse(product[index].price)) : 
                          numberFormat.format(double.parse(product[index].priceNormal)),
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}