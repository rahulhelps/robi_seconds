import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/template_gallery_bloc.dart';

class _TemplateData {
  final String title;
  final String description;
  final String imageUrl;
  final String filterKey;
  final bool isPremium;

  const _TemplateData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.filterKey,
    required this.isPremium,
  });
}

const _templates = [
  _TemplateData(
    title: 'Bank / Corporate / Office job',
    description: 'Finance, corporate roles, and professional office careers.',
    imageUrl:
        'https://i.pinimg.com/1200x/59/f3/71/59f37113b5afae62dbee83a64fe1e113.jpg',
    filterKey: 'Bank / Corporate / Office',
    isPremium: true,
  ),
  _TemplateData(
    title: 'Academic / Research',
    description: 'Universities, research posts, and scholarly CV formats.',
    imageUrl:
        'https://i.pinimg.com/1200x/00/ff/e0/00ffe0ad64c57559ecea3347e0730e68.jpg',
    filterKey: 'Academic / Research',
    isPremium: false,
  ),
  _TemplateData(
    title: 'Technical / IT / Engineering',
    description: 'Software, systems, and engineering career tracks.',
    imageUrl:
        'https://i.pinimg.com/1200x/9a/ab/79/9aab79653565659c801d758569ae7c25.jpg',
    filterKey: 'Technical / IT / Engineering',
    isPremium: true,
  ),
  _TemplateData(
    title: 'Creative / Media / Design — Graphic, Content, UI/UX',
    description: 'Portfolio-friendly layouts for creative and digital roles.',
    imageUrl:
        'https://i.pinimg.com/736x/fa/38/0d/fa380d15ed1f202d027e73475ff3dd56.jpg',
    filterKey: 'Creative / Media / Design',
    isPremium: true,
  ),
  _TemplateData(
    title:
        'Government / NGO / Public Sector — Social, Volunteer, Govt jobs',
    description: 'Public service, non-profit, and civic career paths.',
    imageUrl:
        'https://i.pinimg.com/736x/f7/e5/86/f7e5867a7d765d0222f6c7feb0d6832b.jpg',
    filterKey: 'Government / NGO / Public Sector',
    isPremium: false,
  ),
];

class TemplateGrid extends StatelessWidget {
  const TemplateGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemplateGalleryBloc, TemplateGalleryState>(
      builder: (context, state) {
        final filtered = _templates.where((t) {
          if (state.selectedFilter == 'All Templates') return true;
          return t.filterKey == state.selectedFilter;
        }).toList();

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
                childAspectRatio: 0.75,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                // templateId is 1-based (1–5)
                final templateId = _templates.indexOf(filtered[index]) + 1;
                return _TemplateCard(template: filtered[index], templateId: templateId);
              },
            );
          },
        );
      },
    );
  }
}

class _TemplateCard extends StatefulWidget {
  final _TemplateData template;
  final int templateId;

  const _TemplateCard({required this.template, required this.templateId});

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.template;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? (t.isPremium
                      ? const Color(0xFF024D87).withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08))
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: _isHovered ? 40 : 20,
              offset: Offset(0, _isHovered ? 10 : 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    t.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: const Color(0xFFF3F4F5),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xFF024D87).withValues(
                              alpha: 0.6,
                            ),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF3F4F5),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: t.isPremium
                            ? const Color(0xFF51B1E1)
                            : const Color(0xFF586158),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: t.isPremium
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        t.isPremium ? 'PREMIUM TEMPLATES' : 'FREE TEMPLATES',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF191C1D),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t.description,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF3E4A3C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (t.isPremium)
                          const Icon(
                            Icons.star,
                            color: Color(0xFF024D87),
                            size: 24,
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              context.read<TemplateGalleryBloc>().add(
                                    SelectTemplate(
                                      title: t.title,
                                      isPremium: t.isPremium,
                                      templateId: widget.templateId,
                                    ),
                                  );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: t.isPremium
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF024D87),
                                          Color(0xFF28A745),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFFBFC9BF),
                                          Color(0xFFD9DADB),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                border: !t.isPremium
                                    ? Border.all(
                                        color: const Color(0xFFBDCAB9)
                                            .withValues(alpha: 0.3),
                                        width: 0.5,
                                      )
                                    : null,
                              ),
                              child: Text(
                                'Live Preview',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: t.isPremium
                                      ? Colors.white
                                      : const Color(0xFF151E17),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.favorite_border,
                            color: Color(0xFF3E4A3C),
                            size: 24,
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
