import 'package:flutter/material.dart';
import 'package:prueba2/screens/comentariosScreen.dart';
import 'package:prueba2/screens/registroScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController _email = TextEditingController();
    TextEditingController _password = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'Correo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _password,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                login(_email.text, _password.text, context);
              },
              child: const Text('Iniciar Sesión'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Registro()),
                );
              },
              child: const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> login(email, pass, context) async {
  if (email.isEmpty || pass.isEmpty) {
    mostrarAlerta(context, "Error", "Por favor, completa todos los campos.",
        Icons.error, Colors.red);
    return;
  }

  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: pass,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Comentarios()),
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      mostrarAlerta(
        context,
        "Error",
        "Usuario no encontrado.",
        Icons.error,
        Colors.red,
      );
    } else if (e.code == 'wrong-password') {
      mostrarAlerta(
        context,
        "Error",
        "Contraseña incorrecta.",
        Icons.error,
        Colors.red,
      );
    } else {
      // Manejo genérico de excepciones específicas de FirebaseAuth
      mostrarAlerta(
        context,
        "Error",
        "Error de autenticación: ${e.message}",
        Icons.error,
        Colors.red,
      );
    }
  } catch (e) {
    // Manejo de errores generales
    mostrarAlerta(
      context,
      "Error",
      "Ha ocurrido un error. Inténtalo de nuevo.",
      Icons.error,
      Colors.red,
    );
  }
}

void mostrarAlerta(BuildContext context, String titulo, String mensaje,
    IconData icono, Color colorIcono) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900], // Fondo oscuro para el diálogo
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(icono, color: colorIcono),
            SizedBox(width: 8),
            Text(
              titulo,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          mensaje,
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Cerrar",
              style: TextStyle(
                  color: Colors.blueAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}
