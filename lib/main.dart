import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elotes_make/bloc/carrito/carrito_bloc.dart';
import 'package:elotes_make/routes/routes.dart';
import 'package:elotes_make/themes/custom.dart';
import 'package:elotes_make/system/globals.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CarritoBloc>(create: (context) => CarritoBloc())
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: appName,
          theme: ThemeData(
            fontFamily: 'Titillium',
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            colorScheme: customTheme 
          ),
          initialRoute: '/',
          routes: getApplicationRoutes(),
      ),
    );
  }
}
