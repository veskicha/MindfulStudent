import 'package:flutter/material.dart';
import 'package:mindfulstudent/widgets/bottom_nav_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SleepTrackingPage extends StatefulWidget {
  const SleepTrackingPage({super.key});

  @override
  SleepTrackingPageState createState() => SleepTrackingPageState();
}

class SleepTrackingPageState extends State<SleepTrackingPage> {
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
            padding: const EdgeInsets.only(top: 50.0, bottom: 30.0, left: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Mike',
                  style: TextStyle(
                    fontSize: 35,
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
          Container(
            width: 400,  // Set your desired width
            height: 300, // Set your desired height
            child: SfCartesianChart(
              backgroundColor: Colors.white, // Optional: You can set a background color
              primaryXAxis: DateTimeAxis(
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                intervalType: DateTimeIntervalType.auto,
                majorGridLines: MajorGridLines(width: 0),
                axisLine: AxisLine(color: Color(0xFF497077)),
                labelStyle: TextStyle(color: Color(0xFF497077)),
              ),
              primaryYAxis: NumericAxis(
                labelFormat: '{value}h',
                axisLine: AxisLine(color: Color(0xFF497077)),
                majorTickLines: MajorTickLines(color: Color(0xFF497077)),
                labelStyle: TextStyle(color: Color(0xFF497077)),
                majorGridLines: MajorGridLines(color: Colors.grey[200]), // Light gridlines
              ),
              series: <CartesianSeries<SleepData, DateTime>>[
                LineSeries<SleepData, DateTime>(
                  dataSource: chartData,
                  xValueMapper: (SleepData data, _) => data.date,
                  yValueMapper: (SleepData data, _) => data.hours,
                  color: Color(0xFF497077), // Primary color for the line
                  markerSettings: MarkerSettings(
                      isVisible: true,
                      color: Color(0xFF497077),
                      borderColor: Colors.white,
                      borderWidth: 2
                  ),
                ),
              ],
              tooltipBehavior: TooltipBehavior(enable: true), // Enable tooltip
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 30)
          ),
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.9, // 90% of screen width
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Border radius of 20
                child: Container(
                  color: const Color(0xFF497077),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // Center align the texts
                    children: [
                      const Text(
                        'Your optimal bedtime',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4), // Adjusted padding
                      const Text(
                        '21:30 - 22:30',
                        style: TextStyle(
                          fontSize: 28, // Increased font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4), // Same padding as above
                      GestureDetector(
                        onTap: () {
                          // Handle daily tips and suggestions action
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'Daily tips and suggestions →',
                            style: TextStyle(
                              fontSize: 14, // Font size
                              color: Colors.white, // Text color
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20), // Applying a border radius of 20
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      color: const Color(0xFF6292C7), // Updated background color
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time asleep',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white, // Changed text color to white
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '8h 12m',
                            style: TextStyle(
                              fontSize: 34, // Increased font size
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Changed text color to white
                            ),
                          ),
                          Text(
                            '10:46 pm - 7:08 am',
                            style: TextStyle(
                              color: Colors.white, // Changed text color to white
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20), // Applying a border radius of 20
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      color: const Color(0xFFC8CC5F), // Updated background color
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Week',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white, // Text color is white
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '7h 34m',
                            style: TextStyle(
                              fontSize: 34, // Increased font size
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Text color is white
                            ),
                          ),
                          Text(
                            '10:46 pm - 7:08 am',
                            style: TextStyle(
                              color: Colors.white, // Text color is white
                            ),
                          ),
                        ],
                      ),
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
      ),
    );
  }
}

class SleepData {
  final DateTime date;
  final double hours;

  SleepData(this.date, this.hours);
}
