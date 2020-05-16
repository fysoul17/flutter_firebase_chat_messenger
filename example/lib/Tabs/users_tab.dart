import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_messenger/Model/user.dart';
import 'package:flutter_firebase_chat_messenger/Providers/user_provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_firebase_chat_messenger/Pages/chat_page.dart';

import 'package:firebase_chat_messenger/firebase_chat_messenger.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({Key key}) : super(key: key);

  @override
  _UsersTabState createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    print("[[[[ Build ]]]] Users Tab");
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("All users list"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("users").snapshots(),
        builder: (_, snapshot) {
          UserProvider userProvider = UserProvider.of(context, listen: false);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            String myUserId = userProvider.userData.uid;

            // This is my information.
            DocumentSnapshot myDocument = snapshot.data.documents.firstWhere((doc) => doc.documentID == myUserId, orElse: null);

            // This is all other users.
            List<DocumentSnapshot> others = snapshot.data.documents.where((doc) => doc.documentID != myUserId).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // My information
                _buildListTileFor(User.fromFirebase(myDocument), context, isMyself: true),
                Divider(height: 2, thickness: 2),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.only(left: 15),
                  child: Text("All users"),
                ),
                // Other Users
                ...List.generate(others.length, (index) {
                  return Column(
                    children: <Widget>[
                      _buildListTileFor(User.fromFirebase(others[index]), context),
                      Divider(height: 1, thickness: 1),
                    ],
                  );
                }),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildListTileFor(User user, BuildContext context, {bool isMyself = false}) {
    bool _photoExist = user.avatarUrl.length > 0;
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.black,
        child: CircleAvatar(
          radius: 27,
          backgroundColor: _photoExist ? Colors.white : Colors.grey[400],
          backgroundImage: _photoExist ? CachedNetworkImageProvider(user.avatarUrl) : null,
          child: _photoExist ? Container() : Icon(Icons.person, size: 30, color: Colors.white),
        ),
      ),
      title: Text(user.email),
      //subtitle: Text("Joined At: ${DateFormat("yyyy/MM/dd").format(user.createdAt.toDate())}"),
      subtitle: Text(user.profile),
      trailing: isMyself ? null : Icon(Icons.navigate_next),
      onTap: isMyself ? null : () => _displayChatPage(context, user),
    );
  }

  _displayChatPage(BuildContext context, User opponentUserData) {
    User myUserData = UserProvider.of(context, listen: false).userData;

    String chatGropId = ChatGroupHelper.generateDefaultGroupId(myUserData.uid, opponentUserData.uid);
    ChatGroup chatRoodData = ChatGroup(id: chatGropId, participants: [
      myUserData.uid,
      opponentUserData.uid
    ], participantsData: [
      _generateChatUserFor(myUserData),
      _generateChatUserFor(opponentUserData),
    ], payload: {
      "sample": "payload",
    });

    ChatPage.push(context, chatRoodData);
  }

  ChatUser _generateChatUserFor(User user) {
    return ChatUser(
      uid: user.uid,
      nickname: user.username,
      avatarUrl: user.avatarUrl,
      payload: {
        "email": user.email,
        "createdAt": user.createdAt,
        "profile": user.profile,
      },
    );
  }
}
