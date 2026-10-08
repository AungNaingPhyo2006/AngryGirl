import 'package:flutter/material.dart';

// A menu text which looks vertically centred in its place in both
// languages. Myanmar fonts keep a lot of room below the letters for
// stacked consonants, so Myanmar texts look higher than the centre
// and are moved down a little.
class MenuText extends StatelessWidget {
  // Distance Myanmar texts are moved down, relative to their font size.
  static const _myanmarOffset = 5 / 22;

  final String text;
  final double fontSize;
  final bool isMyanmar;
  final Color? color;

  const MenuText(
    this.text, {
    required this.fontSize,
    required this.isMyanmar,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, isMyanmar ? fontSize * _myanmarOffset : 0),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, color: color),
      ),
    );
  }
}
