import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'second_home_page.dart';
import 'package:views_front/constants/constants.dart';

class SecondLoginPage extends StatelessWidget {
  final String username;
  final String longSessionToken;

  SecondLoginPage({required this.username, required this.longSessionToken});

  Future<void> _loginWithFingerprint(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/fingerprint-login/'),
        body: jsonEncode({
          'username': username,
          'long_session_token': longSessionToken,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        final String shortSessionToken = responseData['access_token'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inicio de sesión exitoso utilizando huella digital.'),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SecondHomePage()), // Navegamos a SecondHomePage
        );
      } else {
        throw Exception('Error al iniciar sesión con huella digital');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Login Page'),
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
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Usuario: $username', // Mostrar el nombre de usuario
                style: AppStyles.labelTextStyle,
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Usuario', // Agregar label para usuario
                  labelStyle: AppStyles.labelTextStyle,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña', // Agregar label para contraseña
                  labelStyle: AppStyles.labelTextStyle,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Lógica para iniciar sesión con nombre de usuario y contraseña
                },
                style: AppStyles.greenButtonStyle,
                child: Text('Iniciar Sesión'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _loginWithFingerprint(context);
                },
                style: AppStyles.greenButtonStyle,
                child: Text('Iniciar Sesión con Huella'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
