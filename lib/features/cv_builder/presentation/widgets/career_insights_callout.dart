import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CareerInsightsCallout extends StatelessWidget {
  const CareerInsightsCallout({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1024;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: isWide ? _WideLayout() : _NarrowLayout(),
    );
  }
}

class _WideLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 7,
          child: _PrimaryPanel(),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 5,
          child: _SecondaryPanel(),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PrimaryPanel(),
        const SizedBox(height: 32),
        _SecondaryPanel(),
      ],
    );
  }
}

class _PrimaryPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox();
    //   Container(
    //   decoration: BoxDecoration(
    //     color: const Color(0xFF024D87),
    //     borderRadius: BorderRadius.circular(16),
    //   ),
    //   clipBehavior: Clip.antiAlias,
    //   child: Stack(
    //     children: [
    //       // Background blobs
    //       Positioned(
    //         right: -48,
    //         bottom: -48,
    //         child: ImageFiltered(
    //           imageFilter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
    //           child: Container(
    //             width: 256,
    //             height: 256,
    //             decoration: BoxDecoration(
    //               shape: BoxShape.circle,
    //               color: const Color(0xFF28A745).withValues(alpha: 0.2),
    //             ),
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         left: -48,
    //         top: -48,
    //         child: ImageFiltered(
    //           imageFilter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
    //           child: Container(
    //             width: 192,
    //             height: 192,
    //             decoration: BoxDecoration(
    //               shape: BoxShape.circle,
    //               color: Colors.white.withValues(alpha: 0.1),
    //             ),
    //           ),
    //         ),
    //       ),
    //       // Content
    //       Padding(
    //         padding: const EdgeInsets.all(48),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Text(
    //               'Need a custom approach?',
    //               style: GoogleFonts.manrope(
    //                 fontSize: 30,
    //                 fontWeight: FontWeight.w800,
    //                 letterSpacing: -0.5,
    //                 color: Colors.white,
    //               ),
    //             ),
    //             const SizedBox(height: 24),
    //             Text(
    //               'Our premium consultants can help you tailor these templates to your specific career trajectory and industry requirements.',
    //               style: GoogleFonts.inter(
    //                 fontSize: 16,
    //                 color: const Color(0xFF83FC8E),
    //                 height: 1.5,
    //               ),
    //             ),
    //             const SizedBox(height: 24),
    //             ElevatedButton(
    //               onPressed: () {},
    //               style: ElevatedButton.styleFrom(
    //                 backgroundColor: Colors.white,
    //                 foregroundColor: const Color(0xFF024D87),
    //                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
    //                 shape: RoundedRectangleBorder(
    //                   borderRadius: BorderRadius.circular(12),
    //                 ),
    //                 elevation: 0,
    //               ),
    //               child: Row(
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   Text(
    //                     'Talk to an Expert',
    //                     style: GoogleFonts.inter(
    //                       fontSize: 16,
    //                       fontWeight: FontWeight.w700,
    //                     ),
    //                   ),
    //                   const SizedBox(width: 12),
    //                   const Icon(Icons.arrow_forward, size: 20),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}

class _SecondaryPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FeatureItem(
            icon: Icons.bolt,
            iconColor: const Color(0xFF51B1E1),
            bgColor: const Color(0xFF51B1E1).withValues(alpha: 0.1),
            title: 'Fast Builder',
            description: 'Build your CV in under 10 minutes',
          ),
          const SizedBox(height: 24),
          _FeatureItem(
            icon: Icons.verified,
            iconColor: const Color(0xFF024D87),
            bgColor: const Color(0xFF024D87).withValues(alpha: 0.1),
            title: 'ATS Score',
            description: 'Real-time keyword optimization',
          ),
          const SizedBox(height: 24),
          _FeatureItem(
            icon: Icons.cloud_download,
            iconColor: const Color(0xFF586158),
            bgColor: const Color(0xFF586158).withValues(alpha: 0.1),
            title: 'Multi-Format',
            description: 'PDF, DOCX, and Online Hosting',
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF191C1D),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF3E4A3C),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
