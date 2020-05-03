import 'package:uuid/uuid.dart';

class ChatGroupHelper {
  /// Generates group id based on two participants' ids.
  /// It will return identical group id for both participants always.
  static String generateDefaultGroupId(String myUid, String opponentUid) {
    int comparison = myUid.compareTo(opponentUid);
    if (comparison < 0) {
      return "${myUid}_$opponentUid";
    } else {
      return "${opponentUid}_$myUid";
    }
  }

  /// Generates group id for the case where participants' chat messages should be separated based on their topic, product, issue or so.
  /// For same two users, they can have multiple diffent groups.
  /// [identifier] can be any issues or topics they want to separate the chat for.
  static String generateUniqueChatGroupId(String chatOpenerUid, String identifier) {
    return "${chatOpenerUid}_$identifier";
  }

  // Generates group id for group chats.
  // IMPORTANT: version 0.0.1 does not support group chat yet.
  static String generateGroupChatGroupId() {
    return Uuid().v1();
  }
}
