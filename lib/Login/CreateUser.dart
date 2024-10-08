import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({super.key});

  @override
  State createState() => _CreateUser();
}

class _CreateUser extends State<CreateUser> {
  final _formKey = GlobalKey<FormState>();
  String error = '';

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usuarioController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff24B209),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Image.asset("assets/logo/logotottus.png"),
          ),
          const Text(
            "APP INVENTARIO",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          Wrap(
            children: [
              Container(
                margin: const EdgeInsets.all(12),
                width: 170,
                height: 40,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                  },
                  child: const Text("Iniciar Sesion", style: TextStyle(color: Colors.black, fontSize: 19)),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(12),
                width: 170,
                height: 40,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateUser()));
                  },
                  child: const Text("Registrarse", style: TextStyle(color: Colors.black, fontSize: 19)),
                ),
              ),
            ],
          ),
          Offstage(
            offstage: error.isEmpty,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(error, style: const TextStyle(color: Colors.white, fontSize: 24)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: formulario(),
          ),
          butonCrearUsuario(),
        ],
      ),
    );
  }

  Widget formulario() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildUsuario(),
          const Padding(padding: EdgeInsets.only(top: 12)),
          buildEmail(),
          const Padding(padding: EdgeInsets.only(top: 12)),
          buildPassword(),
        ],
      ),
    );
  }

  Widget buildUsuario() {
    return TextFormField(
      controller: usuarioController,
      decoration: InputDecoration(
        labelText: 'Nombre y Apellido',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
    );
  }

  Widget buildEmail() {
    return TextFormField(
      controller: emailController,
      decoration: InputDecoration(
        labelText: 'ejemplo@gmail.com',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
    );
  }

  Widget buildPassword() {
    return TextFormField(
      controller: passwordController,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
    );
  }

  Widget butonCrearUsuario() {
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            String email = emailController.text;
            String password = passwordController.text;
            String usuario = usuarioController.text;

            UserCredential? credenciales = await crear(email, password);
            if (credenciales != null && credenciales.user != null) {
              // Agregar usuario a Firestore después de la autenticación
              await FirebaseFirestore.instance.collection('usuarios').doc(credenciales.user!.uid).set({
                'email': email,
                'usuario': usuario,
                // Almacenar otros detalles del usuario si es necesario
              });

              Navigator.of(context).pop();
            }
          }
        },
        child: const Text("Crear Usuario", style: TextStyle(color: Colors.black, fontSize: 23)),
      ),
    );
  }

  Future<UserCredential?> crear(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          error = "Se le envió un correo de verificación";
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.code}');
      if (e.code == 'email-already-in-use') {
        setState(() {
          error = "Usuario ya registrado";
        });
      } else if (e.code == "weak-password") {
        setState(() {
          error = "Contraseña débil";
        });
      } else {
        setState(() {
          error = "Error desconocido: ${e.message}";
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        error = "Error desconocido: $e";
      });
    }
    return null;
  }
}

