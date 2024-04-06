import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/backend/messages.dart';
import 'package:mindfulstudent/main.dart';
import 'package:mindfulstudent/provider/chat_provider.dart';
import 'package:mindfulstudent/widgets/bottom_nav_bar.dart';
import 'package:mindfulstudent/widgets/header_bar.dart';
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
        preferredSize: const Size.fromHeight(80.0),
        child: HeaderBar(
          'Chats',
          actionIcon: const Icon(Icons.search),
          onActionPressed: () {},
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          // Recent Chats List
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return ListView(
                  children: chatProvider.chats
                      .map((chat) => ProfileCard(profileFut: chat.getProfile()))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
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

  @override
  Widget build(BuildContext context) {
    final profileCopy = profile;

    final profileName = profileCopy?.name ?? "Unknown";
    final avatarImg = profileCopy?.getAvatarImage();
    final lastMsg = (profileCopy == null)
        ? null
        : chatProvider.getChatWith(profileCopy.id).messages.lastOrNull;

    String lastMsgSenderStr = "";
    if (lastMsg != null && lastMsg.isSentByMe) {
      lastMsgSenderStr =
          "${lastMsg.isSentByMe ? "You" : profileName}: ${lastMsg.content}";
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: avatarImg,
        backgroundColor: avatarImg == null ? const Color(0xFF497077) : null,
        child: avatarImg == null
            ? const Icon(
                Icons.person,
                color: Colors.white,
              )
            : null,
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

class ChatScreen extends StatelessWidget {
  final Profile profile;

  const ChatScreen(this.profile, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF497077),
        foregroundColor: Colors.white,
        title: Text(profile.name ?? "Unknown"),
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  final chat = chatProvider.getChatWith(profile.id);
                  return ListView(
                    children:
                        chat.messages.map((msg) => ChatBubble(msg)).toList(),
                  );
                },
              ),
            ),
          ),
          // Message Input
          Container(
            padding: const EdgeInsets.all(8.0),
            color: const Color(0xFFC8D4D6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
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
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    // Handle attachment button tap
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Handle send button tap
                  },
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

  const ChatBubble(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: message.isSentByMe
          ? const EdgeInsets.only(left: 40.0)
          : const EdgeInsets.only(right: 40.0),
      child: Align(
        alignment:
            message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color:
                message.isSentByMe ? const Color(0xFF497077) : Colors.grey[300],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              color: message.isSentByMe ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ChatPage(),
  ));
}
