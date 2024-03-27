import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/backend/sleep.dart';
import 'package:mindfulstudent/main.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SleepTrackingLoginPage extends StatelessWidget {
  late final WebViewController controller;
  final WebViewCookieManager cookieManager = WebViewCookieManager();

  SleepTrackingLoginPage({super.key}) {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(onPageFinished: (String url) {
          if (url.startsWith(SleepTracker.callbackUrl)) onLoginComplete();
        }),
      )
      ..loadRequest(
        Uri.parse(SleepTracker.loginUrl),
        headers: {"Authorization": "Bearer ${Auth.jwt ?? ""}"},
      );
  }

  void onLoginComplete() {
    // Clear the user's session
    controller.clearCache();
    controller.clearLocalStorage();
    cookieManager.clearCookies();

    // Future, will complete in the background
    sleepDataProvider.updateData();

    // Remove screen and go back to where we came from
    navigatorKey.currentState?.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF497077),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Fitbit Login'),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
