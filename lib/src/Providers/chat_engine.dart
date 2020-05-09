import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat_messenger/firebase_chat_messenger.dart';

import 'package:firebase_chat_messenger/src/Models/chat_message.dart';
import 'package:firebase_chat_messenger/src/Models/chat_group.dart';
import 'package:firebase_chat_messenger/src/Providers/chat_message_provider.dart';
import 'package:firebase_chat_messenger/src/Providers/chat_group_provider.dart';
import 'package:firebase_chat_messenger/src/Services/firebase_service.dart';
import 'package:firebase_chat_messenger/src/Services/sqlite_service.dart';

class ChatEngine {
  /// Private constructor
  ChatEngine._();

  /// Provides an instance of this class
  static final ChatEngine instance = ChatEngine._();

  final groupRef = Firestore.instance.collection('chatGroups');

  ChatGroupProvider _chatGroupProvider = ChatGroupProvider();
  ChatGroupProvider get chatGroupProvider => _chatGroupProvider;

  List<ChatMessageProvider> _chatMessageProviders = List<ChatMessageProvider>();
  ChatMessageProvider getChatMessageProviderOf(String groupId) {
    ChatMessageProvider provider = _chatMessageProviders.firstWhere((m) => m.groupId == groupId, orElse: () => null);
    provider ??= ChatMessageProvider(groupId: groupId);

    if (_chatMessageProviders.contains(provider) == false) {
      _chatMessageProviders.add(provider);
    }

    return provider;
  }

  Future<void> initialize() async {
    print(">>> Initializing Chat Engine ...");
    try {
      // SQLite Initialize.
      await SQLiteService.instance.initialize();

      // Fetch chat groups and listen (sanpshot).
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      FirebaseService.api.getChatGroupStream(user.uid).listen((snap) => _processIncommingChatGroupDataFromServer(snap));
    } catch (e) {
      print(e.toString());
    }
    print(">>> Chat Engine Initialized !");
  }

  Future<void> _processIncommingChatGroupDataFromServer(QuerySnapshot snapshot) async {
    print("<<<<<<<<<< Chat group data incomming <<<<<<<<<<<<<<");

    List<ChatGroup> groupsOnServer = List<ChatGroup>();

    // Iterate through chat group data and convert to ChatGroup.
    for (int index = 0; index < snapshot.documents.length; index++) {
      ChatGroup _chatGroupDataFromServer = ChatGroup.fromFirebase(snapshot.documents[index]);
      print(_chatGroupDataFromServer.toString());

      groupsOnServer.add(_chatGroupDataFromServer);

      // Group does not exist. It means either:
      // a) App just initialized.
      // b) New group just created.
      String groupId = _chatGroupDataFromServer.id;

      if (_chatGroupProvider.groupExist(groupId) == false) {
        print("<<<< Group $groupId exist. Start loading previous messages...");
        ChatMessageProvider provider = getChatMessageProviderOf(groupId);

        // Load only if there is no previous messages.
        if (provider.messages == null || provider.messages.length < 1) {
          await _loadPreviousMessagesOf(provider);
        }

        if (provider.chatListener == null) {
          print('>>> Listening new messages of group [$groupId]');
          _listenChat(provider);
        }
      }
    }

    // Update group data from server.
    _chatGroupProvider.chatGroups = groupsOnServer;
  }

  Future<void> _loadPreviousMessagesOf(ChatMessageProvider provider) async {
    print(">>> Loading previous messages of ${provider.groupId}");

    // Clear messages on memory.
    provider.clearChatMessages();

    // Temporary list for message history.
    List<ChatMessage> chats = List<ChatMessage>();

    // Fetch all local messages.
    chats.addAll(await SQLiteService.instance.readAllMessages(provider.groupId));

    // Update to provider first. (We need this here since we will check if the server message is in local with messages in provider.)
    provider.addChatMessages(chats);

    // We will fetch other data from server.
    // 1) Fetch the last successfully sent message from local db first.
    ChatMessage lastMessage = chats.lastWhere((c) => c.sendAt != null, orElse: () => null);

    print("----------- Last Message (local DB) -----------------");
    print(lastMessage.toString());

    // 2) If there was no previous message in local db, it is either
    //    a) new message
    //    b) cache is gone.
    if (lastMessage == null) {
      // 3) So try to fetch previous data to check if it is the case that the cache is gone.
      List<ChatMessage> chatsFromServer = await FirebaseService.api.fetchRecentReadMessage(provider.groupId);
      if (chatsFromServer.length > 0) {
        lastMessage = chatsFromServer[0];
      }
    }

    print("----------- Last Message (Server) -----------------");
    print(lastMessage.toString());

    List<ChatMessage> chatsFromServer;
    // 4) If lastMessage is still null, it means this is a new chat to this user, fetch everything we got previously
    //    (there may be some messages sent from other participants before this user notified this group)
    //    TODO: This will fetch whole bunch of messages from scratch. We need to limit the load and lazy load other messages when scrolling down.
    //          When implementing this, we need to think about unread chat count since unloaded messages will be omitted from the count.
    if (lastMessage == null) {
      chatsFromServer = await FirebaseService.api.fetchRecentMessages(provider.groupId);
    }
    // 5) Otherwise, (last message exist) this chat is ongoing, so fetch from unreceived messages.
    //    TODO: This will also fetch all unreceivedMessages, and need to be limited for performance reason. Need a solution for unread counter as well.
    else {
      chatsFromServer = await FirebaseService.api.fetchUnreceivedMessages(provider.groupId, lastMessage.sendAt);
    }

    // *) If there is a message fetched from server, store into local DB.
    if (chatsFromServer.length > 0) {
      print("----------- Updating chats from server -----------");
      List<Future> updates = List<Future>();

      chatsFromServer.reversed.forEach((c) => updates.add(updateServerMessageToLocalDB(provider, c)));

      await Future.wait(updates);

      print("----------- Updates done (fetched: ${chatsFromServer.length}) -----------------");

      // Then, start listening further incomming chats.
      _listenChat(provider, fromTimestamp: lastMessage?.sendAt);
    } else {
      // *) If there is no messages from server, do nothing untill the user starts sending first message / or receive message.
      //listenChat(provider);
    }
  }

  Future<void> updateServerMessageToLocalDB(ChatMessageProvider messageProvider, ChatMessage messageFromServer) async {
    ChatMessage messageOnLocalDB = messageProvider.messages.firstWhere((message) => message.uid == messageFromServer.uid, orElse: () => null);

    if (messageOnLocalDB == null) {
      await SQLiteService.instance.insertMessage(messageFromServer);
      messageProvider.addChatMessage(messageFromServer, notifyNow: false);
    } else {
      await SQLiteService.instance.updateMessage(messageFromServer);
      messageProvider.updateChatMessage(messageFromServer, notifyNow: false);
    }
  }

  void _listenChat(ChatMessageProvider provider, {Timestamp fromTimestamp}) async {
    print(">>> Listen Chat Data From Timestamp : ");
    print(fromTimestamp);

    provider.chatListener = FirebaseService.api.getChatMessageStream(provider.groupId, fromTimestamp).listen((snap) => _processIncommingChatMessageFromServer(provider, snap));
  }

  void _processIncommingChatMessageFromServer(ChatMessageProvider provider, QuerySnapshot snapshot) async {
    print("<<< Chat data incomming");

    ChatMessage recentLocalMessage = provider.messages.lastWhere((m) => m.sendAt != null, orElse: () => null);
    for (int index = 0; index < snapshot.documents.length; index++) {
      ChatMessage messageFromServer = ChatMessage.fromFirebase(snapshot.documents[index]);
      if (messageFromServer.scheduledToRemove) {
        print("------- DATA FROM SERVER (This is schedule to be removed) ----------");
        print(messageFromServer.toString());
        print("-----------------------------------");

        await SQLiteService.instance.deleteMessage(provider.groupId, messageFromServer.uid);
      } else {
        if (recentLocalMessage != null && recentLocalMessage.uid == messageFromServer.uid && recentLocalMessage.readParticipants.length == messageFromServer.readParticipants.length) {
          print("------- Not gonna process below docs ----------");
          break;
        }

        await updateServerMessageToLocalDB(provider, messageFromServer);

        print("------- DATA FROM SERVER ----------");
        print(messageFromServer.toString());
        print("-----------------------------------");
      }
    }

    provider.notifyChanges();
  }

  Future<void> sendChat(String senderId, ChatGroup chatGroupData, String message, {String messageType = "text"}) async {
    print('>>> Sending Chat');

    // Start listening for incomming message including the one the user sent.
    // There are 2 scenarios that we shouldn't listen for chats from the beginning.
    // 1) If this is the new chat.
    // 2) If the user cleared local DB manially and has no previous chats that this user hasn't read yet.
    String groupId = chatGroupData.id;

    // Get/Create provider for message.
    // Need to add if not exist here. Otherwise, getting chat message provider will fail on Selector<>.
    ChatMessageProvider provider = getChatMessageProviderOf(groupId);

    ChatGroup chatGroup = _chatGroupProvider.chatGroups.firstWhere((m) => m.id == groupId, orElse: () => null);
    if (chatGroup == null) {
      await FirebaseService.api.createChatGroup(groupId, chatGroupData);
    }

    DocumentReference docRef = groupRef.document(groupId).collection("chatMessages").document();

    Map<String, dynamic> newChat = {
      "uid": docRef.documentID,
      "groupId": chatGroupData.id,
      "senderId": senderId,
      "messageType": messageType,
      "message": message,
      "sendAt": FieldValue.serverTimestamp(),
      "readParticipants": [senderId],
      "unreadParticipants": [chatGroupData.getOpponentData(senderId).uid],
      "payload": chatGroupData.payload == null ? {} : chatGroupData.payload,
      "scheduledToRemove": false,
    };

    ChatMessage newMessage = ChatMessage.fromMap(newChat);
    await SQLiteService.instance.insertMessage(newMessage);

    // Add to provider.
    provider.addChatMessage(newMessage);

    print(">>> Sending chat to server...");
    await docRef.setData(newChat);
    print(">>> Message send to server!");
  }

  Future<void> markMessagesAsRead(String groupId) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    print(">>> Flag chats as read for ${user.uid} in group $groupId");
    ChatMessageProvider provider = getChatMessageProviderOf(groupId);

    List<ChatMessage> unreadChats = provider.getUnreadMessages(user.uid);

    try {
      WriteBatch batchJob = Firestore.instance.batch();
      unreadChats.forEach((chat) {
        print(chat.toString());
        chat.readParticipants.add(user.uid);
        chat.unreadParticipants.remove(user.uid);
        batchJob.updateData(groupRef.document(groupId).collection('chatMessages').document(chat.uid), {"readParticipants": chat.readParticipants, "unreadParticipants": chat.unreadParticipants});
      });
      batchJob.commit();
    } catch (e) {
      print(e.toString());
    }
  }

  int getNumberOfUnreadMessages(String groupId, String userId) {
    ChatMessageProvider provider = getChatMessageProviderOf(groupId);
    if (provider == null) {
      return 0;
    } else {
      return provider.numberOfUnreadMessages(userId);
    }
  }

  int getAllNumberOfUnreadMessages(String userId) {
    List<ChatMessageProvider> providers = _chatMessageProviders;
    if (providers.length < 1) {
      return 0;
    } else {
      int counter = 0;
      providers.forEach((p) {
        counter += p.numberOfUnreadMessages(userId);
      });
      return counter;
    }
  }

  Future<void> clearCache() async {
    await SQLiteService.instance.clearDB();
    _chatMessageProviders.clear();
    _chatGroupProvider.chatGroups.clear();
  }

  Future<void> removeDB() async {
    await SQLiteService.instance.removeDB();
  }
}
