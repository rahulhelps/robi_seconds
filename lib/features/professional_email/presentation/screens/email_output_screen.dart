import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import '../../../../core/services/download_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/email_model.dart';

// ignore_for_file: avoid_print

// ─────────────────────────────────────────────────────────────────────────────
// EmailOutputScreen — shows generated email preview with download capability.
// Follows EXACT same pattern as SopOutputScreen.
// ─────────────────────────────────────────────────────────────────────────────

class EmailOutputScreen extends StatefulWidget {
  final SavedEmail? savedEmail;
  final Uint8List pdfBytes;
  final EmailModel? model;
  final String? generatedBody;

  const EmailOutputScreen({
    super.key,
    this.savedEmail,
    required this.pdfBytes,
    this.model,
    this.generatedBody,
  });

  @override
  State<EmailOutputScreen> createState() => _EmailOutputScreenState();
}

class _EmailOutputScreenState extends State<EmailOutputScreen> {
  bool _isDownloading = false;

  String get _displayBody {
    if (widget.generatedBody?.isNotEmpty == true) {
      return widget.generatedBody!;
    }
    if (widget.savedEmail?.body.isNotEmpty == true) {
      return widget.savedEmail!.body;
    }
    return 'Your professional email content will appear here.';
  }

  String get _displaySubject {
    if (widget.savedEmail?.subject.isNotEmpty == true) {
      return widget.savedEmail!.subject;
    }
    return widget.model?.subject ?? 'Professional Email';
  }

  Future<void> _download() async {
    setState(() => _isDownloading = true);
    try {
      final savedPath = await DownloadService.downloadAndSaveFile(
        existingBytes: widget.pdfBytes,
        baseFileName: 'ProfessionalEmail',
        fileExtension: 'pdf',
        subDirectory: 'Professional Email',
      );

      print('[EmailOutputScreen] Saved: $savedPath');

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Saved to: $savedPath',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
              ),
              action: SnackBarAction(
                label: 'OPEN',
                textColor: Colors.white,
                onPressed: () {
                  try {
                    OpenFile.open(savedPath);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cannot open file')),
                      );
                    }
                  }
                },
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF024D87),
              duration: const Duration(seconds: 5),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
      }
    } catch (e) {
      // Graceful error handling — show friendly snackbar, never crash
      if (mounted) {
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
                      'ডাউনলোড ব্যর্থ হয়েছে। পরে আবার চেষ্টা করুন।',
                      style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _copyToClipboard() {
    final fullText =
        'Subject: $_displaySubject\n\nDear ${widget.model?.recipientName ?? 'Sir/Madam'},\n\n$_displayBody\n\nSincerely,\n${widget.model?.senderName ?? ''}';
    Clipboard.setData(ClipboardData(text: fullText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email text copied to clipboard!',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: const Color(0xFF024D87),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Per-template display styles — mirrors SopOutputScreen pattern
  _TemplateStyle get _templateStyle {
    final tplId = widget.savedEmail?.templateId ??
        widget.model?.templateId ??
        'corporate_formal';
    switch (tplId) {
      case 'corporate_formal':
        return _TemplateStyle(
          headerBg: const Color(0xFF0D1B2A),
          accentColor: const Color(0xFF0D1B2A),
          bodyStyle: GoogleFonts.lora(fontSize: 12, height: 1.8, color: const Color(0xFF1A1A1A)),
          paperBg: Colors.white,
        );
      case 'modern_minimal':
        return _TemplateStyle(
          headerBg: Colors.white,
          accentColor: const Color(0xFF2563EB),
          bodyStyle: GoogleFonts.inter(fontSize: 12, height: 1.6, color: const Color(0xFF333333)),
          paperBg: Colors.white,
          border: Border(top: BorderSide(color: const Color(0xFF2563EB), width: 3)),
        );
      case 'executive':
        return _TemplateStyle(
          headerBg: const Color(0xFF1C1C1E),
          accentColor: const Color(0xFF1C1C1E),
          bodyStyle: GoogleFonts.ptSerif(fontSize: 12, height: 1.75, color: const Color(0xFF1A1A1A)),
          paperBg: Colors.white,
        );
      case 'creative_professional':
        return _TemplateStyle(
          headerBg: const Color(0xFF7C3AED),
          accentColor: const Color(0xFF7C3AED),
          bodyStyle: GoogleFonts.inter(fontSize: 12, height: 1.65, color: const Color(0xFF333333)),
          paperBg: const Color(0xFFFAFAFF),
        );
      case 'tech_industry':
        return _TemplateStyle(
          headerBg: const Color(0xFFF9FAFB),
          accentColor: const Color(0xFF10B981),
          bodyStyle: GoogleFonts.robotoMono(fontSize: 11, height: 1.6, color: const Color(0xFF111827)),
          paperBg: const Color(0xFFF9FAFB),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        );
      case 'academic_research':
        return _TemplateStyle(
          headerBg: Colors.white,
          accentColor: const Color(0xFF1E3A8A),
          bodyStyle: GoogleFonts.lora(fontSize: 12, height: 1.8, color: const Color(0xFF1A1A1A)),
          paperBg: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        );
      case 'startup_friendly':
        return _TemplateStyle(
          headerBg: const Color(0xFF111827),
          accentColor: const Color(0xFFF59E0B),
          bodyStyle: GoogleFonts.inter(fontSize: 12, height: 1.65, color: const Color(0xFF1F2937)),
          paperBg: const Color(0xFFFFFBF0),
        );
      case 'consulting_firm':
        return _TemplateStyle(
          headerBg: const Color(0xFF374151),
          accentColor: const Color(0xFF374151),
          bodyStyle: GoogleFonts.ptSerif(fontSize: 12, height: 1.75, color: const Color(0xFF1F2937)),
          paperBg: Colors.white,
          border: Border(left: BorderSide(color: const Color(0xFF374151), width: 4)),
        );
      case 'healthcare_medical':
        return _TemplateStyle(
          headerBg: const Color(0xFF0D9488),
          accentColor: const Color(0xFF0D9488),
          bodyStyle: GoogleFonts.playfairDisplay(fontSize: 12, height: 1.8, color: const Color(0xFF111827)),
          paperBg: Colors.white,
          border: Border(top: BorderSide(color: const Color(0xFF0D9488), width: 6)),
        );
      case 'finance_banking':
        return _TemplateStyle(
          headerBg: const Color(0xFF1A0A00),
          accentColor: const Color(0xFF92400E),
          bodyStyle: GoogleFonts.ebGaramond(fontSize: 13, height: 1.8, color: const Color(0xFF1A0A00)),
          paperBg: const Color(0xFFFFFBF5),
        );
      default:
        return _TemplateStyle(
          headerBg: const Color(0xFF024D87),
          accentColor: const Color(0xFF024D87),
          bodyStyle: GoogleFonts.inter(fontSize: 12, height: 1.7, color: const Color(0xFF1A1A1A)),
          paperBg: Colors.white,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _templateStyle;
    final model = widget.model;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF191C1D),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Professional Email',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Copy Text',
              icon: const Icon(Icons.copy_rounded, color: Colors.white),
              onPressed: _copyToClipboard,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: 'Download PDF',
                icon: _isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded, color: Colors.white),
                onPressed: _isDownloading ? null : _download,
              ),
            ),
          ],
        ),
        body: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 3.0,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: style.paperBg,
                  border: style.border,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Sender Header Block ──────────────────────────────
                    Container(
                      width: double.infinity,
                      color: style.headerBg,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            model?.senderName ?? '',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: style.headerBg == Colors.white
                                  ? style.accentColor
                                  : Colors.white,
                            ),
                          ),
                          if (model?.senderDesignation != null)
                            SelectableText(
                              model!.senderDesignation!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: style.headerBg == Colors.white
                                    ? AppColors.textSecondary
                                    : Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          if (model?.senderCompany != null)
                            SelectableText(
                              model!.senderCompany!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: style.headerBg == Colors.white
                                    ? AppColors.textSecondary
                                    : Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ── Email Body ───────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date
                          Text(
                            _formatDate(),
                            style: style.bodyStyle,
                          ),
                          const SizedBox(height: 16),

                          // Recipient
                          SelectableText(
                            model?.recipientName ?? '',
                            style: style.bodyStyle.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                          SelectableText(
                            model?.recipientDesignation ?? '',
                            style: style.bodyStyle,
                          ),
                          SelectableText(
                            model?.companyName ?? '',
                            style: style.bodyStyle,
                          ),
                          const SizedBox(height: 20),

                          // Subject line
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: style.accentColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: SelectableText(
                              'Re: $_displaySubject',
                              style: style.bodyStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: style.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Salutation
                          SelectableText(
                            'Dear ${model?.recipientName ?? 'Sir/Madam'},',
                            style: style.bodyStyle,
                          ),
                          const SizedBox(height: 12),

                          // Body
                          SelectableText(
                            _displayBody,
                            style: style.bodyStyle,
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 24),

                          // Closing
                          SelectableText(
                            'Sincerely,',
                            style: style.bodyStyle,
                          ),
                          const SizedBox(height: 32),
                          SelectableText(
                            model?.senderName ?? '',
                            style: style.bodyStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: style.accentColor,
                            ),
                          ),
                          if (model?.senderDesignation != null)
                            SelectableText(
                              model!.senderDesignation!,
                              style: style.bodyStyle,
                            ),
                          if (model?.senderCompany != null)
                            SelectableText(
                              model!.senderCompany!,
                              style: style.bodyStyle,
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
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.popUntil(
                        context, ModalRoute.withName('/dashboard')),
                    icon: const Icon(Icons.dashboard_outlined, size: 18),
                    label: Text('Dashboard',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF191C1D),
                      side: const BorderSide(color: Color(0xFFD8DDD8)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDownloading ? null : _download,
                    icon: _isDownloading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: Text(
                      _isDownloading ? 'Saving…' : 'Download',
                      style:
                          GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF024D87),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFF024D87).withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TemplateStyle — value object holding per-template visual properties
// ─────────────────────────────────────────────────────────────────────────────

class _TemplateStyle {
  final Color headerBg;
  final Color accentColor;
  final TextStyle bodyStyle;
  final Color paperBg;
  final BoxBorder? border;

  const _TemplateStyle({
    required this.headerBg,
    required this.accentColor,
    required this.bodyStyle,
    required this.paperBg,
    this.border,
  });
}
