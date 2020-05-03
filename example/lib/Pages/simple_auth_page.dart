import 'package:firebase_chat_messenger/firebase_chat_messenger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleAuthPage extends StatefulWidget {
  const SimpleAuthPage({Key key}) : super(key: key);

  @override
  _SimpleAuthPageState createState() => _SimpleAuthPageState();
}

class _SimpleAuthPageState extends State<SimpleAuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print("[[[[ Build ]]]] Auth Page");
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 150),
              Text("Firebase Chat Messenger Sample", style: Theme.of(context).textTheme.body1.copyWith(fontSize: 20)),
              SizedBox(height: 100),
              // e-mail field.
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  hintText: "Input e-mail here",
                  labelText: "e-mail",
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                ),
              ),
              SizedBox(height: 30),
              // password field.
              TextField(
                obscureText: true,
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  hintText: "Input password here",
                  labelText: "password",
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                ),
              ),
              SizedBox(height: 30),
              RaisedButton(
                child: Text("SignIn"),
                onPressed: () async {
                  try {
                    print(">>>>> Signing In with email: ${_emailController.text}");
                    await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text);
                  } catch (e) {
                    print(">>>>> Sign In Error: ${e.toString()}");
                  }
                },
              ),
              RaisedButton(
                child: Text("SignUp"),
                onPressed: () async {
                  try {
                    print(">>>>> Signing Up with email: ${_emailController.text}");
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text);
                    // NOTE: User data creation must be performed on 'Clound Functions' for commercial use app.
                    // This is only for demonstration.
                    FirebaseUser user = await FirebaseAuth.instance.currentUser();
                    String email = _emailController.text.trim();
                    await Firestore.instance.collection("users").document(user.uid).setData({
                      "email": email,
                      "username": email,
                      "createdAt": FieldValue.serverTimestamp(),
                      "avatarUrl": "",
                      "profile": "안녕하세요 OOO 입니다. 말좀 걸어주세욤.",
                    });
                  } catch (e) {
                    print(">>>>> Sign Up Error: ${e.toString()}");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
