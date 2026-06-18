import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../bloc/sop_bloc.dart';
import 'sop_output_screen.dart';
import '../../../../core/widgets/custom_gradient_header.dart';

class SopListScreen extends StatefulWidget {
  const SopListScreen({super.key});

  @override
  State<SopListScreen> createState() => _SopListScreenState();
}

class _SopListScreenState extends State<SopListScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch history fetch event
    context.read<SopBloc>().add(const SopHistoryRequested());
  }

  void _showDeleteConfirmation(BuildContext context, String sopId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Delete SOP',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this SOP? This action cannot be undone.',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA1A1A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<SopBloc>().add(SopDeleteRequested(sopId));
              },
              child: Text('Delete', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
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
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            CustomGradientHeader(
              title: 'SOP History',
              subtitle: 'Review and manage your generated SOPs',
              badgeText: 'All Saved',
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: BlocConsumer<SopBloc, SopState>(
                listener: (context, state) {
                  if (state is SopFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage),
                        backgroundColor: const Color(0xFFBA1A1A),
                      ),
                    );
                  }
                  if (state is SopDeleteSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('SOP deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is SopLoading) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF024D87)));
                  }

                  if (state is SopSuccess && state.history != null) {
                    final history = state.history!;

                    return RefreshIndicator(
                      onRefresh: () async => context.read<SopBloc>().add(const SopHistoryRequested()),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        itemCount: history.isEmpty ? 1 : history.length + 1,
                        itemBuilder: (context, index) {
                          if (index == history.length) {
                            return _buildCreateNewBox(context, '+ Build Another SOP', () => Navigator.pop(context));
                          }
                          
                          final sop = history[index];
                          final sopNumber = history.length - index;
                          DateTime? date;
                          try {
                            date = DateTime.parse(sop.createdAt);
                          } catch (_) {}

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
                                      color: const Color(0xFF024D87), // Royal Blue
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Statement of Purpose #$sopNumber",
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
                                                  color: const Color(0xFFE3F2FD), // Light blue
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  "Standard Format",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(0xFF1565C0),
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
                                                  date != null
                                                      ? DateFormat('MMM dd, yyyy • hh:mm a').format(date.toLocal())
                                                      : 'Unknown Date',
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
                                                    builder: (_) => SopOutputScreen(saved: sop),
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
                                              onTap: () => _showDeleteConfirmation(context, sop.id),
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

                  // Fallback
                  return const Center(child: Text('Something went wrong'));
                },
              ),
            ),
          ],
        ),
      ),
    );
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
