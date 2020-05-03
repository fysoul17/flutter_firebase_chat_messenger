import 'package:flutter/material.dart';

import 'package:firebase_chat_messenger/firebase_chat_messenger.dart';

import 'package:flutter_firebase_chat_messenger/Pages/chat_page.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({Key key}) : super(key: key);

  @override
  _ChatsTabState createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    print("[[[[ Build ]]]] Chats Tab");
    return ChatGroupList(
      builder: (context, chatGroups, child) {
        if (chatGroups == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListView.builder(
            itemCount: chatGroups.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: RaisedButton(
                  child: Text(chatGroups[index].id),
                  onPressed: () {
                    ChatPage.push(context, chatGroups[index]);
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
