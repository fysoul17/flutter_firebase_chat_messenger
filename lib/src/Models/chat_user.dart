class ChatUser {
  ChatUser({
    this.uid,
    this.avatarUrl,
    this.nickname,
    this.payload,
  });

  final String uid;
  final String avatarUrl;
  final String nickname;
  final Map<String, dynamic> payload;

  factory ChatUser.fromMap(Map<String, dynamic> map) {
    return ChatUser(
      uid: map['uid'],
      avatarUrl: map['avatarUrl'],
      nickname: map['nickname'],
      payload: Map.from(map['payload']),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'avatarUrl': avatarUrl,
        'nickname': nickname,
        'payload': payload == null ? {} : payload,
      };
}
