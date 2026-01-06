import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../routes/app_routes.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> fadeAnimation;
  late final Animation<double> scaleAnimation;
  late final Animation<double> slideAnimation;

  late final AudioPlayer _player;

  @override
  void onInit() {
    super.onInit();

    _player = AudioPlayer();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    scaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    slideAnimation = Tween<double>(
      begin: 24,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void onReady() async {
    super.onReady();

    // Start animation
    animationController.forward();

    // Play BGM
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setVolume(0.25);
    await _player.play(
      AssetSource('HorizonCodeLab/Audio/BGM.mp3'),
    );

    // Hold splash
    await Future.delayed(const Duration(milliseconds: 2200));

    // Fade out
    await animationController.reverse(from: 1.0);

    // Stop sound
    await _player.stop();

    Get.offAllNamed(AppRoutes.main);
  }

  @override
  void onClose() {
    animationController.dispose();
    _player.dispose();
    super.onClose();
  }
}
