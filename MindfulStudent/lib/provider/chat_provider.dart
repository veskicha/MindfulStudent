import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/backend/messages.dart';
import 'package:mindfulstudent/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatProvider with ChangeNotifier {
  final List<Connection> _connections = [];
  final List<Chat> _chats = [];

  List<Chat> get chats => _chats;

  List<Connection> get connections => _connections;

  Future<void> init() async {
    _connections.clear();
    _chats.clear();

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

    supabase
        .channel('public:connections')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'connections',
            callback: (payload) {
              log(payload.toString());

              switch (payload.eventType) {
                case PostgresChangeEvent.insert:
                case PostgresChangeEvent.update:
                  _addConnection(Connection.fromRowData(payload.newRecord));
                  break;
                case PostgresChangeEvent.delete:
                  _removeConnection(Connection.fromRowData(payload.oldRecord));
                  break;
                case PostgresChangeEvent.all:
                  break;
              }
            })
        .subscribe();

    supabase
        .channel('public:reactions')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'reactions',
            callback: (payload) {
              log(payload.toString());

              switch (payload.eventType) {
                case PostgresChangeEvent.insert:
                case PostgresChangeEvent.update:
                  _addReaction(
                    payload.newRecord["messageId"],
                    payload.newRecord["author"],
                    payload.newRecord["reaction"],
                  );
                  break;
                case PostgresChangeEvent.delete:
                  _removeReaction(
                    payload.oldRecord["messageId"],
                    payload.oldRecord["author"],
                    payload.oldRecord["reaction"],
                  );
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

    // Pre-cache profiles
    Profile.get(connection.fromId);
    Profile.get(connection.toId);

    if (connection.confirmed) {
      final other =
          (me.id == connection.fromId) ? connection.toId : connection.fromId;
      getChatWith(other); // creates chat if not exists
    }

    notifyListeners();
  }

  void _removeConnection(Connection connection) {
    try {
      final oldConn = _connections.firstWhere((conn) {
        return conn.fromId == connection.fromId && conn.toId == connection.toId;
      });
      _connections.remove(oldConn);

      final connChats = _chats.where((chat) =>
          chat.otherId == connection.fromId || chat.otherId == connection.toId);
      for (final chat in connChats) {
        _chats.remove(chat);
        notifyListeners();
      }
    } on StateError {
      // Just ignore
    }

    notifyListeners();
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

  void _addReaction(String messageId, String authorId, String reaction) {
    Message? msg;
    for (final chat in _chats) {
      try {
        msg = chat.messages.firstWhere((msg) => msg.id == messageId);
      } on StateError {
        // continue
      }
    }

    if (msg == null) return;

    msg.reactions.putIfAbsent(reaction, () => {});
    msg.reactions[reaction]?.add(authorId);

    notifyListeners();
  }

  void _removeReaction(String messageId, String authorId, String reaction) {
    Message? msg;
    for (final chat in _chats) {
      try {
        msg = chat.messages.firstWhere((msg) => msg.id == messageId);
      } on StateError {
        // continue
      }
    }

    if (msg == null) return;

    msg.reactions[reaction]?.remove(authorId);

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
            .then(
          (data) {
            for (final row in data) {
              final msg = Message.fromRowData(row);
              // TODO: this is incredibly wasteful, we do NOT want to make a new network request for each message.
              // Solution: adjust query to fetch reactions as well.
              msg.fetchReactions().then((_) {
                notifyListeners();
              });
              addMessage(msg);
            }
          },
        ),
      ),
    );
  }
}
