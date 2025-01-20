import 'package:flutter/material.dart';
import 'package:weekly_calendar/weekly_calendar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Mycalender extends StatelessWidget {
  const Mycalender({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h, // Adjust height as needed
      child: WeeklyCalendar(
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
          weekendDayOfWeekTextColor:
              Theme.of(context).colorScheme.inversePrimary,
          isShowHeaderDateText: false,
          isShowFooterDateText: false,
        ),
      ),
    );
  }
}
