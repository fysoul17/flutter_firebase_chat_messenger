import 'package:firebase_chat_messenger/src/Models/chat_group.dart';
import 'package:flutter/material.dart';

class ChatGroupProvider with ChangeNotifier {
  List<ChatGroup> _chatGroups;
  List<ChatGroup> get chatGroups => _chatGroups == null ? null : List.unmodifiable(_chatGroups);
  set chatGroups(List<ChatGroup> newGroups) {
    _chatGroups = newGroups;
    notifyListeners();
  }

  bool groupExist(String groupId) {
    print('>>> Check if the group exist');
    bool exist = false;
    if (_chatGroups != null && _chatGroups.length > 0) {
      exist = _chatGroups.firstWhere((group) => group.id == groupId, orElse: () => null) != null;
    }
    return exist;
  }
}
