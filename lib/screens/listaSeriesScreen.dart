import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prueba2/navigator/drawer.dart';

class Lista extends StatelessWidget {
  const Lista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Series'),
      ),
      drawer: MiDrawer(),
      body: _serieListView('https://jritsqmet.github.io/web-api/series.json'),
    );
  }

  Future<List<Map<String, dynamic>>> fetchSeries(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('series')) {
          final seriesList = List<Map<String, dynamic>>.from(data['series']);
          return seriesList;
        } else {
          throw Exception('Formato de datos inválido');
        }
      } catch (e) {
        throw Exception('Error al procesar datos: $e');
      }
    } else {
      throw Exception('Error de conexión: ${response.statusCode}');
    }
  }

  Widget _serieListView(String url) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchSeries(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final series = snapshot.data!;
          return ListView.builder(
            itemCount: series.length,
            itemBuilder: (context, index) {
              final serie = series[index];
              final info = serie['info'] ?? {};
              final metadata = serie['metadata'] ?? {};

              return Card(
                margin: const EdgeInsets.all(10),
                color: Colors.grey[900],
                child: ListTile(
                  leading: info['imagen'] != null
                      ? Image.network(
                          info['imagen'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.broken_image,
                          size: 50, color: Colors.grey),
                  title: Text(
                    serie['titulo'] ?? 'Título no disponible',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    serie['descripcion'] ?? 'Descripción no disponible',
                    style: const TextStyle(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    _mostrarDetalle(context, serie, info, metadata);
                  },
                ),
              );
            },
          );
        } else {
          return const Center(
            child: Text(
              "No hay series disponibles",
              style: TextStyle(color: Colors.white),
            ),
          );
        }
      },
    );
  }

  void _mostrarDetalle(BuildContext context, Map<String, dynamic> serie,
      Map<String, dynamic> info, Map<String, dynamic> metadata) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            serie['titulo'] ?? 'Información de la Serie',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (info['imagen'] != null)
                Image.network(
                  info['imagen'],
                  height: 100,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 10),
              Text(
                'Año: ${serie['anio'] ?? 'No disponible'}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 5),
              Text(
                'Temporadas: ${metadata['temporadas'] ?? 'No disponible'}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 5),
              Text(
                'Creador: ${metadata['creador'] ?? 'No disponible'}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}
