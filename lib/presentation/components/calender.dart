import 'package:flutter/material.dart';
import 'package:weekly_calendar/weekly_calendar.dart';

class Mycalender extends StatefulWidget {
  const Mycalender({super.key});

  @override
  State<Mycalender> createState() => _MycalenderState();
}

class _MycalenderState extends State<Mycalender> {
  @override
  Widget build(BuildContext context) {
    return WeeklyCalendar(
      calendarStyle: CalendarStyle(
        locale: "en",
        padding: const EdgeInsets.all(0),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        dayOfWeekTextColor: Theme.of(context).colorScheme.inversePrimary,
        dayTextColor: Theme.of(context).colorScheme.inversePrimary,
        weekendDayTextColor: Theme.of(context).colorScheme.inversePrimary,
        weekendDayOfWeekTextColor: Theme.of(context).colorScheme.inversePrimary,
        isShowHeaderDateText: false,
        isShowFooterDateText: false,
      ),
    );
  }
}
