import 'package:flutter/material.dart';
import 'package:elotes_make/system/arguments.dart';
import 'package:elotes_make/system/platillos_arguments.dart';
import 'package:elotes_make/models/Categories.dart';
import 'package:elotes_make/services/categories_service.dart';
import 'package:intl/intl.dart';

import '../presentation/carrito.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final numberFormat = NumberFormat.currency(locale: 'es_MX', symbol:"\$");
  final carrito = Carrito();
  final CategoriesService _categoriesService = CategoriesService();
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as AppArguments;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
      ),
      backgroundColor: Colors.yellow,
      floatingActionButton: carrito.showFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: carrito.showBottomBar(),
      body: SafeArea(
        child: FutureBuilder(
          future: _categoriesService.getCategories(),
          builder: (_, AsyncSnapshot snap) {
            if(snap.hasData) {
              return _showResults(snap.data, args.servicio);
            } else {
              return const Center(child: CircularProgressIndicator());
            } 
          },
        ),
      ),
    );
  }
  
  Widget _showResults(List<Categories> categories, String servicio) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final categoria = categories[i];
        return GestureDetector(
          onTap: (){
            Navigator.pushNamed(context, 'platillos', arguments: PlatillosArguments(idCategoria: categoria.idCategoria, nombre: categoria.nombre, servicio: servicio, adiciones: []));
          },
          child: Container(            
              height: 100,
              decoration: BoxDecoration(    
                border: const Border(bottom: BorderSide(color: Colors.white, width: 2.0)),
                color: Colors.black,
                image: DecorationImage(
                  opacity: 0.6,
                  fit: BoxFit.cover,
                  image: NetworkImage('https://zesty.com.mx'+categories[i].foto)
                )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, left: 10.0),
                    child: Text(
                      categories[i].nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Titillium',
                        fontSize: 26.0
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_sharp,
                    size: 35,
                    color: Colors.white,
                  )
                ],
              )
            ),
        );
      },
    );
  }
}