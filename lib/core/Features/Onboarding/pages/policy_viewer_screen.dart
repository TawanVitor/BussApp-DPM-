import 'package:flutter/material.dart';

class PolicyViewerScreen extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;

  const PolicyViewerScreen({
    super.key,
    required this.title,
    required this.content,
    required this.onThemeToggle,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: onThemeToggle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
