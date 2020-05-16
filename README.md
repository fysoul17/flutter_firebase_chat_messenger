# Chat Messenger using Firestore for Flutter (Alpha)

**This is closed alpha version, please use it at your own risk**

## Support
Your support is always welcome appreciated. It will boost me up to make better packages.

<a href="https://www.buymeacoffee.com/Oj17EcZ" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

## Getting Started

To use this plugin:

1. Add `cloud_firestore` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

### Android

1. Using the [Firebase Console](http://console.firebase.google.com/), add an Android app to your project.
2. Follow the assistant, and download the generated `google-services.json` file and place it inside `android/app`.
3. Modify the `android/build.gradle` file and the `android/app/build.gradle` file to add the Google services plugin as described by the Firebase assistant. Ensure that your `android/build.gradle` file contains the
`maven.google.com` as [described here](https://firebase.google.com/docs/android/setup#add_the_sdk).

### iOS

1. Using the [Firebase Console](http://console.firebase.google.com/), add an iOS app to your project.
2. Follow the assistant, download the generated `GoogleService-Info.plist` file. Do **NOT** follow the steps named _"Add Firebase SDK"_ and _"Add initialization code"_ in the Firebase assistant.
3. Open `ios/Runner.xcworkspace` with Xcode, and **within Xcode** place the `GoogleService-Info.plist` file inside `ios/Runner`.

## Usage

There are three main Module/Widgets we provide.
1. ChatEngine - The core module of the package. It provides features like sending chat, clearning cache, removing db and more. 
                This must be initialized at the beginning of the app start.
2. ChatGroupList - This widget provides chat groups that is created for the user.
3. ChatMessages - This widget provides chat messages for each chat groups.

### Chat Engine

Call ```ChatEngine.instance.initialize();``` after the firebase is authenticated. 
This initializes local database and start listening for chat groups' updates.

Set 'allowReadReceipts' to **false** if you want to avoid users to send 'message delivered flag' to opponents.
Then, every user will not be able to get notify of whether the each user has read other's messages or not.
This will reduce the read counts of messages on Firestore to half (4 -> 2). 

Defaults to true, and recommended to use as default for the most of case. Consider using it for reducing read counts only.
  
### Chat Group List

Provides chat group list data.

Sample code
```dart 
ChatGroupList(
  builder: (context, chatGroups, child) {
    if (chatGroups == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ListView.builder(
        itemCount: chatGroups.length,
        itemBuilder: (context, index) {
          ChatUser opponentUser = chatGroups[index].getOpponentData(myUserId);
          bool photoExist = opponentUser.avatarUrl != null && opponentUser.avatarUrl.length > 0;
          
          // Some other codes
          // return ChatMessages(...);
        },
      );
    }
  },
);
```

### Chat Messages

Provides chat messages of selected chat group.

Sample code
```dart
ChatMessages(
  groupId: chatGroupId,
  builder: (context, messages, child) {
    if (messages == null || messages.length < 1) {
      return Container();
    } else {
      List<ChatMessage> chats = messages.reversed.toList();
      
      // Some other codes
      // return ListView(...);
    }
  },
);
```
