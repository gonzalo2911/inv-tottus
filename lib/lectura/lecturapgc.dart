import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class lecturapgc extends StatefulWidget {
  final String nombreUbicacion;
  final String title;
  final String local;
  final String numeroUbicacion;

  lecturapgc({
    required this.nombreUbicacion,
    required this.title,
    required this.local,
    required this.numeroUbicacion,
  });

  @override
  _lecturapgcState createState() => _lecturapgcState();

}

class _lecturapgcState extends State<lecturapgc> {
  final TextEditingController lecturaEanController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController cajaNumeroController = TextEditingController(text: "1");

  List<Map<String, String>> datosIngresados = [];
  bool stopAutoIncrement = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void agregarDatos() async {
    String lecturaEan = lecturaEanController.text;
    String cantidad = cantidadController.text;
    String cajaNumero = cajaNumeroController.text;

    if (lecturaEan.isNotEmpty && cantidad.isNotEmpty && cajaNumero.isNotEmpty) {
      try {
        DocumentSnapshot eanDoc = await FirebaseFirestore.instance
            .collection('bdpgc')
            .doc(lecturaEan)
            .get();

        if (eanDoc.exists) {
          String descripcion = eanDoc.get('descripcion');
          String costo = eanDoc.get('costo');
          String div = eanDoc.get('div');
          String sku = eanDoc.get('sku');
          String und = eanDoc.get('und');

          double cantidadNum = double.parse(cantidad);
          double costoNum = double.parse(costo);
          double costoTotal = cantidadNum * costoNum;

          Map<String, dynamic> dataToUpload = {
            'Lectura Ean': lecturaEan,
            'Cantidad': cantidad,
            'Caja Numero': cajaNumero,
            'Descripcion': descripcion,
            'Costo': costo,
            'Div': div,
            'SKU': sku,
            'Und': und,
            'Costo Total': costoTotal.toString(),
            'Nombre Ubicacion': widget.nombreUbicacion,
            'Title': widget.title,
            'Local': widget.local,
            'Numero Ubicacion': widget.numeroUbicacion,
          };

          await FirebaseFirestore.instance.collection('lecturaspgc').add(dataToUpload);

          setState(() {
            datosIngresados.add({
              'Lectura Ean': lecturaEan,
              'Cantidad': cantidad,
              'Caja Numero': cajaNumero,
              'Descripcion': descripcion,
              'Costo': costo,
              'Div': div,
              'SKU': sku,
              'Und': und,
              'Costo Total': costoTotal.toString(),
              'Nombre Ubicacion': widget.nombreUbicacion,
              'Title': widget.title,
              'Local': widget.local,
              'Numero Ubicacion': widget.numeroUbicacion,
            });

            if (!stopAutoIncrement) {
              int cajaNum = int.parse(cajaNumero);
              cajaNum++;
              cajaNumeroController.text = cajaNum.toString();
            }
          });

          lecturaEanController.clear();
          cantidadController.clear();
        } else {
          print('No se encontró un documento para el EAN proporcionado.');
        }
      } catch (e) {
        print('Error al obtener el documento: $e');
      }
    }
  }

  void aumentarNumeroCaja() {
    setState(() {
      int cajaNum = int.parse(cajaNumeroController.text);
      cajaNum++;
      cajaNumeroController.text = cajaNum.toString();
    });
  }

  void disminuirNumeroCaja() {
    setState(() {
      int cajaNum = int.parse(cajaNumeroController.text);
      if (cajaNum > 1) {
        cajaNum--;
        cajaNumeroController.text = cajaNum.toString();
      }
    });
  }

  void toggleAutoIncrement() {
    setState(() {
      stopAutoIncrement = !stopAutoIncrement;
    });
  }

  void mostrarDialogoConfirmacion(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar este ítem?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                eliminarDato(index);
                Navigator.of(context).pop();
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void eliminarDato(int index) async {
    try {
      String ean = datosIngresados[index]['Lectura Ean']!;

      await FirebaseFirestore.instance
          .collection('lecturaspgc')
          .where('Lectura Ean', isEqualTo: ean)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      setState(() {
        datosIngresados.removeAt(index);
      });

      print('Documento eliminado correctamente de Firestore.');
    } catch (e) {
      print('Error al eliminar el documento de Firestore: $e');
    }
  }

  void cargarDatos() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('lecturaspgc')
          .where('Nombre Ubicacion', isEqualTo: widget.nombreUbicacion)
          .where('Title', isEqualTo: widget.title)
          .where('Local', isEqualTo: widget.local)
          .where('Numero Ubicacion', isEqualTo: widget.numeroUbicacion)
          .get();

      setState(() {
        datosIngresados = snapshot.docs.map((doc) => Map<String, String>.from(doc.data() as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  Future<void> scanBarcode() async {
    try {
      final scannedCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Color de la línea de escaneo
        'Cancelar', // Texto del botón de cancelar
        true, // Muestra la linterna
        ScanMode.BARCODE, // Modo de escaneo
      );

      if (scannedCode != '-1') { // Verifica si el código no fue cancelado
        setState(() {
          lecturaEanController.text = scannedCode;
        });
      }
    } catch (e) {
      print('Error al escanear el código de barras: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${widget.nombreUbicacion}/${widget.title}/${widget.local}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Nº Ubicacion: ${widget.numeroUbicacion}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Color(0xff2AAC08),
        toolbarHeight: 80,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: lecturaEanController,
                    decoration: InputDecoration(
                      hintText: "Lectura Ean",
                      labelText: "Lectura Ean",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                IconButton(
                  onPressed: scanBarcode,
                  icon: Icon(Icons.camera_alt),
                  iconSize: 35.0,
                ),

              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cantidadController,
                    decoration: InputDecoration(
                      hintText: "Cantidad",
                      labelText: "Cantidad",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.edit),
                  iconSize: 35.0,
                ),

                // Elimina el botón de edición
                // IconButton(
                //   onPressed: () {},
                //   icon: Icon(Icons.edit),
                //   iconSize: 35.0,
                // ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cajaNumeroController,
                    decoration: InputDecoration(
                      hintText: "Caja Numero",
                      labelText: "Caja Numero",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    enabled: false,
                  ),
                ),
                Text(
                  "       Nª CAJA    ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                IconButton(
                  onPressed: disminuirNumeroCaja,
                  icon: Icon(Icons.remove_circle_outlined),
                  iconSize: 35.0,
                ),
                IconButton(
                  onPressed: aumentarNumeroCaja,
                  icon: Icon(Icons.add_circle),
                  iconSize: 35.0,
                ),
                IconButton(
                  onPressed: toggleAutoIncrement,
                  icon: Icon(
                    stopAutoIncrement ? Icons.play_circle : Icons.stop_circle,
                  ),
                  iconSize: 35.0,
                ),
              ],
            ),
            SizedBox(height: 15),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: agregarDatos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffECE34C),
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: Text(
                    'Agregar',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: datosIngresados.length,
                itemBuilder: (context, index) {
                  final item = datosIngresados[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${item['Descripcion']}"),
                              Text("Ean : ${item['Lectura Ean']}    Sku : ${item['SKU']}"),
                              Text("Cantidad : ${item['Cantidad']}    Nº Caja : ${item['Caja Numero']}     Und : ${item['Und']}"),
                              Text("Costo : ${item['Costo']}     Costo Total : ${item['Costo Total']}"),
                              Text("Div : ${item['Div']}"),
                              Text("Ubicacion: ${item['Nombre Ubicacion']}/${item['Title']}/${item['Local']}",style: TextStyle(fontSize: 1,color: Colors.white),),
                              Text("Nº Ubicacion: ${item['Numero Ubicacion']}",style: TextStyle(fontSize: 1,color: Colors.white),),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            // Elimina el botón de edición
                            // IconButton(
                            //   icon: Icon(Icons.edit, color: Colors.green),
                            //   onPressed: () => editarCantidad(index),
                            // ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.green),
                              onPressed: () => mostrarDialogoConfirmacion(index),
                            ),
                          ],
                        ),
                      ],
                    ),
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



















