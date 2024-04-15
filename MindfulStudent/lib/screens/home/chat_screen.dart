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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        // Adjusted height for extra padding
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFFC8D4D6),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF497077)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 12),
                Text(
                  "Chats",
                  style: TextStyle(
                    color: Color(0xFF497077),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your messages',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(20), // Adjusted for padding
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                // Padding added here
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.psychology,
                        size: 30,
                        color: Color(0xFF497077),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const ExpertsPage()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.link,
                        size: 30,
                        color: Color(0xFF497077),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const ConnectionsPage()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        size: 30,
                        color: Color(0xFF497077),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const AddFriendsPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            // Rest of your ListView or other body content
            return ListView(
              children: chatProvider.chats
                  .map((chat) => ProfileCard(profileFut: chat.getProfile()))
                  .toList(),
            );
          },
        ),
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFFC8D4D6),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF497077)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 12),
                Text(
                  "Connection Requests",
                  style: TextStyle(
                    color: Color(0xFF497077),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage your connections',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            final me = profileProvider.userProfile?.id;

            final connections = chatProvider.connections;
            final incoming =
                connections.where((conn) => conn.toId == me && !conn.confirmed);
            final outgoing = connections
                .where((conn) => conn.fromId == me && !conn.confirmed);

            final List<Widget> page = [];
            if (incoming.isNotEmpty) {
              page.add(
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "Incoming requests",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF497077)),
                      ),
                      SizedBox(height: 8),
                      Icon(Icons.arrow_back,
                          size: 20, color: Color(0xFF497077)),
                    ],
                  ),
                ),
              );
              page.addAll(incoming.map(
                (conn) => ProfileCard(
                  profileFut: Profile.get(conn.fromId),
                ),
              ));
            }

            if (incoming.isNotEmpty && outgoing.isNotEmpty) {
              page.add(const SizedBox(height: 50));
            }

            if (outgoing.isNotEmpty) {
              page.add(
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "Outgoing requests",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF497077)),
                      ),
                      SizedBox(height: 8),
                      Icon(Icons.arrow_forward,
                          size: 20, color: Color(0xFF497077)),
                    ],
                  ),
                ),
              );
              page.addAll(outgoing.map(
                (conn) => ProfileCard(
                  profileFut: Profile.get(conn.toId),
                ),
              ));
            }

            if (page.isEmpty) {
              return const Center(
                child: Text(
                  "No connection requests!",
                  style: TextStyle(
                      fontSize: 26,
                      color: Color(0xFF497077),
                      fontWeight: FontWeight.bold),
                ),
              );
            }

            return ListView(
                children: page); // Changed to ListView for better scrolling
          },
        ),
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFFC8D4D6),
            centerTitle: true,
            title: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Add Friends",
                  style: TextStyle(
                    color: Color(0xFF497077),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Find new friends here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: TextField(
                    controller: _controller,
                    cursorColor: const Color(0xFF497077),
                    style: const TextStyle(color: Color(0xFF497077)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search by name',
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF497077)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Color(0xFF497077)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Color(0xFF497077)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Color(0xFF497077)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: results
              .map((res) => ProfileCard(profileFut: Future.value(res)))
              .toList(),
        ),
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
    final List<Profile>? accounts = healthExperts
        ?.where(
          (profile) => !chatProvider.connections.any(
            (conn) =>
                (conn.fromId == profile.id || conn.toId == profile.id) &&
                conn.confirmed,
          ),
        )
        .toList();

    late final Widget body;
    if (accounts == null) {
      body = Container(
        margin: const EdgeInsets.only(top: 50),
        child: const Center(
          child: Text(
            "Loading...",
            style: TextStyle(
                color: Color(0xFF497077),
                fontWeight: FontWeight.bold,
                fontSize: 22),
          ),
        ),
      );
    } else if (accounts.isEmpty) {
      body = Container(
        margin: const EdgeInsets.only(top: 50),
        child: const Center(
          child: Text(
            "No mental health experts found!",
            style: TextStyle(
                color: Color(0xFF497077),
                fontWeight: FontWeight.bold,
                fontSize: 22),
          ),
        ),
      );
    } else {
      body = Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: healthExperts!
              .where(
                (profile) => !chatProvider.connections.any(
                  (conn) =>
                      (conn.fromId == profile.id || conn.toId == profile.id) &&
                      conn.confirmed,
                ),
              )
              .map((profile) => ProfileCard(profileFut: Future.value(profile)))
              .toList(),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFFC8D4D6),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF497077)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 15),
                Text(
                  "Mental Health Experts",
                  style: TextStyle(
                    color: Color(0xFF497077),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Connect with professionals',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: body,
    );
  }
}

class ProfileCard extends StatefulWidget {
  final Future<Profile?> profileFut;

  const ProfileCard({required this.profileFut, super.key});

  @override
  State<StatefulWidget> createState() => ProfileCardState();
}

class ProfileCardState extends State<ProfileCard> {
  Profile? profile;

  @override
  void initState() {
    super.initState();

    widget.profileFut.then((p) {
      setState(() {
        profile = p;
      });
    });
  }

  Connection? get connection {
    try {
      return chatProvider.connections.firstWhere(
        (conn) => conn.fromId == profile?.id || conn.toId == profile?.id,
      );
    } on StateError {
      return null;
    }
  }

  bool get isHealthExpert {
    return profile?.role == "HEALTH_EXPERT";
  }

  bool get isIncomingRequest {
    return connection?.fromId == profile?.id &&
        !(connection?.confirmed ?? false);
  }

  bool get isOutgoingRequest {
    return connection?.toId == profile?.id && !(connection?.confirmed ?? false);
  }

  bool get isExistingChat {
    return connection?.confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final profileCopy = profile;

    final profileName = profileCopy?.name ?? "Unknown";

    // Subtitle under username
    late final String subtitle;
    if (isExistingChat) {
      final lastMsg = (profileCopy == null)
          ? null
          : chatProvider.getChatWith(profileCopy.id).messages.lastOrNull;
      if (lastMsg != null) {
        subtitle =
            "${lastMsg.isSentByMe ? "You" : profileName}: ${lastMsg.content}";
      } else {
        subtitle = "";
      }
    } else {
      subtitle = "";
    }

    // On user tap action
    late final void Function() onTap;
    if (isExistingChat && profileCopy != null) {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(profileCopy),
          ),
        );
      };
    } else {
      onTap = () {};
    }

    // On user long press action
    late final void Function() onHold;
    if (isExistingChat) {
      onHold = _showDisconnectConfirmDialog;
    } else {
      onHold = () {};
    }

    // Action buttons
    final List<Widget> buttons = [];
    if (isIncomingRequest) {
      // Accept & deny buttons
      buttons.add(ActionIconButton(
        icon: Icons.check,
        color: Colors.green,
        onPressed: connection?.accept,
      ));
      buttons.add(ActionIconButton(
        icon: Icons.close,
        color: Colors.red,
        onPressed: connection?.deny,
      ));
    } else if (isOutgoingRequest) {
      // Deny (cancel) button
      buttons.add(ActionIconButton(
        icon: Icons.close,
        color: Colors.red,
        onPressed: connection?.deny,
      ));
    } else if (isHealthExpert && !isExistingChat) {
      // Accept immediate button
      buttons.add(ActionIconButton(
        icon: Icons.chat,
        color: const Color(0xFF497077),
        onPressed: () async {
          if (profile == null) return;
          await Connection.request(profile!);
          if (!context.mounted) return;
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ChatScreen(profile!)),
          );
        },
      ));
    } else if (!isExistingChat) {
      // Request button
      buttons.add(ActionIconButton(
        icon: Icons.add,
        color: const Color(0xFF497077),
        onPressed: () async {
          if (profile == null) return;
          await Connection.request(profile!);
          if (!context.mounted) return;
          Navigator.of(context).pop();
        },
      ));
    }

    return ListTile(
      leading: ProfilePicture(
        profile: profileCopy,
      ),
      title: Text(
        profileName,
        style: const TextStyle(
          color: Color(0xFF497077),
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: buttons,
      ),
      onTap: onTap,
      onLongPress: onHold,
    );
  }

  _showDisconnectConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Disconnect?"),
          content: Text(
            "Are you sure you wish to disconnect from ${profile?.name}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                connection?.deny();
                Navigator.of(context).pop();
              },
              child: const Text("Yes, disconnect"),
            ),
          ],
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

  Future<void> _onMessageDeletePress() async {
    try {
      await Future.wait(selectedMessages.map((msg) => msg.delete()));
      setState(() {
        selectedMessages = [];
      });
    } catch (e) {
      setState(() {
        selectedMessages = [];
      });

      final ctx = context;
      if (ctx.mounted) {
        showError(
          ctx,
          "Delete error",
          description: e.toString(),
        );
      }
    }
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
    final List<ActionIconButton> actions = [];
    if (selectedMessages.length == 1) {
      // emoji button
      actions.add(
        ActionIconButton(
          icon: Icons.mood,
          onPressed: () async {
            // TODO: emoji selection screen?
            // Note: requires backend support (emoji needs to be allow-listed)
            const String emoji = "RED_HEART";

            final reactions = selectedMessages[0].reactions[emoji];
            if ((reactions ?? {}).contains(profileProvider.userProfile?.id)) {
              // We already reacted, so remove it i guess
              await selectedMessages[0].removeReaction("RED_HEART");
            } else {
              // Add new reaction
              await selectedMessages[0].addReaction("RED_HEART");
            }
            setState(() {
              selectedMessages = [];
            });
          },
        ),
      );
    }
    if (selectedMessages.isNotEmpty &&
        selectedMessages.every((msg) => msg.isSentByMe)) {
      actions.add(ActionIconButton(
        icon: Icons.delete_outline,
        onPressed: _onMessageDeletePress,
      ));
    }

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            backgroundColor: const Color(0xFFC8D4D6),
            foregroundColor: const Color(0xFF497077),
            title: Row(
              children: [
                ProfilePicture(profile: widget.profile),
                const SizedBox(width: 15.0),
                Expanded(
                  child: Text(
                    widget.profile.name ?? "Unknown",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: actions,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(10),
              child: Container(),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 20.0, right: 10, left: 10),
          child: Column(
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
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: inputController,
                        cursorColor: const Color(0xFF497077),
                        style: const TextStyle(color: Color(0xFF497077)),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Type a message...',
                          hintStyle:
                              TextStyle(color: Colors.grey.withOpacity(0.6)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide:
                                const BorderSide(color: Color(0xFFC8D4D6)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide:
                                const BorderSide(color: Color(0xFFC8D4D6)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide:
                                const BorderSide(color: Color(0xFFC8D4D6)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: const Color(0xFF497077),
                      onPressed:
                          (!canSend || isSending) ? null : _onSendPressed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
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
    final screenWidth = MediaQuery.of(context).size.width;
    final bubbleMaxWidth = screenWidth * 0.5;

    final bubble = Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
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

    // TODO: probably better UI, don't throw everything in the text :D
    String timeStr = DateFormat("HH:mm").format(message.sentAt);
    for (final reaction in message.reactions.entries) {
      timeStr += "\n  - ${reaction.key}: ${reaction.value.length}";
    }

    late final Row row;
    if (message.isSentByMe) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 40.0),
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Text(
              timeStr,
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
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
            padding: const EdgeInsets.only(left: 7.0),
            child: Text(
              timeStr,
              maxLines: 5,
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
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

class ActionIconButton extends StatefulWidget {
  final IconData icon;

  final Future<void> Function()? onPressed;
  final Color? color;

  const ActionIconButton({
    required this.icon,
    this.onPressed,
    this.color,
    super.key,
  });

  @override
  State<ActionIconButton> createState() => _ActionIconButtonState();
}

class _ActionIconButtonState extends State<ActionIconButton> {
  bool isActive = true;

  void _onPress() {
    final fun = widget.onPressed;
    if (!isActive || fun == null) return;

    setState(() {
      isActive = false;
    });

    fun().then((_) {
      setState(() {
        isActive = true;
      });
    }).catchError((e) {
      setState(() {
        isActive = true;
      });
      log(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(widget.icon),
      color: widget.color,
      onPressed: isActive ? _onPress : null,
    );
  }
}
