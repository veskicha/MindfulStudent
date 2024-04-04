import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mindfulstudent/main.dart';

class Firebase {
  static Future<void> init() async {
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      await Firebase._updateToken(token: fcmToken);
    });

    FirebaseMessaging.onMessage.listen((payload) {
      final notification = payload.notification;
      log("Message received: ${notification?.title}");
    });

    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance.getAPNSToken();

    // Update token on init
    await Firebase._updateToken();
  }

  static Future<void> _updateToken({String? token}) async {
    log("Updating FCM token");

    token ??= await FirebaseMessaging.instance.getToken();
    if (token == null) {
      log("Could not update FCM token: no token yet!");
      return;
    }

    final uid = profileProvider.userProfile?.id;
    if (uid == null) {
      log("Could not update FCM token: supabase user not logged in!");
      return;
    }

    await supabase.from("profiles").update({"fcm_token": token}).eq("id", uid);

    log("FCM token updated");
  }
}
