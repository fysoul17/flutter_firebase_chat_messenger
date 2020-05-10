import 'dart:async';

import 'package:firebase_chat_messenger/firebase_chat_messenger.dart';
import 'package:firebase_chat_messenger/src/Models/chat_message.dart';
import 'package:flutter/material.dart';

class ChatMessageProvider with ChangeNotifier {
  ChatMessageProvider({this.groupId});

  final String groupId;

  List<ChatMessage> _messages;
  List<ChatMessage> get messages => _messages == null ? null : List.unmodifiable(_messages);

  void clearChatMessages() {
    if (_messages != null) {
      _messages.clear();
    }
  }

  StreamSubscription<QuerySnapshot> chatListener;

  @override
  void dispose() {
    chatListener.cancel();
    chatListener = null;
    super.dispose();
  }

  void addChatMessage(ChatMessage newChat, {bool notifyNow = true}) {
    _messages ??= List<ChatMessage>();
    _messages.add(newChat);
    if (notifyNow) notifyListeners();
  }

  void addChatMessages(List<ChatMessage> newChats) {
    _messages ??= List<ChatMessage>();
    _messages.addAll(newChats);
    notifyListeners();
  }

  void updateChatMessage(ChatMessage newChat, {bool notifyNow = true}) {
    ChatMessage previousChat = _messages.firstWhere((m) => m.uid == newChat.uid, orElse: () => null);
    if (previousChat != null) {
      _messages[_messages.indexOf(previousChat)] = newChat;
    }

    if (notifyNow) notifyListeners();
  }

  void removeChatMessage(String uid) {
    _messages.removeWhere((m) => m.uid == uid);
    notifyListeners();
  }

  void notifyChanges() {
    notifyListeners();
  }

  List<ChatMessage> getUnreadMessages(String userId) {
    List<ChatMessage> unreadMessages;

    if (_messages == null) {
      unreadMessages = List<ChatMessage>();
    } else {
      unreadMessages = _messages.where((m) => m.readParticipants.contains(userId) == false).toList();
      unreadMessages ??= List<ChatMessage>();
      unreadMessages.sort((a, b) => a.sendAt.compareTo(b.sendAt));
    }
    return unreadMessages;
  }

  int numberOfUnreadMessages(String userId) {
    if (_messages.length > 0) {
      return _messages.where((m) => m.readParticipants.contains(userId) == false).length;
    } else
      return 0;
  }
}
