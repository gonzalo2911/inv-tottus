import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../HomePage/HomePage.dart';
import 'CreateUser.dart';


class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State createState(){
    return _LoginState();
  }
}

class _LoginState extends State<LoginPage>{

  late String email, password;
  final _formKey = GlobalKey<FormState>();
  String error='';

  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xff24B209),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Padding(
            padding: const EdgeInsets.only(left: 20,right: 20 ),
            child: Image.asset("assets/logo/logotottus.png"),
          ),
          const Text("APP INVENTARIO",style: TextStyle(color: Colors.white,fontSize: 22,fontWeight: FontWeight.w800 ),),
          Wrap(
            children: [
              Container(
                margin: const EdgeInsets.all(12),
                 width: 170,
                  height: 40,
                  child: TextButton(
                      onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
              }, child: const Text("Iniciar Sesion",style: TextStyle(color: Colors.black,fontSize: 19)))
              ),
              Container(
                  margin: const EdgeInsets.all(12),
                  width: 170,
                  height: 40,
                  child: TextButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateUser()));
                  }, child: const Text("Registrarse",style: TextStyle(color: Colors.black,fontSize: 19)))
              ),


            ],
          ),
          Offstage(
            offstage: error =='',
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(error,style: const TextStyle(color: Colors.white, fontSize: 24),),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: formulario(),
          ),
          butonLogin(),

        ],
      ),
    );
  }



  Widget formulario(){
    return Form(
        key: _formKey,
        child: Column(children: [
          buildEmail(),
          const Padding(padding: EdgeInsets.only(top: 12)),
          buildPassword(),
        ],)
    );
  }

  Widget buildEmail(){
    return TextFormField(
      decoration: InputDecoration(
          label: const Text("ejemplo@gmail.com"),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black)
          )
      ),
      keyboardType: TextInputType.emailAddress,
      onSaved: (String? value){
        email = value!;
      },
      validator: (value){
        if(value!.isEmpty){
          return "este campo es obligatorio";
        }
        return null;
      },
    );
  }

  Widget buildPassword(){
    return TextFormField(
      decoration: InputDecoration(
          label: const Text('Contraseña'),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black)
          )
      ),
      obscureText: true,
      validator: (value){
        if(value!.isEmpty){
          return "este campo es obligatorio";
        }
        return null;
      },

      onSaved: (String? value){
        password = value!;
      },
    );
  }

  Widget butonLogin(){
    return FractionallySizedBox(
      widthFactor: 0.9,
      child: ElevatedButton(onPressed:() async{
        if(_formKey.currentState!.validate()){
          _formKey.currentState!.save();
          UserCredential? credenciales = await login(email, password);
          if(credenciales !=null){
            if(credenciales.user !=null){
              if(credenciales.user!.emailVerified){
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
              }
              else{
                setState(() {
                  error = "Verificar Correo";
                });
              }
            }
          }
        }
      }, child: const Text("Ingresar",style: TextStyle(color: Colors.black,fontSize: 23),)),
    );
  }

  Future<UserCredential?> login(String email, String password) async{
    try{
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email,
          password: password);
      return userCredential;

    }on FirebaseAuthException catch(e){
      if(e.code == 'user-not-found'){
        setState(() {
          error = "Usuario no encontrado";
        });
      }

      if(e.code == "wrong-password"){
        setState(() {
          error = "Contraseña Incorrecta";
        });
      }
    }
    return null;
  }
}