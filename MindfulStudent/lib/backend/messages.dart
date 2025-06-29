import 'dart:developer';

import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/main.dart';

class Connection {
  final String fromId;
  final String toId;
  bool confirmed;

  Connection(this.fromId, this.toId, this.confirmed);

  static Connection fromRowData(Map<String, dynamic> row) {
    final String fromId = row["source"];
    final String toId = row["target"];
    final bool isConfirmed = row["isMutual"] ?? false;

    return Connection(fromId, toId, isConfirmed);
  }

  Future<void> accept() async {
    final Profile? me = profileProvider.userProfile;
    if (me == null) throw Exception("Not logged in yet!");

    if (me.id != toId) {
      throw Exception("Cannot accept incoming connection request");
    }

    // Already done I guess?
    if (confirmed) return;

    await supabase
        .from("connections")
        .update({"isMutual": true})
        .eq("source", fromId)
        .eq("target", toId);

    confirmed = true;
    return;
  }

  Future<void> deny() async {
    final Profile? me = profileProvider.userProfile;
    if (me == null) throw Exception("Not logged in yet!");

    await supabase
        .from("connections")
        .delete()
        .eq("source", fromId)
        .eq("target", toId);

    confirmed = true;
    return;
  }

  static Future<void> request(Profile user) async {
    final Profile? me = profileProvider.userProfile;
    if (me == null) throw Exception("Not logged in yet!");

    await supabase.from("connections").insert({
      "source": me.id,
      "target": user.id,
      "isMutual": user.role == "HEALTH_EXPERT"
    });
  }

  static Future<List<Connection>> fetchAll() async {
    log("Fetching all user connections");
    final res = await supabase.from("connections").select();

    return res.map((row) => Connection.fromRowData(row)).toList();
  }
}

class Message {
  final String id;
  final String authorId;
  final String recipientId;
  final DateTime sentAt;
  final String content;

  final Map<String, Set<String>> reactions = {};

  Message(this.id, this.authorId, this.recipientId, this.sentAt, this.content);

  static Message fromRowData(Map<String, dynamic> row) {
    final String id = row["id"];
    final String from = row["from"];
    final String to = row["to"];
    final DateTime sentAt = DateTime.parse(row["created_at"]).toLocal();
    final String content = row["text"];

    return Message(id, from, to, sentAt, content);
  }

  bool get isSentByMe {
    final me = profileProvider.userProfile;
    if (me == null) return false;
    return authorId == me.id;
  }

  Future<void> delete() async {
    await supabase.from("messages").delete().eq("id", id);
  }

  Future<void> addReaction(String reaction) async {
    final Profile? me = profileProvider.userProfile;
    if (me == null) throw Exception("Not logged in yet!");

    await supabase
        .from("reactions")
        .insert({"messageId": id, "author": me.id, "reaction": reaction});
  }

  Future<void> removeReaction(String reaction) async {
    final Profile? me = profileProvider.userProfile;
    if (me == null) throw Exception("Not logged in yet!");

    await supabase
        .from("reactions")
        .delete()
        .eq("messageId", id)
        .eq("author", me.id)
        .eq("reaction", reaction);
  }

  Future<void> fetchReactions() async {
    late final List<Map<String, dynamic>> data;
    try {
      data = await supabase.from("reactions").select().eq("messageId", id);
    } catch (e) {
      log("Reaction fetch error: $e");
      return;
    }
    for (final row in data) {
      final String authorId = row["author"];
      final String reaction = row["reaction"];

      reactions.putIfAbsent(reaction, () => {});
      reactions[reaction]?.add(authorId);
    }
  }
}

class Chat {
  final String otherId;
  final Map<String, Message> _messages = {};

  Chat(this.otherId);

  Future<Profile?> getProfile() async {
    return await Profile.get(otherId);
  }

  List<Message> get messages {
    return _messages.values.toList()
      ..sort((Message a, Message b) => a.sentAt.compareTo(b.sentAt));
  }

  void addMessage(Message message) {
    _messages[message.id] = message;
  }

  void removeMessage(String messageId) {
    _messages.remove(messageId);
  }

  Future<Message?> sendMessage(String content) async {
    final me = profileProvider.userProfile;
    if (me == null) return null;

    final res = await supabase
        .from("messages")
        .insert({"from": me.id, "to": otherId, "text": content}).select();

    if (res.isEmpty) return null;

    final msg = Message.fromRowData(res[0]);
    addMessage(msg);
    return msg;
  }
}
