import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/template_gallery_bloc.dart';

const _filters = [
  'All Templates',
  'Bank / Corporate / Office',
  'Academic / Research',
  'Technical / IT / Engineering',
  'Creative / Media / Design',
  'Government / NGO / Public Sector',
];

class GalleryFilters extends StatelessWidget {
  const GalleryFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemplateGalleryBloc, TemplateGalleryState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _filters.map((filter) {
              final isSelected = state.selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _FilterButton(
                  title: filter,
                  isSelected: isSelected,
                  onTap: () {
                    context
                        .read<TemplateGalleryBloc>()
                        .add(TemplateFilterChanged(filter));
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAllTemplates = title == 'All Templates';

    if (isAllTemplates && isSelected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF024D87), Color(0xFF28A745)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF024D87).withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.grid_view, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD9E2D7) : const Color(0xFFF3F4F5),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF024D87)
                : const Color(0xFF3E4A3C),
          ),
        ),
      ),
    );
  }
}
