import 'package:firebase_chat_messenger/firebase_chat_messenger.dart';

class User {
  User({
    this.uid,
    this.username,
    this.email,
    this.avatarUrl,
    this.createdAt,
    this.profile,
  });
  final String uid;
  final String username;
  final String email;
  final String avatarUrl;
  final Timestamp createdAt;
  final String profile;

  factory User.fromFirebase(DocumentSnapshot doc) {
    return User(
      uid: doc.documentID,
      username: doc.data['username'],
      email: doc.data['username'],
      avatarUrl: doc.data['avatarUrl'],
      createdAt: doc.data['createdAt'],
      profile: doc.data['profile'],
    );
  }
}
