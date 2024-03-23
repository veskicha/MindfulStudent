import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color(0xFF5C7F85),
      selectedItemColor: Color(0xFF5C7F85),
      unselectedItemColor: Colors.black,
      currentIndex: selectedIndex,
      onTap: (index) {
        // Call the onItemTapped function provided by the parent widget
        onItemTapped(index);
        // Navigate to the respective page based on the index
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/sleep');
            break;
          case 2:
            Navigator.pushNamed(context, '/chat');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
          default:
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/HomeIcon.png'),
            size: 24,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/Sleep.png'),
            size: 24,
          ),
          label: 'Sleep',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/Chat.png'),
            size: 24,
          ),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/Profile.png'),
            size: 24,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: Color(0xFF497077),
          title: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              'Chats',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // Handle search action
              },
            ),
          ],
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
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          // Recent Chats List
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Replace with actual number of chats
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey, // Placeholder color
                    child: Icon(Icons.person),
                  ),
                  title: Text('Contact Name $index'),
                  subtitle: Text('Last message from contact $index'),
                  onTap: () {
                    // Handle chat item tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2, // Chat page index
        onItemTapped: (index) {
          // Handle bottom navigation bar item tapped
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/sleep');
              break;
            case 2:
              // Already on chat page
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
            default:
              break;
          }
        },
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF497077),
        title: Text('Contact Name'),
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  // Replace with actual chat messages
                  ChatBubble(message: 'Hello', isMe: true),
                  ChatBubble(message: 'Hi there!', isMe: false),
                ],
              ),
            ),
          ),
          // Message Input
          Container(
            padding: EdgeInsets.all(8.0),
            color: Color(0xFFC8D4D6),
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
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: () {
                    // Handle attachment button tap
                  },
                ),
                IconButton(
                  icon: Icon(Icons.send),
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
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isMe ? Color(0xFF497077) : Colors.grey[300],
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
  runApp(MaterialApp(
    home: ChatPage(),
  ));
}
