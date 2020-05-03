import '../../firebase_chat_messenger.dart';

class FirebaseService {
  /// Private constructor
  FirebaseService._();

  /// Provides an instance of this class
  static final FirebaseService api = FirebaseService._();

  final _chatGroupRef = Firestore.instance.collection('chatGroups');

  Future<void> createChatGroup(String groupId, ChatGroup chatGroupData) async {
    print('>>> Creating group of $groupId');
    final paticipatnsData = chatGroupData.participantsData.map((data) => data.toJson()).toList();
    await _chatGroupRef.document(groupId).setData({
      "participants": chatGroupData.participants,
      "participantsData": paticipatnsData,
      "payload": chatGroupData.payload == null ? {} : chatGroupData.payload,
    });
  }

  Stream<QuerySnapshot> getChatGroupStream(String userId) {
    return _chatGroupRef.where("participants", arrayContains: userId).snapshots();
  }

  Stream<QuerySnapshot> getChatMessageStream(String groupId, Timestamp endAt) {
    Query query = _chatGroupRef.document(groupId).collection('chatMessages').orderBy("sendAt", descending: true);
    if (endAt != null) {
      query = query.endAt([endAt]);
    }
    return query.snapshots();
  }

  Future<List<ChatMessage>> fetchRecentReadMessage(String groupId) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    print('>>> Fetch recent read message of group $groupId');
    return _chatGroupRef
        .document(groupId)
        .collection('chatMessages')
        .where("readParticipants", whereIn: [user.uid])
        .orderBy("sendAt", descending: true)
        .limit(1)
        .getDocuments()
        .then((snap) => snap.documents.map((doc) => ChatMessage.fromFirebase(doc)).toList());
  }

  Future<List<ChatMessage>> fetchRecentMessages(String groupId) async {
    print('>>> Fetch recent message of group $groupId');
    return _chatGroupRef
        .document(groupId)
        .collection('chatMessages')
        .orderBy("sendAt", descending: true)
        //.limit(30)
        .getDocuments()
        .then((snap) => snap.documents.map((doc) => ChatMessage.fromFirebase(doc)).toList());
  }

  Future<List<ChatMessage>> fetchUnreceivedMessages(String groupId, Timestamp latestMessageSentAt) async {
    print('>>> Fetch chat after $latestMessageSentAt');
    Query query = _chatGroupRef.document(groupId).collection('chatMessages').orderBy("sendAt", descending: true);
    //.limit(30)

    if (latestMessageSentAt != null) {
      query = query.endBefore([latestMessageSentAt]);
    }
    return query.getDocuments().then((snap) => snap.documents.map((doc) => ChatMessage.fromFirebase(doc)).toList());
  }
}
