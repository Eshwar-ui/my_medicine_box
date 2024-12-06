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
        dayOfWeekTextColor: Colors.black,
        dayTextColor: Colors.black87,
        weekendDayTextColor: Colors.black87,
        weekendDayOfWeekTextColor: Colors.black,
        isShowHeaderDateText: false,
        isShowFooterDateText: false,
      ),
    );
  }
}
