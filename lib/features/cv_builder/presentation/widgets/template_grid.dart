import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/template_gallery_bloc.dart';
import 'template_preview_dialog.dart';

class TemplateGrid extends StatelessWidget {
  const TemplateGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemplateGalleryBloc, TemplateGalleryState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filtered = state.templates.where((t) {
          if (state.selectedFilter == 'All Templates') return true;
          return t['category'] == state.selectedFilter;
        }).toList();

        if (filtered.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No templates found for this category.'),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 1;
            if (constraints.maxWidth >= 1024) {
              crossAxisCount = 3;
            } else if (constraints.maxWidth >= 600) {
              crossAxisCount = 2;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.72,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return _TemplateCard(template: filtered[index]);
              },
            );
          },
        );
      },
    );
  }
}

class _TemplateCard extends StatefulWidget {
  final dynamic template;

  const _TemplateCard({required this.template});

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _isHovered = false;

  Color _parsePrimaryColor(dynamic template) {
    try {
      final layoutSource = template['layout_source'];
      if (layoutSource is Map && layoutSource['primary_color'] != null) {
        final hex =
            layoutSource['primary_color'].toString().replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        }
      }
    } catch (_) {}
    return const Color(0xFF024D87);
  }

  void _onSelect() {
    final t = widget.template;
    final isPremium = t['is_premium'] == 1 || t['is_premium'] == true;
    context.read<TemplateGalleryBloc>().add(
          SelectTemplate(
            title: t['name'] ?? 'Unknown Template',
            isPremium: isPremium,
            templateId: t['id'],
          ),
        );
  }

  void _openPreview() {
    showTemplatePreviewModal(
      context: context,
      template: widget.template,
      onUseTemplate: _onSelect,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.template;
    final isPremium = t['is_premium'] == 1 || t['is_premium'] == true;
    final primaryColor = _parsePrimaryColor(t);
    final title = t['name'] ?? 'Professional CV';
    final category = (t['category'] ?? 'General').toString();
    final description = t['description'] ?? 'Clean, modern resume layout';

    final rawThumb = t['thumbnail_url']?.toString() ?? '';
    final rawLayout = t['layout_source']?['layout']?.toString() ?? 'single_column';
    final isPlaceholder = rawThumb.isEmpty ||
        rawThumb.contains('placehold.co') ||
        rawThumb.contains('placeholder.com');

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? primaryColor.withValues(alpha: 0.16)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: _isHovered ? 28 : 14,
              offset: Offset(0, _isHovered ? 10 : 4),
            ),
          ],
          border: Border.all(
            color: _isHovered
                ? primaryColor.withValues(alpha: 0.4)
                : const Color(0xFFE2E8F0),
            width: _isHovered ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Top Visual Thumbnail / CV Mockup ───────────────────────────
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: _openPreview,
                    child: isPlaceholder
                        ? _TemplateThumbnailIllustration(
                            primaryColor: primaryColor,
                            title: title,
                            category: category,
                            layout: rawLayout,
                            isHovered: _isHovered,
                          )
                        : Image.network(
                            rawThumb,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _TemplateThumbnailIllustration(
                              primaryColor: primaryColor,
                              title: title,
                              category: category,
                              layout: rawLayout,
                              isHovered: _isHovered,
                            ),
                          ),
                  ),

                  // Free / Pro Badge
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPremium
                            ? const Color(0xFF024D87)
                            : const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        isPremium ? 'PRO' : 'FREE',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Quick Preview Hover Action
                  if (_isHovered)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _openPreview,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.35),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.visibility_rounded,
                                    size: 16, color: primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  'Preview Template',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Card Details & Action Buttons ──────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E293B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Action buttons
                    Row(
                      children: [
                        // Preview Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openPreview,
                            icon: const Icon(Icons.visibility_outlined, size: 15),
                            label: const Text('Preview'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF334155),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Use Template Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _onSelect,
                            icon: const Icon(Icons.check_rounded, size: 15),
                            label: const Text('Select'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                              textStyle: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A neat, realistic mini CV document mockup rendered natively in Flutter
class _TemplateThumbnailIllustration extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final String category;
  final String layout;
  final bool isHovered;

  const _TemplateThumbnailIllustration({
    required this.primaryColor,
    required this.title,
    required this.category,
    required this.layout,
    required this.isHovered,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildLayoutPreview(),
      ),
    );
  }

  Widget _buildLayoutPreview() {
    if (layout == 'sidebar_left') {
      return _buildSidebarThumbnail();
    } else if (layout == 'two_column') {
      return _buildTwoColumnThumbnail();
    } else {
      return _buildSingleColumnThumbnail();
    }
  }

  // ── Thumbnail for Sidebar Left ──────────────────────────────────────────
  Widget _buildSidebarThumbnail() {
    return Row(
      children: [
        // Mini Left Sidebar
        Container(
          width: 58,
          color: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 14, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Container(width: 36, height: 3, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(height: 2),
              Container(width: 24, height: 2, color: Colors.white.withValues(alpha: 0.6)),
              const SizedBox(height: 12),
              Container(width: 40, height: 2, color: Colors.white.withValues(alpha: 0.5)),
              const SizedBox(height: 3),
              Container(width: 32, height: 2, color: Colors.white.withValues(alpha: 0.5)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text('SIDEBAR', style: TextStyle(fontSize: 5, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        // Mini Right Body
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                _miniLine(widthRatio: 0.4, color: primaryColor, height: 2.5),
                const SizedBox(height: 8),
                _miniLine(widthRatio: 0.35, color: primaryColor, height: 3),
                const SizedBox(height: 3),
                _miniLine(widthRatio: 0.9, color: const Color(0xFFE2E8F0)),
                const SizedBox(height: 2),
                _miniLine(widthRatio: 0.75, color: const Color(0xFFE2E8F0)),
                const SizedBox(height: 8),
                _miniLine(widthRatio: 0.4, color: primaryColor, height: 3),
                const SizedBox(height: 3),
                _miniCard(primaryColor: primaryColor),
                const SizedBox(height: 3),
                _miniCard(primaryColor: primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Thumbnail for Two Column ────────────────────────────────────────────
  Widget _buildTwoColumnThumbnail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mini Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border(bottom: BorderSide(color: primaryColor, width: 2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)),
                child: Text('2-COL', style: TextStyle(fontSize: 5, color: primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        // Two Side by Side mini columns
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _miniLine(widthRatio: 0.7, color: primaryColor, height: 3),
                      const SizedBox(height: 3),
                      _miniCard(primaryColor: primaryColor),
                      const SizedBox(height: 3),
                      _miniCard(primaryColor: primaryColor),
                      const SizedBox(height: 6),
                      _miniLine(widthRatio: 0.6, color: primaryColor, height: 3),
                      const SizedBox(height: 3),
                      _miniChip(color: primaryColor),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Right Column
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _miniLine(widthRatio: 0.5, color: primaryColor, height: 3),
                      const SizedBox(height: 3),
                      _miniLine(widthRatio: 0.95, color: const Color(0xFFE2E8F0)),
                      const SizedBox(height: 2),
                      _miniLine(widthRatio: 0.8, color: const Color(0xFFE2E8F0)),
                      const SizedBox(height: 6),
                      _miniLine(widthRatio: 0.55, color: primaryColor, height: 3),
                      const SizedBox(height: 3),
                      _miniLine(widthRatio: 0.9, color: const Color(0xFFE2E8F0)),
                      const SizedBox(height: 2),
                      _miniLine(widthRatio: 0.75, color: const Color(0xFFE2E8F0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Thumbnail for Classic Single Column ─────────────────────────────────
  Widget _buildSingleColumnThumbnail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Classic Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          color: primaryColor,
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 11, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      category.toUpperCase(),
                      style: GoogleFonts.inter(fontSize: 6, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Stacked Single Column Body
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _miniLine(widthRatio: 0.4, color: primaryColor, height: 3.5),
                const SizedBox(height: 3),
                _miniLine(widthRatio: 0.95, color: const Color(0xFFE2E8F0)),
                const SizedBox(height: 2),
                _miniLine(widthRatio: 0.8, color: const Color(0xFFE2E8F0)),
                const SizedBox(height: 6),
                _miniLine(widthRatio: 0.35, color: primaryColor, height: 3.5),
                const SizedBox(height: 3),
                _miniCard(primaryColor: primaryColor),
                const SizedBox(height: 3),
                _miniCard(primaryColor: primaryColor),
                const SizedBox(height: 6),
                _miniLine(widthRatio: 0.3, color: primaryColor, height: 3.5),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _miniChip(color: primaryColor),
                    const SizedBox(width: 4),
                    _miniChip(color: primaryColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniLine({
    required double widthRatio,
    required Color color,
    double height = 3,
  }) {
    return FractionallySizedBox(
      widthFactor: widthRatio,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _miniCard({required Color primaryColor}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 3,
                  color: const Color(0xFF64748B),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 40,
                  height: 2.5,
                  color: const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip({required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Container(
        width: 18,
        height: 2.5,
        color: color,
      ),
    );
  }
}
