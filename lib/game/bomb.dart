import 'dart:ui';

import 'package:flame/components.dart';

import '/game/enemy.dart';
import '/game/rocket.dart';
import '/game/score_popup.dart';
import 'ninja_run.dart';

// A bomb dropped from the top of the screen by a burst. It falls
// onto its target enemy, following it as it runs, and destroys it.
// Any enemy can be destroyed by a bomb, even the ones that can be kicked.
class Bomb extends PositionComponent with HasGameReference<NinjaRun> {
  // Number of enemies a burst drops bombs on.
  static const maxTargets = 2;

  static const _speed = 260.0;
  static const _radius = 5.0;

  static final _bodyPaint = Paint()..color = const Color(0xFF263238);
  static final _shinePaint = Paint()..color = const Color(0x88FFFFFF);
  static final _fusePaint = Paint()
    ..color = const Color(0xFF8D6E63)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  static final _sparkPaint = Paint()..color = const Color(0xFFFFA726);

  final Enemy target;

  Bomb(this.target)
    : super(
        position: Vector2(target.absoluteCenter.x, -_radius * 2),
        size: Vector2.all(_radius * 2),
        anchor: Anchor.center,
        priority: 5,
      );

  @override
  void update(double dt) {
    final toTarget = target.absoluteCenter - position;
    final step = _speed * dt;

    if (target.isRemoved || toTarget.length <= step) {
      _explode();
    } else {
      position += toTarget.normalized() * step;
    }
    super.update(dt);
  }

  void _explode() {
    game.world.add(Explosion(position: position.clone()));

    // The target may have been kicked or left the screen on the way.
    if (!target.isRemoved && !target.isTransformed) {
      final points = target.enemyData.rocketPoints ?? target.enemyData.points;
      game.world.add(ScorePopup.above(target, points: points));
      game.playerData.currentScore += points;
      target.removeFromParent();
    }
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(_radius, _radius);
    canvas.drawCircle(center, _radius, _bodyPaint);
    canvas.drawCircle(
      center - const Offset(_radius * 0.4, _radius * 0.4),
      _radius * 0.3,
      _shinePaint,
    );
    // A short fuse at the top, with a spark at its end.
    canvas.drawLine(
      const Offset(_radius, 0),
      const Offset(_radius + 2, -3),
      _fusePaint,
    );
    canvas.drawCircle(const Offset(_radius + 2, -3), 1.3, _sparkPaint);
  }
}
