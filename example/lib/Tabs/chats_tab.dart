import 'package:flutter/material.dart';

import 'package:firebase_chat_messenger/firebase_chat_messenger.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_firebase_chat_messenger/Pages/chat_page.dart';
import 'package:flutter_firebase_chat_messenger/Providers/user_provider.dart';

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

    UserProvider userProvider = UserProvider.of(context, listen: false);
    String myUserId = userProvider.userData.uid;
    TextStyle defaultTextStyle = Theme.of(context).textTheme.bodyText2;

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
              ChatUser opponentUser = chatGroups[index].getOpponentData(myUserId);
              bool photoExist = opponentUser.avatarUrl != null && opponentUser.avatarUrl.length > 0;

              return ChatMessages(
                groupId: chatGroups[index].id,
                builder: (context, messages, child) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.black,
                      child: CircleAvatar(
                        radius: 27,
                        backgroundColor: photoExist ? Colors.white : Colors.grey[400],
                        backgroundImage: photoExist ? CachedNetworkImageProvider(opponentUser.avatarUrl) : null,
                        child: photoExist ? Container() : Icon(Icons.person, size: 30, color: Colors.white),
                      ),
                    ),
                    title: Row(
                      children: <Widget>[
                        Text(opponentUser.nickname),
                        Expanded(child: SizedBox()),
                        Text("${ChatEngine.instance.getNumberOfUnreadMessages(chatGroups[index].id, myUserId)}", style: defaultTextStyle.copyWith(color: Colors.red)),
                      ],
                    ),
                    subtitle: Text(messages != null && messages.length > 0 ? messages.last.message : ""),
                    trailing: Icon(Icons.navigate_next),
                    onTap: () => ChatPage.push(context, chatGroups[index]),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
