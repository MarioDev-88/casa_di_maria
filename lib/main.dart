import 'package:flutter/material.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cotizador_casa_di_maria/routes/routes.dart';
import 'package:cotizador_casa_di_maria/system/globals.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  // Plugin must be initialized before using
  /*await FlutterDownloader.initialize(
    debug: true, // optional: set to false to disable printing logs to console (default: true)
    ignoreSsl: true // option: set to false to disable working with http links (default: false)
  );*/
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appName,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('es'), // Spanish
        ],
        theme: ThemeData(
          fontFamily: 'Inter',
          primaryColor: const Color(0xFFDAA520), // Color mostazas
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFDAA520), // Color mostaza
            primary: const Color(0xFFDAA520),
          ),
          inputDecorationTheme: InputDecorationTheme(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: TextStyle(color: const Color(0xFFDAA520).withOpacity(0.8)),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFDAA520), width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFFDAA520).withOpacity(0.5), width: 1.0),
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.            
        ),
        initialRoute: '/',
        routes: getApplicationRoutes(),
    );
  }
}
