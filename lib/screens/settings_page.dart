import 'package:flutter/material.dart';
import 'package:my_medicine_box/providers/camera_preview_provider.dart';
import 'package:my_medicine_box/providers/theme_provider.dart';
import 'package:my_medicine_box/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int selectedDay = 1;
  bool cameraPreviewEnabled = true;
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentThemeMode = themeProvider.themeMode;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Settings',
            style: AppTextStyles.H3(context)
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text("Theme",
                      style: AppTextStyles.H3(context).copyWith(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      )),
                  const Spacer(),
                  Row(
                    children: [
                      _buildThemeButton(
                          context, 'sys', ThemeMode.system, currentThemeMode),
                      // const SizedBox(width: 2),
                      _buildThemeButton(
                          context, 'L', ThemeMode.light, currentThemeMode),
                      // const SizedBox(width: 2),
                      _buildThemeButton(
                          context, 'D', ThemeMode.dark, currentThemeMode),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Dashboard',
                    style: AppTextStyles.H4(context)
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).colorScheme.primary,
                      thickness: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Camera Preview',
                    style: AppTextStyles.H4(context).copyWith(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                  const Spacer(),
                  Consumer<CameraToggleProvider>(
                    builder: (context, cameraProvider, child) {
                      return Switch(
                        // title: const Text('Enable Camera Preview'),
                        value: cameraProvider.isCameraEnabled,
                        onChanged: (value) {
                          cameraProvider.toggleCamera(value);
                        },
                      );
                    },
                  )
                ],
              ),
              const SizedBox(height: 20),
              DefaultDaySelector(),
            ],
          ),
        ));
  }

  Widget _buildThemeButton(
    BuildContext context,
    String label,
    ThemeMode targetMode,
    ThemeMode currentMode,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isSelected = targetMode == currentMode;

    return OutlinedButton(
      onPressed: () {
        themeProvider.setThemeMode(targetMode);
      },
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
      ),
      child: Text(
        label,
        style: AppTextStyles.BM(context).copyWith(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class DefaultDaySelector extends StatefulWidget {
  const DefaultDaySelector({super.key});

  @override
  State<DefaultDaySelector> createState() => _DefaultDaySelectorState();
}

class _DefaultDaySelectorState extends State<DefaultDaySelector> {
  int _selectedDay = 1;

  @override
  void initState() {
    super.initState();
    _loadDefaultDay();
  }

  Future<void> _loadDefaultDay() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDay = prefs.getInt('default_day') ?? 1;
    });
  }

  Future<void> _saveDefaultDay(int day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('default_day', day);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: Row(
        children: [
          Text(
            'Default Day in Date:',
            style: AppTextStyles.H4(context).copyWith(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedDay,
                items: List.generate(
                  30,
                  (index) => DropdownMenuItem(
                    value: index + 01,
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.BM(context).copyWith(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedDay = value);
                    _saveDefaultDay(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
