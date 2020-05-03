import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_chat_messenger/firebase_chat_messenger.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_firebase_chat_messenger/Components/chat_input_field.dart';
import 'package:flutter_firebase_chat_messenger/Components/chat_view.dart';
import 'package:flutter_firebase_chat_messenger/Providers/user_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    Key key,
    this.chatGroupData,
    this.screenWidth,
  }) : super(key: key);

  final ChatGroup chatGroupData;
  final double screenWidth;

  static push(BuildContext context, ChatGroup chatGroupData) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => ChatPage(
          chatGroupData: chatGroupData,
          screenWidth: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    print("[[[[ Build ]]]] Chat Page");

    UserProvider userProvider = UserProvider.of(context, listen: false);
    ChatUser opponentUserData = widget.chatGroupData.getOpponentData(userProvider.userData.uid);
    bool photoExist = opponentUserData.avatarUrl.length > 0;
    TextStyle defaultTextStyle = Theme.of(context).textTheme.body1;
    //Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 16,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: photoExist ? Colors.white : Colors.grey[400],
                backgroundImage: photoExist ? CachedNetworkImageProvider(opponentUserData.avatarUrl) : null,
                child: photoExist ? Container() : Icon(Icons.person, size: 30, color: Colors.white),
              ),
            ),
            SizedBox(width: 10),
            Text(opponentUserData.nickname, style: defaultTextStyle.copyWith(fontSize: 17, color: Colors.white)),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                _focusNode.unfocus();
              },
              child: ChatView(
                chatGroupData: widget.chatGroupData,
                mySenderId: userProvider.userData.uid,
                chatBubbleMaxWidth: widget.screenWidth * 0.7,
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[400],
          ),
          ChatInputField(
            chatGroupData: widget.chatGroupData,
            mySenderId: userProvider.userData.uid,
            focusNode: _focusNode,
          ),
        ],
      ),
    );
  }
}
