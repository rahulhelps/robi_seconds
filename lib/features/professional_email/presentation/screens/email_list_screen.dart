import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/custom_gradient_header.dart';
import '../../data/email_pdf_generator.dart';
import '../../domain/email_model.dart';
import '../bloc/email_bloc.dart';
import 'email_output_screen.dart';

// ignore_for_file: avoid_print

// ─────────────────────────────────────────────────────────────────────────────
// EmailListScreen — Full history screen following exact SopListScreen pattern.
// Fetches data via EmailBloc, handles Loading / Loaded / Error / Empty states.
// ─────────────────────────────────────────────────────────────────────────────

class EmailListScreen extends StatefulWidget {
  const EmailListScreen({super.key});

  @override
  State<EmailListScreen> createState() => _EmailListScreenState();
}

class _EmailListScreenState extends State<EmailListScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch history fetch on entry — matches SopListScreen.initState
    context.read<EmailBloc>().add(const EmailHistoryRequested());
  }

  // ── Delete confirmation dialog ─────────────────────────────────────────────

  void _showDeleteConfirmation(BuildContext context, String emailId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Delete Email',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to permanently delete this email? This action cannot be undone.',
            style: GoogleFonts.inter(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA1A1A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context
                    .read<EmailBloc>()
                    .add(EmailDeleteRequested(emailId));
              },
              child: Text('Delete',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ── Navigate to output screen by regenerating PDF from saved body ──────────

  Future<void> _openEmailDetail(
      BuildContext context, SavedEmail savedEmail) async {
    // Show a brief loading overlay so the user knows we're regenerating
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF024D87)),
      ),
    );

    try {
      // Reconstruct a minimal EmailModel from SavedEmail for PDF metadata
      final model = EmailModel(
        emailType: 'Professional Email',
        senderName: '',
        recipientName: '',
        recipientDesignation: '',
        companyName: '',
        subject: savedEmail.subject,
        templateId: savedEmail.templateId,
      );

      // Regenerate PDF from the stored body text
      final pdfGenerator = EmailPdfGenerator();
      final Uint8List pdfBytes = await pdfGenerator.generatePdf(
        model,
        savedEmail.body.isNotEmpty
            ? savedEmail.body
            : 'Your professional email content.',
      );

      if (context.mounted) {
        // Dismiss loading dialog
        Navigator.of(context).pop();

        final bloc = context.read<EmailBloc>();
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: bloc,
              child: EmailOutputScreen(
                savedEmail: savedEmail,
                pdfBytes: pdfBytes,
                generatedBody: savedEmail.body,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('[EmailListScreen] PDF regeneration error: $e');
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to open email. Please try again later.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFBA1A1A),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // ── Email type icon mapping ────────────────────────────────────────────────

  IconData _iconForEmailType(String? subject) {
    final s = (subject ?? '').toLowerCase();
    if (s.contains('job') || s.contains('application')) {
      return Icons.work_outline_rounded;
    } else if (s.contains('internship')) {
      return Icons.school_outlined;
    } else if (s.contains('proposal') || s.contains('business')) {
      return Icons.handshake_outlined;
    } else if (s.contains('follow')) {
      return Icons.replay_rounded;
    } else if (s.contains('thank')) {
      return Icons.favorite_border_rounded;
    } else if (s.contains('networking') || s.contains('network')) {
      return Icons.people_outline_rounded;
    } else if (s.contains('resignation')) {
      return Icons.exit_to_app_rounded;
    } else if (s.contains('recommendation')) {
      return Icons.star_border_rounded;
    } else if (s.contains('cold') || s.contains('outreach')) {
      return Icons.send_outlined;
    } else if (s.contains('client')) {
      return Icons.business_center_outlined;
    }
    return Icons.mark_email_read_outlined;
  }

  // ── Template pill label ────────────────────────────────────────────────────

  String _labelForTemplate(String? templateId) {
    switch (templateId) {
      case 'corporate_formal':
        return 'Corporate Formal';
      case 'modern_minimal':
        return 'Modern Minimal';
      case 'executive':
        return 'Executive';
      case 'creative_professional':
        return 'Creative Professional';
      case 'tech_industry':
        return 'Tech Industry';
      case 'academic_research':
        return 'Academic Research';
      case 'startup_friendly':
        return 'Startup Friendly';
      case 'consulting_firm':
        return 'Consulting Firm';
      case 'healthcare_medical':
        return 'Healthcare';
      case 'finance_banking':
        return 'Finance & Banking';
      default:
        return 'Standard Format';
    }
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
            // ── Gradient Header — matches SopListScreen exactly ────────────
            CustomGradientHeader(
              title: 'Email History',
              subtitle: 'Manage and access your generated professional emails',
              badgeText: 'All Saved',
              onBackPressed: () => Navigator.pop(context),
            ),

            // ── BLoC-driven body ───────────────────────────────────────────
            Expanded(
              child: BlocConsumer<EmailBloc, EmailState>(
                listener: (context, state) {
                  if (state is EmailFailure) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Failed to load email history. Please try again later.',
                                  style:
                                      GoogleFonts.inter(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.redAccent,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                          margin:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                  }

                  if (state is EmailDeleteSuccess) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                'Email deleted successfully.',
                                style:
                                    GoogleFonts.inter(color: Colors.white),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          margin:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                  }
                },
                builder: (context, state) {
                  // ── Loading state: clean Shimmer Cards ──────────
                  if (state is EmailLoading) {
                    return _buildShimmerList();
                  }

                  // ── Error state with retry ───────────────────────────────
                  if (state is EmailFailure) {
                    return _buildErrorState(context);
                  }

                  // ── Loaded state ─────────────────────────────────────────
                  if (state is EmailSuccess && state.history != null) {
                    final history = state.history!;

                    if (history.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return RefreshIndicator(
                      color: const Color(0xFF024D87),
                      onRefresh: () async =>
                          context
                              .read<EmailBloc>()
                              .add(const EmailHistoryRequested()),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        itemCount: history.length + 1,
                        itemBuilder: (context, index) {
                          // CTA at end of list
                          if (index == history.length) {
                            return _buildCreateNewBox(context);
                          }

                          final email = history[index];
                          final emailNumber = history.length - index;
                          DateTime? date;
                          try {
                            date = DateTime.parse(email.createdAt);
                          } catch (_) {}

                          return _buildEmailCard(
                            context: context,
                            email: email,
                            emailNumber: emailNumber,
                            date: date,
                          );
                        },
                      ),
                    );
                  }

                  // ── Fallback / initial state ─────────────────────────────
                  return _buildShimmerList();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Email History Card ─────────────────────────────────────────────────────

  Widget _buildEmailCard({
    required BuildContext context,
    required SavedEmail email,
    required int emailNumber,
    required DateTime? date,
  }) {
    final templateLabel = _labelForTemplate(email.templateId);
    final iconData = _iconForEmailType(email.subject);

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
              // ── Left Accent Strip (email blue) ──────────────────────────
              Container(
                width: 4,
                color: const Color(0xFF024D87),
              ),

              // ── Leading icon block ──────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    iconData,
                    size: 22,
                    color: const Color(0xFF024D87),
                  ),
                ),
              ),

              // ── Main text content ───────────────────────────────────────
              Expanded(
                child: InkWell(
                  onTap: () => _openEmailDetail(context, email),
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(0, 16, 8, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title: "Email #N" in bold
                        Text(
                          'Professional Email #$emailNumber',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: const Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Subject as subtitle
                        if (email.subject.isNotEmpty)
                          Text(
                            email.subject,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                              height: 1.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),

                        // Template pill badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            templateLabel,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1565C0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Timestamp row
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              date != null
                                  ? DateFormat('MMM dd, yyyy • hh:mm a')
                                      .format(date.toLocal())
                                  : 'Unknown Date',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Trailing action buttons ─────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // View / Download button
                    Material(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _openEmailDetail(context, email),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.download_rounded,
                            color: Color(0xFF024D87),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Delete button
                    Material(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () =>
                            _showDeleteConfirmation(context, email.id),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFBA1A1A),
                            size: 20,
                          ),
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
  }

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5FF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF024D87).withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                size: 48,
                color: Color(0xFF024D87),
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'No emails created yet',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF191C1D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              'Your generated professional emails will appear here.\nCreate your first email now!',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // CTA button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF024D87), Color(0xFF0369B7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF024D87).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '+ Create New Email',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
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

  // ── "Build Another Email" CTA at bottom of list ────────────────────────────

  Widget _buildCreateNewBox(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF024D87).withValues(alpha: 0.2),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline_rounded,
                color: Color(0xFF024D87)),
            const SizedBox(width: 8),
            Text(
              '+ Create New Email',
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

  // ── Error State ────────────────────────────────────────────────────────────

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBA1A1A).withValues(alpha: 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: Color(0xFFBA1A1A),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Failed to load history.\nPlease check your internet connection and try again.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF6B7280),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<EmailBloc>().add(const EmailHistoryRequested()),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Retry',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF024D87),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shimmer Skeleton Loader ────────────────────────────────────────────────

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: 5,
      itemBuilder: (context, index) => _ShimmerEmailCard(index: index),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ShimmerEmailCard — animated skeleton card matching the real card layout
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerEmailCard extends StatefulWidget {
  final int index;

  const _ShimmerEmailCard({required this.index});

  @override
  State<_ShimmerEmailCard> createState() => _ShimmerEmailCardState();
}

class _ShimmerEmailCardState extends State<_ShimmerEmailCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Stagger each card's animation
    Future.delayed(Duration(milliseconds: widget.index * 120), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(opacity: _animation.value, child: child);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        // height: 110, // Removed rigid height to prevent overflow
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
                // Left accent strip
                Container(width: 4, color: const Color(0xFFBFDEF0)),
                // Icon placeholder
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              // Text placeholders
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SkeletonLine(width: 180, height: 14),
                      const SizedBox(height: 12),
                      _SkeletonLine(width: 130, height: 11),
                      const SizedBox(height: 10),
                      _SkeletonLine(width: 80, height: 10),
                    ],
                  ),
                ),
              ),
              // Action button placeholders
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SkeletonBox(size: 36),
                    const SizedBox(height: 6),
                    _SkeletonBox(size: 36),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF2),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double size;

  const _SkeletonBox({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
