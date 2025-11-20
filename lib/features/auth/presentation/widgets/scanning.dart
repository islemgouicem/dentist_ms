import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A standalone, responsive widget for the "Scanning" state.
/// Includes a radar-style scan animation and pulsating rings.
class FaceScanningOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const FaceScanningOverlay({super.key, required this.onClose});

  @override
  State<FaceScanningOverlay> createState() => _FaceScanningOverlayState();
}

class _FaceScanningOverlayState extends State<FaceScanningOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Controller for the vertical scanning line
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Controller for the breathing/pulsing rings
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // 1. Dimmed Background with Blur
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
            width: size.width,
            height: size.height,
            color: Colors.black.withOpacity(0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // 2. The Dialog Content
        Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400, minWidth: 300),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 10, 32, 40),
                      child: Column(
                        children: [
                          _buildAnimatedScanner(),
                          const SizedBox(height: 40),
                          const Text(
                            'Scanning Face...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Please look directly at the camera',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const _TypingIndicator(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              onPressed: widget.onClose,
              icon: const Icon(Icons.close, color: Colors.white54, size: 20),
              splashRadius: 20,
              tooltip: "Cancel Scan",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedScanner() {
    return SizedBox(
      height: 220,
      width: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Ring (Pulsing opacity & scale)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.05),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(
                        0xFF4F7EFF,
                      ).withOpacity(0.3 * (1 - _pulseController.value)),
                      width: 1,
                    ),
                  ),
                ),
              );
            },
          ),

          // Middle Ring (Rotating)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _pulseController.value * 2 * math.pi,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF9D6CFF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
              );
            },
          ),

          // Inner Circle with Scanner
          Container(
            width: 140,
            height: 140,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4F7EFF).withOpacity(0.2),
                  const Color(0xFF9D6CFF).withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Icon Background
                Center(
                  child: Icon(
                    Icons.face,
                    size: 60,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),

                // Moving Scan Line
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    return Positioned(
                      top:
                          _scanController.value * 140 -
                          10, // Move from -10 to 130
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40, // Height of the gradient trail
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF00D9A3).withOpacity(0.0),
                              const Color(
                                0xFF00D9A3,
                              ).withOpacity(0.5), // Scan line color
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // The sharp line at the bottom of the gradient
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    return Positioned(
                      top: _scanController.value * 140 + 30,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        // FIX: Moved color inside BoxDecoration to avoid conflict
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D9A3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00D9A3).withOpacity(0.8),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Corner brackets (decorative)
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              children: [
                _buildCorner(Alignment.topLeft),
                _buildCorner(Alignment.topRight),
                _buildCorner(Alignment.bottomLeft),
                _buildCorner(Alignment.bottomRight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    return Align(
      alignment: alignment,
      child: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: Colors.white54, width: 2)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Colors.white54, width: 2)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: Colors.white54, width: 2)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: Colors.white54, width: 2)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/// Animated 3-dot loading indicator
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Calculate opacity based on sine wave offset by index
            final double t = (_controller.value + index * 0.2) % 1.0;
            final double opacity =
                0.3 + (0.7 * math.sin(t * 2 * math.pi).abs());

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF4F7EFF).withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
