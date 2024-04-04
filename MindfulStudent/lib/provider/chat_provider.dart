import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/messages.dart';

class ConnectionProvider with ChangeNotifier {
  List<Connection> _connections = [];

  List<Connection> get connections => _connections;

  Future<void> fetch() async {
    _connections = await Connection.fetchAll().catchError((err) {
      log("Error: $err");
      return [] as List<Connection>;
    });
    notifyListeners();
  }
}
