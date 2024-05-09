import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:views_front/constants/constants.dart';
import 'package:views_front/pages/login_page.dart';


class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registerUser() async {
    final Uri registerUrl = Uri.parse('http://127.0.0.1:8000/register/');
    final Map<String, String> requestBody = {
      'username': _usernameController.text,
      'password': _passwordController.text,
    };

    try {
      final http.Response response = await http.post(
        registerUrl,
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        // Registro exitoso
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Registro Exitoso'),
              content: Text('Usuario registrado correctamente.'),
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
      } else {
        // Error en el registro
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error de Registro'),
              content: Text('Hubo un error al registrar el usuario.'),
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
        title: Text('Registro de Usuario'),
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
                onPressed: _registerUser,
                child: Text(
                  'Registrarse',
                  style: AppStyles.labelTextStyle,
                ),
              ),
              SizedBox(height: 10), // Espacio adicional
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()), // Navega a la página de inicio de sesión
                  );
                },
                child: Text(
                  'Ir a Login',
                  style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)), // Cambia el color del texto
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}