import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class LegalContentScreen extends StatefulWidget {
  final String title;
  final String content;

  const LegalContentScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<LegalContentScreen> createState() => _LegalContentScreenState();
}

class _LegalContentScreenState extends State<LegalContentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Fade-in animation for a premium feel
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Parses the text dynamically into professional widgets
  List<Widget> _buildContentSegments(String text) {
    final List<Widget> widgets = [];
    final lines = text.split('\n');
    
    // Process line by line to detect titles and paragraphs
    for (final line in lines) {
      final p = line.trim();
      if (p.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Simple heuristic for section titles:
      // Short enough, doesn't end with a period, and matches a capitalization/number format
      final isTitle = (p.length < 60 && !p.endsWith('.')) &&
          (RegExp(r'^([A-Z]|\d+\.)').hasMatch(p) || !p.contains(RegExp(r'[a-z]')));

      if (isTitle) {
        widgets.add(const SizedBox(height: 16));
        widgets.add(
          Text(
            p,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: const Color(0xFF024D87),
              letterSpacing: 0.3,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 8));
        // Divider between sections
        widgets.add(const Divider(color: Color(0xFFE8ECEF), thickness: 1));
        widgets.add(const SizedBox(height: 8));
      } else {
        widgets.add(
          Text(
            p,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              height: 1.6, // Line height for readability
              color: const Color(0xFF4A4A4A),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF024D87),
        elevation: 0,
        centerTitle: true,
        // Match icon color and status bar
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Scrollbar(
          thumbVisibility: true,
          radius: const Radius.circular(8),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(), // Smooth scroll
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), // Premium spacing
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildContentSegments(widget.content),
                const SizedBox(height: 48),
                const Center(
                  child: Icon(
                    Icons.verified_user_outlined,
                    color: Color(0xFFE0E0E0),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "End of Document",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}
