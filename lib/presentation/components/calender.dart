import 'package:flutter/material.dart';
import 'package:weekly_calendar/weekly_calendar.dart';

class mycalender extends StatefulWidget {
  const mycalender({super.key});

  @override
  State<mycalender> createState() => _mycalenderState();
}

class _mycalenderState extends State<mycalender> {
  @override
  Widget build(BuildContext context) {
    return WeeklyCalendar(
      calendarStyle: CalendarStyle(
        locale: "en",
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
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
