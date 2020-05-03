import 'package:flutter/widgets.dart';

import 'package:provider/provider.dart';

import 'package:flutter_firebase_chat_messenger/Model/user.dart';

class UserProvider with ChangeNotifier {
  static UserProvider of(BuildContext context, {bool listen = true}) => Provider.of<UserProvider>(context, listen: listen);

  User _userData;
  User get userData => _userData;
  set userData(User newData) {
    _userData = newData;
    notifyListeners();
  }
}
