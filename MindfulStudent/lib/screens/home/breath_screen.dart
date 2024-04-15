import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mindfulstudent/widgets/bottom_nav_bar.dart';

class BreathingExercisePage extends StatefulWidget {
  const BreathingExercisePage({super.key});

  @override
  BreathingExercisePageState createState() => BreathingExercisePageState();
}

class BreathingExercisePageState extends State<BreathingExercisePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late Timer _timer;
  int _elapsedSeconds = 0;
  final int _exerciseDuration = 23;
  final List<String> _imagePaths = [
    'assets/BreatheIn.jpg',
    'assets/Hold.png',
    'assets/BreatheOut.png',
  ];
  String _currentImagePath = 'assets/Breathing.jpg';
  String _displayText = "Let's start your breathing exercise!";
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
      if (_isTimerRunning) {
        _startTimer();
      } else {
        _stopTimer();
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _stopTimer();
      _elapsedSeconds = 0;
      _displayText = "Let's start your breathing exercise!";
      _currentImagePath = 'assets/BreatheIn.jpg';
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;

        if (_elapsedSeconds <= 7) {
          _displayText = 'Inhale';
          _currentImagePath = _imagePaths[0];
        } else if (_elapsedSeconds <= 15) {
          _displayText = 'Hold';
          _currentImagePath = _imagePaths[1];
        } else {
          _displayText = 'Exhale';
          _currentImagePath = _imagePaths[2];
        }

        if (_elapsedSeconds >= _exerciseDuration) {
          _elapsedSeconds = 0;
        }
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Breathing Exercise',
          style: TextStyle(color: Color(0xFF497077)),
        ),
        backgroundColor: const Color(0xFFC8D4D6),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Visual Timer
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CircularProgressIndicator(
                    value: _elapsedSeconds / _exerciseDuration,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFFC8D4D6),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF497077)),
                  ),
                ),
                // Image
                ClipOval(
                  child: Image.asset(
                    _currentImagePath,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _displayText,
              style: const TextStyle(
                fontSize: 24,
                fontFamily: 'assets/Poppins',
                color: Color(0xFF497077),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _toggleTimer,
                  tooltip: _isTimerRunning ? 'Pause' : 'Start',
                  backgroundColor: const Color(0xFFC8D4D6),
                  child: Icon(
                    _isTimerRunning ? Icons.pause : Icons.play_arrow,
                    color: const Color(0xFF497077),
                  ),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: _resetTimer,
                  tooltip: 'Restart',
                  backgroundColor: const Color(0xFFC8D4D6),
                  child: const Icon(Icons.refresh, color: Color(0xFF497077)),
                ),
              ],
            ),
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

void main() {
  runApp(const MaterialApp(
    home: BreathingExercisePage(),
  ));
}
