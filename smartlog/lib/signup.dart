import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:progettotps/api_client.dart';
import 'package:progettotps/login.dart';
import 'package:progettotps/model/password.dart';

class SignUpPage extends StatefulWidget{
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState()=>_SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController controllerName1=TextEditingController();
  final TextEditingController controllerName2=TextEditingController();
  final TextEditingController controllerSurname=TextEditingController();
  final TextEditingController controllerEmail=TextEditingController();
  final TextEditingController controllerPassword=TextEditingController();

  final ApiClient apiClient=ApiClient();

  Future<void> _handleSignup(BuildContext context) async{
    final name1=controllerName1.text.trim();
    final name2=controllerName2.text.trim();
    final surname=controllerSurname.text.trim();
    final email=controllerEmail.text.trim();
    final password=controllerPassword.text.trim();

    if(name1.isEmpty || surname.isEmpty || email.isEmpty || password.isEmpty){
      if(!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Center(
              child: Text(
                'Inserire i campi richiesti',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            elevation: null,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFFC62828),
          )
      );
    }else{
      try{
        await apiClient.signUp(name1, name2, surname, email, password);

        if(!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
              Center(
                child: Text(
                  'Registrazione avvenuta con successo!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              elevation: null,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black,
            )
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );

      }catch(e){
        if (!context.mounted) return;

        if(e.toString()=='Exception: 409'){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                Center(
                  child: Text(
                    'Utente già registrato',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                elevation: null,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Color(0xFFC62828),
              )
          );
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registrazione fallita: ${e.toString()}')),
          );
        }
      }

    }
  }


  @override
  Widget build(BuildContext context) {
    final textFieldDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.black, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.white,
    );

    return Theme(
      data: Theme.of(context).copyWith(
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/logos/icon.svg',
                  width: 150,
                  height: 150,
                  placeholderBuilder: (context) => const Text('Errore SVG'),
                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Crea un account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: const Text(
                    'Hai già un account? Esegui il log in!',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: controllerName1,
                          decoration: textFieldDecoration.copyWith(
                            labelText: 'Nome',
                            hintText: 'Nome',
                            labelStyle: const TextStyle(color: Colors.black),
                            floatingLabelStyle: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controllerName2,
                          decoration: textFieldDecoration.copyWith(
                            labelText: 'Secondo nome (opzionale)',
                            hintText: 'Secondo nome (opzionale)',
                            labelStyle: const TextStyle(color: Colors.black),
                            floatingLabelStyle: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controllerSurname,
                          decoration: textFieldDecoration.copyWith(
                            labelText: 'Cognome',
                            hintText: 'Cognome',
                            labelStyle: const TextStyle(color: Colors.black),
                            floatingLabelStyle: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controllerEmail,
                          decoration: textFieldDecoration.copyWith(
                            labelText: 'Email',
                            hintText: 'Email',
                            labelStyle: const TextStyle(color: Colors.black),
                            floatingLabelStyle: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Password(passwordController: controllerPassword),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _handleSignup(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Registrati'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}