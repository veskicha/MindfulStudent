import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/provider/user_profile_provider.dart';
import 'package:mindfulstudent/screens/auth/login_screen.dart';
import 'package:mindfulstudent/screens/home/profile_edit_screen.dart';
import 'package:mindfulstudent/widgets/button.dart';
import 'package:provider/provider.dart';

import '../../widgets/bottom_nav_bar.dart';

class EmergencyContactPage extends StatefulWidget {
  const EmergencyContactPage({Key? key}) : super(key: key);

  @override
  EmergencyContactPageState createState() => EmergencyContactPageState();
}

class EmergencyContactPageState extends State<EmergencyContactPage> {
  int _selectedIndex = 3; // Default selected index

  String? _selectedFruit;
  final List<String> _fruits = [
    'Police Emergency',
    'Fire Emergency',
    'Police Non Emergency',
    'Fire Non Emergency',
    'Mental Health Expert',
    'Suicide Prevention',
    'Alcohol Abuse',
    'Sexual Violence',
    'Discrimination'
  ];


  final Map<String, String> _emergencyNumbers = {
    'Police Emergency': 'Dial 112',
    'Fire Emergency': 'Dial 112',
    'Police Non Emergency': 'Dial 0900 8844',
    'Fire Non Emergency': 'Dial 0900 0904',
    'Mental Health Expert': 'Dial 033 460 89 00',
    'Suicide Prevention': 'Dial 0900 0113',
    'Alcohol Abuse': 'Dial 020 625 6057',
    'Sexual Violence': 'Dial 010 820 08 40',
    'Discrimination': 'Dial 0900 2 354 354 ',
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/background.jpg',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                const Positioned(
                  top: 40,
                  child: Text(
                    'Emergency Contact Information',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 0),
            child: Consumer<UserProfileProvider>(
              builder: (context, profileProvider, child) {
                final Profile? userProfile = profileProvider.userProfile;
                final avatarImg = userProfile?.getAvatarImage();

                return Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      userProfile?.name ?? "What Service Do You Wish To Contact?",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF497077),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                    ),
                    _title("Select Emergency Service You Wish To Connect To"),
                    _dropDown(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Container(
                        padding: const EdgeInsets.all(2), // Border width
                        child: Text(
                          _selectedFruit != null
                              ? _emergencyNumbers[_selectedFruit!] ?? ''
                              : '',
                          style: TextStyle(color: Colors.black, fontSize: 25),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Spacer(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _title(String val) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        val,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _dropDown({
    Widget? underline,
    Widget? icon,
    TextStyle? style,
    TextStyle? hintStyle,
    Color? dropdownColor,
    Color? iconEnabledColor,
  }) =>
      DropdownButton<String>(
          value: _selectedFruit,
          underline: underline,
          icon: icon,
          dropdownColor: dropdownColor,
          style: style,
          iconEnabledColor: iconEnabledColor,
          onChanged: (String? newValue) {
            setState(() {
              _selectedFruit = newValue;
            });
          },
          hint: Text("Service", style: hintStyle),
          items: _fruits
              .map((fruit) =>
                  DropdownMenuItem<String>(value: fruit, child: Text(fruit)))
              .toList());
}
