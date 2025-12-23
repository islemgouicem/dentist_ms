import 'dart:ui';
import 'package:flutter/material.dart';

/// A standalone, responsive dialog widget for Face Recognition success.
/// Compact version designed to fit without scrolling on most screens.
class FaceRecognitionOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onContinue;
  final VoidCallback onTryAgain;

  const FaceRecognitionOverlay({
    super.key,
    required this.onClose,
    required this.onContinue,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // 1. Dimmed Background with Blur
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: size.width,
            height: size.height,
            color: Colors.black.withValues(alpha: 0.6),
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
              constraints: const BoxConstraints(
                maxWidth: 400, // Slightly narrower for better proportions
                minWidth: 300,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        32,
                        0,
                        32,
                        32,
                      ), // Reduced outer padding
                      child: Column(
                        children: [
                          const _ProfileSection(),
                          const SizedBox(height: 16), // Reduced spacing
                          const _StatusBadge(),
                          const SizedBox(height: 16), // Reduced spacing
                          const _UserInfo(),
                          const SizedBox(height: 24), // Reduced spacing
                          _ActionButtons(
                            onContinue: onContinue,
                            onTryAgain: onTryAgain,
                          ),
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
              onPressed: onClose,
              icon: const Icon(Icons.close, color: Colors.white54, size: 20),
              splashRadius: 20,
              tooltip: "Close",
            ),
          ),
        ],
      ),
    );
  }
}

/// Sub-widget for the Profile Image and Checkmark
class _ProfileSection extends StatelessWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main Avatar - Reduced size
        Container(
          width: 100, // Reduced from 140
          height: 100, // Reduced from 140
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00D9A3), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D9A3).withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
            image: const DecorationImage(
              image: AssetImage("assets/images/person.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Success Indicator - Adjusted for new size
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 32, // Reduced from 42
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF00D9A3),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1A2332), width: 3),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }
}

/// Sub-widget for the "Face Recognized" Badge
class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00D9A3).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF00D9A3).withValues(alpha: 0.3),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.face_retouching_natural,
            color: Color(0xFF00D9A3),
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            'Face Recognized',
            style: TextStyle(
              color: Color(0xFF00D9A3),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sub-widget for User Name and Role
class _UserInfo extends StatelessWidget {
  const _UserInfo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Dr. Emily Rodriguez',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22, // Slightly smaller
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF4F7EFF).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'emily.rodriguez@dentalcare.com',
            style: TextStyle(
              color: Color(0xFF7EA2FF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        )
      ],
    );
  }
}

/// Sub-widget for Buttons
class _ActionButtons extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onTryAgain;

  const _ActionButtons({required this.onContinue, required this.onTryAgain});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gradient Button
        Container(
          width: double.infinity,
          height: 44, // Reduced height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF4F7EFF), Color(0xFF9D6CFF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F7EFF).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onContinue,
              borderRadius: BorderRadius.circular(12),
              child: const Center(
                child: Text(
                  'Continue as Emily',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Outlined Button
        SizedBox(
          width: double.infinity,
          height: 44, // Reduced height
          child: TextButton(
            onPressed: onTryAgain,
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
              ),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Not you? Try again',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}
