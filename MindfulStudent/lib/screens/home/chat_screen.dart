import 'dart:developer';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/backend/messages.dart';
import 'package:mindfulstudent/main.dart';
import 'package:mindfulstudent/provider/chat_provider.dart';
import 'package:mindfulstudent/util.dart';
import 'package:mindfulstudent/widgets/bottom_nav_bar.dart';
import 'package:mindfulstudent/widgets/profile_img.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF497077),
        foregroundColor: Colors.white,
        title: const Text("Chats"),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExpertsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ConnectionsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddFriendsPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return ListView(
            children: chatProvider.chats
                .map((chat) => ProfileCard(profileFut: chat.getProfile()))
                .toList(),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class ConnectionsPage extends StatelessWidget {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF497077),
        foregroundColor: Colors.white,
        title: const Text("Connection Requests"),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final me = profileProvider.userProfile?.id;

          final connections = chatProvider.connections;
          final incoming =
              connections.where((conn) => conn.toId == me && !conn.confirmed);
          final outgoing =
              connections.where((conn) => conn.fromId == me && !conn.confirmed);

          final List<Widget> page = [];
          if (incoming.isNotEmpty) {
            page.addAll([
              const Text("Incoming requests"),
              ...incoming.map(
                (conn) => ProfileCard(
                  profileFut: Profile.get(conn.fromId),
                ),
              )
            ]);
          }
          if (outgoing.isNotEmpty) {
            page.addAll([
              const Text("Outgoing requests"),
              ...outgoing.map(
                (conn) => ProfileCard(
                  profileFut: Profile.get(conn.toId),
                ),
              )
            ]);
          }

          if (page.isEmpty) {
            return const Text("No connection requests!");
          }

          return Column(children: page);
        },
      ),
    );
  }
}

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({super.key});

  @override
  State<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  final TextEditingController _controller = TextEditingController();
  CancelableOperation? _searchOp;

  List<Profile> results = [];

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onSearchModify);
  }

  @override
  void dispose() {
    super.dispose();

    _controller.removeListener(_onSearchModify);
    _controller.dispose();

    _searchOp?.cancel();
  }

  void _onSearchModify() {
    final text = _controller.text;

    if (text.isEmpty) {
      _searchOp?.cancel();
      setState(() {
        results = [];
      });

      return;
    }

    _searchOp?.cancel();
    _searchOp = CancelableOperation.fromFuture(Profile.find(text));
    _searchOp?.then((res) {
      final Set<String> bannedIds = {profileProvider.userProfile?.id ?? ""};
      for (final conn in chatProvider.connections) {
        bannedIds.addAll([conn.fromId, conn.toId]);
      }

      log(res.map((p) => p.name).toList().toString());

      setState(() {
        results =
            res.where((profile) => !bannedIds.contains(profile.id)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF497077),
        foregroundColor: Colors.white,
        title: const Text("Add Friends"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children:
                  results.map((res) => ProfileCard(profile: res)).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class ExpertsPage extends StatefulWidget {
  const ExpertsPage({super.key});

  @override
  State<ExpertsPage> createState() => _ExpertsPageState();
}

class _ExpertsPageState extends State<ExpertsPage> {
  List<Profile>? healthExperts;

  @override
  void initState() {
    super.initState();

    Profile.getHealthExperts().then((profiles) {
      setState(() {
        healthExperts = profiles;
      });
    }).catchError((e) {
      if (!context.mounted) return;

      showError(
        context,
        "Fetch error",
        description: e.toString(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    late final Widget body;
    if (healthExperts == null) {
      body = const Text("Loading...");
    } else {
      body = Column(
        children: healthExperts!
            .map((profile) => ProfileCard(profile: profile))
            .toList(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF497077),
        foregroundColor: Colors.white,
        title: const Text("Mental Health Experts"),
      ),
      body: body,
    );
  }
}

class ProfileCard extends StatefulWidget {
  final Profile? profile;
  final Future<Profile?>? profileFut;

  const ProfileCard({this.profile, this.profileFut, super.key});

  @override
  State<StatefulWidget> createState() => ProfileCardState();
}

class ProfileCardState extends State<ProfileCard> {
  Profile? profile;

  @override
  void initState() {
    super.initState();

    final fut = widget.profileFut;
    if (fut != null) {
      fut.then((p) {
        setState(() {
          profile = p;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileCopy = profile ?? widget.profile;

    final profileName = profileCopy?.name ?? "Unknown";
    final lastMsg = (profileCopy == null)
        ? null
        : chatProvider.getChatWith(profileCopy.id).messages.lastOrNull;

    String lastMsgSenderStr = "";
    if (lastMsg != null) {
      lastMsgSenderStr =
          "${lastMsg.isSentByMe ? "You" : profileName}: ${lastMsg.content}";
    }

    return ListTile(
      leading: ProfilePicture(
        profile: profileCopy,
      ),
      title: Text(profileName),
      subtitle: Text(
        lastMsgSenderStr,
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      onTap: profileCopy == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(profileCopy),
                ),
              );
            },
    );
  }
}

class ChatScreen extends StatefulWidget {
  final Profile profile;

  const ChatScreen(this.profile, {super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final inputController = TextEditingController();

  bool isSending = false;
  bool canSend = true;
  List<Message> selectedMessages = [];

  @override
  void initState() {
    super.initState();

    inputController.addListener(_onTextUpdate);
  }

  @override
  void dispose() {
    super.dispose();

    inputController.dispose();

    inputController.removeListener(_onTextUpdate);
  }

  Chat get chat {
    return chatProvider.getChatWith(widget.profile.id);
  }

  void _onTextUpdate() {
    final sendAllowed = inputController.text.isNotEmpty;

    if (sendAllowed != canSend) {
      setState(() {
        canSend = sendAllowed;
      });
    }
  }

  void _onSendPressed() {
    setState(() {
      isSending = true;
    });

    final text = inputController.text;
    inputController.clear();

    chat.sendMessage(text).then((_) {
      setState(() {
        isSending = false;
      });
    }).catchError((e) {
      log(e.toString());
      showError(context, "Send error", description: e.toString());

      setState(() {
        isSending = false;
      });
    });
  }

  void _onMessageDeletePress() {
    Future.wait(selectedMessages.map((msg) => msg.delete())).then((_) {
      setState(() {
        selectedMessages = [];
      });
    }).catchError((e) {
      showError(
        context,
        "Delete error",
        description: e.toString(),
      );
    });
  }

  void _onMessageTap(Message msg) {
    // Message selected: deselect
    if (selectedMessages.contains(msg)) {
      setState(() {
        selectedMessages = selectedMessages.toList()..remove(msg);
      });
      return;
    }

    // Not in selection mode: do nothing
    if (selectedMessages.isEmpty) return;

    // In selection mode and ot selected: add to selection
    setState(() {
      selectedMessages = selectedMessages..add(msg);
    });
  }

  void _onMessageHold(Message msg) {
    if (selectedMessages.contains(msg)) {
      setState(() {
        selectedMessages = selectedMessages..remove(msg);
      });
    } else {
      setState(() {
        selectedMessages = selectedMessages..add(msg);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF497077),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            ProfilePicture(profile: widget.profile),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(widget.profile.name ?? "Unknown"),
            )
          ],
        ),
        actions: selectedMessages.isEmpty ||
                selectedMessages.any((msg) => !msg.isSentByMe)
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _onMessageDeletePress,
                ),
              ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return ListView(
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  children: chat.messages.reversed
                      .map((msg) => ChatBubble(
                            msg,
                            onTap: _onMessageTap,
                            onHold: _onMessageHold,
                            isSelected: selectedMessages.contains(msg),
                          ))
                      .toList(),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: const Color(0xFFC8D4D6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: (!canSend || isSending) ? null : _onSendPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  final void Function(Message)? onTap;
  final void Function(Message)? onHold;
  final bool isSelected;

  const ChatBubble(
    this.message, {
    this.onTap,
    this.onHold,
    this.isSelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: visually show isSelected property

    final bubble = Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: message.isSentByMe ? const Color(0xFF497077) : Colors.grey[300],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        message.content,
        style: TextStyle(
          color: message.isSentByMe ? Colors.white : Colors.black,
        ),
      ),
    );

    final timeStr =
        DateFormat("HH:mm").format(message.sentAt) + isSelected.toString();

    late final Row row;
    if (message.isSentByMe) {
      // Align right
      row = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 40.0),
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Text(timeStr),
          ),
          Flexible(child: bubble),
        ],
      );
    } else {
      // Align left
      row = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(child: bubble),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(timeStr),
          ),
          const SizedBox(width: 40.0),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(message),
      onLongPress: onHold == null ? null : () => onHold!(message),
      child: row,
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ChatPage(),
  ));
}
