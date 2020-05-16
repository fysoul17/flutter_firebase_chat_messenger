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
