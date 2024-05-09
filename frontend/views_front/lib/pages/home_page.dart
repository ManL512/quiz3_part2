import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:views_front/constants/constants.dart';
import 'package:views_front/pages/deals_page.dart';
import 'articles_page.dart'; // Importa la página de artículos

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _accessToken;
  String _username = "Usuario";
  List<dynamic> _articles = []; // Lista de artículos obtenidos del backend

  @override
  void initState() {
    super.initState();
    _loadAccessToken();
  }

  Future<void> _loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessToken = prefs.getString('accessToken');
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('accessToken');
    Navigator.pop(context);
  }

  Future<void> _getArticles() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/get-articles/'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('articulos')) {
          final List<dynamic> articlesData = jsonData['articulos'];
          setState(() {
            _articles = articlesData;
          });
          
          // Navegar a la página de artículos y pasar la lista de artículos como argumento
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticlesPage(articles: _articles),
            ),
          );
        } else {
          throw Exception('La respuesta del servidor no contiene la lista de artículos');
        }
      } else {
        throw Exception('Error al obtener los artículos');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
Future<void> _getOffers() async {
  try {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/get-offers/'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );
    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);
      if (jsonData is Map<String, dynamic> && jsonData.containsKey('articulos')) {
        final List<dynamic> offersData = jsonData['articulos'];
        
        // Filtrar los artículos en descuento
        final List<dynamic> discountedOffers = offersData.where((offer) => offer['descuento'] != '0').toList();
        
        setState(() {
          _articles = discountedOffers; // Actualiza _articles con los datos de las ofertas filtradas
        });
        
        // Navegar a la página de ofertas y pasar la lista de ofertas como argumento
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DealsPage(articles: _articles),
          ),
        );
      } else {
        throw Exception('La respuesta del servidor no contiene la lista de ofertas');
      }
    } else {
      throw Exception('Error al obtener las ofertas');
    }
  } catch (error) {
    print('Error: $error');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppStyles.gradientStartColor,
              AppStyles.gradientEndColor,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bienvenido $_username',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getArticles,
                style: AppStyles.greenButtonStyle,
                child: Text('Ver Artículos', style: AppStyles.labelTextStyle),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Acción para habilitar la huella digital
                },
                style: AppStyles.greenButtonStyle,
                child: Text('Habilitar huella', style: AppStyles.labelTextStyle),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getOffers,
                style: AppStyles.greenButtonStyle,
                child: Text('Ver ofertas', style: AppStyles.labelTextStyle),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                style: AppStyles.greenButtonStyle,
                child: Text('Cerrar Sesión', style: AppStyles.labelTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
