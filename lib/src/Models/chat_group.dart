import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat_messenger/src/Models/chat_user.dart';

class ChatGroup {
  ChatGroup({
    this.id,
    this.participants,
    this.participantsData,
    this.payload,
  });

  final String id;
  final List<String> participants;
  final List<ChatUser> participantsData;
  final Map<String, dynamic> payload;

  factory ChatGroup.fromFirebase(DocumentSnapshot doc) {
    return ChatGroup(
      id: doc.documentID,
      participants: List.from(doc.data['participants']),
      participantsData: List.from(doc.data['participantsData']).map((data) => ChatUser.fromMap(Map.from(data))).toList(),
      payload: doc.data['payload'] == null ? {} : Map.from(doc.data['payload']),
    );
  }

  ChatUser getMyData(String userId) {
    return participantsData.firstWhere((u) => u.uid == userId);
  }

  ChatUser getOpponentData(String myUserId) {
    return participantsData.firstWhere((u) => u.uid != myUserId);
  }

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.writeln("ChatGroup ID: $id (groupId)");
    for (int index = 0; index < participants.length; index++) {
      sb.writeln("       Participants[$index] uid: ${participants[index]}");
    }
    for (int index = 0; index < participantsData.length; index++) {
      sb.writeln("       ParticipantsData[$index] uid: ${participantsData[index].uid}");
      sb.writeln("       ParticipantsData[$index] nickname: ${participantsData[index].nickname}");
      sb.writeln("       ParticipantsData[$index] avatarUrl: ${participantsData[index].avatarUrl}");
    }

    sb.writeln("   Payloads -------");
    payload.forEach((key, value) => sb.writeln("       $key: $value"));

    return sb.toString();
  }
}
