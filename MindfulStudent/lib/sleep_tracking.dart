import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:mindfulstudent/widgets/bottom_nav_bar.dart';

class SleepTrackingPage extends StatefulWidget {
  @override
  _SleepTrackingPageState createState() => _SleepTrackingPageState();
}

class _SleepTrackingPageState extends State<SleepTrackingPage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<SleepData> chartData = [
    SleepData(DateTime(2023, 5, 1), 10),
    SleepData(DateTime(2023, 5, 7), 12),
    SleepData(DateTime(2023, 5, 15), 8),
    SleepData(DateTime(2023, 5, 22), 11),
    SleepData(DateTime(2023, 5, 30), 7),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome Mike',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF497077),
                  ),
                ),
                Text(
                  'Are you gliding into sleep?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF497077),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(),
              series: <CartesianSeries<SleepData, DateTime>>[
                LineSeries<SleepData, DateTime>(
                  dataSource: chartData,
                  xValueMapper: (SleepData data, _) => data.date,
                  yValueMapper: (SleepData data, _) => data.hours,
                ),
              ],
            ),
          ),
          Container(
            color: Color(0xFF497077),
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your optimal bedtime',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '21:30 - 22:30',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Handle daily tips and suggestions action
                    },
                    child: Text(
                      'Daily tips and suggestions →',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Color(0xFFC8D4D6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time asleep',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF497077),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '8h 12m',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF497077),
                          ),
                        ),
                        Text(
                          '10:46 pm - 7:08 am',
                          style: TextStyle(
                            color: Color(0xFF497077),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Color(0xFFC8D4D6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Week',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF497077),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '7h 34m',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF497077),
                          ),
                        ),
                        Text(
                          '10:46 pm - 7:08 am',
                          style: TextStyle(
                            color: Color(0xFF497077),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ), // Using the BottomNavBar widget
    );
  }
}

class SleepData {
  final DateTime date;
  final double hours;

  SleepData(this.date, this.hours);
}
