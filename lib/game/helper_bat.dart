import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '/game/audio_manager.dart';
import '/game/collectibles.dart';
import 'ninja_run.dart';

// Image of the bat, a sheet of [_frames] frames of [_frameSize].
const _image = 'Bat/Flying (46x30).png';
const _frames = 7;
final _frameSize = Vector2(46, 30);

// An item which calls a [HelperBat] to carry Ninja when picked up.
class HelperBatItem extends Collectible {
  HelperBatItem({required super.position}) : super(radius: 10);

  @override
  void onLoad() {
    super.onLoad();
    add(
      CircleComponent(
        radius: size.x / 2,
        paint: Paint()..color = Colors.purpleAccent.withAlpha(110),
      ),
    );
    // The first frame of the bat.
    add(
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(_image), srcSize: _frameSize),
        size: _frameSize * (size.x * 0.8 / _frameSize.x),
        anchor: Anchor.center,
        position: size / 2,
      ),
    );
  }

  @override
  void onCollected() {
    final playerData = game.playerData;
    playerData.carryTime = playerData.carryDuration;
    // Picked up while already carried, the same bat carries Ninja longer.
    if (game.world.children.whereType<HelperBat>().isEmpty) {
      game.world.add(HelperBat());
    }
    AudioManager.instance.playSfx('jump3.wav');
  }
}

// A friendly bat which flies down, holds Ninja's head with its feet
// and carries Ninja while [PlayerData.isCarried]. Ninja moves itself,
// and the bat stays on its head. Then it lets go and flies away.
class HelperBat extends SpriteAnimationComponent
    with HasGameReference<NinjaRun> {
  static const _grabSpeed = 12.0;
  static const _leaveSpeed = 160.0;

  bool _leaving = false;

  // Drawn above Ninja, so that its feet are in front of Ninja's head.
  HelperBat()
    : super(size: _frameSize * 0.7, anchor: Anchor.bottomCenter, priority: 1);

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(_image),
      SpriteAnimationData.sequenced(
        amount: _frames,
        stepTime: 0.06,
        textureSize: _frameSize,
      ),
    );
    // The sheet faces left, and this bat flies to the right.
    flipHorizontally();
    position = Vector2(game.ninja.absoluteCenter.x, -size.y);
  }

  @override
  void update(double dt) {
    if (!_leaving && game.playerData.isCarried) {
      final ninja = game.ninja;
      final grab = Vector2(
        ninja.x + ninja.size.x / 2,
        ninja.y - ninja.size.y + 6,
      );
      position += (grab - position) * min(1, _grabSpeed * dt);
    } else {
      _leaving = true;
      position += Vector2(1, -0.6).normalized() * _leaveSpeed * dt;
      if (y < 0 || x > game.virtualSize.x + size.x) {
        removeFromParent();
      }
    }
    super.update(dt);
  }
}
