import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable app footer widget
/// Displays copyright information consistently across all screens
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      alignment: Alignment.center,
      child: const Text(
        '@2026 Perhutani Padangan',
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7280), // grey-600
        ),
      ),
    );
  }
}
