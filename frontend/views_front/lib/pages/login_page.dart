import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:views_front/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:views_front/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginUser() async {
    final Uri loginUrl = Uri.parse('http://192.168.1.87:3000/login');
    final Map<String, String> requestBody = {
      'username': _usernameController.text,
      'password': _passwordController.text,
    };

    try {
      final http.Response response = await http.post(
        loginUrl,
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Login exitoso
        final responseData = jsonDecode(response.body);
        final accessToken = responseData['access_token'];

        // Guardar el token de acceso en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('accessToken', accessToken);

        // Navegar a la página HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // Error en el login
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error de Login'),
              content: Text('Credenciales inválidas.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      // Error de conexión
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error de Conexión'),
            content: Text('Hubo un error de conexión.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de Sesión'),
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de usuario',
                  labelStyle: AppStyles.labelTextStyle,
                  filled: true,
                  fillColor: AppStyles.labelBackgroundColor,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: AppStyles.labelTextStyle,
                  filled: true,
                  fillColor: AppStyles.labelBackgroundColor,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: AppStyles.greenButtonStyle,
                onPressed: _loginUser,
                child: Text(
                  'Iniciar Sesión',
                  style: AppStyles.labelTextStyle,
                ),
              ),
              SizedBox(height: 10), // Espacio adicional
              TextButton(
                onPressed: () {
                  // Aquí puedes implementar la navegación a la página de registro
                },
                child: Text(
                  'Crear una cuenta',
                  style: TextStyle(color: Colors.white), // Cambia el color del texto
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
