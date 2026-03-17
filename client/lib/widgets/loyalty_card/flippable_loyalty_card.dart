import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:localboost_shared/models/enrollment.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:provider/provider.dart';

import 'loyalty_card_back.dart';
import 'loyalty_card_front.dart';

/// A loyalty card widget that flips between a stamp-progress front and a
/// QR-code back on tap.
///
/// The 3-D flip uses a proper perspective matrix split into two halves so that
/// each face is only rendered while it is actually visible — front from 0° to
/// 90°, back from 90° to 180°.  This avoids the "ghost card" artefact and
/// keeps the widget tree small during animation.
class FlippableLoyaltyCard extends StatefulWidget {
  final Shop shop;

  /// When true the card starts showing the back side (promotional view).
  final bool startFlipped;

  /// Height of the card. Defaults to 300.
  final double height;

  const FlippableLoyaltyCard({
    super.key,
    required this.shop,
    this.startFlipped = false,
    this.height = 300,
  });

  @override
  State<FlippableLoyaltyCard> createState() => _FlippableLoyaltyCardState();
}

class _FlippableLoyaltyCardState extends State<FlippableLoyaltyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _showFront = true;
  bool _pressing = false;

  @override
  void initState() {
    super.initState();
    _showFront = !widget.startFlipped;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    // Ease-in-out feels snappy; FastOutSlowIn adds a nice deceleration at rest.
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    if (widget.startFlipped) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;
    if (_showFront) {
      setState(() => _showFront = false);
      _controller.forward(from: 0);
    } else {
      setState(() => _showFront = true);
      _controller.reverse(from: 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Enrollment? enrollment = _resolveEnrollment(context);

    return GestureDetector(
      onTap: _flip,
      onTapDown: (_) => setState(() => _pressing = true),
      onTapUp: (_) => setState(() => _pressing = false),
      onTapCancel: () => setState(() => _pressing = false),
      child: AnimatedScale(
        scale: _pressing ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          height: widget.height,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              // _showFront was toggled *before* the animation started so its
              // value tells us the target face.  During a forward sweep (0→1)
              // the current visual angle goes from 0° to 180°.
              final value = _animation.value; // 0.0 → 1.0
              final isFrontTarget = _showFront; // where we're going

              // When going to front  (reverse): angle sweeps 0→180 logically
              // but we reverse, so we map: angle = (1-value)*π
              // When going to back (forward): angle = value * π
              final angle = isFrontTarget
                  ? (1.0 - value) * math.pi
                  : value * math.pi;

              final showingFront = angle <= math.pi / 2;

              // Each face gets its own half: front 0→90°, back 90°→180°
              // The back face matrix is offset by π to un-mirror it.
              final faceAngle =
                  showingFront ? angle : angle - math.pi;

              final child = showingFront
                  ? LoyaltyCardFront(shop: widget.shop)
                  : LoyaltyCardBack(shop: widget.shop, enrollment: enrollment);

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015) // perspective depth
                  ..rotateY(faceAngle),
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }

  Enrollment? _resolveEnrollment(BuildContext context) {
    final enrollmentId = widget.shop.enrollmentId;
    if (enrollmentId == null) return null;
    return context
        .watch<EnrollmentProvider>()
        .enrollments
        .where((e) => e.id == enrollmentId)
        .firstOrNull;
  }
}
