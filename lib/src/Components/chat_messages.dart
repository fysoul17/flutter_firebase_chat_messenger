import 'package:flutter/widgets.dart';

import 'package:provider/provider.dart';

import 'package:firebase_chat_messenger/firebase_chat_messenger.dart';
import 'package:firebase_chat_messenger/src/Providers/chat_group_provider.dart';
import 'package:firebase_chat_messenger/src/Providers/chat_message_provider.dart';

typedef ChatMessageBuilder = Widget Function(BuildContext context, List<ChatMessage> snapshot, Widget child);

class ChatMessages extends StatelessWidget {
  const ChatMessages({
    Key key,
    @required this.groupId,
    @required this.builder,
    this.child,
  })  : assert(groupId != null),
        super(key: key);

  final Widget child;
  final ChatMessageBuilder builder;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    print("[[[[ Build ]]]] Package >> ChatMessages");

    ChatMessageProvider messageProvider = ChatEngine.instance.getChatMessageProviderOf(groupId);
    if (messageProvider == null) {
      return ChangeNotifierProvider.value(
        value: ChatEngine.instance.chatGroupProvider,
        child: ChatGroupMessageConsumer(
          child: child ?? Container(),
          builder: builder,
          groupId: groupId,
        ),
      );
    } else {
      ChatEngine.instance.markMessagesAsRead(groupId);

      return ChangeNotifierProvider.value(
        value: messageProvider,
        child: ChatMessageConsumer(
          child: child ?? Container(),
          builder: builder,
        ),
      );
    }
  }
}

class ChatGroupMessageConsumer extends StatelessWidget {
  const ChatGroupMessageConsumer({
    Key key,
    @required this.groupId,
    this.child,
    this.builder,
  }) : super(key: key);

  final String groupId;
  final Widget child;
  final ChatMessageBuilder builder;

  @override
  Widget build(BuildContext context) {
    print("[[[[ Build ]]]] Package >> ChatGroupMessageConsumer");
    List<ChatGroup> chatGroups = context.select<ChatGroupProvider, List<ChatGroup>>((provider) => provider.chatGroups);

    print("[[[[ Selector ]]]] Package >> ChatGroupMessageConsumer");

    if (chatGroups != null) {
      if (chatGroups.firstWhere((g) => g.id == groupId, orElse: () => null) == null) {
        return builder(context, List<ChatMessage>(), child);
      } else {
        return ChangeNotifierProvider.value(
          value: ChatEngine.instance.getChatMessageProviderOf(groupId),
          child: ChatMessageConsumer(builder: builder, child: child),
        );
      }
    } else {
      return builder(context, List<ChatMessage>(), child);
    }
  }
}

class ChatMessageConsumer extends StatelessWidget {
  const ChatMessageConsumer({
    Key key,
    this.child,
    this.builder,
  }) : super(key: key);

  final Widget child;
  final ChatMessageBuilder builder;

  @override
  Widget build(BuildContext context) {
    print("[[[[ Build ]]]] Package >> ChatMessageConsumer");

    List<ChatMessage> messages = context.select<ChatMessageProvider, List<ChatMessage>>((provider) => provider.messages);

    print("[[[[ Selector ]]]] Package >> ChatMessageConsumer");
    return builder(context, messages, child);
  }
}
