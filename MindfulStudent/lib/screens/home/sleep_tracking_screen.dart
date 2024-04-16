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
import 'package:provider/provider.dart';

String fmtTimeOfDay(TimeOfDay? time) => time == null
    ? "Unknown"
    : "${time.hour.toString().padLeft(2, '0')}"
        ":${time.minute.toString().padLeft(2, '0')}";

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
      height: MediaQuery.of(context).size.height * 0.35,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: BarChart(
          BarChartData(
            barGroups: barGroups,
            titlesData: titlesData,
            minY: minVal ~/ _accuracy * _accuracy,
            maxY: (maxVal ~/ _accuracy + 1) * _accuracy,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: const Color(0xFFC8D4D6),
                width: 1,
              ),
            ),
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
            width: 20,
            color: const Color(0xFF497077),
          ),
        ],
      );
    }).toList();
  }

  FlTitlesData get titlesData {
    var relevantHours = getRelevantHours(barGroups);

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
                color: Color(0xFF497077),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          getTitlesWidget: (double value, TitleMeta meta) {
            var hourDateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
            var formattedHour = DateFormat('h a').format(hourDateTime);

            if (relevantHours.contains(hourDateTime.hour)) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  formattedHour,
                  style: const TextStyle(
                    color: Color(0xFF497077),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
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

  Set<int> getRelevantHours(List<BarChartGroupData> barGroups) {
    var hours = <int>{};
    for (var group in barGroups) {
      var barRod = group.barRods[0];
      var fromHour = DateTime.fromMillisecondsSinceEpoch(barRod.fromY.toInt()).hour;
      var toHour = DateTime.fromMillisecondsSinceEpoch(barRod.toY.toInt()).hour;
      for (var hour = fromHour; hour <= toHour; hour++) {
        hours.add(hour);
      }
    }
    return hours;
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFC8D4D6),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: const Center(
            child: Text(
              'Sleep Tracking',
              style: TextStyle(
                color: Color(0xFF497077),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
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
    final optimalBedtime = sleepDataProvider.sleepData?.optimalBedtime;
    final lastNightSession = sleepDataProvider.sleepData?.sessions.lastOrNull;

    final lastNight = lastNightSession == null
        ? null
        : (
            TimeOfDay.fromDateTime(lastNightSession.startTime),
            TimeOfDay.fromDateTime(lastNightSession.endTime)
          );
    final thisWeek = sleepDataProvider.sleepData?.avgWeekSleepSession;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SleepChart(),
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 1,
            color: const Color(0xFFC8D4D6),
          ),
        ),
        const SizedBox(height: 20),
        const Padding(padding: EdgeInsets.only(top: 20)),
        Center(
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: const Color(0xFF497077),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    const Text(
                      'Your optimal bedtime',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${fmtTimeOfDay(optimalBedtime?.$1)} - ${fmtTimeOfDay(optimalBedtime?.$2)}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        // Handle daily tips and suggestions action
                      },
                      child: const Text.rich(
                        TextSpan(
                          text: 'Daily tips and suggestions →',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
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
              TimeRangeBox(
                  header: "Last night",
                  startTime: lastNight?.$1,
                  endTime: lastNight?.$2,
                  color: const Color(0xFF6292C7)),
              const SizedBox(width: 14),
              TimeRangeBox(
                  header: "This week",
                  startTime: thisWeek?.$1,
                  endTime: thisWeek?.$2,
                  color: const Color(0xFFC8CC5F))
            ],
          ),
        ),
      ],
    );
  }
}

class TimeRangeBox extends StatelessWidget {
  final String header;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final Color color;

  const TimeRangeBox({
    required this.header,
    required this.startTime,
    required this.endTime,
    required this.color,
    super.key,
  });

  Duration? get duration {
    if (startTime == null || endTime == null) return null;

    int hourDiff = endTime!.hour - startTime!.hour;
    if (hourDiff < 0) hourDiff += 24;

    int minuteDiff = endTime!.minute - startTime!.minute;
    if (minuteDiff < 0) {
      hourDiff -= 1;
      minuteDiff += 60;
    }

    return Duration(hours: hourDiff, minutes: minuteDiff);
  }

  @override
  Widget build(BuildContext context) {
    final timeDiff = duration;

    final cols = [
      Text(
        header,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white, // Changed text color to white
        ),
      ),
      const SizedBox(height: 2),
      Text(
        timeDiff == null
            ? "-"
            : "${timeDiff.inHours}h ${timeDiff.inMinutes % 60}m",
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
    if (startTime != null && endTime != null) {
      cols.add(Text(
        '${fmtTimeOfDay(startTime)} - ${fmtTimeOfDay(endTime)}',
        style: const TextStyle(
          color: Colors.white,
        ),
      ));
    }

    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        // Applying a border radius of 20
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: color,
          // Updated background color
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cols,
          ),
        ),
      ),
    );
  }

  static String fmtTimeOfDay(TimeOfDay? time) => time == null
      ? "Unknown"
      : "${time.hour.toString().padLeft(2, '0')}"
          ":${time.minute.toString().padLeft(2, '0')}";


}
