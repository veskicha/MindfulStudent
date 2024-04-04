import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';
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
          Expanded(child: Consumer<ConnectionProvider>(
              builder: (context, connectionProvider, child) {
            // TODO: show some kind of loading page if not logged in yet
            final me = profileProvider.userProfile;
            if (me == null) return const SizedBox.shrink();

            final connections =
                connectionProvider.connections.where((conn) => conn.confirmed);
            return ListView(
              children: connections.map((conn) {
                if (conn.from.id == me.id) {
                  return ProfileCard(conn.to);
                } else {
                  return ProfileCard(conn.from);
                }
              }).toList(),
            );
          })),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final Profile profile;

  const ProfileCard(this.profile, {super.key});

  @override
  Widget build(BuildContext context) {
    final avatarImg = profile.getAvatarImage();

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
      title: Text(profile.name ?? "Unknown"),
      subtitle: const Text("blablabla chocoladevla"),
      onTap: () {
        // Handle chat item tap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(profile),
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
              child: ListView(
                children: const [
                  // Replace with actual chat messages
                  ChatBubble(message: 'Hello', isMe: true),
                  ChatBubble(message: 'Hi there!', isMe: false),
                ],
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
  final String message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF497077) : Colors.grey[300],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
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
