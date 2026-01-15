import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: controller.animationController,
          builder: (context, _) {
            return Opacity(
              opacity: controller.fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, controller.slideAnimation.value),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product of text
                    const Text(
                      "Product Of",
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),

                    const SizedBox(height: 8),
                    // Logo
                    Transform.scale(
                      scale: controller.scaleAnimation.value,
                      child: Image.asset(
                          'assets/Reversant/Logo/Reversant.png',
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                    
                    const SizedBox(height: 8),

                    const Text(
                      "Plan - Innovate - Solves",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
