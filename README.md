# Chat Messenger using Firestore (Alpha)

**This is closed alpha version, please use it at your own risk**

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
