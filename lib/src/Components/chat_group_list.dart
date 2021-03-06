import 'package:firebase_chat_messenger/firebase_chat_messenger.dart';
import 'package:firebase_chat_messenger/src/Providers/chat_group_provider.dart';
import 'package:firebase_chat_messenger/src/Providers/chat_message_provider.dart';
import 'package:flutter/material.dart';

import 'package:firebase_chat_messenger/src/Providers/chat_engine.dart';
import 'package:firebase_chat_messenger/src/Models/chat_group.dart';
import 'package:provider/provider.dart';

typedef ChatGroupListBuilder = Widget Function(BuildContext context, List<ChatGroup> chatGroups, Widget child);

class ChatGroupList extends StatelessWidget {
  const ChatGroupList({
    Key key,
    this.builder,
    this.child,
  }) : super(key: key);

  final Widget child;
  final ChatGroupListBuilder builder;

  @override
  Widget build(BuildContext context) {
    print("[[[[ Build ]]]] Package >> ChatGroupList");

    return ChangeNotifierProvider.value(
      value: ChatEngine.instance.chatGroupProvider,
      child: ChatGroupConsumer(
        child: child,
        builder: builder,
      ),
    );
  }
}

class ChatGroupConsumer extends StatelessWidget {
  const ChatGroupConsumer({
    Key key,
    this.builder,
    this.child,
  }) : super(key: key);
  final Widget child;
  final ChatGroupListBuilder builder;

  @override
  Widget build(BuildContext context) {
    print("[[[[ Build ]]]] Package >> ChatGroupConsumer");
    List<ChatGroup> cg = context.select<ChatGroupProvider, List<ChatGroup>>((provider) => provider.chatGroups);

    print("[[[[ Selector ]]]] Package >> ChatGroupConsumer");
    return builder(context, cg, child);
  }
}
