import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '/game/enemy.dart';

// Shows the points earned from an enemy above its head. The text
// floats up while fading out, and then removes itself.
class ScorePopup extends TextComponent {
  static const _duration = 0.8;
  static const _rise = 20.0;

  double _elapsed = 0;
  final Color _color;

  ScorePopup(int points, {required Vector2 position})
    : this.text('+$points', position: position);

  // Shows any text, such as a life earned, in the given colour.
  ScorePopup.text(
    String text, {
    required super.position,
    Color color = Colors.yellow,
  }) : _color = color,
       super(
         text: text,
         anchor: Anchor.bottomCenter,
         priority: 10,
         textRenderer: _paint(color, 1),
       );

  // Creates a popup just above the head (and name) of the given enemy.
  // Shows the enemy's points, or the given [points] instead.
  ScorePopup.above(Enemy enemy, {int? points})
    : this(
        points ?? enemy.enemyData.points,
        position: enemy.absoluteCenter - Vector2(0, enemy.size.y / 2 + 8),
      );

  static TextPaint _paint(Color color, double opacity) {
    final alpha = (255 * opacity).round();
    return TextPaint(
      style: TextStyle(
        fontSize: 10,
        fontFamily: 'Audiowide',
        color: color.withAlpha(alpha),
        shadows: [Shadow(blurRadius: 2, color: Colors.black.withAlpha(alpha))],
      ),
    );
  }

  @override
  void update(double dt) {
    _elapsed += dt;
    y -= _rise / _duration * dt;
    textRenderer = _paint(_color, 1 - (_elapsed / _duration).clamp(0, 1));

    if (_elapsed >= _duration) {
      removeFromParent();
    }
    super.update(dt);
  }
}
