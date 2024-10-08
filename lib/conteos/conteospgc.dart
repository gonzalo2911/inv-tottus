import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Importar intl
import 'package:inventariotottus/lectura/lecturapgc.dart'; // Importar la nueva pantalla

class conteospgc extends StatefulWidget {
  final String title;
  final String local;

  conteospgc({required this.title, required this.local});

  @override
  _conteospgcState createState() => _conteospgcState();
}

class _conteospgcState extends State<conteospgc> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Controlador separado para el campo de contraseña en el diálogo
  final TextEditingController _dialogPasswordController = TextEditingController();

  String? _nombreUsuarioAutenticado;

  Future<void> _obtenerNombreUsuario() async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('usuarios')
            .doc(user.uid)
            .get();
        if (snapshot.exists) {
          setState(() {
            _nombreUsuarioAutenticado = snapshot.data()?['usuario'] ?? 'Usuario desconocido';
          });
        }
      } catch (e) {
        print('Error al obtener el nombre de usuario desde Firestore: $e');
      }
    } else {
      _nombreUsuarioAutenticado = 'Usuario desconocido';
    }
  }

  @override
  void initState() {
    super.initState();
    _obtenerNombreUsuario();
  }

  void _addUbicacion() async {
    final String nombre = _nombreController.text;
    final String numero = _numeroController.text;
    final String password = _passwordController.text;

    final user = _auth.currentUser;

    if (nombre.isNotEmpty && numero.isNotEmpty && password.isNotEmpty && user != null) {
      try {
        final DateTime now = DateTime.now().toUtc();
        final Timestamp timestamp = Timestamp.fromDate(now);

        await _firestore.collection('ubicaciones').add({
          'nombre': nombre,
          'numero': numero,
          'password': password,
          'usuario': _nombreUsuarioAutenticado,
          'uidCreador': user.uid,
          'tituloAppBar': '${widget.local} - ${widget.title}',
          'timestamp': timestamp,
        });

        _nombreController.clear();
        _numeroController.clear();
        _passwordController.clear();
      } catch (e) {
        print('Error al agregar ubicación: $e');
      }
    }
  }

  Future<void> _eliminarUbicacion(String id) async {
    try {
      await _firestore.collection('ubicaciones').doc(id).delete();
    } catch (e) {
      print('Error al eliminar ubicación: $e');
    }
  }

  Future<void> _mostrarDialogoConfirmacion(BuildContext context, String id) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar esta ubicación?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                _eliminarUbicacion(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _verificarYNavegar(String docId, String passwordAlmacenada, String nombreUbicacion, String numeroUbicacion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingresar Contraseña'),
          content: TextField(
            obscureText: true,
            controller: _dialogPasswordController,
            decoration: InputDecoration(
              hintText: 'Contraseña',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                if (_dialogPasswordController.text == passwordAlmacenada) {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => lecturapgc(
                        nombreUbicacion: nombreUbicacion,
                        title: widget.title,
                        local: widget.local,
                        numeroUbicacion: numeroUbicacion, // Pasar el número de ubicación aquí
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contraseña incorrecta')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(localTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.local} - ${widget.title}'),
        backgroundColor: Color(0xff2AAC08),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                hintText: "Nombre Ubicación",
                labelText: "Nombre Ubicación",
                icon: Icon(Icons.assignment_rounded),
              ),
            ),
            TextField(
              controller: _numeroController,
              decoration: InputDecoration(
                hintText: "Número Ubicación",
                labelText: "Número Ubicación",
                icon: Icon(Icons.numbers_sharp),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: "Contraseña",
                labelText: "Contraseña",
                icon: Icon(Icons.lock),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            SizedBox(height: 13),
            ElevatedButton(
              onPressed: _addUbicacion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffECE34C),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Text(
                'Crear Ubicación',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('ubicaciones')
                    .where('tituloAppBar', isEqualTo: '${widget.local} - ${widget.title}')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return Center(child: Text('No hay ubicaciones'));
                  }

                  final ubicaciones = snapshot.data!.docs;
                  final currentUserUid = _auth.currentUser?.uid;

                  return ListView.builder(
                    itemCount: ubicaciones.length,
                    itemBuilder: (context, index) {
                      final doc = ubicaciones[index];
                      final ubicacion = doc.data() as Map<String, dynamic>;
                      final esCreador = ubicacion['uidCreador'] == currentUserUid;
                      final timestamp = ubicacion['timestamp'] as Timestamp?;
                      final fechaHora = timestamp != null ? _formatDateTime(timestamp.toDate()) : 'Desconocida';

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.0),
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.white,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(8.0),
                          title: Text(ubicacion['nombre'] ?? ''),
                          subtitle: Text(
                            'Número Ubicación: ${ubicacion['numero']}\n'
                                'Contraseña: ${esCreador ? ubicacion['password'] : '******'}\n'
                                'Creado por: ${ubicacion['usuario']}\n'
                                'Fecha: ${fechaHora}\n'
                                'Local-Inv: ${ubicacion['tituloAppBar']}',
                          ),
                          onTap: () {
                            _verificarYNavegar(
                              doc.id,
                              ubicacion['password'],
                              ubicacion['nombre'],
                              ubicacion['numero'], // Pasar el número de ubicación aquí
                            );
                          },
                          trailing: ElevatedButton.icon(
                            onPressed: () {
                              if (esCreador) {
                                _mostrarDialogoConfirmacion(context, doc.id);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Solo el usuario creador de la ubicación puede eliminar')),
                                );
                              }
                            },
                            icon: Icon(Icons.delete, color: Colors.black),
                            label: Text('Eliminar', style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
