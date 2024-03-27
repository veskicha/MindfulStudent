import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mindfulstudent/provider/sleep_tracking_provider.dart';
import 'package:mindfulstudent/screens/home/sleep_tracking_login_screen.dart';
import 'package:mindfulstudent/widgets/bottom_nav_bar.dart';
import 'package:mindfulstudent/widgets/button.dart';
import 'package:mindfulstudent/widgets/header_bar.dart';
import 'package:provider/provider.dart';

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

  final List<BarChartRodData> chartData = [
    BarChartRodData(fromY: 2, toY: 10),
    BarChartRodData(fromY: 2, toY: 10),
    BarChartRodData(fromY: 5, toY: 10),
    BarChartRodData(fromY: 2, toY: 10),
    BarChartRodData(fromY: 2, toY: 10),
    BarChartRodData(fromY: 2, toY: 10),
    BarChartRodData(fromY: 2, toY: 10),
    BarChartRodData(fromY: 2, toY: 10),
    BarChartRodData(fromY: 5, toY: 10),
    BarChartRodData(fromY: 2, toY: 10),
    BarChartRodData(fromY: 2, toY: 10),
    BarChartRodData(fromY: 2, toY: 10),
    BarChartRodData(fromY: 2, toY: 10),
    BarChartRodData(fromY: 2, toY: 10),
    BarChartRodData(fromY: 5, toY: 10),
    BarChartRodData(fromY: 2, toY: 10),
    BarChartRodData(fromY: 2, toY: 10),
    BarChartRodData(fromY: 2, toY: 10),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: HeaderBar('Sleep Tracking'),
      ),
      body: Consumer<SleepDataProvider>(
          builder: (context, sleepDataProvider, child) {
        if (sleepDataProvider.sleepData == null) {
          return buildLoginContent(context);
        } else {
          return buildDataContent(context);
        }
      }),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget buildLoginContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Text(
            'MindfulStudent can integrate with external services in order to provide sleep insights and suggestions.\n\n'
            'If you wish to use this feature, please connect a provider to your account using one of the buttons below.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF497077),
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
          child: Button(
            'Connect Fitbit',
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SleepTrackingLoginPage()),
              );
            },
          ),
        )
      ],
    );
  }

  Widget buildDataContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              barGroups: chartData.indexed
                  .map((d) => BarChartGroupData(x: d.$1, barRods: [d.$2]))
                  .toList(),
            ),
          ),
        ),
        Container(
          color: const Color(0xFF497077),
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your optimal bedtime',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
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
                  child: const Text(
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
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  color: const Color(0xFFC8D4D6),
                  child: const Column(
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
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  color: const Color(0xFFC8D4D6),
                  child: const Column(
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
    );
  }
}
