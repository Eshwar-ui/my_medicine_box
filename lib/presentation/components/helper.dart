import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

Future<String> formatWithDefaultDay(String expiryDate) async {
  final prefs = await SharedPreferences.getInstance();
  final defaultDay =
      prefs.getInt('default_day') ?? 1; // Default to 1 if not set

  final parts = expiryDate.split('-'); // [MM, YYYY]
  if (parts.length != 2) return expiryDate; // fallback if malformed

  final formattedDay = defaultDay.toString().padLeft(2, '0');
  final formattedMonth = parts[0].padLeft(2, '0');
  final formattedYear = parts[1];

  // Return the formatted string in dd-MM-yyyy format
  return "$formattedDay-$formattedMonth-$formattedYear";
}

class DateUtilsHelper {
  // Parse expiry date with default day
  static Future<DateTime> parseExpiryDateWithDefaultDay(
      String expiryDate) async {
    final prefs = await SharedPreferences.getInstance();
    final defaultDay =
        prefs.getInt('default_day') ?? 1; // Default to 1 if not set

    final parts = expiryDate.split('-'); // MM-yyyy
    if (parts.length != 2)
      return DateTime.now(); // Return current date if format is incorrect

    final month =
        int.tryParse(parts[0]) ?? 1; // Default to January if parsing fails
    final year = int.tryParse(parts[1]) ??
        DateTime.now().year; // Default to current year if parsing fails

    // Return a DateTime object with the specified year, month, and default day
    return DateTime(year, month, defaultDay);
  }

  // Optional: A utility function to help in the future (could be used to format a DateTime back to string)
  static String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }
}
