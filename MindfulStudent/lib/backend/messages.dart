import 'dart:developer';

import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/main.dart';

class Connection {
  final Profile from;
  final Profile to;
  bool confirmed;

  Connection(this.from, this.to, this.confirmed);

  Future<void> accept() async {
    final Profile? me = profileProvider.userProfile;
    if (me == null) throw Exception("Not logged in yet!");

    if (me.id != to.id) {
      throw Exception("Cannot accept outgoing connection request");
    }

    // Already done I guess?
    if (confirmed) return;

    await supabase
        .from("connections")
        .update({"isMutual": true})
        .eq("from", from.id)
        .eq("to", to.id);

    confirmed = true;
    return;
  }

  Future<void> request(Profile user) async {
    final Profile? me = profileProvider.userProfile;
    if (me == null) throw Exception("Not logged in yet!");

    await supabase.from("connections").insert({"from": me.id, "to": user.id});
  }

  static Future<List<Connection>> fetchAll() async {
    log("Fetching all user connections");
    final res = await supabase.from("connections").select();

    final List<Connection> connections = [];
    for (final connData in res) {
      final from = await Profile.get(connData["source"]);
      final to = await Profile.get(connData["target"]);

      if (from == null || to == null) continue;

      connections.add(Connection(from, to, connData["isMutual"]));
    }
    return connections;
  }
}

class Message {
  final String id;
  final Profile? author;
  final Profile? recipient;
  final DateTime sentAt;
  final String content;

  const Message(
      this.id, this.author, this.recipient, this.sentAt, this.content);

  static Future<Message> fromRowData(Map<String, dynamic> row) async {
    final String id = row["id"];
    final Profile? from = await Profile.get(row["from"]);
    final Profile? to = await Profile.get(row["to"]);
    final DateTime sentAt =
        DateTime.fromMillisecondsSinceEpoch(row["createdAt"]);
    final String content = row["text"];

    return Message(id, from, to, sentAt, content);
  }
}

class Chat {
  final Profile me;
  final Profile other;
  final Map<String, Message> messages = {};

  Chat(this.me, this.other);

  void addMessage(Message message) {
    messages[message.id] = message;
  }

  Future<Message?> sendMessage(String content) async {
    final res = await supabase
        .from("messages")
        .insert({"from": me.id, "to": other.id, "text": content}).select();

    if (res.isEmpty) return null;

    final msg = await Message.fromRowData(res[0]);
    addMessage(msg);
    return msg;
  }
}
