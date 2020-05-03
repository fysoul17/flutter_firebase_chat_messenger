import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:firebase_chat_messenger/firebase_chat_messenger.dart';

import 'package:flutter_firebase_chat_messenger/Tabs/chats_tab.dart';
import 'package:flutter_firebase_chat_messenger/Tabs/profile_tab.dart';
import 'package:flutter_firebase_chat_messenger/Tabs/users_tab.dart';
import 'package:flutter_firebase_chat_messenger/Model/user.dart';
import 'package:flutter_firebase_chat_messenger/Providers/user_provider.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  final List<Widget> _pages = [UsersTab(), ChatsTab(), ProfilePage()];
  final List<BottomNavigationBarItem> _tabItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.phone),
      title: Text('Users'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat),
      title: Text('Chats'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      title: Text('Profile'),
    ),
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    print("[[[[ Init ]]]] Landing Page");
    UserProvider userProvider = UserProvider.of(context, listen: false);
    if (userProvider.userData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        userProvider.userData = User.fromFirebase(await Firestore.instance.collection("users").document(user.uid).get());
      });
    }

    ChatEngine.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    print("[[[[ Build ]]]] Landing Page");

    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: _buildTabBar(),
        body: Consumer<UserProvider>(
          builder: (BuildContext context, UserProvider provider, Widget child) {
            if (provider.userData == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return _buildTabPages();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return BottomNavigationBar(
      onTap: (index) {
        _pageController.jumpToPage(index);
      },
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      items: _tabItems,
    );
  }

  Widget _buildTabPages() {
    return PageView.builder(
      controller: _pageController,
      itemCount: _pages.length,
      itemBuilder: (context, index) {
        return _pages[index];
      },
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}
