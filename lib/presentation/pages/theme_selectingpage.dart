import 'package:flutter/material.dart';
import 'package:my_medicine_box/providers/theme_provider.dart';

import 'package:provider/provider.dart';

class ThemeSwitcherScreen extends StatelessWidget {
  const ThemeSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Themes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              tileColor: Colors.white10,
              title: const Text('System Theme'),
              trailing: Radio<ThemeMode>(
                fillColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.inversePrimary),
                splashRadius: 20,
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                  }
                },
              ),
              onTap: () => themeProvider.setThemeMode(ThemeMode.system),
            ),
            const SizedBox(
              height: 10,
            ),
            ListTile(
              contentPadding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              tileColor: Colors.white10,
              title: const Text('Light Theme'),
              trailing: Radio<ThemeMode>(
                fillColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.inversePrimary),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                  }
                },
              ),
              onTap: () => themeProvider.setThemeMode(ThemeMode.light),
            ),
            const SizedBox(
              height: 10,
            ),
            ListTile(
              contentPadding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              tileColor: Colors.white10,
              title: const Text('Dark Theme'),
              trailing: Radio<ThemeMode>(
                activeColor: Theme.of(context).colorScheme.inversePrimary,
                fillColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.inversePrimary),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                  }
                },
              ),
              onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }
}
