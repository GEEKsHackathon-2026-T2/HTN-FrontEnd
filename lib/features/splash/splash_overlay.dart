import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Sits on top of the already-running app for 3s, then fades out over 200ms.
///
/// Rendering [child] from the very first frame (instead of navigating to it
/// after the splash delay) means the home screen's widget tree is already
/// built and warm by the time the overlay fades, so there's no blank/white
/// stall while a heavy screen compiles and lays out for the first time.
class SplashOverlay extends StatefulWidget {
  const SplashOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      await _controller.forward();
      if (!mounted) return;
      setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_visible)
          Positioned.fill(
            child: IgnorePointer(
              child: FadeTransition(
                opacity: _opacity,
                child: const _SplashContent(),
              ),
            ),
          ),
      ],
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Spacer(flex: 5),
              Image.asset(
                'assets/img/app_logo.png',
                width: 160,
                height: 160,
              ),
              const Text(
                '우선해줘',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(flex: 4),
              const Text(
                '"간단 신속 정확하게 해결해 드립니다"',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(flex: 7),
            ],
          ),
        ),
      ),
    );
  }
}
