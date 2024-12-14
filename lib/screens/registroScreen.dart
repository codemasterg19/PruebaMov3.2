import 'package:flutter/material.dart';
import 'package:prueba2/screens/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Registro extends StatelessWidget {
  const Registro({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController _email = TextEditingController();
    TextEditingController _password = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
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
                registro(_email.text, _password.text, context);
              },
              child: const Text('Registrarse'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
              child: const Text('Ya tengo cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> registro(email, password, context) async {
  if (email.isEmpty || password.isEmpty) {
    // Validación de campos vacíos
    error_alert(context, 'Por favor, completa todos los campos.');
    return;
  }

  try {
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Registro exitoso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Usuario registrado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context); // Regresa a la pantalla anterior
  } on FirebaseAuthException catch (e) {
    // Manejo de errores específicos de FirebaseAuth
    switch (e.code) {
      case 'weak-password':
        error_alert(context,
            'La contraseña es demasiado débil. Intenta con una más segura.');
        break;
      case 'email-already-in-use':
        error_alert(context, 'El correo ya está en uso por otro usuario.');
        break;
      case 'invalid-email':
        error_alert(context,
            'El formato del correo no es válido. Verifica e intenta de nuevo.');
        break;
      case 'operation-not-allowed':
        error_alert(
            context, 'El registro con correo y contraseña no está habilitado.');
        break;
      default:
        error_alert(context, 'Ocurrió un error: ${e.message}');
        break;
    }
  } catch (e) {
    // Manejo de errores generales
    error_alert(context, 'Se produjo un error inesperado: ${e.toString()}');
  }
}

// Alerta personalizada
void error_alert(BuildContext context, String mensaje) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8.0),
            Text("Error", style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Text(
          mensaje,
          style: TextStyle(fontSize: 16.0),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Cerrar",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      );
    },
  );
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
