import 'package:flutter/material.dart';
import '../opcioneszona/invzonaa.dart';
import '../opcioneszona/invzonac.dart';
import '../opcioneszona/invzonad.dart';
import '../opcioneszona/invzonae.dart';
import '../opcioneszona/invzonb.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> localeszonaa = [
    '104-Las Begonias',
    '105-La Marina',
    '114-San Luis',
    '122-La Fontana',
    '123-Angamos',
    '124-Jockey Plaza',
    '158-Miraflores',
    '176-Calle 7',
    '177-Comandante Espinar',
    '316-Arequipa Porongoche',
    '317-Arequipa Cayma',
    '338-Arequipa Parra',
  ];

  final List<String> localeszonab = [
    '103-Mega Plaza',
    '107-Atocongo',
    '110-Huaylas',
    '118-Bellavista',
    '155-Santa Anita',
    '175-Lima Sur',
    '193-Puruchuco',
    '311-Trujillo',
    '314-Trujillo',
    '335-Chimbote',
    '357-Cusco La Cultura',
  ];

  final List<String> localeszonac = [
    '117-Canta Callao',
    '120-Puente Piedra',
    '156-Los Olivos',
    '171-San Hilarion',
    '194-MP Comas',
    '310-Chiclayo 1',
    '315-Piura',
    '336-Chiclayo San Jose',
    '350-Sullana',
    '371-Piura Maestro',
    '450-HTO Pucallpa',
  ];

  final List<String> localeszonad = [
    '112-Quilca',
    '113-Saenz Pena',
    '116-Lima Centro',
    '157-Av. Central',
    '179-MP Villa el Salvador',
    '190-Dominicos',
    '313-Ica',
    '332-Chincha',
    '337-Cañete',
    '359-Huaral MP',
    '372-Huacho',
    '474-TT IQUITOS MALL',
  ];

  final List<String> localeszonae = [
    '111-Zorritos',
    '115-El Agustino',
    '119-Pachacutec',
    '121-Tusilagos',
    '125-Proceres',
    '142-Campoy',
    '352-Pacasmayo',
    '356-Chepen',
    '358-Cajamarca',
    '375-Huancayo',
    '451-HTO Huanuco',
  ];

  List<String> displayedLocales = [];

  void _navigateToDetail(String local) {
    if (displayedLocales == localeszonaa) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => invzonaa(local: local),
        ),
      );
    } else {}

    if (displayedLocales == localeszonab) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => invzonab(local: local),
        ),
      );
    } else {}

    if (displayedLocales == localeszonac) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => invzonac(local: local),
        ),
      );
    } else {}

    if (displayedLocales == localeszonad) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => invzonad(local: local),
        ),
      );
    } else {}

    if (displayedLocales == localeszonae) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => invzonae(local: local),
        ),
      );
    } else {}
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Locales Tottus',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            wordSpacing: 10,
          ),
        ),
        backgroundColor: Color(0xff2AAC08),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 5.0,
              runSpacing: 5.0,
              children: [
                ...['ZONA A', 'ZONA B', 'ZONA C', 'ZONA D', 'ZONA E'].map((zona) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        switch (zona) {
                          case 'ZONA A':
                            displayedLocales = localeszonaa;
                            break;
                          case 'ZONA B':
                            displayedLocales = localeszonab;
                            break;
                          case 'ZONA C':
                            displayedLocales = localeszonac;
                            break;
                          case 'ZONA D':
                            displayedLocales = localeszonad;
                            break;
                          case 'ZONA E':
                            displayedLocales = localeszonae;
                            break;
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffECE34C),
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                    child: Text(
                      zona,
                      style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: displayedLocales.map((locale) {
                return ElevatedButton(
                  onPressed: () {
                    _navigateToDetail(locale);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.0),
                    ),
                  ),
                  child: Text(
                    locale,
                    style: TextStyle(fontSize: 17, color: Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}