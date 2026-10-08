import 'dart:math';

import 'package:flutter/material.dart';

import '../game/ninja_run.dart';
import '/game/collectibles.dart';
import '/models/player_data.dart';
import '/widgets/hud.dart';

// This represents the hud guide overlay, shown above the [Hud] in the
// first game of a new player. It darkens the screen except for one
// part of the hud at a time, and explains that part. The game waits
// until the guide is closed.
class HudGuide extends StatefulWidget {
  // An unique identified for this overlay.
  static const id = 'HudGuide';

  // Reference to parent game.
  final NinjaRun game;

  const HudGuide(this.game, {super.key});

  @override
  State<HudGuide> createState() => _HudGuideState();
}

// A part of the hud and what it is for. A part without a key
// is explained in the middle of the screen.
typedef _Step = ({GlobalKey? key, String text});

class _HudGuideState extends State<HudGuide> {
  static const _cardWidth = 320.0;
  static const _margin = 16.0;

  // Size of the power-ups area when no power-up is active, as it is
  // empty then. It is about the size of one power-up chip.
  static const _emptyPowerUpsSize = Size(130, 36);

  int _index = 0;

  // Area of the explained part, in this widget's coordinates.
  Rect? _target;

  List<_Step> get _steps {
    final s = widget.game.settings.strings;
    return [
      (key: null, text: s.guideJump),
      (key: Hud.scoreKey, text: s.guideScore),
      (key: Hud.diamondsKey, text: s.guideDiamonds),
      (key: Hud.pauseKey, text: s.guidePause),
      (key: Hud.livesKey, text: s.guideLives),
      (key: Hud.powerUpsKey, text: s.guidePowerUps),
      (key: Hud.fireKey, text: s.guideRockets(PlayerData.scorePerRocket)),
      (key: Hud.burstKey, text: s.guideBurst(PlayerData.scorePerBurst)),
    ];
  }

  @override
  void initState() {
    super.initState();
    _measureLater();
  }

  // The hud parts are measured once they have been laid out.
  void _measureLater() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final key = _steps[_index].key;
      final target = _measure(key);
      setState(() => _target = target);

      // The hud may not be built yet, so try again on the next frame.
      if (key != null && target == null) {
        _measureLater();
      }
    });
  }

  Rect? _measure(GlobalKey? key) {
    final part = key?.currentContext?.findRenderObject() as RenderBox?;
    final self = context.findRenderObject() as RenderBox?;
    if (part == null || self == null || !part.hasSize) {
      return null;
    }
    final rect =
        self.globalToLocal(part.localToGlobal(Offset.zero)) & part.size;
    if (key == Hud.powerUpsKey && rect.width < 1) {
      return Rect.fromLTWH(
        rect.left,
        rect.bottom - _emptyPowerUpsSize.height,
        _emptyPowerUpsSize.width,
        _emptyPowerUpsSize.height,
      );
    }
    return rect;
  }

  void _next() {
    if (_index == _steps.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _target = null;
    });
    _measureLater();
  }

  void _finish() {
    final game = widget.game;
    game.settings.hudGuideSeen = true;
    game.overlays.remove(HudGuide.id);
    game.resumeEngine();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    final step = steps[_index];
    final target = _target?.inflate(6);

    return GestureDetector(
      // Tapping anywhere goes on, and the taps don't reach the game.
      behavior: HitTestBehavior.opaque,
      onTap: _next,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final cardWidth = min(_cardWidth, size.width - 2 * _margin);
          final card = SizedBox(
            width: cardWidth,
            child: _card(step, steps.length),
          );

          // Waiting for the part to be measured.
          if (step.key != null && target == null) {
            return const SizedBox.expand();
          }

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _SpotlightPainter(target)),
              ),
              if (target == null)
                Center(child: card)
              else
                Positioned(
                  left: (target.center.dx - cardWidth / 2).clamp(
                    _margin,
                    size.width - cardWidth - _margin,
                  ),
                  // Below the parts at the top, above the ones at the bottom.
                  top: target.center.dy < size.height / 2
                      ? target.bottom + 12
                      : null,
                  bottom: target.center.dy < size.height / 2
                      ? null
                      : size.height - target.top + 12,
                  child: card,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(_Step step, int count) {
    final s = widget.game.settings.strings;
    final isLast = _index == count - 1;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.black.withAlpha(200),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step.text,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            // The power-ups area may be empty, so show what can be there.
            if (step.key == Hud.powerUpsKey)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    for (final type in PowerUpType.values) ...[
                      Image.asset(
                        'assets/images/${PowerUpItem.image(type)}',
                        width: 22,
                        height: 22,
                      ),
                      const SizedBox(width: 12),
                    ],
                    const Text(
                      'x2',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Text(
                  '${_index + 1} / $count',
                  style: const TextStyle(color: Colors.white54),
                ),
                const Spacer(),
                if (!isLast)
                  TextButton(
                    onPressed: _finish,
                    child: Text(
                      s.guideSkip,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                TextButton(
                  onPressed: _next,
                  child: Text(
                    isLast ? s.guideDone : s.guideNext,
                    style: const TextStyle(color: Colors.amber),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Darkens the whole screen except for [target], which gets a border.
class _SpotlightPainter extends CustomPainter {
  final Rect? target;

  _SpotlightPainter(this.target);

  @override
  void paint(Canvas canvas, Size size) {
    final screen = Path()..addRect(Offset.zero & size);
    final scrim = Paint()..color = Colors.black.withAlpha(170);
    final target = this.target;
    if (target == null) {
      canvas.drawPath(screen, scrim);
      return;
    }

    final hole = RRect.fromRectAndRadius(target, const Radius.circular(12));
    canvas.drawPath(
      Path.combine(PathOperation.difference, screen, Path()..addRRect(hole)),
      scrim,
    );
    canvas.drawRRect(
      hole,
      Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.target != target;
}
