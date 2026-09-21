import 'package:flutter/material.dart';
import 'package:wcwi_team_project/widgets/connection_card.dart';
import 'package:wcwi_team_project/widgets/landing_header.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final safeArea = MediaQuery.paddingOf(context);
    final availableHeight = screen.height - safeArea.vertical;
    final scale = (availableHeight / 1020).clamp(0.52, 1.0);
    final horizontalPadding = screen.width < 390 ? 20.0 : 24.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF10192F), Color(0xFF171344), Color(0xFF06091D)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 12 * scale,
            ),
            child: Column(
              children: [
                LandingHeader(scale: scale),
                SizedBox(height: 37 * scale),
                _SectionLabel(scale: scale),
                SizedBox(height: 52 * scale),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Select Connection Mode',
                    style: TextStyle(
                      fontSize: 30 * scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(height: 33 * scale),
                ConnectionCard(
                  icon: Icons.wifi_rounded,
                  title: 'WiFi Mode',
                  subtitle: 'Connect via Local WiFi Access Point or\nHotspot',
                  colors: const [Color(0xFF6366F1), Color(0xFF8B55ED)],
                  scale: scale,
                  onTap: () => _showSelection(context, 'WiFi Mode'),
                ),
                SizedBox(height: 26 * scale),
                ConnectionCard(
                  icon: Icons.bluetooth_rounded,
                  title: 'Bluetooth Mode',
                  subtitle:
                      'Connect directly offline using Bluetooth\npaired devices',
                  colors: const [Color(0xFF12B5CA), Color(0xFF367DEF)],
                  scale: scale,
                  onTap: () => _showSelection(context, 'Bluetooth Mode'),
                ),
                SizedBox(height: 26 * scale),
                ConnectionCard(
                  icon: Icons.history_rounded,
                  title: 'Chat History',
                  subtitle: 'View & manage offline messages, audio &\nphotos',
                  colors: const [Color(0xFFE94199), Color(0xFFFA3855)],
                  scale: scale,
                  onTap: () => _showSelection(context, 'Chat History'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSelection(BuildContext context, String mode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$mode selected'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 8 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2A354F),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF71809A), width: 1.5),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              color: const Color(0xFFFFA000),
              size: 16 * scale,
            ),
            SizedBox(width: 10 * scale),
            Text(
              'Choose connection mode',
              style: TextStyle(
                fontSize: 17 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
