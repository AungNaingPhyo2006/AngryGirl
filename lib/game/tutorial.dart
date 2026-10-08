import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '/game/enemy.dart';
import '/game/collectibles.dart';
import '/game/enemy_manager.dart';
import '/models/tutorial_step.dart';
import 'ninja_run.dart';

// How the player did in the current tutorial step.
enum TutorialFeedback { none, great, tryAgain }

// Teaches a new player the game one step at a time. Each step spawns
// what it needs and waits until the player has done what it asks,
// spawning it again if the player missed. Ninja doesn't lose lives
// here, so the tutorial can't be lost.
class TutorialManager extends Component with HasGameReference<NinjaRun> {
  // Pause after a step is done, so that the player sees it went well.
  static const _stepGap = 1.5;
  static const _diamondCount = 3;

  final EnemyManager _enemyManager;

  TutorialManager(this._enemyManager);

  // The current step and how the player did, shown by the hud.
  final state = ValueNotifier((TutorialStep.jump, TutorialFeedback.none));

  TutorialStep get step => state.value.$1;

  // What was spawned for the current step.
  Enemy? _enemy;
  PowerUpItem? _shield;
  final List<Diamond> _diamonds = [];
  int _diamondsAtStart = 0;

  // True if Ninja got hit by the enemy of the current step.
  bool _wasHit = false;

  // Seconds left until the next step starts.
  double _gap = 0;

  @override
  void onMount() {
    _startStep(TutorialStep.jump);
    super.onMount();
  }

  @override
  void update(double dt) {
    final playerData = game.playerData;
    final ninja = game.ninja;

    // Give back the lives lost, so that the game is never over.
    if (ninja.isHit) {
      _wasHit = true;
    }
    if (playerData.lives < playerData.maxLives) {
      playerData.lives = playerData.maxLives.toDouble();
    }

    if (_gap > 0) {
      _gap -= dt;
      if (_gap <= 0) {
        _startStep(TutorialStep.values[step.index + 1]);
      }
      super.update(dt);
      return;
    }

    switch (step) {
      case TutorialStep.jump:
        if (!ninja.isOnGround) {
          _complete();
        }
      case TutorialStep.doubleJump:
        if (ninja.jumpCount == 2 && !ninja.isOnGround) {
          _complete();
        }
      case TutorialStep.dodge:
        if (_enemy!.isRemoved) {
          _wasHit ? _retry() : _complete();
        }
      case TutorialStep.kick:
        if (_enemy!.isTransformed) {
          _complete();
        } else if (_enemy!.isRemoved) {
          _retry();
        }
      case TutorialStep.diamonds:
        if (playerData.diamonds - _diamondsAtStart >= _diamondCount) {
          _complete();
        } else if (_diamonds.every((diamond) => diamond.isRemoved)) {
          _retry();
        }
      case TutorialStep.rocket:
        // A rocket removes the enemy while it is still on the screen.
        if (_enemy!.isRemoved) {
          _enemy!.x >= 0 ? _complete() : _retry();
        }
      case TutorialStep.shield:
        if (playerData.hasShield) {
          _complete();
        } else if (_shield!.isRemoved) {
          _retry();
        }
      case TutorialStep.done:
        break;
    }
    super.update(dt);
  }

  void _startStep(TutorialStep newStep) {
    state.value = (newStep, TutorialFeedback.none);
    if (newStep == TutorialStep.done) {
      game.settings.tutorialDone = true;
    }
    _spawn();
  }

  void _complete() {
    state.value = (step, TutorialFeedback.great);
    _gap = _stepGap;
  }

  void _retry() {
    state.value = (step, TutorialFeedback.tryAgain);
    _spawn();
  }

  // Spawns what the current step needs.
  void _spawn() {
    _wasHit = false;
    final size = game.virtualSize;
    switch (step) {
      case TutorialStep.dodge:
        _enemy = _enemyManager.spawnById('angry_pig');
      case TutorialStep.kick:
        _enemy = _enemyManager.spawnById('gino');
      case TutorialStep.diamonds:
        _diamondsAtStart = game.playerData.diamonds;
        _diamonds
          ..clear()
          ..addAll([
            for (var i = 0; i < _diamondCount; i++)
              Diamond(position: Vector2(size.x + 10 + i * 20, size.y - 32)),
          ]);
        game.world.addAll(_diamonds);
      case TutorialStep.rocket:
        game.playerData.rockets = 1;
        _enemy = _enemyManager.spawnById('angry_pig');
      case TutorialStep.shield:
        _shield = PowerUpItem(
          PowerUpType.shield,
          position: Vector2(size.x + 10, size.y - 40),
        );
        game.world.add(_shield!);
      case TutorialStep.jump:
      case TutorialStep.doubleJump:
      case TutorialStep.done:
        break;
    }
  }
}
