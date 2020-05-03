import 'package:firebase_chat_messenger/firebase_chat_messenger.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    print("[[[[ Build ]]]] Profile Tab");
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          child: Text("Sign Out"),
          onPressed: () {
            ChatEngine.instance.clearCache();
            FirebaseAuth.instance.signOut();
          },
        ),
        RaisedButton(
          child: Text("Remove chat cache"),
          onPressed: () {
            ChatEngine.instance.clearCache();
          },
        ),
        RaisedButton(
          child: Text("RecreateDB"),
          onPressed: () async {
            await ChatEngine.instance.removeDB();
            await ChatEngine.instance.initialize();
          },
        ),
      ],
    );
  }
}
