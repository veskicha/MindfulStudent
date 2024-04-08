import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/messages.dart';
import 'package:mindfulstudent/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatProvider with ChangeNotifier {
  final List<Connection> _connections = [];
  final List<Chat> _chats = [];

  List<Chat> get chats => _chats;

  List<Connection> get connections => _connections;

  Future<void> init() async {
    for (final connection in await Connection.fetchAll()) {
      _addConnection(connection);
    }

    supabase
        .channel('public:messages')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              log('DB change received: ${payload.toString()}');

              switch (payload.eventType) {
                case PostgresChangeEvent.insert:
                case PostgresChangeEvent.update:
                  addMessage(Message.fromRowData(payload.newRecord));
                  break;
                case PostgresChangeEvent.delete:
                  removeMessage(payload.oldRecord["id"]);
                  break;
                case PostgresChangeEvent.all:
                  break;
              }
            })
        .subscribe();

    log("Listening for message updates");

    backFill().catchError((e) {
      log(e.toString());
    });
  }

  void _addConnection(Connection connection) {
    final me = profileProvider.userProfile;
    if (me == null) {
      log("Cannot add connection if not logged in");
      return;
    }

    try {
      final oldConn = _connections.firstWhere((conn) {
        return conn.fromId == connection.fromId && conn.toId == connection.toId;
      });
      oldConn.confirmed = connection.confirmed;
    } on StateError {
      _connections.add(connection);
    }

    final other =
        (me.id == connection.fromId) ? connection.toId : connection.fromId;
    getChatWith(other); // creates chat if not exists

    notifyListeners();
  }

  void _removeConnection(Connection connection) {
    try {
      final oldConn = _connections.firstWhere((conn) {
        return conn.fromId == connection.fromId && conn.toId == connection.toId;
      });
      _connections.remove(oldConn);
    } on StateError {
      return;
    }
  }

  Chat getChatWith(String userId) {
    try {
      return _chats.firstWhere((chat) => chat.otherId == userId);
    } on StateError {
      final chat = Chat(userId);
      _chats.add(chat);
      return chat;
    }
  }

  Chat? _getChatForMessage(Message msg) {
    final me = profileProvider.userProfile;
    if (me == null) {
      log("Cannot find message chat if not logged in");
      return null;
    }

    final other = (me.id == msg.authorId) ? msg.recipientId : msg.authorId;
    return getChatWith(other);
  }

  void addMessage(Message msg) {
    final chat = _getChatForMessage(msg);
    if (chat == null) return;

    log("Adding message: $msg");

    chat.addMessage(msg);
    notifyListeners();
  }

  void removeMessage(String msgId) {
    log("Removing message: $msgId");

    for (final chat in _chats) {
      chat.removeMessage(msgId);
    }
    notifyListeners();
  }

  Future<void> backFill({List<Chat>? chats}) {
    chats ??= _chats;

    return Future.wait(
      chats.map(
        (chat) => supabase
            .from("messages")
            .select()
            .or("from.eq.${chat.otherId},to.eq.${chat.otherId}")
            .limit(50)
            .then((data) =>
                data.forEach((row) => addMessage(Message.fromRowData(row)))),
      ),
    );
  }
}
