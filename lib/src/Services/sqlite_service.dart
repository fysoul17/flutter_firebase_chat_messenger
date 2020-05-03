import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../firebase_chat_messenger.dart';

class SQLiteService {
  /// Private constructor
  SQLiteService._();

  /// Provides an instance of this class
  static final SQLiteService instance = SQLiteService._();

  final _chatMessageTable = "Messages";
  Database _localDB;

  /// SQLite Init
  Future<void> initialize() async {
    print('>>> Initializing Chat DB');

    // Debug
    //await removeDB();

    var databasePath = await getDatabasesPath();
    String path = join(databasePath, 'chat.db');

    _localDB = await openDatabase(path, version: 1, onCreate: (Database db, int verison) async {
      await db.execute(
          'CREATE TABLE $_chatMessageTable (id INTEGER PRIMARYKEY, uid Text, groupId TEXT, senderId TEXT, messageType TEXT, message TEXT, sendAt int, readParticipants TEXT, unreadParticipants TEXT, payload TEXT, scheduledToRemove int)');
      print('>>> Chat message db created');
    });

    print('>>> Initialized Chat DB');

    debugTable();
  }

  Future<void> clearDB() async {
    _localDB.rawDelete('DELETE FROM $_chatMessageTable');
  }

  Future<void> removeDB() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, 'chat.db');

    await deleteDatabase(path);
  }

  void debugTable() async {
    List<Map> map = await _localDB.rawQuery('SELECT * FROM Messages');

    List<ChatMessage> chats = map.map((m) => ChatMessage.fromMap(m)).toList();
    print("--------------- Table ---------------------");
    chats.forEach((c) => print(c.toString()));
    print("-------------------------------------------");
  }

  /// SQLite CRUD
  Future<ChatMessage> insertMessage(ChatMessage message) async {
    print('>>> Inserting Chat Message [${message.message}]');
    await _localDB.transaction((txn) async {
      await txn.insert(_chatMessageTable, message.toMap());
      print("[SQLite] Inserted to local DB. uid: ${message.uid}");
      print("-------- Message --------------");
      print(message.toString());
      print("-------------------------------");
    });

    //addChatMessage(message);
    return message;
  }

  Future<void> updateMessage(ChatMessage message) async {
    print('>>> Updating local message');
    await _localDB.transaction((txn) async {
      await txn.update(_chatMessageTable, message.toMap(), where: "uid = ?", whereArgs: [message.uid]);
    });

    //updateChatMessage(message);
  }

  Future<ChatMessage> readMessage(String uid) async {
    print('>>> Reading a single local message of $uid');
    List<Map> maps = await _localDB.query(_chatMessageTable,
        columns: ["uid", "groupId", "senderId", "messageType", "message", "sendAt", "payload", "readParticipants", "unreadParticipants", "scheduledToRemove"],
        where: "uid = ?",
        whereArgs: [uid],
        orderBy: "sendAt");
    if (maps.length > 0) {
      print("[SQLite] Read ${maps.length} messages");
      return ChatMessage.fromMap(maps.first);
    } else {
      print("[SQLite] No messages");
      return null;
    }
  }

  Future<List<ChatMessage>> readAllMessages(String groupId) async {
    print('>>> Reading all local messages of $groupId');
    List<ChatMessage> _localMessages = List<ChatMessage>();

    List<Map> chatsOnServer = await _localDB.query(_chatMessageTable,
        columns: ["uid", "groupId", "senderId", "messageType", "message", "sendAt", "payload", "readParticipants", "unreadParticipants", "scheduledToRemove"],
        where: "groupId = ? AND sendAt IS NOT NULL",
        whereArgs: [groupId],
        orderBy: "sendAt",
        limit: 30);

    _localMessages.addAll(chatsOnServer.map((m) => ChatMessage.fromMap(m)).toList());

    print("----------- Local Messages (sendAt IS NOT NULL) -----------------");
    _localMessages.forEach((m) => print(m.toString()));

    List<Map> _chatsNotSentToServer = await _localDB.query(_chatMessageTable,
        columns: ["uid", "groupId", "senderId", "messageType", "message", "sendAt", "payload", "readParticipants", "unreadParticipants", "scheduledToRemove"],
        where: "groupId = ? AND sendAt IS NULL",
        whereArgs: [groupId]);

    print("----------- Local Messages (sendAt IS NULL) -----------------");

    _chatsNotSentToServer.map((m) => ChatMessage.fromMap(m)).toList().forEach((m) => print(m.toString()));

    _localMessages.addAll(_chatsNotSentToServer.map((m) => ChatMessage.fromMap(m)).toList());

    return _localMessages;
  }

  Future<void> deleteMessage(String groupId, String uid) async {
    print('>>> Removing Chat Message of $uid');
    await _localDB.transaction((txn) async {
      await txn.delete(_chatMessageTable, where: "uid = ?", whereArgs: [uid]);
    });

    //removeChatMessage(groupId, uid);
  }

  void dispose() {
    _localDB.close();
  }
}
