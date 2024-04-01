import 'dart:developer';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mindfulstudent/backend/sleep.dart';
import 'package:mindfulstudent/main.dart';
import 'package:mindfulstudent/provider/sleep_data_provider.dart';
import 'package:mindfulstudent/screens/home/sleep_tracking_login_screen.dart';
import 'package:mindfulstudent/widgets/bottom_nav_bar.dart';
import 'package:mindfulstudent/widgets/button.dart';
import 'package:mindfulstudent/widgets/header_bar.dart';
import 'package:provider/provider.dart';

class SleepChart extends StatelessWidget {
  static const double _accuracy = 30 * 60 * 1000; // 30 min

  const SleepChart({super.key});

  @override
  Widget build(BuildContext context) {
    final bars = barGroups.map((group) => group.barRods.singleOrNull);
    final minVal = bars.map((bar) => bar?.fromY ?? 0).fold(0.0, math.min);
    final maxVal = bars.map((bar) => bar?.toY ?? 0).fold(0.0, math.max);

    return SizedBox(
      width: bars.length * 100 + 50,
      height: MediaQuery.of(context).size.height * 0.4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: BarChart(
          BarChartData(
            barGroups: barGroups,
            titlesData: titlesData,
            minY: minVal ~/ _accuracy * _accuracy,
            maxY: (maxVal ~/ _accuracy + 1) * _accuracy,
            gridData: const FlGridData(show: false),
            barTouchData: BarTouchData(enabled: false),
          ),
        ),
      ),
    );
  }

  List<SleepSession> get sleepSessions =>
      sleepDataProvider.sleepData?.sessions ?? [];

  List<BarChartGroupData> get barGroups {
    return sleepSessions.map((session) {
      final (startOffset, endOffset) = getStartEndOffset(session);

      return BarChartGroupData(
        x: session.startTime.millisecondsSinceEpoch,
        barRods: [
          BarChartRodData(
            fromY: startOffset.inMilliseconds.toDouble(),
            toY: endOffset.inMilliseconds.toDouble(),
            width: 30,
          ),
        ],
      );
    }).toList();
  }

  FlTitlesData get titlesData {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (double value, TitleMeta meta) => SideTitleWidget(
            axisSide: meta.axisSide,
            child: Text(
              formatEpoch(value),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          interval: _accuracy * 2,
          getTitlesWidget: (double value, TitleMeta meta) => SideTitleWidget(
            axisSide: meta.axisSide,
            child: Text(
              formatRelTime(value),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  (Duration, Duration) getStartEndOffset(SleepSession session) {
    final dayStart = session.startTime.copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    log(session.startTime.toString());
    log(dayStart.toString());

    final startOffset = session.startTime.difference(dayStart);
    final endOffset = session.endTime.difference(dayStart);

    return (startOffset, endOffset);
  }

  String formatEpoch(double epoch) {
    final fmt = DateFormat("MMM dd");
    final date =
        DateTime.fromMillisecondsSinceEpoch(epoch.toInt(), isUtc: true);
    return fmt.format(date);
  }

  String formatRelTime(double value) {
    final fmt = DateFormat("HH:mm");
    final time =
        DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
    return fmt.format(time);
  }
}

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

  static final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: HeaderBar('Sleep Tracking'),
      ),
      body: RefreshIndicator(
        key: refreshIndicatorKey,
        onRefresh: sleepDataProvider.updateData,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverFillRemaining(
              child: Consumer<SleepDataProvider>(
                builder: (context, sleepDataProvider, child) {
                  if (sleepDataProvider.sleepData == null) {
                    return buildLoginContent(context);
                  } else {
                    return buildDataContent(context);
                  }
                },
              ),
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
        const SleepChart(),
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
