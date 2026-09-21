import 'package:flutter/material.dart';

class LandingHeader extends StatelessWidget {
  const LandingHeader({super.key, required this.scale});

  static const _logoPath = 'assets/Icons/app_icon.png';
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            _logoPath,
            width: 178 * scale,
            height: 178 * scale,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 25 * scale),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: 16 * scale,
            horizontal: 16 * scale,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF202C42),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF216786), width: 2),
          ),
          child: Column(
            children: [
              Text(
                'WCWI',
                style: TextStyle(
                  color: Color(0xFF28B9F1),
                  fontSize: 40 * scale,
                  fontWeight: FontWeight.w900,
                  height: .95,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                'Wireless Communication Without Internet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFABB5C7),
                  fontSize: 18 * scale,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
