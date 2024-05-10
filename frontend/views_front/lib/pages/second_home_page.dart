import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:views_front/constants/constants.dart';
import 'package:views_front/pages/articles_page.dart';
import 'package:views_front/pages/login_page.dart';
import 'package:views_front/pages/secondlogin_page.dart';
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
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('accessToken');
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
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Habilitar huella digital'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Usuario'),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Contraseña'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _enableFingerprint(
                    usernameController.text, passwordController.text);
              },
              child: Text('Aceptar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _enableFingerprint(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/fingerprint-create/'),
        body: jsonEncode({
          'username': username,
          'password': password,
          'access_token': _accessToken,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        final String longSessionToken = responseData['long_session_token'];
        setState(() {
          _longSessionToken = longSessionToken;
        });
        await _saveLongSessionToken();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Huella activada'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SecondLoginPage(
              username: username,
              longSessionToken: longSessionToken,
            ),
          ),
        );
      } else {
        throw Exception('Error al activar la huella digital');
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
                child:
                    Text('Ver Artículos', style: AppStyles.labelTextStyle),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showFingerprintModal(context);
                },
                style: AppStyles.greenButtonStyle,
                child: Text('Deshabilitar huella',
                    style: AppStyles.labelTextStyle),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getOffers,
                style: AppStyles.greenButtonStyle,
                child:
                    Text('Ver Ofertas', style: AppStyles.labelTextStyle),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                style: AppStyles.greenButtonStyle,
                child:
                    Text('Cerrar Sesión', style: AppStyles.labelTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
