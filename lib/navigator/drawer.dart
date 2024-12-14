import 'package:flutter/material.dart';
import 'package:prueba2/screens/comentariosScreen.dart';
import 'package:prueba2/screens/listaSeriesScreen.dart';

class MiDrawer extends StatelessWidget {
  const MiDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[900], // Fondo oscuro para todo el Drawer
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  'Menú Prueba 2',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildMenuItem(
              context,
              title: "Comentarios",
              icon: Icons.comment,
              color: Colors.redAccent,
              destination: Comentarios(),
            ),
            _buildMenuItem(
              context,
              title: "Series",
              icon: Icons.tv,
              color: Colors.greenAccent,
              destination: Lista(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color,
        size: 30,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      tileColor: Colors.grey[800],
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      onTap: () {
        Navigator.pop(context); // Cierra el Drawer antes de navegar
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
