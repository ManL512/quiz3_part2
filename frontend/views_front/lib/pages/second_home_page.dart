import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:views_front/constants/constants.dart';
import 'package:views_front/pages/articles_page.dart';
import 'package:views_front/pages/login_page.dart';
import 'package:views_front/pages/deals_page.dart';

class SecondHomePage extends StatefulWidget {
  @override
  _SecondHomePageState createState() => _SecondHomePageState();
}

class _SecondHomePageState extends State<SecondHomePage> {
  String? _accessToken;
  String _username = "Usuario";
  String _longSessionToken = "";
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessToken = prefs.getString('accessToken');
    });
    _longSessionToken = await _storage.read(key: 'longSessionToken') ?? '';
  }

  Future<void> _saveLongSessionToken() async {
    await _storage.write(key: 'longSessionToken', value: _longSessionToken);
  }

  Future<void> _logout() async {
    // Muestra un diálogo de confirmación antes de deshabilitar la huella digital
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seguro que desea eliminar la huella?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _removeFingerprint(); // Elimina la huella digital
              },
              child: Text('Sí'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeFingerprint() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await _storage.delete(key: 'longSessionToken');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
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
        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('articulos')) {
          final List<dynamic> articlesData = jsonData['articulos'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticlesPage(articles: articlesData),
            ),
          );
        } else {
          throw Exception(
              'La respuesta del servidor no contiene la lista de artículos');
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
        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('articulos')) {
          final List<dynamic> articlesData = jsonData['articulos'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DealsPage(offers: articlesData),
            ),
          );
        } else {
          throw Exception(
              'La respuesta del servidor no contiene la lista de artículos');
        }
      } else {
        throw Exception('Error al obtener los artículos');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _showFingerprintModal(BuildContext context) {
    // ...
  }

  Future<void> _enableFingerprint(
      String username, String password) async {
    // ...
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
                onPressed: _logout,
                style: AppStyles.greenButtonStyle,
                child: Text(
                  'Deshabilitar huella',
                  style: AppStyles.labelTextStyle,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getOffers,
                style: AppStyles.greenButtonStyle,
                child: Text('Ver Ofertas', style: AppStyles.labelTextStyle),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                style: AppStyles.greenButtonStyle,
                child: Text(
                  'Cerrar Sesión',
                  style: AppStyles.labelTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
