import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Omni DateTime Picker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.light,
        ),
      ),
      home: const OmniExample(),
    );
  }
}

class OmniExample extends StatelessWidget {
  const OmniExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  DateTime now = DateTime.now();

                  final DateTime? dateTime = await showOmniDateTimePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime(now.year - 100),
                    lastDate: now,
                    is24HourMode: true,
                    untilNow: true,
                  );

                  // Use dateTime here
                  debugPrint('dateTime: $dateTime');
                },
                child: const Text('Show DateTime Picker'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final List<DateTime>? dateTime =
                      await showOmniDateTimeRangePicker(context: context);

                  // Use dateTime here
                  debugPrint('dateTime: $dateTime');
                },
                child: const Text('Show DateTime Picker'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
