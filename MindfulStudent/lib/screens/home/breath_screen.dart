import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:mindfulstudent/widgets/bottom_nav_bar.dart';
import 'package:audioplayers/audioplayers.dart';


class CircularTimerPage extends StatefulWidget {
  const CircularTimerPage({Key? key}) : super(key: key);

  @override
  _CircularTimerPageState createState() => _CircularTimerPageState();
}

class _CircularTimerPageState extends State<CircularTimerPage> {
  int _selectedIndex = 0;
  final int _duration = 24;
  int _counter = 0;
  Duration _previousDuration = const Duration(seconds: 0);
  AudioPlayer player = AudioPlayer();
  final CountDownController _controller = CountDownController();
  @override
  void initState() {
    super.initState();
    player.setSource(AssetSource('rainy-day-in-town-with-birds-singing-194011.mp3'));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularCountDownTimer(
          // Countdown duration in Seconds.
          duration: _duration,
          // Countdown initial elapsed Duration in Seconds.
          initialDuration: 0,
          // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
          controller: _controller,
          // Width of the Countdown Widget.
          width: MediaQuery.of(context).size.width / 2,
          // Height of the Countdown Widget.
          height: MediaQuery.of(context).size.height / 2,
          // Ring Color for Countdown Widget.
          ringColor: const Color(0xFF497077),
          // Ring Gradient for Countdown Widget.
          ringGradient: null,
          // Filling Color for Countdown Widget.
          fillColor: Colors.white,
          // Filling Gradient for Countdown Widget.
          fillGradient: null,
          // Background Color for Countdown Widget.
          backgroundColor: const Color(0xFFC8D4D6),
          // Background Gradient for Countdown Widget.
          backgroundGradient: null,
          // Border Thickness of the Countdown Ring.
          strokeWidth: 20.0,
          // Begin and end contours with a flat edge and no extension.
          strokeCap: StrokeCap.round,
          // Text Style for Countdown Text.
          textStyle: const TextStyle(
            fontSize: 23.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          // Format for the Countdown Text.
          textFormat: CountdownTextFormat.S,
          // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
          isReverse: false,
          // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
          isReverseAnimation: false,
          // Handles visibility of the Countdown Text.
          isTimerTextShown: true,
          // Handles the timer start.
          autoStart: false,

          onComplete: () => _controller.reset(),



          timeFormatterFunction: (defaultFormatterFunction, duration) {

            if (duration.inSeconds == 0) {
              _counter = 0;
              return "START";

            }
            else if (duration.inSeconds == 1) {
              _counter = 0;
              return "INHALE";

            }
            else if(duration.inSeconds == 6){
              _counter = 0;
              return "HOLD";
            }
            else if(duration.inSeconds == 14){
              _counter = 0;
              return "EXHALE";
            }
            else if(duration.inSeconds == 23){
              _counter = 0;
              _controller.restart(duration: _duration);
            }
            else {
              // Check if the duration has changed by one second
              if (duration.inSeconds != _previousDuration.inSeconds) {
                _counter++; // Increment the counter
              }
              _previousDuration = duration; // Update the previous duration
              return _counter.toString();

            }

          },

        ),

      ),

      floatingActionButton: Row(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          const SizedBox(

            width: 40,

          ),

          _button(

            title: "Start",

            onPressed: () => {_controller.resume(), player.resume()},

          ),

          const SizedBox(

            width: 10,

          ),

          _button(

            title: "Pause",

            onPressed: () => {_controller.pause(), player.pause()},

          ),

          const SizedBox(

            width: 10,

          ),

          _button(

            title: "Restart",

            onPressed: () => {_controller.reset() , player.pause()},

          ),

        ],

      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),

    );

  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _button({required String title, VoidCallback? onPressed}) {

    return Expanded(

      child: ElevatedButton(

        style: ButtonStyle(

          backgroundColor: MaterialStateProperty.all(const Color(0xFF497077)),

        ),

        onPressed: onPressed,

        child: Text(

          title,

          style: const TextStyle(color: const Color(0xFFC8D4D6)),

        ),

      ),

    );

  }

}


