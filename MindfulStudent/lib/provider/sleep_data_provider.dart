import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/sleep.dart';
import 'package:mindfulstudent/screens/home/sleep_tracking_screen.dart';

class SleepDataProvider with ChangeNotifier {
  SleepData? _sleepData;

  SleepData? get sleepData => _sleepData;

  Future<void> setData(SleepData? newData) async {
    _sleepData = newData;
    notifyListeners();

    final bedtimeRange = _sleepData?.optimalBedtime;
    if (bedtimeRange == null) return;

    log("Scheduling sleep notification");
    try {
      await AwesomeNotifications().setChannel(
        NotificationChannel(
          channelKey: "sleep-reminder",
          channelName: "Sleep reminders",
          channelDescription:
              "Automated reminders for a consistent sleep schedule",
        ),
      );
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 0,
          channelKey: "sleep-reminder",
          title: "Reminder to sleep",
          body:
              "Go to bed between ${fmtTimeOfDay(bedtimeRange.$1)} - ${fmtTimeOfDay(bedtimeRange.$2)} "
              "for a consistent sleep schedule.",
          notificationLayout: NotificationLayout.BigText,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar(
          hour: bedtimeRange.$1.hour,
          minute: bedtimeRange.$1.minute,
          allowWhileIdle: true,
          repeats: true,
        ),
      );
    } catch (e) {
      log(e.toString());
    }
    log("Sleep notification scheduled!");
  }

  Future<void> updateData() async {
    final sleepData = await SleepTracker.getData();
    await setData(sleepData);
  }
}
