import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/auth.dart';
import 'package:mindfulstudent/provider/user_profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  JournalScreenState createState() => JournalScreenState();
}



class JournalScreenState extends State<JournalScreen> {
  int _selectedIndex = 1;
  TextEditingController noteController = TextEditingController();
  TextEditingController anotherController = TextEditingController();
  bool isTitleEmpty = false;
  bool isContentEmpty = false;
  List<Note> notes = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    final user = Auth.user;
    if (user == null) return;

    _fetchNotesFromDatabase();

  }





  @override
  void dispose() {
    noteController.dispose();
    anotherController.dispose();
    super.dispose();
  }




  void _saveNote() {
    final String title = noteController.text;
    final String content = anotherController.text;
    final DateTime now = DateTime.now();

    // Save to local list
    setState(() {
      notes.add(Note(title,content, now));
    });

    _saveNoteToDatabase(title, content, now);

    noteController.clear();
    anotherController.clear();

    Navigator.of(context).pop();
  }

  Future<void> _saveNoteToDatabase(String title, String content, DateTime date) async {
    final userId = Auth.user?.id;
    if (userId == null) return;

    String formattedDate = DateFormat('dd-MM-yyyy').format(date);

    try {
      await Supabase.instance.client
          .from('journal')
          .insert({
            'title': title,
            'content': content,
            'created_at': formattedDate,
            'user_id': userId,
          })
          .select();

    } catch (e) {
      // Handle error
    }
  }

  void _handleSave() {
    bool titleIsEmpty = noteController.text.isEmpty;
    bool contentIsEmpty = anotherController.text.isEmpty;

    if (titleIsEmpty || contentIsEmpty) {
      setState(() {
        isTitleEmpty = titleIsEmpty;
        isContentEmpty = contentIsEmpty;
      });
    } else {
      _saveNote();
    }
  }

  Future<void> _fetchNotesFromDatabase() async {
    final userId = Auth.user?.id;
    if (userId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('journal')
          .select()
          .eq('user_id', userId)
          .select();

        List<dynamic> data = response;
        List<Note> fetchedNotes = List<Note>.from(data.map((noteData) {
          return Note(
            noteData['title'],
            noteData['content'],
            DateTime.parse(noteData['created_at']),
          );
        }));

        setState(() {
          notes = fetchedNotes;
        });
    } catch (e) {
      //
    }
  }

  void _showNoteDetails(Note note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            note.title,
            style: const TextStyle(
              color: Color(0xFF497077),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(note.content),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          actions: <Widget>[
            TextButton(
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF497077)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF497077),
              onPrimary: Colors.white,
              onSurface: Color(0xFF497077),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF497077),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != DateTime.now()) {
      _fetchNotesFromSelectedDate(pickedDate);
    }
  }

  Future<void> _fetchNotesFromSelectedDate(DateTime date) async {
    final userId = Auth.user?.id;
    if (userId == null) return;

    String formattedDate = DateFormat('dd-MM-yyyy').format(date);

    try {
      final response = await Supabase.instance.client
          .from('journal')
          .select()
          .eq('user_id', userId)
          .eq('created_at', formattedDate)
          .select();

      List<dynamic> data = response;
      List<Note> fetchedNotes = List<Note>.from(data.map((noteData) {
        return Note(
          noteData['title'],
          noteData['content'],
          DateTime.parse(noteData['created_at']),
        );
      }));

      setState(() {
        notes = fetchedNotes;
      });
    } catch (e) {
      //
    }
  }



  void _showNoteDialog(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Give your thoughts for the day',
            style: TextStyle(
              color: Color(0xFF497077),
              fontSize: 20,
            ),
          ),
          content: SizedBox(
            width: screenWidth * 0.8,
            height: screenHeight* 0.4,
            child: Column(
              children: [
                const SizedBox(height: 40),
                TextFormField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: isTitleEmpty ? Colors.red : const Color(0xFFC8D4D6),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: isTitleEmpty ? Colors.red : const  Color(0xFFC8D4D6)),
                    ),
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 60),
                Container(
                  height: 100,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFC8D4D6)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: anotherController,
                    decoration: InputDecoration(
                      hintText: 'Enter your thoughts',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                ),
              ],
            ),
          ),


          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF497077)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Color(0xFF497077)),
                  ),
                  onPressed: () {
                    _handleSave();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }









  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double overlapHeight = screenHeight * 0.02;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFC8D4D6),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  width: double.infinity,
                  height: 300,
                    child: Consumer<UserProfileProvider>(
                        builder: (context, profileProvider, child) {
                          final Profile? userProfile = profileProvider.userProfile;
                          final avatarImg = userProfile?.getAvatarImage();

                          return Stack(
                            children: [
                              Positioned(
                                top: 75,
                                left: 300,
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: avatarImg,
                                  backgroundColor: avatarImg == null
                                      ? const Color(0xFF497077)
                                      : null,
                                  child: avatarImg == null
                                      ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.white,
                                  )
                                      : null,
                                ),
                              ),
                              const Positioned(
                                top: 75,
                                left: 60,
                                child: Text(
                                  'Journal',
                                  style: TextStyle(
                                    color: Color(0xFF497077),
                                    fontFamily: 'Poppins',
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 110,
                                left: 60,
                                child: Text(
                                  'Give your thought of the day',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                    ),
                ),
                Positioned(
                  top: 220 - overlapHeight,
                  left: MediaQuery.of(context).size.width * 0.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start, // Aligns children to the start of the row
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: ElevatedButton(
                          onPressed: () => _showNoteDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            alignment: Alignment.center,
                            elevation: 3,
                            shadowColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF497077),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Color(0xFF497077),
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'New Note',
                                style: TextStyle(
                                  color: Color(0xFF497077),
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.15), // Spacing between the button and the date picker
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          alignment: Alignment.center,
                          elevation: 3,
                          shadowColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Icon(Icons.calendar_today, color: Color(0xFF497077)), // Calendar icon
                      ),
                    ],
                  ),
                ),


              ],
            ),
            const SizedBox(height: 100),
            if (notes.isNotEmpty)
              SizedBox(
                height: screenHeight * 0.45,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1,
                  ),
                  itemCount: notes.length > 7 ? 7 : notes.length,
                  itemBuilder: (context, index) {
                    final note = notes.reversed.toList()[index];
                    return GestureDetector(
                        onTap: () => _showNoteDetails(note),
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              note.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF497077),
                                fontSize: 20
                              ),
                            ),
                            Flexible(
                              child: Text(
                                note.content.length > 50 ? '${note.content.substring(0, 50)}...' : note.content,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                DateFormat('dd-MM-yyyy').format(note.date),
                                style: TextStyle(
                                    color: Colors.grey[600],
                                  fontSize: 12
                                ),

                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    );

                  },
                ),
              ),
              ),
            // Add any other widgets that should appear below the notes grid
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

}

class Note {
  String title;
  String content;
  DateTime date;

  Note(this.title, this.content, this.date);
}