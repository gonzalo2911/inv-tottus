import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Importar para el formato de la fecha
import 'package:inventariotottus/conteos/conteospgc.dart';
import '../conteos/conteoselectro.dart';
import '../conteos/conteosnonfood.dart';
import '../conteos/conteosperecibles.dart';

class invzonaa extends StatefulWidget {
  final String local;

  invzonaa({required this.local});

  @override
  _invzonaaState createState() => _invzonaaState();
}

class _invzonaaState extends State<invzonaa> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final Map<String, List<Map<String, dynamic>>> _inventarioLists = {
    'PGC': [],
    'PERECIBLE': [],
    'NON FOOD': [],
    'ELECTRO': [],
  };

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllInventarios();
  }

  Future<void> _loadAllInventarios() async {
    await Future.wait([
      _loadInventario('PGC'),
      _loadInventario('PERECIBLE'),
      _loadInventario('NON FOOD'),
      _loadInventario('ELECTRO'),
    ]);
  }

  Future<void> _loadInventario(String category) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('inventario')
          .where('subtitle', isEqualTo: widget.local)
          .where('category', isEqualTo: category)
          .get();

      final List<Map<String, dynamic>> loadedInventarioList = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final date = data['date'] as Timestamp?;

        // Convertir Timestamp a DateTime y luego a String en formato legible
        final dateTime = date?.toDate();
        final localDateTime = dateTime?.toLocal();
        final formattedDate = localDateTime != null
            ? DateFormat('d MMMM yyyy').format(localDateTime) // Personaliza el formato como desees
            : '';

        print('Fecha en UTC: ${dateTime?.toUtc()}'); // Depuración
        print('Fecha convertida a hora local: $localDateTime'); // Depuración

        return {
          'id': doc.id,
          'title': data['title'] as String? ?? '',
          'subtitle': data['subtitle'] as String? ?? '',
          'date': formattedDate,
          'dateTime': localDateTime ?? DateTime.now(),
          'creatorName': data['creatorName'] as String? ?? 'Desconocido',
        };
      }).toList();

      loadedInventarioList.sort((a, b) => b['dateTime'].compareTo(a['dateTime']));

      setState(() {
        _inventarioLists[category]?.clear();
        _inventarioLists[category]?.addAll(loadedInventarioList);
      });
    } catch (e) {
      print('Error al cargar inventario: $e');
    }
  }

  Future<void> _agregarInventario(String category) async {
    if (_controller.text.isNotEmpty) {
      final now = DateTime.now(); // Usar la hora local

      // Obtener el UID y nombre del usuario actual
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No hay un usuario autenticado');
        return;
      }

      try {
        // Obtener el nombre del usuario desde la colección 'usuarios'
        final userProfile = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
        final userName = userProfile.data()?['usuario'] ?? 'Desconocido';

        final newItem = {
          'title': _controller.text,
          'subtitle': widget.local,
          'date': Timestamp.fromDate(now.toUtc()), // Guardar como Timestamp en UTC
          'category': category,
          'creator': user.uid,
          'creatorName': userName,
        };

        DocumentReference docRef = await FirebaseFirestore.instance.collection('inventario').add(newItem);
        print('Documento agregado');

        final newItemWithDate = {
          'id': docRef.id,
          'title': _controller.text,
          'subtitle': widget.local,
          'date': DateFormat('d MMMM yyyy').format(now), // Mostrar en formato legible
          'dateTime': now.toLocal(),
          'creatorName': userName,
        };

        setState(() {
          _inventarioLists[category]?.add(newItemWithDate);
          _inventarioLists[category]?.sort((a, b) => b['dateTime'].compareTo(a['dateTime']));
        });

        _controller.clear();
      } catch (error) {
        print('Error al obtener el perfil del usuario o agregar documento: $error');
      }
    }
  }

  Future<void> _eliminarInventario(String documentId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('inventario').doc(documentId).get();
      final data = doc.data() as Map<String, dynamic>;

      final creatorUid = data['creator'] as String?;
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && creatorUid == currentUser.uid) {
        await FirebaseFirestore.instance.collection('inventario').doc(documentId).delete();
        print('Documento eliminado');

        setState(() {
          _inventarioLists.forEach((category, list) {
            list.removeWhere((item) => item['id'] == documentId);
          });
        });
      } else {
        _showErrorDialog('Solo el usuario creador puede eliminar el inventario.');
      }
    } catch (error) {
      print('Error al eliminar documento: $error');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showConfirmDeleteDialog(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación de Eliminación'),
          content: Text('¿Estás seguro de eliminar el inventario?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop();
                _eliminarInventario(documentId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.local),
          backgroundColor: Color(0xff2AAC08),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            unselectedLabelStyle: TextStyle(fontSize: 13),
            tabs: [
              Tab(text: 'PGC'),
              Tab(text: 'PERECIBLE'),
              Tab(text: 'NON FOOD'),
              Tab(text: 'ELECTRO'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildInventarioTab('PGC'),
            _buildInventarioTab('PERECIBLE'),
            _buildInventarioTab('NON FOOD'),
            _buildInventarioTab('ELECTRO'),
          ],
        ),
      ),
    );
  }

  Widget _buildInventarioTab(String category) {
    final inventoryList = _inventarioLists[category] ?? [];
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Nombre Inventario",
              labelText: "Nombre Inventario",
              icon: Icon(Icons.assignment_add),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () => _agregarInventario(category),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffECE34C),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Text(
                'Crear Inventario',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: inventoryList.length,
              itemBuilder: (context, index) {
                final item = inventoryList[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.all(6),
                          title: Text(item['title'] ?? ''),
                          subtitle: Text(
                            '${item['subtitle'] ?? ''} - ${item['date'] ?? ''} - ${item['creatorName'] ?? ''}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          onTap: () {
                            switch (category) {
                              case 'PGC':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => conteospgc(
                                      title: item['title'] ?? '',
                                      local: widget.local,
                                    ),
                                  ),
                                );
                                break;
                              case 'PERECIBLE':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => conteosperecibles(
                                      title: item['title'] ?? '',
                                      local: widget.local,
                                    ),
                                  ),
                                );
                                break;
                              case 'NON FOOD':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => conteosnonfood(
                                      title: item['title'] ?? '',
                                      local: widget.local,
                                    ),
                                  ),
                                );
                                break;
                              case 'ELECTRO':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => conteoselectro(
                                      title: item['title'] ?? '',
                                      local: widget.local,
                                    ),
                                  ),
                                );
                                break;
                            }
                          },
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showConfirmDeleteDialog(item['id']);
                        },
                        icon: Icon(Icons.delete, color: Colors.black),
                        label: Text('Eliminar', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}





















