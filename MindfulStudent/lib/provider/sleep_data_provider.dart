import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/sleep.dart';

class SleepDataProvider with ChangeNotifier {
  SleepData? _sleepData;

  SleepData? get sleepData => _sleepData;

  void setData(SleepData? newData) {
    _sleepData = newData;
    notifyListeners();
  }

  Future<void> updateData() async {
    final sleepData = await SleepTracker.getData();
    setData(sleepData);
  }
}
