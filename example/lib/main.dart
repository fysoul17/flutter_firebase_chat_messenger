import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:firebase_chat_messenger/firebase_chat_messenger.dart';

import 'package:flutter_firebase_chat_messenger/Pages/landing_page.dart';
import 'package:flutter_firebase_chat_messenger/Pages/simple_auth_page.dart';
import 'package:flutter_firebase_chat_messenger/Providers/user_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget landingPage;

  @override
  void initState() {
    super.initState();
    print("[[[[ Init ]]]] Material App home");

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      if (user == null) {
        landingPage = SimpleAuthPage();
      } else {
        landingPage = LandingPage();
      }
      setState(() {});
    });
  }

  // Alternative way to handle Rebuilding issue.
  // @override
  // void didChangeDependencies() {
  //   //we don't have to close or unsubscribe SB
  //   Provider.of<AuthService>(context, listen: false).streamAuthServiceState().listen((state) {
  //     switch (state) {
  //       case AuthServiceState.Starting:
  //         print("starting");
  //         break;
  //       case AuthServiceState.SignedIn:
  //         Navigator.pushReplacementNamed(context, Routes.HOME);
  //         break;
  //       case AuthServiceState.SignedOut:
  //         Navigator.pushReplacementNamed(context, Routes.LOGIN);
  //         break;
  //       default:
  //         Navigator.pushReplacementNamed(context, Routes.LOGIN);
  //     }
  //   });

  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    print("[[[[ Build ]]]] MyApp");

    // Some providers needs to be always on top of Material App.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Chat Group List',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // Putting stream in here will cause rebuild when the screen is resized. (eg. keyboard pops, push pages)
        home: landingPage == null ? Center(child: CircularProgressIndicator()) : landingPage,
      ),
    );
  }
}
