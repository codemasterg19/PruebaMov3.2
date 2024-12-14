import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prueba2/navigator/drawer.dart';
import 'package:firebase_database/firebase_database.dart';

class Comentarios extends StatefulWidget {
  const Comentarios({super.key});

  @override
  _ComentariosState createState() => _ComentariosState();
}

class _ComentariosState extends State<Comentarios> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController();
  String? _serieSeleccionada;

  List<Map<String, dynamic>> _series = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarSeries();
  }

  Future<void> _cargarSeries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('https://jritsqmet.github.io/web-api/series.json'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data.containsKey('series')) {
          setState(() {
            _series = List<Map<String, dynamic>>.from(data['series']);
          });
        } else {
          throw Exception('Formato de datos inválido');
        }
      } else {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar las series: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentarios'),
      ),
      drawer: const MiDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Realiza un comentario",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        labelText: "ID de Comentario",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _serieSeleccionada,
                      items: _series.map((serie) {
                        return DropdownMenuItem<String>(
                          value: serie['titulo'],
                          child: Text(serie['titulo']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _serieSeleccionada = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Selecciona una serie",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _comentarioController,
                      decoration: const InputDecoration(
                        labelText: "Comentario",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_validarCampos()) {
                          guardar(
                            _idController.text,
                            _serieSeleccionada!,
                            _comentarioController.text,
                          ).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Comentario guardado'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _limpiarCampos();
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Error al guardar comentario: $error'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Guardar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  bool _validarCampos() {
    if (_idController.text.isEmpty) {
      _mostrarAlerta("Error", "El ID del comentario no puede estar vacío");
      return false;
    }
    if (_serieSeleccionada == null) {
      _mostrarAlerta("Error", "Debe seleccionar una serie");
      return false;
    }
    if (_comentarioController.text.isEmpty) {
      _mostrarAlerta("Error", "El comentario no puede estar vacío");
      return false;
    }
    return true;
  }

  void _mostrarAlerta(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  void _limpiarCampos() {
    _idController.clear();
    _comentarioController.clear();
    setState(() {
      _serieSeleccionada = null;
    });
  }

  Future<void> guardar(String id, String serie, String comentario) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("comentarios/$id");
    await ref.set({
      "serie": serie,
      "comentario": comentario,
    });
  }
}
