import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  ChatMessage({
    this.uid,
    this.groupId,
    this.senderId,
    this.messageType,
    this.message,
    this.sendAt,
    this.readParticipants,
    this.unreadParticipants,
    this.payload,
    this.scheduledToRemove,
  });

  final String uid;
  final String groupId;
  final String senderId;
  final String messageType;
  final String message;
  final Timestamp sendAt;
  final List<String> readParticipants; // Used for displying recount more easily.
  final List<String>
      unreadParticipants; // Used for tracking most recent unread message. This cannot be used for counter as someone could leave the group and the userId will be there forever.
  final Map<dynamic, dynamic> payload;
  final bool scheduledToRemove;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "uid": uid,
      "groupId": groupId,
      "senderId": senderId,
      "messageType": messageType,
      "message": message,
      "sendAt": sendAt == null ? null : sendAt.millisecondsSinceEpoch,
      "readParticipants": json.encode(readParticipants),
      "unreadParticipants": json.encode(unreadParticipants),
      "payload": json.encode(payload),
      "scheduledToRemove": scheduledToRemove == true ? 1 : 0,
    };
    return map;
  }

  factory ChatMessage.fromFirebase(DocumentSnapshot doc) {
    return ChatMessage(
      uid: doc.documentID,
      groupId: doc.data['groupId'],
      senderId: doc.data['senderId'],
      messageType: doc.data['messageType'],
      message: doc.data['message'],
      sendAt: doc.data['sendAt'],
      readParticipants: List.from(doc.data['readParticipants']),
      unreadParticipants: List.from(doc.data['unreadParticipants']),
      payload: doc.data['payload'],
      scheduledToRemove: doc.data['scheduledToRemove'],
    );
  }

  // Load from sqlite
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      uid: map['uid'] == null ? null : map['uid'],
      groupId: map['groupId'],
      senderId: map['senderId'],
      messageType: map['messageType'],
      message: map['message'],
      sendAt: map['sendAt'] == null || map['sendAt'] is FieldValue ? null : Timestamp.fromMillisecondsSinceEpoch(map['sendAt']),
      readParticipants: map['readParticipants'] is String ? List.from(json.decode(map['readParticipants'])) : map['readParticipants'],
      unreadParticipants: map['unreadParticipants'] is String ? List.from(json.decode(map['unreadParticipants'])) : map['unreadParticipants'],
      payload: map['payload'] is String ? json.decode(map['payload']) : map['payload'],
      scheduledToRemove: map['scheduledToRemove'] == 1,
    );
  }

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.writeln("Chat uid: $uid");
    sb.writeln("       GroupId: $groupId");
    sb.writeln("       SenderId: $senderId");
    sb.writeln("       MessageType: $messageType");
    sb.writeln("       Message: $message");
    sb.writeln("       SendAt: $sendAt");
    sb.writeln("       ReadParticipants");
    for (int index = 0; index < readParticipants.length; index++) {
      sb.writeln("          Id: ${readParticipants[index]}");
    }
    sb.writeln("       UnreadParticipants");
    for (int index = 0; index < unreadParticipants.length; index++) {
      sb.writeln("          Id: ${unreadParticipants[index]}");
    }
    sb.writeln("       Payload: $payload");
    sb.writeln("       ScheduledToRemove: $scheduledToRemove");
    return sb.toString();
  }
}
