import 'package:allewellyn4fanpage0/auth_bloc.dart';
import 'package:allewellyn4fanpage0/signin.dart';
import 'package:provider/provider.dart';

import 'database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference posts = FirebaseFirestore.instance.collection("posts");
  final _postController = TextEditingController();
  late String valueText;
  late String postText;

  @override
  void initState() {
    var authBloc = Provider.of<AuthBloc>(context, listen: false);
    authBloc.currentUser.listen((fbUser) {
      if (fbUser == null) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SignInPage()));
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
      appBar: AppBar(actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          onPressed: () {
            authBloc.logout();
          },
        )
      ]),
      floatingActionButton:
          DatabaseService.userMap[_auth.currentUser!.uid]?.role == "ADMIN"
              ? FloatingActionButton(
                  onPressed: () {
                    addPost();
                  },
                  child: const Text("ADMIN POST"),
                )
              : null,
      body: StreamBuilder<QuerySnapshot>(
        stream: posts.orderBy('Time').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Someting went wrong querying users");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot doc) {
            var post = doc.data() as Map<String, dynamic>;

            return ListTile(
              title: Text(post["message"]),
            );
          }).toList());
        },
      ),
    );
  }

  void addPost() async {
    //await _db.collection("posts").add({"message": "Random stuff can go here"});
    _displayTextInputDialog(context);
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Create Post'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _postController,
              decoration: InputDecoration(hintText: "Message"),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('POST'),
                onPressed: () async {
                  postText = valueText;
                  await _db
                      .collection("posts")
                      .add({"message": postText, "Time": DateTime.now()});
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }
}
