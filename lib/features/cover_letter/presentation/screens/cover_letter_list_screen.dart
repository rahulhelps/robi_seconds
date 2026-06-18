import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/cover_letter_repository.dart';
import '../bloc/cover_letter_bloc.dart';
import 'cover_letter_output_screen.dart';
import '../../../../core/widgets/custom_gradient_header.dart';

class CoverLetterListScreen extends StatelessWidget {
  const CoverLetterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CoverLetterBloc(context.read<CoverLetterRepository>())..add(const FetchCoverLetters()),
      child: const _CoverLetterListView(),
    );
  }
}

class _CoverLetterListView extends StatelessWidget {
  const _CoverLetterListView();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            CustomGradientHeader(
              title: 'My Cover Letters',
              subtitle: 'Access your drafted cover letters',
              badgeText: 'All Saved',
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: BlocConsumer<CoverLetterBloc, CoverLetterState>(
                listener: (context, state) {
                  if (state is CoverLetterError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is CoverLetterLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CoverLetterLoaded) {
                    final items = state.items;
                    
                    return RefreshIndicator(
                      onRefresh: () async =>
                          context.read<CoverLetterBloc>().add(const FetchCoverLetters()),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        itemCount: items.isEmpty ? 1 : items.length + 1,
                        itemBuilder: (context, index) {
                          if (index == items.length) {
                            return _buildCreateNewBox(context, '+ Build Another Cover Letter', () => Navigator.pop(context));
                          }
                          final item = items[index];
                          final letterNumber = items.length - index;
                          final dateStr = _formatDate(item.createdAt);
                          
                          // Template Name
                          final String templateName = 'Professional';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Left Accent Strip
                                    Container(
                                      width: 4,
                                      color: const Color(0xFF009688), // Teal
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Cover Letter #$letterNumber",
                                              style: GoogleFonts.manrope(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: const Color(0xFF1A1A1A),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            // Pill badge
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE0F2F1), // Light teal
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  templateName,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(0xFF00796B),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            // Date
                                            Row(
                                              children: [
                                                const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  dateStr,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Trailing Block
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Material(
                                            color: const Color(0xFFF0F9FF),
                                            borderRadius: BorderRadius.circular(8),
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(8),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => CoverLetterOutputScreen(saved: item),
                                                  ),
                                                );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(Icons.download_rounded, color: Color(0xFF024D87), size: 20),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Material(
                                            color: const Color(0xFFFFF0F0),
                                            borderRadius: BorderRadius.circular(8),
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(8),
                                              onTap: () {},
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(Icons.delete_outline_rounded, color: Color(0xFFBA1A1A), size: 20),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return 'No date';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (_) {
      return iso;
    }
  }

  Widget _buildCreateNewBox(BuildContext context, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF024D87).withValues(alpha: 0.2), width: 1.5, strokeAlign: BorderSide.strokeAlignInside),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF024D87)),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF024D87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
