import 'package:allewellyn4fanpage0/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _Register();
}

class _Register extends State<RegisterPage> {
  // const SignInPage({ Key? key }) : super(key: key);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _display = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Registration")),
        body: _loading
            ? LoadingPage()
            : Center(
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Display Name'),
                            controller: _display,
                            validator: (String? text) {
                              if (text == null || text.isEmpty) {
                                return "you must have a display name";
                              } else if (DatabaseService.usernames
                                  .contains(text.toLowerCase())) {
                                return "Display name already in use";
                              }
                            }),
                        TextFormField(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Email'),
                            controller: _email,
                            validator: (String? text) {
                              if (text == null || text.isEmpty) {
                                return "your email can't be empty";
                              } else if (!text.contains('@')) {
                                return "Please enter valid email";
                              }
                            }),
                        TextFormField(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Password'),
                            controller: _password,
                            validator: (String? text) {
                              if (text == null || text.length < 6) {
                                return "Your password cant be empty";
                              }
                              return null;
                            }),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _loading = true;
                              register(context);
                            });
                          },
                          child: const Text("Register"),
                        ),
                      ],
                    ))));
  }

  void register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
            email: _email.text, password: _password.text);
      } on FirebaseAuthException catch (e) {
        if (e.code == "wrong-password" || e.code == "no-email") {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Incorrect email/password")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() {
          _loading = false;
        });
      }
      try {
        if (_auth.currentUser != null) {
          await _db.collection("users").doc(_auth.currentUser!.uid).set({
            "display_name": _display.text,
            "role": "USER",
            "email": _email.text
          });
        }
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? "Unknown Error")));
        setState(() {
          _loading = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() {
          _loading = false;
        });
      }
    }
  }
}

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
